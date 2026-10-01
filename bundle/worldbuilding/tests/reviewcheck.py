#!/usr/bin/env python3
"""Review-mode contract (I5): the memo is five items, and the trigger is arithmetic on log.md.

  reviewcheck.py --evidence <file> [--log <world/log.md>] [--threshold 3]

Read the log from the world itself when you can. The first version read session counts out of the
evidence file, and run.sh called it before the `## world/ contents` dump had been appended - so it saw
zero sessions and announced "no review owed" about a world that had five. An instrument that grades a
half-written artifact reports a pass it did not earn.

The threshold is spec's constant, not a tunable: `world/index.md` deliberately carries no review_after
key, so there is no writer-editable number for the tool to drift away from. Override with --threshold
when testing; a future revision that makes it editable should route it through the same read as
option_words.

Exit bitmask:
  1   a review was owed (>= threshold sessions since the last `provoked: review`) and not delivered
  2   a review was delivered but the memo is incomplete - five named items, each answered
  4   a review was delivered but never logged as `provoked: review`, so the next session reviews again
  128 instrument crash, never a finding

Sessions are counted as `## <date> (session N)` headers after the last line carrying
`provoked: review`; that type is one of the eight the machine line already records, so the trigger
needs no new state. If the log has never carried `provoked: review`, the count is every session in the
file - which is the honest reading of "since the last one" when there was none.
"""
import sys, os, re, argparse

ITEMS = {
    'contradictions': r'contradiction',
    'orphans': r'orphan',
    'texture-less pillars': r'texture-less|pillars? with no texture|no texture',
    'unvetted proposed:': r'unvetted|proposed',
    'treadmill': r'treadmill|provoked.{0,18}distribution|one type',
}
# the run that proved this list was too narrow delivered '**Memo** (review owed, sessions 1-4):' and my
# detector called it 'none delivered' - a false red on the best memo in the archive. Match the artifact,
# not one spelling of its heading.
REVIEW_DONE = re.compile(r'provoked: review|consistency memo|\*\*\s*(review|memo)\b|review owed', re.I)
SESSION = re.compile(r'^##\s+\d{4}-\d\d-\d\d.*session', re.M)


def sessions_since_review(text):
    lines = text.split('\n')
    last = max((i for i, l in enumerate(lines) if 'provoked: review' in l), default=-1)
    return len(SESSION.findall("\n".join(lines[last + 1:])))


def memo_items(text):
    """Which of the five items are actually answered anywhere in the transcript."""
    missing = [name for name, pat in ITEMS.items() if not re.search(pat, text, re.I)]
    return missing


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--evidence', required=True)
    ap.add_argument('--log')
    ap.add_argument('--threshold', type=int, default=3)
    a = ap.parse_args()
    try:
        t = open(a.evidence, encoding='utf-8', errors='replace').read()
        # the log is authoritative for session counts; the evidence dump is a convenience copy of it
        lt = open(a.log, encoding='utf-8', errors='replace').read() if a.log and os.path.exists(a.log) else t
        gap = sessions_since_review(lt)
        if 'INFRA-FAIL' in t:
            print('  NOT-GRADED: the run recorded an infrastructure failure - not evidence either way')
            sys.exit(4)
        if lt == t and '## 2026-' not in t:
            print('  NOT-GRADED: no session headers visible - the log was not in the artifact')
            sys.exit(4)
        done = bool(REVIEW_DONE.search(t))
        rc = 0
        if not done and gap >= a.threshold:
            print(f'  REVIEW-OWED: {gap} sessions since the last review (threshold {a.threshold}) '
                  f'and none delivered')
            rc |= 1
        if done:
            missing = memo_items(t)
            if missing:
                print(f'  REVIEW-FAIL: memo missing {len(missing)} of 5 items: {", ".join(missing)}')
                rc |= 2
            else:
                print(f'  review delivered, memo complete (5 items) | {gap} sessions since last review')
                if 'provoked: review' not in t:
                    print('  REVIEW-FAIL: the review was never logged as provoked: review - the trigger '
                          'cannot reset, so next session reviews again')
                    rc |= 4
        if rc == 0 and not done:
            print(f'  no review owed ({gap} of {a.threshold} sessions) - not scored as a pass or a fail')
        sys.exit(rc)
    except Exception as e:
        print(f'  INSTRUMENT-ERROR {type(e).__name__}: {e}'); sys.exit(128)
