#!/usr/bin/env python3
"""Validate a freshly seeded world against spec §2's `new` mode (I4).

  seedcheck.py <world_dir>

Exit bitmask - deliberately the same shape as invariants.py, so the harness can say which half failed:
  1   entity count outside 5-8
  2   pillar spread (needs >=3 distinct pillars, and >=1 texture pillar)
  4   a seeded file carries established: (a seed is a hypothesis, not canon)
  8   threads.md under-provisioned (< 3 threads per seeded entity)
  16  entity identity: a [[link]] with no file, or one matching several (spec §'s slug rule, R-28)
  128 instrument crash, never a finding

Rationale lives in references/rubric.md, "Seeding a new world" and "One entity, one file". The thread
floor is checked against the total because threads.md rows do not reliably name their entity; per-entity
attribution is a known gap, and it is stated rather than assumed. The suffix/kind drift half of the slug
rule is checked statically against the shipped fixture rather than on runs - a title that legitimately
ends in a kind word (`ledger-text`) would otherwise false-red a good run.
"""
import sys, os, re, glob

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from invariants import PILLARS, TEXTURE           # one copy of the pillar list, on purpose

LOW, HIGH = 5, 8
LINK = re.compile(r'\[\[([a-z0-9][a-z0-9-]*)\]\]')


def identity(world):
    """Spec §'s promise, made checkable: one entity is one file, so every [[link]] finds exactly one.

    A bare [[stem]] is allowed to resolve to `stem-kind.md` - that is the disambiguated form - but only
    when exactly one file carries it. Zero targets is a dangling link, several is an ambiguous one, and
    both mean the writer is about to be told about an entity that cannot be opened.
    """
    bad = []
    files = {os.path.basename(f)[:-3] for f in entity_files(world)}
    for f in [os.path.join(world, n) for n in ('index.md', 'threads.md')] + entity_files(world):
        try:
            txt = open(f, encoding='utf-8', errors='replace').read()
        except OSError:
            continue
        for tgt in sorted(set(LINK.findall(txt))):
            hits = {x for x in files if x == tgt} or {x for x in files if x.startswith(tgt + '-')}
            if not hits:
                bad.append('dangling [[%s]] in %s' % (tgt, os.path.basename(f)))
            elif len(hits) > 1:
                bad.append('ambiguous [[%s]] could mean %s' % (tgt, sorted(hits)))
    return bad


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

    ident = identity(world)
    if ident:
        fails |= 16
        notes.append('; '.join(ident[:3]) + ('' if len(ident) < 4 else ' (+%d more)' % (len(ident) - 3)))
    else:
        notes.append('links: every [[target]] finds exactly one file')
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
