#!/usr/bin/env python3
"""Measure a turn against words_per_turn, the way voice.md defines it.

  python3 tests/wordcount.py evidence/<file>.md [limit]

CAP applies to **turn words**: the conversational body (digest, target, question, reflect, stop,
and any prose at all). APPENDIX words are exempt from the cap because spec §3.1 and voice.md rule 4
mandate them and give them their own limits:
  - candidate options, `steady`/`sharp`/`strange`  → ≤18 words each
  - the session-close recap bullets                → ≤6 bullets
Counting either against the conversational budget makes the cap unsatisfiable by design on a wrap-up
turn, which is what the first version of this tool did (see spec revision R-3).
"""
import sys, re

OPT   = re.compile(r'^\s*[-*] ?\*{0,2}(steady|sharp|strange)\b\*{0,2}\s*[—:-]?', re.I)
RECAP = re.compile(r'^\s*[-*] +(`[\w-]+`|\*\*|new |T-\d)', re.I)     # close-recap bullet
CLOSE = re.compile(r'^\s*\*\*(what we decided|decided|session \d|close)', re.I)

def measure(path):
    t = open(path, encoding='utf-8', errors='replace').read()
    if '## transcript' not in t: return None
    body = t.split('## transcript', 1)[1].split('## files after run', 1)[0]
    body = re.sub(r'## pi exit status.*', '', body, flags=re.S)
    turn, opts, recap = [], [], []
    for l in body.split('\n'):
        (opts if OPT.match(l) else recap if (RECAP.match(l) or CLOSE.match(l)) else turn).append(l)
    w = len(' '.join(turn).split())
    if w <= 10 and not opts and not recap: return None      # empty/aborted transcript: no verdict
    return w, [len(l.split()) for l in opts], len(recap)

if __name__ == '__main__':
    files = [a for a in sys.argv[1:] if not a.isdigit()]
    args = [a for a in sys.argv[1:] if a.isdigit()]
    limit = int(args[0]) if args else 160
    bad_turn = bad_aux = 0
    for f in sorted(files):
        m = measure(f)
        if m is None:
            print(f'  skip  {f} (no transcript, or an aborted run - not counted as a pass)'); continue
        w, opts, recap = m
        over_opt = [o for o in opts if o > 18]
        flag = 'ok  ' if w <= limit and not over_opt and recap <= 6 else 'OVER'
        bad_turn += w > limit
        bad_aux += bool(over_opt) or recap > 6
        print(f'  {flag}  {w:4d} turn words (limit {limit}) | {len(opts)} options'
              f'{", longest " + str(max(opts)) if opts else ""} | {recap} recap bullets'
              f'{"  <-- " + ",".join(str(o) for o in over_opt) + "-word options" if over_opt else ""}'
              f'{"  <-- recap > 6" if recap > 6 else ""}  <- {f.split("/")[-1]}')
    # exit: 0 clean | 1 turn cap | 2 options/recap appendix limits | 3 both - so the caller can say
    # which instrument rang, instead of reporting a turn overrun when the options were too long.
    sys.exit((1 if bad_turn else 0) | (2 if bad_aux else 0))
