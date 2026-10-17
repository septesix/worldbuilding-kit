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
import harness_markers as hm

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
    memo_item_words and never against the turn budget - and it is still measured, because an exempt artifact
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
    """Per-item ceiling. The total is deliberately not the measured thing: totals across the archive run
    55-182 and hide a 60-word bullet inside a 147-word memo."""
    m = re.search(r'memo_item_words:\s*(\d+)', text)
    return int(m.group(1)) if m else 45


def wc_words(line):
    return len(re.findall(r"[\w'’]+", line))


def _tunable(text, key, default):
    # One precedence, shared with invariants via harness_markers.tunable (label, then dumped index,
    # then the shipped default). See GRADER-20261016.md F8.
    return hm.tunable(text, key, default)[0]


def option_cap(text):
    # this used to be a literal 18 in the flag test, which meant a world that changed option_words
    # moved one gate and not the other
    return _tunable(text, 'option_words', 18)


def sketch_cap(text):
    return _tunable(text, 'sketch_words', 25)


def cap_for(path):
    """The turn cap this run was graded under, from its own label line; 170 is the shipped default."""
    try:
        return _tunable(open(path, encoding='utf-8', errors='replace').read(), 'words_per_turn', 170)
    except OSError:
        return 170


def measure(path):
    """(worst turn words, option lengths, recap count, memo item lengths, memo cap, turns graded,
    turns skipped) for one artifact, or None when nothing in it could be read.

    Multi-turn runs used to return None: they carry `## turn N` sections and no `## transcript`, so the
    length cap was never measured in the mode where prose grows longest, and the gate printed `skip`
    where it meant `never looked`. An eaten turn (nothing produced) is skipped on its own and does not
    void the rest of the run - it is neither a pass nor a breach.
    """
    t = hm.strip(open(path, encoding='utf-8', errors='replace').read())
    bodies = []
    if '## transcript' in t:
        bodies = [t.split('## transcript', 1)[1].split('## files after run', 1)[0]]
    elif '## turn ' in t:
        parts = re.split(r'\n?## turn \d+[^\n]*\n', t)
        bodies = [re.split(r'\n## (?!turn \d)', seg, 1)[0] for seg in parts[1:]]
    else:
        return None
    bodies = [re.sub(r'## pi exit status.*', '', b, flags=re.S) for b in bodies]
    worst = None; graded = skipped = 0
    for bi, b in enumerate(bodies):
        memo, lines = memo_split(b.split('\n'))
        memo = [l for l in memo if not OPT.match(l)]
        turn, opts, recap = [], [], []
        last_turn = (bi == len(bodies) - 1)
        sketch = []
        sk_idx = hm.sketch_lines(lines, last_turn, len(bodies))
        for li, l in enumerate(lines):
            # The harness echoes the scripted turn as the first line under `## turn N`. That echo, and
            # only that echo, is excluded. Skipping any line that merely starts `writer:` is a
            # free-words channel: an assistant line could opt out of the cap by prefixing it.
            if hm.is_writer_echo(lines, li):
                continue
            # An appendix bullet is exempt by ROLE, not by the shape of its first token. A bullet that
            # leads with a slug counts as a recap only once the turn has announced the session close;
            # before that it is prose. Reaction mode writes six such lines mid-session, and those lines
            # ARE the beat. Audited 2026-10-16: 162w counted against 291w for the same words in prose
            # order, in a certified artifact (evidence/cadence-skill-multi-20261015T035948Z.md turn 5).
            if OPT.match(l):
                opts.append(l)
            elif CLOSE.match(l):
                recap.append(l)
            elif li in sk_idx:
                sketch.append(l)
            elif RECAP.match(l) and hm.close_context(lines, li, last_turn, len(bodies)):
                recap.append(l)
            else:
                turn.append(l)
        w = len(' '.join(turn).split())
        if w <= 10 and not opts and not recap and not memo and not sketch:
            skipped += 1
            continue
        graded += 1
        items = [wc_words(l) for l in memo if MEMO_ITEM.match(l)]
        sk_w = [wc_words(l) for l in sketch]
        m = (w, [option_words(l) for l in opts], len(recap),
             items or [sum(wc_words(l) for l in memo)], memo_cap(t),
             len(sk_w), sk_w, option_cap(t), sketch_cap(t))
        if worst is None or w > worst[0]:
            worst = m
    if not graded:
        return None
    return worst + (graded, skipped)


if __name__ == '__main__':
    files = [a for a in sys.argv[1:] if not a.isdigit()]
    args = [a for a in sys.argv[1:] if a.isdigit()]
    # An explicit cap on the command line wins (that is how run.sh grades against the live template).
    # With none, each artifact is judged by the words_per_turn in its own dump - the same rule invariants
    # already follows. Before this, argument-less calls graded every 170-cap run against a literal 160,
    # which is stricter than the rule the run was made under: good runs failing, not bad ones passing.
    cli = int(args[0]) if args else None
    bad_turn = bad_aux = 0; nfiles = nskip = 0
    for f in sorted(files):
        limit = cli if cli is not None else cap_for(f)
        m = measure(f)
        if m is None:
            nskip += 1
            print(f'  skip  {f} (no readable turn block, or every turn produced nothing)'); continue
        w, opts, recap, memo_w, memo_lim, nsk, sk_w, opt_lim, sk_lim, nt, ns = m
        nfiles += 1
        over_opt = [o for o in opts if o > opt_lim]
        over_sk = [x for x in sk_w if x > sk_lim]
        over_memo = max(memo_w) > memo_lim
        flag = 'ok  ' if (w <= limit and not over_opt and recap <= 6 and not over_memo
                          and not over_sk and nsk <= 6) else 'OVER'
        bad_turn += w > limit
        bad_aux += bool(over_opt) or recap > 6 or over_memo or bool(over_sk) or nsk > 6
        scope = '' if nt <= 1 else f' | {nt} turns graded' + (f' ({ns} produced nothing)' if ns else '')
        print(f'  {flag}  {w:4d} turn words (limit {limit}){scope} | {len(opts)} options'
              f'{", longest " + str(max(opts)) if opts else ""} | {recap} recap bullets'
              f'{f" | {nsk} sketch lines" if nsk else ""}'
              f'{" | memo max item " + str(max(memo_w)) + "w (limit " + str(memo_lim) + ")" if memo_w else ""}'
              f'{"  <-- " + ",".join(str(o) for o in over_opt) + "-word options" if over_opt else ""}'
              f'{"  <-- recap > 6" if recap > 6 else ""}'
              f'{"  <-- " + ",".join(str(x) + "w" for x in over_sk) + " over sketch_words " + str(sk_lim) if over_sk else ""}'
              f'{"  <-- sketch > 6 lines" if nsk > 6 else ""}'
              f'{"  <-- memo over " + str(memo_lim) + "w" if over_memo else ""}  <- {f.split("/")[-1]}')
    # exit: 0 clean | 1 turn cap | 2 an appendix limit (options, recap count, sketch length or count,
    # memo item) | 3 both | 64 NOTHING GRADED
    # so the caller can say which instrument rang, instead of reporting a turn overrun when the options
    # were too long - and, newly, instead of reporting 0 when every file was skipped. A run where nothing
    # was readable is not a clean run; the two used to share the byte.
    if nfiles == 0:
        sys.exit(hm.NOT_GRADED)
    sys.exit((1 if bad_turn else 0) | (2 if bad_aux else 0))
