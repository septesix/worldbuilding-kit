import re
"""Lines the harness writes, told apart from lines the run wrote.

An evidence file is one self-describing record: the prompt, the transcript, the world dump, and the
verdicts. That is good for whoever reads a run afterwards and dangerous for anything parsing the same
bytes, because the harness's own sentences contain the strings the graders search for. `INFRA-FAIL`
looked like an aborted run; `provoked: review` appears inside the failure message for a missing
`provoked: review`, so a verdict could erase the finding it was reporting. Found by re-grading the
2026-10-13 certification batch, where a genuine bit-4 breach read as NOT-GRADED forever.

Anything that scans an artifact calls strip() first. New artifacts also carry their verdicts in one
reserved section at the end (VERDICT_SECTION), written only after grading finishes; the line filter is
what makes the older interleaved files readable, and both are kept on purpose.

Exit codes, shared by every grader in this directory:
    1..31   findings, a bitmask
    64      NOT-GRADED - the artifact could not be examined. Never 0, never a finding.
    128     instrument crash - distinct from every verdict, because a traceback that exits 1 is the
            same byte as "the contract was breached"
"""

NOT_GRADED = 64
CRASH = 128
VERDICT_SECTION = '## harness verdicts'
# the middot that separates fields on a machine line; prose that quotes a marker rarely has one
SEPARATOR = chr(0xb7)

# the exact shapes this repo's own tools emit. Deliberately anchored and worded, not a generic
# "looks like a report line": a model writing `ok then what?` must not lose a transcript line.
_HARNESS_LINE = (
    r'^\s{0,2}(?:NOT-GRADED|INSTRUMENT-ERROR|REVIEW-FAIL|REVIEW-OWED|SEED-FAIL|SEED-OK|'
    r'CANON-LOSS|CANON-CHECK|INFRA-FAIL|CONTAMINATED|BOOKKEEPING HOLE|'
    r'review delivered, memo complete|no review owed|seeded inside the band)\b'
    r'|^clean -> |^\s{0,2}skip\s+\S+\.md\b'
)


def strip(text):
    """Return artifact text with harness-authored verdict lines removed."""
    if VERDICT_SECTION in text:
        text = text.split(VERDICT_SECTION, 1)[0]
    import re
    pat = re.compile(_HARNESS_LINE, re.M)
    return '\n'.join(l for l in text.split('\n') if not pat.match(l))


# --- position, not shape: who wrote this line, and where in the turn does it sit ---------
#
# These three helpers exist because an independent audit of the graders found four defects that were
# all the same mistake: a rule keyed on what a line LOOKS like instead of where it came from. A close
# recap and a reaction-mode sketch are both "bullets starting with a slug"; a harness echo and an
# assistant line that begins "writer:" are both lines starting "writer:"; the guide's example of a
# machine line and a real machine line are both `- turn: ... · provoked: ... ·`.

_TURN_HEAD = re.compile(r'^##\s+turn\s+\d+', re.I)
_WRITER = re.compile(r'^writer\s*:', re.I)
# In real runs the close recap is announced by a plain sentence - "Session 5 closed at turn 12 of 12."
# - and not always by a bold cue, so both spellings open the region. "**The six lines.**" (reaction
# mode) deliberately does NOT, which is the whole point of the distinction.
_CLOSE_CUE = re.compile(r'^(?:\*\*)?\s*(?:what we decided|decided\b|session \d+ closed'
                        r'|.*\bclosed at turn\b)', re.I)


def is_writer_echo(lines, i):
    """True only for the harness echo: the first non-blank line right after a `## turn N` header.

    Both graders used to skip ANY line starting `writer:`, which is a free-words channel - a line of
    assistant prose can opt out of the cap by beginning with that token. In the corpus 140 of 140
    real `writer:` lines sit in the echo position, so narrowing it costs no measurement.
    """
    if not _WRITER.match(lines[i].strip()):
        return False
    for j in range(i - 1, -1, -1):
        s = lines[j].strip()
        if not s:
            continue
        return bool(_TURN_HEAD.match(s))
    return False


def in_close_region(lines, i):
    """True when this same turn block already announced the session close."""
    return any(_CLOSE_CUE.match(l.strip()) for l in lines[:i])


# someone asking to end the session is positional evidence that this turn is the close, but only on
# the LAST turn: mid-session it would let the writer's phrasing launder the model's words
_WRAP_CUE = re.compile(r"(?i)\b(that'?s all|that is all|wrap (it|things) up|done for (today|the day)|"
                       r"let'?s stop here|call it a (day|night)|close the session)\b")


# mirrors turns_per_session in the shipped template; invariants' close-contract check already uses the
# same threshold, and a second definition of "this run reached a session" is how two gates disagree
SESSION_TURNS = 12


# a sketch block: four or more consecutive bullets that each open with a bare `slug`. This is what
# reaction mode writes when the interview stalls, and it is an appendix like the recap - but it is not
# a close, so nothing may exempt it by shape alone. Six lines is the instruction; more than six stops
# being a sketch and starts being a parallel document.
SKETCH_MIN = 4
SKETCH_MAX = 6
_SKETCH_BULLET = re.compile(r'^\s*[-*] +(`[\w-]+`)')
_OPTIONISH = re.compile(r'^\s*[-*]?\s*\d+[.)]\s')


def sketch_lines(lines, is_last=False, n_turns=0):
    """Indices of the bullets that form a sketch block in this turn block."""
    out, run = set(), []
    for i, l in enumerate(lines):
        keep = (_SKETCH_BULLET.match(l) and not _OPTIONISH.match(l)
                and not is_writer_echo(lines, i)
                and not close_context(lines, i, is_last, n_turns))
        if keep:
            run.append(i)
        else:
            if len(run) >= SKETCH_MIN:
                out.update(run)
            run = []
    if len(run) >= SKETCH_MIN:
        out.update(run)
    return out


def close_context(lines, i, is_last=False, n_turns=0):
    """Is line i inside a session close? Three ways: the turn announced it, the writer asked for the
    wrap-up on the final turn, or the run reached a session's worth of turns and this is the last one.
    Shape alone is not one of them - reaction mode writes the same bullets mid-session.
    """
    if in_close_region(lines, i):
        return True
    if not is_last:
        return False
    joined = chr(10).join(lines)
    return bool(_CLOSE_CUE.search(joined) or _WRAP_CUE.search(joined) or n_turns >= SESSION_TURNS)


def is_machine_line(line):
    """A `log.md` machine line, as opposed to a sentence ABOUT one.

    A bullet at column 0 carrying a `·` separator and digits in the `turn:` slot. The documented
    example `- turn: <n> · provoked: <one or more of the five engagement types, plus review on a memo
    turn> · targeted: <pillar>` fails the digit test by construction - that is the point, because a
    grader was counting the guide text as a delivered review. Prose that quotes a marker inside bold
    beats or inline code is rejected the same way. The older two-line spelling with no `turn:` field
    still counts, so a run that logged a review that way is not silently reclassified as review-owed.
    """
    s = line.strip()
    if not re.match(r'^[-*]\s', s) or SEPARATOR not in s or '**' in s:
        return False
    if re.search(r'turn:\s*\d+', s, re.I):
        return True
    return bool(re.match(r'^[-*]\s+provoked:', s, re.I))


def pi_status(text):
    """The run's own exit status, from the typed line the harness writes. None when absent."""
    import re
    m = re.search(r'^##\s*pi exit status:\s*(\d+)', text, re.M)
    return None if m is None else int(m.group(1))


def aborted(text):
    """True when the artifact records a run that did not happen - infrastructure, not behaviour.

    Two signals count, in this order of trust: a typed `## pi exit status:` that is nonzero, and an
    `INFRA-FAIL` line at the start of a line. The second exists because older artifacts recorded an abort
    only in prose - and strip() removes prose like that, so honouring it here is what keeps "the run did
    not happen" from becoming "nothing was wrong". A file with neither signal is not known to be aborted,
    which leaves old artifacts gradable instead of quietly exempt.
    """
    st = pi_status(text)
    if st is not None:
        return st != 0
    return bool(re.search(r'^\s*(?:INFRA-FAIL|MISSING: no session)\b', text, re.M))
