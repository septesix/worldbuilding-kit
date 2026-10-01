#!/usr/bin/env python3
"""CANON-LOSS detector: the encyclopedia may gain files, never lose them.

  canoncheck.py --dir <work> [--fixture <orig>] [--seen <file>] [--transcript <md|jsonl>]

Three independent witnesses, because each one alone has a blind spot:

  --fixture     files the world started with must still exist. The classic check, and blind to a file
                created at turn 3 and deleted at turn 7 - which is what the retcon runs did with
                `rm encyclopedia/lighthouse-place.md`: nothing in the fixture was lost, so the canon
                counts stayed green while an entity's history vanished.
  --seen        every encyclopedia path observed at ANY point during the run. Catches the
                created-then-deleted case.
  --transcript  the tool calls themselves: catches deletion even when the run cleaned up afterwards.
                Reported as attempted, because a failed `rm` is still intent.

Exit: 0 clean | 1 canon lost or attempted. Lines start with CANON-LOSS so `grep -q '^CANON-LOSS'` in
run.sh / multiturn.sh / check.sh keeps working unchanged.
"""
import sys, os, re, argparse


def norm(p):
    """One spelling for one file: the false positives in the first draft came from './world/x' from
    the seen list never matching 'world/x' from the walk."""
    p = p.strip().replace('\\', '/').lstrip('./')
    while p.startswith('./'): p = p[2:]
    return re.sub(r'^\.?/?', '', p)


def enc_paths(root):
    out = set()
    if not root or not os.path.isdir(root): return out
    for dirpath, _, files in os.walk(root):
        for f in files:
            if not f.endswith('.md'): continue
            rel = norm(os.path.relpath(os.path.join(dirpath, f), root))
            if '/encyclopedia/' in '/' + rel or rel.startswith('encyclopedia/'):
                out.add(rel)
    return out


def read_seen(path):
    out = set()
    if not path or not os.path.exists(path): return out
    for line in open(path, encoding='utf-8', errors='replace'):
        line = line.strip()
        if line.endswith('.md') and 'encyclopedia' in line: out.add(norm(line))
    return out


DEL = re.compile(r'(?:\brm\s+-?[a-zA-Z]*\s*[^\n"\\]*\.md|os\.remove\([^\n)]*\.md'
                 r'|os\.unlink\([^\n)]*\.md|\bgit\s+rm\s+[^\n]*\.md)', re.I)


def entity_names(text):
    """Every encyclopedia basename the session itself mentions - written, edited, or read. A bare
    `rm lighthouse-place.md` is only suspicious because the same transcript wrote that file a minute
    earlier; deciding by on-disk state alone would miss it once the temp world is gone."""
    return {n.lower() for n in re.findall(r'encyclopedia/([A-Za-z0-9_-]+\.md)', text)}


def deletions(text, ever, names=()):
    """Commands that remove an encyclopedia file. A bare `rm lighthouse-place.md` is the same act as
    `rm encyclopedia/lighthouse-place.md` - matching only on the path would have missed exactly what
    the retcon runs did."""
    hits = []
    for m in DEL.findall(text):
        toks = [w for w in m.split() if w.endswith('.md')]
        if not toks:
            mm = re.search(r'([^\s/\\]+\.md)', m)
            if not mm: continue
            toks = [mm.group(1)]
        base = os.path.basename(toks[-1].strip('"\''))
        # three ways the same act shows up: a path that says encyclopedia, a bare name that some other
        # turn of this session wrote (the retcon case), or a name present in the world on disk
        if 'encyclopedia' in m or base in names or any(p.split('/')[-1] == base for p in ever):
            hits.append(' '.join(m.split())[:90])
    return hits


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--dir', required=True)
    ap.add_argument('--fixture')
    ap.add_argument('--seen')
    ap.add_argument('--transcript', nargs='+')
    a = ap.parse_args()

    now = enc_paths(a.dir)
    lost = [('present at the start of the run', f) for f in sorted(enc_paths(a.fixture) - now)]
    seen = read_seen(a.seen)
    lost += [('seen during the run', f) for f in sorted(seen - now - {p for _, p in lost})]
    ever = now | seen | {p for _, p in lost}

    # a session directory is accepted too: one pi session per run, one jsonl per turn, and the run's
    # deletions can be spread across them
    files = []
    for t in (a.transcript or []):
        if os.path.isdir(t): files += sorted(os.path.join(t, f) for f in os.listdir(t) if f.endswith('.jsonl'))
        elif os.path.exists(t): files.append(t)
    text = '\n'.join(open(f, encoding='utf-8', errors='replace').read() for f in files)
    tried = sorted(set(deletions(text, ever, entity_names(text))))

    for why, f in lost:
        print(f'CANON-LOSS: {f} {why} and is gone from the world')
    for c in tried:
        print(f'CANON-LOSS: attempted deletion during the run: {c}')
    return 1 if (lost or tried) else 0


if __name__ == '__main__':
    sys.exit(main())
