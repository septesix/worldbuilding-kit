#!/usr/bin/env python3
"""Where each tunable's number actually came from.

Every limit in the shipped skill is a made-up number until something measures it. This reads the evidence
corpus and reports, per tunable, what has actually been observed - in which mode, with how many samples,
against which cap the run itself recorded. It exists because `words_per_turn: 170` was set from four
single-turn measurements and then applied to sessions of twelve, where it fails in three turns out of
four: a number measured in one mode is a guess in the other.

Run from the repo root:  python3 tools/tunable_provenance.py
Output: a markdown table for docs/tunables.md, plus the machine-readable form on --json.

Deliberately conservative about two things:
  - it uses each artifact's OWN recorded caps when deciding "over", so a run graded under 160 is not
    retro-judged against today's 170;
  - it counts a sample only if the instrument could read it. Skipped files are reported, not folded into
    the median, because "0 of 36" passing is the failure this project keeps meeting in new clothes.
"""
import os, re, sys, glob, json, statistics, subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
EV = os.path.join(ROOT, 'evidence')
INVAR = os.path.join(ROOT, 'bundle', 'worldbuilding', 'tests', 'invariants.py')
WORDC = os.path.join(ROOT, 'bundle', 'worldbuilding', 'tests', 'wordcount.py')
NOT_RUNS = ('G1', 'G2', 'G3', 'G4', 'G5', 'G6', 'CANON', 'CERTIFY', 'BASELINE')
CAP_KEYS = ('words_per_turn', 'texture_cadence', 'reads_per_turn', 'beat_budget',
            'option_words', 'memo_item_words', 'turns_per_session', 'lopsidedness_floor')


def caps_of(text):
    """The limits this run recorded for itself: label line first, then any world/index.md dump."""
    out = {}
    lab = re.search(r'^label: (.*)$', text, re.M)
    if lab:
        for k, v in re.findall(r'(\w+)=(\d+)', lab.group(1)):
            out[k] = int(v)
    for k, v in re.findall(r'^\s+(\w+):\s*(\d+)', text, re.M):
        if k in CAP_KEYS and k not in out:
            out[k] = int(v)
    return out


def records(path):
    base = os.path.basename(path)
    if any(n in base for n in NOT_RUNS):
        return None
    arm = 'skill' if '-skill' in base else 'control' if '-control' in base else 'unknown'
    scen = re.match(r'([a-z-]+?)-(skill|control)', base)
    try:
        text = open(path, encoding='utf-8', errors='ignore').read()
    except Exception:
        return None
    multi = bool(re.search(r'^## turn 2\b', text, re.M))
    key = (re.search(r'guidance=([0-9a-f]{8})', text) or [None, '???????'])[1]
    r = {'file': base, 'arm': arm, 'mode': 'multi' if multi else 'single', 'key': key,
         'scenario': scen.group(1) if scen else base.split('-')[0], 'caps': caps_of(text),
         'turn_words': [], 'reads': [], 'opts': [], 'memo_items': [], 'marker': {}}
    try:
        out = subprocess.run([sys.executable, INVAR, path], capture_output=True, text=True, timeout=120)
    except Exception as e:
        r['error'] = f'{type(e).__name__}: {e}'
        return r
    o = out.stdout + out.stderr
    r['turn_words'] = [int(x) for x in re.findall(r'turn \d+:\s+(\d+)w', o)]
    need_wc = not (r['turn_words'] and r['opts']) or not r['memo_items']
    if need_wc:
        # each field falls back on its own. The first version gated the fallback on turn words being
        # absent, so whenever invariants scored the prose the options and memo cells stayed empty -
        # an instrument reporting 'no samples' about data it had simply never asked for
        try:
            w = subprocess.run([sys.executable, WORDC, path], capture_output=True, text=True, timeout=120)
            w = w.stdout + w.stderr
            m = re.search(r'(\d+) turn words \(limit (\d+)\)', w)
            if m and not r['turn_words']:
                r['turn_words'] = [int(m.group(1))]
            if m:
                r['caps'].setdefault('words_per_turn', int(m.group(2)))
            mo = re.search(r'(\d+) options, longest (\d+)', w)
            if mo and not r['opts']:
                r['opts'] = [int(mo.group(2))]
            mm = re.search(r'memo max item (\d+)w \(limit (\d+)\)', w)
            if mm:
                if int(mm.group(1)) > 0:
                    r['memo_items'] = [int(mm.group(1))]
                r['caps'].setdefault('memo_item_words', int(mm.group(2)))
        except Exception:
            pass
    reads = re.search(r'entity reads per turn: \[([0-9, ]*)\]', o)
    if reads:
        r['reads'] = [int(x) for x in re.findall(r'\d+', reads.group(1))]
    for name, pat in (('texture', r'texture not asked within'),
                      ('same_pillar', r'same pillar in consecutive turns'),
                      ('ledger_gap', r'ledger gap'),
                      ('questions', r'0 questions|\d questions'),
                      ('canon_loss', r'CANON-LOSS'),
                      ('beats_over', r'>\s*beat'),
                      ('options_over', r'>\s*option_words')):
        r['marker'][name] = bool(re.search(pat, o))
    return r


def dist(vals):
    if not vals:
        return None
    v = sorted(vals)
    return {'n': len(v), 'min': v[0], 'med': int(statistics.median(v)),
            'p90': v[min(len(v) - 1, int(0.9 * len(v)))], 'max': v[-1]}


def main():
    recs = [x for x in (records(p) for p in sorted(glob.glob(os.path.join(EV, '*.md')))) if x]
    report = {}
    excluded = {'empty_turns': 0}
    for r in recs:   # a turn with no assistant text is infrastructure, not prose
        n0 = len([x for x in r['turn_words'] if x == 0])
        excluded['empty_turns'] += n0
        r['turn_words'] = [x for x in r['turn_words'] if x > 0]

    for tun, field, cap in (('words_per_turn', 'turn_words', 'words_per_turn'),
                            ('reads_per_turn', 'reads', 'reads_per_turn'),
                            ('option_words', 'opts', 'option_words')):
        cells = {}
        for mode in ('single', 'multi'):
            for arm in ('skill', 'control'):
                vals, over, lims = [], 0, []
                for r in recs:
                    if r['mode'] != mode or r['arm'] != arm:
                        continue
                    vs = r[field]
                    if not vs:
                        continue
                    lim = r['caps'].get(cap)
                    vals += vs
                    if lim:
                        over += sum(1 for x in vs if x > lim)
                        lims.append(lim)
                cells[f'{mode}/{arm}'] = {'dist': dist(vals), 'over': over,
                                          'cap_seen': (statistics.mode(lims) if lims else None)}
        report[tun] = cells
    mark = {}
    for name in ('texture', 'same_pillar', 'ledger_gap', 'canon_loss', 'beats_over', 'options_over'):
        for mode in ('single', 'multi'):
            hit = [r for r in recs if r['mode'] == mode and r['marker'][name]]
            tot = [r for r in recs if r['mode'] == mode]
            mark.setdefault(name, {})[mode] = {'runs_with_it': len(hit), 'runs': len(tot)}
    report['_markers'] = mark
    report['_files'] = len(recs)
    report['_keys'] = len({r['key'] for r in recs})
    report['_excluded'] = excluded
    report['_memo'] = {}
    for mode in ('single', 'multi'):
        for arm in ('skill', 'control'):
            vals = [x for r in recs if r['mode'] == mode and r['arm'] == arm for x in r['memo_items']]
            lims = [r['caps'].get('memo_item_words') for r in recs
                    if r['mode'] == mode and r['arm'] == arm and r['caps'].get('memo_item_words')]
            cap = statistics.mode(lims) if lims else None
            over = sum(1 for x in vals if x > cap) if cap else 0
            report['_memo'][mode + '/' + arm] = {'dist': dist(vals), 'cap': cap, 'over': over}
    if '--json' in sys.argv:
        print(json.dumps(report, indent=1))
        return
    for tun, cells in report.items():
        if tun.startswith('_'):
            continue
        print(f'\n**{tun}**')
        for k, c in cells.items():
            d = c['dist']
            if not d:
                print(f'  - `{k}`: no scored samples - the instrument read nothing here')
                continue
            share = f'{100 * c["over"] // max(d["n"], 1)}% over its own cap' if c['cap_seen'] else 'cap unknown'
            print(f'  - `{k}`: n={d["n"]} · min {d["min"]} · median {d["med"]} · p90 {d["p90"]} · '
                  f'max {d["max"]} · cap {c["cap_seen"]} · {share}')
    f = str(report['_files']) + ' run records across ' + str(report['_keys']) + ' guidance keys; '
    f += str(report['_excluded']['empty_turns']) + ' empty turns excluded as infrastructure'
    print('_(' + f + ')_')
    print('')
    print('**memo_item_words** - the shape cap on each of the five memo lines')
    for k, c in report['_memo'].items():
        d = c['dist']
        if not d:
            print('  - `' + k + '`: no memo items in evidence for this cell')
        else:
            print('  - `' + k + '`: n=' + str(d['n']) + ' | median ' + str(d['med']) + ' | max ' +
                  str(d['max']) + ' | cap ' + str(c['cap']) + ' | ' + str(c['over']) + ' items over')

    for name, modes in mark.items():
        line = ', '.join(f'{m}: {v["runs_with_it"]}/{v["runs"]} runs' for m, v in modes.items())
        print(f'  - `{name}` breaches - {line}')


if __name__ == '__main__':
    main()
