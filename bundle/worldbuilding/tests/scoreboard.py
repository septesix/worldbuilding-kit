#!/usr/bin/env python3
"""Recompute a world index's coverage tables from the entity files that back them.

Index tables are DERIVED (spec §7): entity files are authoritative. This prints the tables a given
world/ directory implies, and with --diff exits 1 where an existing index.md disagrees.

  bash bundle/worldbuilding/tests/check.sh fixture     # gate used at HEAD
  python3 tests/scoreboard.py <world_dir> [--diff]

Counting rules, pinned so two runs cannot disagree:
  entries      = entity files whose pillars[] name the pillar
  established  = '- established:' bullets in those files, excluding any line carrying 'supersedes'
  proposed     = '- proposed:' bullets in those files
  status       = empty (0 entries) | thin (<3 established) | substantial | all-proposed
  hooks (entity row) = inbound [[slug]] links from OTHER files in encyclopedia/
"""
import re, sys, glob, os, collections

def scan(world):
    keys, ent = [], {}
    tpl = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'index-template.md')
    for line in open(tpl, encoding='utf-8'):
        m = re.match(r'^\| ([a-z-]+) +\|', line)
        if m and m.group(1) != 'pillar': keys.append(m.group(1))
        if line.startswith('## Entities'): break
    for path in sorted(glob.glob(os.path.join(world, 'encyclopedia', '*.md'))):
        slug = os.path.basename(path)[:-3]
        s = open(path, encoding='utf-8').read()
        pillars = [p.strip() for p in re.findall(r'pillars:\s*\[([^\]]*)\]', s)[0].split(',')] if re.search(r'pillars:\s*\[', s) else []
        est = len([l for l in s.split('\n') if l.startswith('- established:') and 'supersedes' not in l])
        prop = len([l for l in s.split('\n') if l.startswith('- proposed:')])
        ent[slug] = dict(pillars=pillars, est=est, prop=prop, kind=re.search(r'^kind: (\w+)', s, re.M).group(1))
    for others in ent.values():
        others['hooks'] = 0
    for slug, e in ent.items():
        for other, oe in ent.items():
            if slug != other and f'[[{slug}]]' in open(os.path.join(world, 'encyclopedia', other + '.md'), encoding='utf-8').read():
                oe['hooks'] += 1
    return keys, ent

def tables(keys, ent):
    cov = collections.defaultdict(lambda: [0, 0, 0])
    for e in ent.values():
        for p in e['pillars']:
            cov[p][0] += 1; cov[p][1] += e['est']; cov[p][2] += e['prop']
    rows = []
    for p in keys:
        n, est, prop = cov.get(p, (0, 0, 0))
        st = 'empty' if n == 0 else ('all-proposed' if est == 0 and prop else ('thin' if est < 3 else 'substantial'))
        rows.append(f'| {p} | {n} | {est} | {prop} | {st} |')
    ents = [f'| {s} | {e["kind"]} | {", ".join(e["pillars"])} | '
            f'{"established" if e["est"] and not e["prop"] else ("mixed" if e["prop"] and e["est"] else "proposed")} | {e["hooks"]} |'
            for s, e in sorted(ent.items())]
    return rows, ents

def main():
    world = sys.argv[1]; diff = '--diff' in sys.argv
    keys, ent = scan(world)
    rows, ents = tables(keys, ent)
    idx = os.path.join(world, 'index.md')
    if not diff:
        print('\n'.join(rows)); print(); print('\n'.join(ents)); return 0
    if not os.path.exists(idx):
        print('index.md missing'); return 1
    cur = open(idx, encoding='utf-8').read()
    for heading, hdr in (('## Pillar coverage', '| pillar |'), ('## Entities', '| slug |')):
        i = cur.find(heading)
        nxt = cur.find('\n## ', i + 1)
        seg = cur[i:nxt if nxt > 0 else len(cur)] if i >= 0 else ''
        if hdr not in seg:
            print(f'NO COLUMN HEADER under {heading} (markdown table will not render)')
            return 1
    bad = [r for r in rows + ents if r not in cur]
    stale = [l for l in cur.split('\n') if re.match(r'^\| [a-z-]+ \| \d', l) and l not in rows and l not in ents]
    for b in bad: print('MISSING from index : ' + b)
    for s in stale: print('WRONG in index     : ' + s)
    if bad or stale:
        n = len([l for l in cur.split('\n') if re.match(r'^\| [a-z-]+ \| \d', l)])
        print(f'\n{len(set(bad))} of ~{n} rows disagree with the entity files that back them')
        return 1
    print('index tables agree with the entity files (0 mismatches)'); return 0

sys.exit(main())
