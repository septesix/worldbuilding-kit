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
import sys, re, json, os

HERE = os.path.dirname(os.path.abspath(__file__))
PILLARS = [m.group(1) for m in re.finditer(r'^\| ([a-z-]+) +\|',
           open(os.path.join(HERE, '..', 'assets', 'index-template.md'), encoding='utf-8').read(), re.M)
           if m.group(1) != 'pillar']
TEXTURE = ('daily-life', 'voice-attention', 'texture')
OPT       = re.compile(r'^\s*[-*] ?\*{0,2}(steady|sharp|strange)\b', re.I)
BULLET    = re.compile(r'^\s*[-*] +')
RECAP     = re.compile(r'^\s*[-*] +(`[\w-]+`|\*\*|new |T-\d)')
CLOSING   = re.compile(r'(?i)\*\*(session \d+ closed|what we decided|closing)|(?:session \d+ closed)')
NEXTLINE  = re.compile(r'(?i)\*\*next ?(thread)?[:：]|next thread')
QUOTED    = re.compile(r'"[^"]*"|`[^`]*`')
BEAT      = re.compile(r'^\s*\*\*(write back|reflect|digest|target|question|stop)\b', re.I)


def turns_of(text):
    if '## turn ' not in text: return []
    body = text.split('## turn ', 1)[1]
    body = re.split(r'\n## (?!turn )', body, 1)[0]      # never absorb the world/ dump
    return [c for c in re.split(r'\n## turn \d+', body) if c.strip()]


MACHINE = re.compile(r'^-\s*turn:\s*\d+\s*·\s*provoked:\s*([a-z-,\s]+?)\s*·\s*targeted:\s*([a-z-]+)', re.M)


def log_dump(text):
    m = re.search(r'--- (?:\./)?world/log\.md\n(.*?)(?=\n--- |\Z)', text, re.S)
    return m.group(1) if m else ''


def log_sequence(text, n):
    """(targeted, provoked) per turn from the machine lines R-9 requires - one line per turn.

    Prose `provoked:` lines are a fallback only: before R-9 the fields arrived intermittently (one
    `targeted:` in 14 log lines in one run, 15 in the next), which made cadence arithmetic compute
    from a ledger with holes and report that as a clean pass.
    """
    log = log_dump(text)
    mach = [(g.group(2), g.group(1).split(',')[-1].strip()) for g in MACHINE.finditer(log)]
    if mach:
        return (mach[-n:] if len(mach) >= n else mach), len(mach), 'machine'
    out = []
    for line in log.split('\n'):
        tg = re.search(r'targeted:\s*([a-z-]+)', line)
        pv = re.findall(r'provoked:\s*([a-z-]+)', line)
        if tg or pv: out.append((tg.group(1) if tg else '?', pv[-1] if pv else '?'))
    return (out[-n:] if len(out) >= n else out), len(out), 'prose' 


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
    # computed up front: the cadence and rotation loops both consult it, and an earlier draft
    # referenced it before assignment, which is a crash, not a verdict (UnboundLocalError)
    # R-9 detection. Suppression is proportional: a ledger that is whole but for the close turn is
    # still readable, and blacking out every window over one gap hands the run a free pass on cadence.
    # The 1-line tolerance is my invention, not the spec's; missing lines beyond it stop the scoring.
    scored = len(ts) - sum(1 for b in ts if 'INFRA-FAIL' in b)   # eaten turns are not scored
    gap = (scored - NMACH) if LOGSRC == 'machine' else 0
    holes = LOGSRC == 'machine' and gap > 1
    if LOGSRC == 'machine' and gap == 1:
        print(f'   ledger gap: 1 turn without a machine line (turn {scored}); windows are scored from'
              f' the {NMACH} that exist - texture is never assumed satisfied by a gap')
    eaten = [i for i, b in enumerate(ts) if 'INFRA-FAIL' in b]
    words, nq_all, targ, prov, nrecap, src = [], [], [], [], [], []
    print(f'  {len(ts)} turns | limit {limit}w | cadence {cad} | max {maxr} entity reads'
          f' | log.md: {NMACH} lines ({LOGSRC}) for {len(ts) - len(eaten)} scored turns' + (f' | {len(eaten)} turn(s) eaten by harness, not scored' if eaten else '')
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
        print(f'  INSTRUMENT-ERROR {type(e).__name__}: {e}'); sys.exit(128)
