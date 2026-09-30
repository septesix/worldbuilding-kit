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
# the option is what the writer reads, not the markup presenting it. Counting the bullet, the label and
# the em dash added a flat +3 to every option and turned a compliant 17-word line into a "20-word"
# breach - F9's twin: an instrument reporting a finding it manufactured itself.
OPT_TEXT = re.compile(r'^\s*[-*] ?\*{0,2}(?:steady|sharp|strange)\b\*{0,2}\s*[—:\-]?\s*(.*)$', re.I)


def option_words(line):
    m = OPT_TEXT.match(line.strip())
    return len(re.findall(r"[\w'’]+", m.group(1) if m else line))
RECAP = re.compile(r'^\s*[-*] +(`[\w-]+`|\*\*|new |T-\d)', re.I)     # close-recap bullet
CLOSE = re.compile(r'^\s*\*\*(what we decided|decided|session \d|close)', re.I)

MEMO_LEAD = re.compile(r'^\s*\*\*(memo|review)\b[^*]*\*\*\s*[—:]?\s*(.*)$', re.I)
MEMO_ITEM = re.compile(r'^\s*(?:[-*]|\d\.)\s+')


def memo_split(lines):
    """(memo_lines, other_lines). The review memo is a mandated appendix, so it is measured against
    memo_words and never against the turn budget - and it is still measured, because an exempt artifact
    without a ceiling is just a place to hide length."""
    memo, other, i = [], [], 0
    while i < len(lines):
        m = MEMO_LEAD.match(lines[i])
        if not m:
            other.append(lines[i]); i += 1; continue
        memo.append(lines[i]); i += 1
        taken = 0
        while i < len(lines) and taken < 6:
            t = lines[i].strip()
            if not t:
                if memo and i + 1 < len(lines) and MEMO_ITEM.match(lines[i + 1]): i += 1; continue
                break
            if not MEMO_ITEM.match(lines[i]): break
            memo.append(lines[i]); taken += 1; i += 1
    return memo, other


def memo_cap(text):
    m = re.search(r'memo_words:\s*(\d+)', text)
    return int(m.group(1)) if m else 120


def wc_words(line):
    return len(re.findall(r"[\w'’]+", line))


def measure(path):
    t = open(path, encoding='utf-8', errors='replace').read()
    if '## transcript' not in t: return None
    body = t.split('## transcript', 1)[1].split('## files after run', 1)[0]
    body = re.sub(r'## pi exit status.*', '', body, flags=re.S)
    memo, lines = memo_split(body.split('\n'))
    memo = [l for l in memo if not OPT.match(l)]
    turn, opts, recap = [], [], []
    for l in lines:
        (opts if OPT.match(l) else recap if (RECAP.match(l) or CLOSE.match(l)) else turn).append(l)
    w = len(' '.join(turn).split())
    if w <= 10 and not opts and not recap and not memo:
        return None                                  # empty/aborted transcript: no verdict
    return (w, [option_words(l) for l in opts], len(recap),
            sum(wc_words(l) for l in memo), memo_cap(t))

if __name__ == '__main__':
    files = [a for a in sys.argv[1:] if not a.isdigit()]
    args = [a for a in sys.argv[1:] if a.isdigit()]
    limit = int(args[0]) if args else 160
    bad_turn = bad_aux = 0
    for f in sorted(files):
        m = measure(f)
        if m is None:
            print(f'  skip  {f} (no transcript, or an aborted run - not counted as a pass)'); continue
        w, opts, recap, memo_w, memo_lim = m
        over_opt = [o for o in opts if o > 18]
        over_memo = memo_w > memo_lim
        flag = 'ok  ' if w <= limit and not over_opt and recap <= 6 and not over_memo else 'OVER'
        bad_turn += w > limit
        bad_aux += bool(over_opt) or recap > 6 or over_memo
        print(f'  {flag}  {w:4d} turn words (limit {limit}) | {len(opts)} options'
              f'{", longest " + str(max(opts)) if opts else ""} | {recap} recap bullets'
              f'{" | memo " + str(memo_w) + "w (limit " + str(memo_lim) + ")" if memo_w else ""}'
              f'{"  <-- " + ",".join(str(o) for o in over_opt) + "-word options" if over_opt else ""}'
              f'{"  <-- recap > 6" if recap > 6 else ""}'
              f'{"  <-- memo over " + str(memo_lim) + "w" if over_memo else ""}  <- {f.split("/")[-1]}')
    # exit: 0 clean | 1 turn cap | 2 options/recap appendix limits | 3 both - so the caller can say
    # which instrument rang, instead of reporting a turn overrun when the options were too long.
    sys.exit((1 if bad_turn else 0) | (2 if bad_aux else 0))

