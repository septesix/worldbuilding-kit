#!/usr/bin/env python3
"""Validate a freshly seeded world against spec §2's `new` mode (I4).

  seedcheck.py <world_dir>

Exit bitmask - deliberately the same shape as invariants.py, so the harness can say which half failed:
  1   entity count outside 5-8
  2   pillar spread (needs >=3 distinct pillars, and >=1 texture pillar)
  4   a seeded file carries established: (a seed is a hypothesis, not canon)
  8   threads.md under-provisioned (< 3 threads per seeded entity)
  128 instrument crash, never a finding

Rationale lives in references/rubric.md, "Seeding a new world". The thread floor is checked against the
total because threads.md rows do not reliably name their entity; per-entity attribution is a known gap,
and it is stated rather than assumed.
"""
import sys, os, re, glob

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from invariants import PILLARS, TEXTURE           # one copy of the pillar list, on purpose

LOW, HIGH = 5, 8


def entity_files(world):
    return sorted(glob.glob(os.path.join(world, 'encyclopedia', '*.md')))


def check(world):
    fails, notes = 0, []
    files = entity_files(world)
    n = len(files)
    if not (LOW <= n <= HIGH):
        fails |= 1
        notes.append(f'entities: {n} (want {LOW}-{HIGH})')
    else:
        notes.append(f'entities: {n}')

    pillars = set()
    established = 0
    for f in files:
        t = open(f, encoding='utf-8', errors='replace').read()
        head = t.split('---')[1] if t.count('---') >= 2 else t[:400]
        m = re.search(r'pillars:\s*\[?([^\]\n]*)\]?', head)
        for p in re.findall(r'[a-z][a-z-]+', (m.group(1) if m else '')):
            if p in PILLARS: pillars.add(p)
        if not m:
            notes.append(f'no pillars: line in {os.path.basename(f)}')
            fails |= 2
        established += len(re.findall(r'^\s*[-*]\s*established:', t, re.M))
    tex = pillars & set(TEXTURE)
    if len(pillars) < 3 or not tex:
        fails |= 2
        notes.append('pillars: %d distinct, texture %s (%s)'
                     % (len(pillars), 'present' if tex else 'ABSENT', sorted(pillars)[:5]))
    else:
        notes.append(f'pillars: {len(pillars)} distinct incl. {sorted(tex)[0]}')

    if established:
        fails |= 4
        notes.append(f'{established} established: line(s) in a seed - canon needs the writer first')

    tp = os.path.join(world, 'threads.md')
    body = open(tp, encoding='utf-8', errors='replace').read() if os.path.exists(tp) else ''
    rows = re.findall(r'^\|\s*T-\d+', body, re.M)
    want = 3 * max(n, LOW)
    if len(rows) < want:
        fails |= 8
        notes.append(f'threads: {len(rows)} rows, want >= {want} (3 per entity)')
    else:
        notes.append(f'threads: {len(rows)} rows for {n} entities')
    return fails, notes


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('usage: seedcheck.py <world_dir>', file=sys.stderr); sys.exit(2)
    try:
        rc, notes = check(sys.argv[1])
    except Exception as e:
        print(f'  INSTRUMENT-ERROR {type(e).__name__}: {e}'); sys.exit(128)
    print('  ' + ' | '.join(notes))
    sys.exit(rc)
