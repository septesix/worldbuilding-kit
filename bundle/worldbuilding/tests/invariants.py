#!/usr/bin/env python3
"""Check the history-dependent invariants of a multi-turn run.

    python3 tests/invariants.py evidence/<scen>-<var>-multi-<stamp>.md [--max-reads 3]

Exit code is a bitmask so the caller can say WHICH instrument rang (a lesson from this build:
a gate that reports "failed" without saying what failed gets trusted for the wrong thing).

  1  a turn exceeded words_per_turn        8   more than --max-reads entity bodies read in a turn
  2  an appendix limit (options / recap)    16  texture_cadence not honoured in some window
  4  not exactly one question in a turn     32  the same provoked: type three turns running
  8  entity reads over budget in a turn     64  the same pillar in CONSECUTIVE turns
     (spec §4 makes 64 a breach only "when another candidate reaches lopsidedness_floor"; the targets
      must be logged for that to be adjudicable, hence the ADVISORY line when they are not)
 128 reserved: the instrument crashed - an exception, not a finding. NOTE: shell status is one byte,
      so no bit above 128 exists. An earlier draft used 512 and 256, which truncated to 0 and made a
      real breach invisible while the code printed it.
"""
import sys, re, json, os, glob

HERE = os.path.dirname(os.path.abspath(__file__))
PILLARS = [m.group(1) for m in re.finditer(r'^\| ([a-z-]+) +\|',
           open(os.path.join(HERE, '..', 'assets', 'index-template.md'), encoding='utf-8').read(), re.M)
           if m.group(1) != 'pillar']
TEXTURE = ('daily-life', 'voice-attention', 'texture')
OPT = re.compile(r'^\s*[-*] ?\*{0,2}(steady|sharp|strange)\b', re.I)
RECAP = re.compile(r'^\s*[-*] +(`[\w-]+`|\*\*|new |T-\d)', re.I)

def turns_of(text):
    if '## turn ' not in text: return []
    body = text.split('## turn ', 1)[1]
    body = re.split(r'\n## (?!turn )', body, 1)[0]   # stop at the first non-turn section
    return [c for c in re.split(r'\n## turn \d+', body) if c.strip()]

def reads_per_turn(session_path):
    counts, cur = [], None
    if not session_path or not os.path.exists(session_path):
        return None
    for line in open(session_path, encoding='utf-8', errors='replace'):
        try: r = json.loads(line)
        except Exception: continue
        msg = r.get('message') or {}
        role = msg.get('role') or r.get('role')
        if role == 'user':
            counts.append(0); cur = len(counts) - 1
        content = msg.get('content') or []
        if isinstance(content, list):
            for c in content:
                if isinstance(c, dict) and c.get('type') in ('toolCall', 'tool_use', 'toolCall'):
                    p = str((c.get('arguments') or c.get('input') or {}).get('path', ''))
                    if 'world/encyclopedia/' in p and cur is not None:
                        counts[cur] += 1
    return counts or None

def main():
    files = [a for a in sys.argv[1:] if not a.startswith('--')]
    opt = dict(re.findall(r'--(\w[\w-]*)\s+(?!=)(\S+)', ' '.join(sys.argv[1:])) or
               [(k.split('=')[0], k.split('=', 1)[1]) for k in sys.argv[1:] if k.startswith('--')])
    limit = int(opt.get('limit', 160)); cad = int(opt.get('cadence', 4)); maxr = int(opt.get('max-reads', 3))
    path = files[0]
    text = open(path, encoding='utf-8', errors='replace').read()
    label = re.search(r'^label: .*words_per_turn=(\d+) texture_cadence=(\d+)', text, re.M)
    if label: limit, cad = int(label.group(1)), int(label.group(2))
    sess = path + '.session.jsonl' if os.path.exists(path + '.session.jsonl') else ''
    ts = turns_of(text)
    if not ts:
        print('  skip  no turns recorded (single-turn file or aborted run)'); return 0
    rc = 0
    print(f'  {len(ts)} turns | limit {limit} words | cadence {cad} | max {maxr} entity reads')
    prov, targ, qw, qn, rd, src = [], [], [], [], [], []
    logged = 0
    for i, b in enumerate(ts):
        lines = b.split('\n')
        body = [l for l in lines if not l.startswith('writer:')]
        opts = [l for l in body if OPT.match(l)]
        recap = [l for l in body if RECAP.match(l)]
        w = len(' '.join(l for l in body if l not in opts and l not in recap).split())
        # count question MARKS, not lines ending in '?': the spec's failure is "two questions in one
        # turn", which one line containing two questions satisfies. Quoted writer speech and code
        # spans are excluded - §6 warns against asking a question that only survives inside quotes.
        qs = []
        for l in body:
            if OPT.match(l) or RECAP.match(l): continue
            t = re.sub(r'"[^"]*"|`[^`]*`', '', l)
            if '?' in t: qs.append(t.count('?'))
        nq = sum(qs)
        t = ' '.join(body).lower()
        # the recorded target beats guessing from prose: the rule needs what the LAST turn targeted,
        # and SKILL.md line 60 only started logging that in R-4
        tg = re.findall(r'targeted:\s*([a-z-]+)', ' '.join(body))
        hits = (tg[:1] if tg else []) + [p for p in PILLARS if p in t] + [x for x in TEXTURE if x in t]
        if tg: tgt_src = 'logged'
        elif hits: tgt_src = 'inferred'
        else: tgt_src = 'none'
        pv = re.findall(r'provoked:\s*([a-z-]+)', t)
        qw.append(w); qn.append(nq); targ.append(hits[0] if hits else '?'); prov.append(pv[-1] if pv else '?')
        src.append(tgt_src)
        bad = []
        if w > limit: bad.append('words'); rc |= 1
        if len(set(opts)) and any(len(l.split()) > 18 for l in opts): bad.append('option>18'); rc |= 2
        if len(recap) > 6: bad.append('recap>6'); rc |= 2
        if nq != 1: bad.append(f'{nq} questions'); rc |= 4
        print(f"   turn {i+1}: {w:4d}w | {nq}q | target {targ[-1]:<12} | provoked {prov[-1]:<12}"
              + (f" | target {src[-1]}" if src[-1] != 'logged' else '')
              + (f" | {', '.join(bad)}" if bad else ''))
    if sess:
        rd = reads_per_turn(sess) or []
        over = [i + 1 for i, n in enumerate(rd) if n > maxr]
        print(f'   entity reads per turn: {rd or "none recorded"}')
        if over: print(f'   OVER max-reads in turns {over}'); rc |= 8
    else:
        print('   entity reads: UNKNOWN (no session log copied - cannot certify the read budget)'); rc |= 8
    if len(ts) >= cad:
        for i in range(len(ts) - cad + 1):
            if not any(t in TEXTURE for t in targ[i:i + cad]):
                print(f'   texture not asked within {cad} turns ending at turn {i + cad} (targets {targ[i:i + cad]})')
                rc |= 16
    rep = [i + 1 for i in range(2, len(prov)) if prov[i] == prov[i-1] == prov[i-2] != '?']
    if rep: print(f'   same provoked type 3 turns running, ending at turn {rep}'); rc |= 32
    logged = sum(1 for x in src if x == 'logged')
    runs = [i + 1 for i in range(1, len(targ)) if targ[i] == targ[i-1] != '?']
    if runs and logged == len(targ):
        print(f'   same pillar in consecutive turns, ending at turn(s) {runs} - breach unless no alternative'
              f' reached lopsidedness_floor (targets were logged, so this is adjudicable)'); rc |= 64
    elif runs:
        print(f'   same pillar in consecutive turns, ending at turn(s) {runs} - ADVISORY: only'
              f' {logged}/{len(targ)} turns logged `targeted:`, so the rest are inferred from prose')
    if logged < len(targ):
        print(f'   `targeted:` logged in {logged}/{len(targ)} turns - the consecutive-pillar rule has'
              f' no state to evaluate against without it (R-4)')
    return rc

if __name__ == '__main__':
    # A crash must not wear the mask of a finding: exit 1 WAS also "turn cap breached", so an
    # exception in this file once showed up as five red gates about the world instead of one red
    # gate about the tool. Crash codes live above the invariant bitmask.
    try:
        sys.exit(main())
    except SystemExit:
        raise
    except Exception as e:
        print(f'  INSTRUMENT-ERROR {type(e).__name__}: {e}'); sys.exit(128)
