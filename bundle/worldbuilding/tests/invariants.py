#!/usr/bin/env python3
"""Check the history-dependent invariants of a multi-turn run.

    python3 tests/invariants.py evidence/<scen>-<var>-multi-<stamp>.md

Exit is a bitmask, and shell status is ONE BYTE, so nothing above 128 exists:
  1  a turn exceeded words_per_turn          16  texture_cadence window missed
  2  an appendix limit (options >18, recap >6, close contract unmet)   32  same provoked type 3 running
  4  not exactly one question in a turn      64  same pillar in CONSECUTIVE turns
  8  entity reads over reads_per_turn        128 the instrument crashed (never a finding)

Turn counts, tunables and per-turn state are read from the evidence label and from the dumped
world/log.md - not guessed from prose. Three separate versions of this file got that wrong in one
evening: reads that counted edits, tunables that silently fell back to defaults when one label field
was blank, and a close detector that only recognised bullets shaped like `- slug:`.
"""
import sys, re, traceback, json, os

HERE = os.path.dirname(os.path.abspath(__file__))
PILLARS = [m.group(1) for m in re.finditer(r'^\| ([a-z-]+) +\|',
           open(os.path.join(HERE, '..', 'assets', 'index-template.md'), encoding='utf-8').read(), re.M)
           if m.group(1) != 'pillar']
TEXTURE = ('daily-life', 'voice-attention', 'texture')

# I7: a printed score is a claim about arithmetic, and the world index carries the operands. Checking
# one against the other is what turns "the skill improvised the number" from a vibe into a failure.
COVERAGE = re.compile(r'^\|\s*([a-z][a-z-]+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|', re.M)
# either spelling of the disclosure - `gap 3 x 1.0 + ...` or `3 x weight_gap + ...` - because the first
# draft required the literal 'weight_gap' and would have scored the rubric's own example as a bare number
# A line that shows a score must disclose its factors; the first factor is gap_weight. Detection is
# per line, not per joined prose: a negative lookahead over a big string let the engine backtrack
# "scores 3.0" down to "scores 3" to dodge its own guard, and reported a compliant line as bare.
GAP_LABELED = re.compile(r'gap(?:_weight)?\s*(\d+)\s*(?:\u00d7|x)', re.I)
GAP_IMPLIED = re.compile(r'(\d+)\s*(?:\u00d7|x)\s*[\d.]+\s*\+', re.I)
# a disclosed-looking `gap 3` with no factors is the form I7's wrong arithmetic actually travelled in,
# so it is audited for value even though it fails the disclosure rule
GAP_MENTION = re.compile(r'gap(?:_weight)?\s*(\d+)', re.I)
SHOWS_SCORE = re.compile(r'\bscore(?:d|s)?\b|\bscores\b', re.I)


def coverage_table(text):
    out = {}
    for m in COVERAGE.finditer(text):
        out[m.group(1)] = (int(m.group(2)), int(m.group(3)))     # entries, established
    return out


def gap_scale(entries, established):
    # spec §4.1, read off the table instead of the prose: 3 means nothing is there, 2 means thin
    if established == 0: return 3
    if established <= 2: return 2
    if established >= 3 and entries >= 2: return 1
    return 0
OPT       = re.compile(r'^\s*[-*] ?\*{0,2}(steady|sharp|strange)\b', re.I)
BULLET    = re.compile(r'^\s*[-*] +')
RECAP     = re.compile(r'^\s*[-*] +(`[\w-]+`|\*\*|new |T-\d)')
CLOSING   = re.compile(r'(?i)\*\*(session \d+ closed|what we decided|closing)|(?:session \d+ closed)')
NEXTLINE  = re.compile(r'(?i)\*\*next ?(thread)?[:：]|next thread')
QUOTED    = re.compile(r'"[^"]*"|`[^`]*`')
BEAT      = re.compile(r'^\s*\*\*(write back|reflect|digest|target|question|stop)\b', re.I)

# words_per_turn alone told me a turn ran 211 words and left me guessing where: the total is easy to
# keep by starving one beat and inflating another, so a compliant-looking turn can still be a monologue.
# The per-beat cap names the bloated beat, which is the part worth rewriting.
BEAT_WORD = re.compile(r'^\s*\*\*(write back|reflect|digest|target|question|stop)\b[^*]*\*\*\s*(.*)$',
                       re.I | re.M)
BEAT_CAP_DEFAULT = 45


def beat_cap(text, label):
    m = re.search(r'beat_budget:\s*(\d+)', text)
    if m: return int(m.group(1)), 'the dumped world/index.md'
    m = re.search(r'beat_budget=(\d+)', label)
    if m: return int(m.group(1)), 'the run label'
    return BEAT_CAP_DEFAULT, 'default (no beat_budget in the world index)'


def turns_of(text):
    if '## turn ' not in text: return []
    body = text.split('## turn ', 1)[1]
    body = re.split(r'\n## (?!turn )', body, 1)[0]      # never absorb the world/ dump
    return [c for c in re.split(r'\n## turn \d+', body) if c.strip()]


# A turn line is any line starting `- turn: <n>`; the fields may ride on it in any order, because the
# skill puts `decided:` prose on the same line rather than spending a second line. An earlier regex
# demanded 'turn: n · provoked: · targeted:' in that exact order and read 9 well-formed lines as 2,
# which is how a clean run got reported as a ledger collapse.
TURN_LINE = re.compile(r'^[-*]\s*turn:\s*(\d+)(.*)$', re.M)


def log_dump(text):
    m = re.search(r'--- (?:\./)?world/log\.md\n(.*?)(?=\n--- |\Z)', text, re.S)
    return m.group(1) if m else ''


def log_sequence(text, want):
    """(targeted, provoked) per turn from the turn lines R-9 requires - one line per turn.

    Prose `provoked:` lines are a fallback only: before R-9 the fields arrived intermittently (one
    `targeted:` in 14 log lines in one run, 15 in the next), which made cadence arithmetic compute
    from a ledger with holes and report that as a clean pass. The parameter is `want`, not `n`: a
    `for n, rest in …` loop shadowed it and made the slice arithmetic crash on a string.
    """
    log = log_dump(text)
    mach = []
    for num, rest in TURN_LINE.findall(log):
        tg = re.search(r'targeted:\s*([a-z-]+)', rest)
        pv = re.findall(r'provoked:\s*([a-z-, ]+)', rest)
        mach.append((int(num), tg.group(1) if tg else '?', pv[-1].strip().rstrip(', ') if pv else '?'))
    mach.sort(key=lambda r: r[0])
    if mach:
        lo, hi = mach[-min(len(mach), want)][0], mach[-1][0]
        NUMRANGE = f'#{lo}-#{hi}'
        return [(t, pv) for _, t, pv in (mach[-want:] if len(mach) >= want else mach)], \
               len(mach), 'machine (' + NUMRANGE + ')'
    out = []
    for line in log.split('\n'):
        tg = re.search(r'targeted:\s*([a-z-]+)', line)
        pv = re.findall(r'provoked:\s*([a-z-]+)', line)
        if tg or pv: out.append((tg.group(1) if tg else '?', pv[-1] if pv else '?'))
    return (out[-want:] if len(out) >= want else out), len(out), 'prose' 


def reads_per_turn(session_path, n):
    counts = []
    if not session_path or not os.path.exists(session_path): return None
    for line in open(session_path, encoding='utf-8', errors='replace'):
        try: r = json.loads(line)
        except Exception: continue
        m = r.get('message') or {}
        if m.get('role') == 'user': counts.append(0)
        content = m.get('content')
        if isinstance(content, list) and counts:
            for c in content:
                if isinstance(c, dict) and c.get('type') in ('toolCall', 'tool_use') and c.get('name') == 'read':
                    a = c.get('arguments') or c.get('input') or {}
                    if 'world/encyclopedia/' in str(a.get('path', '')): counts[-1] += 1
    return counts[-n:] or None


def main():
    args = sys.argv[1:]
    path = next(a for a in args if not a.startswith('--'))
    text = open(path, encoding='utf-8', errors='replace').read()
    limit, cad, maxr, fallback = 170, 4, 3, []
    lab = re.search(r'^label: .*', text, re.M)
    for key, box in (('words_per_turn', 'limit'), ('texture_cadence', 'cad'), ('reads_per_turn', 'maxr')):
        m = re.search(key + r'=(\d+)', lab.group(0) if lab else '')
        if m:
            v = int(m.group(1))
            limit, cad, maxr = (v, cad, maxr) if key == 'words_per_turn' else \
                               (limit, v, maxr) if key == 'texture_cadence' else (limit, cad, v)
        else:
            fallback.append(key)
    ts = turns_of(text)
    if not ts:
        print('  skip  no turns recorded (single-turn file or aborted run)'); return 0
    sess = path + '.session.jsonl' if os.path.exists(path + '.session.jsonl') else ''
    LOG, NMACH, LOGSRC = log_sequence(text, len(ts))
    CAP, CAPSRC = beat_cap(text, lab.group(0) if lab else '')
    TABLE = coverage_table(text)
    print(f'   beat budget {CAP}w ({CAPSRC})')
    # computed up front: the cadence and rotation loops both consult it, and an earlier draft
    # referenced it before assignment, which is a crash, not a verdict (UnboundLocalError)
    # R-9 detection. Suppression is proportional: a ledger that is whole but for the close turn is
    # still readable, and blacking out every window over one gap hands the run a free pass on cadence.
    # The 1-line tolerance is my invention, not the spec's; missing lines beyond it stop the scoring.
    scored = len(ts) - sum(1 for b in ts if 'INFRA-FAIL' in b)   # eaten turns are not scored
    gap = (scored - NMACH) if LOGSRC.startswith('machine') else 0
    # startswith, not equality: LOGSRC gained a numbering range ("machine (#2-#9)") and the equality
    # test silently stopped matching, which made hole detection inert and a probe caught it
    mach_src = LOGSRC.startswith('machine')
    holes = mach_src and gap > 1
    if mach_src and gap == 1:
        print(f'   ledger gap: 1 turn without a machine line (turn {scored}); windows are scored from'
              f' the {NMACH} that exist - texture is never assumed satisfied by a gap')
    eaten = [i for i, b in enumerate(ts) if 'INFRA-FAIL' in b]
    words, nq_all, targ, prov, nrecap, src = [], [], [], [], [], []
    print(f'  {len(ts)} turns | limit {limit}w | cadence {cad} | max {maxr} entity reads'
          f' | log.md: {NMACH} turn lines {LOGSRC} for {len(ts) - len(eaten)} scored turns' + (f' | {len(eaten)} turn(s) eaten by harness, not scored' if eaten else '')
          + (' | DEFAULTED: ' + ', '.join(fallback) if fallback else ''))
    rc = 0
    for i, b in enumerate(ts):
        lines = b.split('\n')
        body = [l for l in lines if not l.startswith('writer:')]
        is_infra = 'INFRA-FAIL' in ' '.join(lines)
        closing = bool(CLOSING.search(' '.join(lines)))
        opts  = [l for l in body if OPT.match(l)]
        recap = [l for l in body if BULLET.match(l) and (RECAP.match(l) or closing)]
        prose = [l for l in body if l not in opts and l not in recap]
        # matched line by line: joining the beats into one string would break the ^ anchor and read
        # the whole turn as one beat
        fat = []
        for l in prose:
            mb = BEAT_WORD.match(l)
            if mb:
                bw = len(re.findall(r"[\w'’]+", mb.group(2)))
                if bw > CAP: fat.append((mb.group(1).lower(), bw))
        w = len(' '.join(prose).split())
        # a question is the **Question.** beat, not a '?': reaction mode asks "What is wrong with
        # them - name the line number and the thing it costs." which is one question and zero marks.
        qb = [l for l in body if re.match(r'^\s*\*\*question\b', l.strip(), re.I)]
        nq = len(qb) + sum(max(0, l.count('?') - 1) for l in qb)          # two fused in one beat = 2
        nq += sum(len(QUOTED.sub('', l).split('?')) - 1 for l in prose
                  if not BULLET.match(l) and not BEAT.match(l))          # a '?' hiding elsewhere
        if closing and len(recap) >= 3: nq = max(nq, 1)                   # the close owes a recap, not a q
        txt = ' '.join(body).lower()
        # the machine line wins outright. Joining LOG[i] into the search text was useless - the tuple
        # holds bare values ('daily-life', 'cost') with no 'targeted:' prefix, so the regex never
        # matched and every run silently scored prose guesses while claiming the ledger was read.
        rec_t = LOG[i][0] if i < len(LOG) and LOG[i][0] != '?' else None
        rec_p = LOG[i][1] if i < len(LOG) and LOG[i][1] != '?' else None
        tg = [rec_t] if rec_t else re.findall(r'targeted:\s*([a-z-]+)', txt)
        pv = ([rec_p] if rec_p else []) or re.findall(r'provoked:\s*([a-z-]+)', txt)
        hit = (tg[:1] or [p for p in PILLARS if p in txt] or [x for x in TEXTURE if x in txt] or ['?'])
        pvx = (pv[-1:] or ['?'])[0]
        # logged = the state is recorded somewhere authoritative: in chat this turn, or in log.md
        logged = bool(tg) or (i < len(LOG) and LOG[i][0] != '?')
        words.append(w); nq_all.append(nq); targ.append(hit[0]); prov.append(pvx)
        nrecap.append(len(recap)); src.append('logged' if logged else ('inferred' if hit[0] != '?' else 'none'))
        bad = []
        if is_infra:
            print(f'   turn {i+1}: (turn eaten by the harness - instrument failure, not scored)'); continue
        if w > limit: bad.append(f'words>{limit}'); rc |= 1
        if any(len(l.split()) > 18 for l in opts): bad.append(f'option {max(len(l.split()) for l in opts)}w>18'); rc |= 2
        if len(recap) > 6: bad.append('recap>6'); rc |= 2
        # the beat cap is the second half of the word rule: a turn inside words_per_turn can still be
        # one 90-word monologue beat, and that is the shape that stops sounding like conversation
        for nm, bw in fat: bad.append(f'{nm} {bw}w > beat {CAP}'); rc |= 1
        # scoring audit: a score with no terms cannot be checked; a score with terms can, and the
        # index is the referee. Both halves of I7 were observed in the archive.
        shown = ' '.join(prose)
        for l in prose:
            if not SHOWS_SCORE.search(l): continue
            g = GAP_LABELED.search(l) or GAP_IMPLIED.search(l)
            if not g:
                bad.append('bare score, no terms (show gap x weight + hook x weight + contradiction x weight)')
                rc |= 2
                g = GAP_MENTION.search(l)          # still worth auditing the number it did give
                if not g: continue
            if hit[0] in TABLE:
                entries, est = TABLE[hit[0]]
                want = gap_scale(entries, est)
                got = int(g.group(1))
                if got != want:
                    bad.append(f'gap_weight {got} contradicts index '
                               f'({hit[0]}: {est} established / {entries} entities wants {want})')
                    rc |= 2
        # the close turn owes a recap and the next thread, not another question - §3.1. Scoring it for
        # "0 questions" failed a turn for doing the thing the contract asks for at the end of a session.
        if nq != 1 and not (closing and len(recap) >= 3): bad.append(f'{nq} questions'); rc |= 4
        print(f'   turn {i+1}: {w:4d}w | {nq}q | target {hit[0]:<20} | provoked {pvx:<12}'
              f'{"" if logged else " | " + src[-1]}{" | " + ", ".join(bad) if bad else ""}')
    rd = reads_per_turn(sess, len(ts)) if sess else None
    if rd is None:
        print('   entity reads: UNKNOWN (no session log) - cannot certify the read budget'); rc |= 8
    else:
        over = [j + 1 for j, n in enumerate(rd) if n > maxr and j not in eaten]
        print(f'   entity reads per turn: {rd}' + (f' - tripwire crossed at {over} (scoring from files;'
              f' raise reads_per_turn if this world needs it)' if over else ''))
        if over: rc |= 8
    for i in range(0, max(0, len(targ) - cad + 1)) if not holes else []:
        win = targ[i:i + cad]
        if not any(t in TEXTURE for t in win) and '?' not in win:
            print(f'   texture not asked within {cad} turns ending at turn {i + cad} {win}'); rc |= 16
    runs = [j + 1 for j in range(1, len(prov)) if prov[j] == prov[j-1] == prov[j-2] != '?'] if len(prov) >= 3 else []
    if runs: print(f'   same provoked type 3 turns running, ending at {runs}'); rc |= 32
    same = [] if holes else [j + 1 for j in range(1, len(targ)) if targ[j] == targ[j-1] != '?']
    nlog = sum(1 for x in src if x == 'logged')
    if same and nlog == len(targ):
        print(f'   same pillar in consecutive turns ending at {same} - breach unless no alternative'
              f' reached lopsidedness_floor (all targets logged, so adjudicable)'); rc |= 64
    elif same:
        print(f'   same pillar in consecutive turns ending at {same} - see state note below')
    if holes:
        print(f'   BOOKKEEPING HOLE: {NMACH} machine log lines for {scored} scored turns'
              f' - cadence and rotation windows are OMITTED, not scored (R-9)'); rc |= 2
    if nlog < len(targ):
        # announce missing per-turn state whether or not it happened to cause a repeat, so a clean
        # looking run can never be read as "the consecutive rule was checked and passed"
        how = ('evaluated on the logged turns' if nlog * 2 >= len(targ)
               else 'NOT evaluated - too few logged to say')
        print(f'   state note: targeted: logged in {nlog}/{len(targ)} turns; rotation was {how}'
              f'{"; " + str(len(targ) - nlog) + " turn(s) inferred from prose" if nlog < len(targ) else ""}')
    # no ^ anchor: a chunk starts with the turn number, so the writer line is never at position 0
    owed = (len(ts) - 1) if len(ts) >= 12 else next((j for j in range(len(ts))
             if re.search(r"(?i)writer:.*(that's all|that is all|wrap it up|done for today)", ts[j])), -1)
    if owed >= 0:
        tail = ' '.join(ts[owed:])
        n_rec, names = (max(nrecap[owed:] or [0])), bool(NEXTLINE.search(tail))
        if n_rec < 3 or not names:
            print(f'   close contract NOT met at turn {owed + 1}:'
                  f' {n_rec} recap bullets, {"names" if names else "no"} next thread'); rc |= 2
        else:
            print(f'   close contract met: {n_rec} bullets + next thread named')
    elif len(ts) < 12:
        print(f'   close not owed ({len(ts)} turns, no wrap cue) - not scored')
    return rc


if __name__ == '__main__':
    try:
        sys.exit(main())
    except SystemExit:
        raise
    except Exception as e:
        if os.environ.get('INV_DEBUG'): raise          # INV_DEBUG=1 to see the frame, not just the type
        print(f'  INSTRUMENT-ERROR {type(e).__name__}: {e}'); sys.exit(128)
