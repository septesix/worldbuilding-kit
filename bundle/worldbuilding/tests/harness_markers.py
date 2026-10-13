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
