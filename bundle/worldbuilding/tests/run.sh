#!/usr/bin/env bash
# Headless skill-run harness.  Dev fixture: never copied into a writer's project.
# usage: bash tests/run.sh <scenario-id> <control|skill>
set -uo pipefail
export PYTHONDONTWRITEBYTECODE=1  # the suite imports these modules; a .pyc under bundle/ is shipped debris
HERE="$(cd "$(dirname "$0")" && pwd)"; REPO="$(cd "$HERE/../../.." && pwd)"; BUNDLE="$HERE/.."
SCEN="$1"; VAR="${2:-control}"; WORK="$(mktemp -d)"; FAKEHOME="$(mktemp -d)"
mkdir -p "$FAKEHOME/.pi/agent"
ln -s "$HOME/.pi/agent/models.json" "$FAKEHOME/.pi/agent/models.json" 2>/dev/null
printf '{}' > "$FAKEHOME/.pi/agent/settings.json"
trap 'rm -rf "$WORK" "$FAKEHOME" "$VDT"' EXIT
case "$SCEN" in
  established|continue-established|stale-index|tone-sarcasm|reaction-mode|pressure-wrapup|review|review-owed)
    cp -R "$HERE/fixtures/established/." "$WORK/" ;;
  continue-empty|new-world|you-pick) : ;;    # empty project dir (new-world: nothing to read yet)
  home-dir) : ;;                             # non-project dir == the refuse-to-scaffold predicate
esac
[ "$SCEN" = stale-index ] && rm -f "$WORK/world/index.md"
# only scenarios that started from the fixture have a "present at the start" witness; a run that began
# in an empty dir would otherwise report every fixture file as deleted
ORIG=""; case "$SCEN" in
  established|continue-established|stale-index|tone-sarcasm|reaction-mode|pressure-wrapup|review|review-owed)
    ORIG="$HERE/fixtures/established" ;;
esac
CLEAN=(env -u PI_API_KEY -u PI_SESSION_ID -u PI_SESSION_FILE -u PI_CODING_AGENT -u PI_MODEL -u PI_PROVIDER -u PI_REASONING_LEVEL HOME="$FAKEHOME")
args=(--no-extensions --no-skills --no-session)
[ "$VAR" = skill ] && if [ "$SCEN" = home-dir ]; then args+=(--skill "$REPO/kit"); else args+=(--skill "$REPO/bundle/worldbuilding"); fi
RUN_TIMEOUT="${RUN_TIMEOUT:-900}"
guidance_key(){
  # Hash the WORKING TREE contents of what the model reads - not git's committed copy. Evidence
  # produced against uncommitted guidance used to carry the pre-edit key, which made "graded against
  # the current build" false on every dirty step (that is: all of them). Locates the bundle from this
  # script's own path, so it must not depend on $B / $BUNDLE being defined by the caller.
  local d; d=$(cd "$(dirname "$0")/.." && pwd)
  { cat "$d/SKILL.md" 2>/dev/null; cat "$d"/references/*.md 2>/dev/null; cat "$d"/assets/*.md 2>/dev/null; } \
    | cksum | awk '{printf "%08x", $1}'
}
VDT="$(mktemp)"   # verdicts stay out of the artifact until it is closed
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"; OUT="$REPO/evidence/$SCEN-$VAR-$STAMP.md"; mkdir -p "$REPO/evidence"
# provenance: which build produced this verdict. Without it, behavior() grades a pile of eras and
# a stale transcript can pass or fail for reasons the current code no longer has.
COMMIT="$(git -C "$REPO" rev-parse --short HEAD 2>/dev/null || echo unknown)"
[ -n "$(git -C "$REPO" status --porcelain 2>/dev/null)" ] && COMMIT="$COMMIT+dirty"
BHASH="$(guidance_key)"
SPECREV="$(grep -ohE '^\*\*R-[0-9]+' "$REPO"/docs/superpowers/specs/*-design.md 2>/dev/null | tail -1 | tr -d '*')"
WPT=$(awk '/words_per_turn/{gsub(/[^0-9]/,"",$2); print $2; exit}' "$BUNDLE/assets/index-template.md" 2>/dev/null)
CAD=$(awk '/texture_cadence/{gsub(/[^0-9]/,"",$2); print $2; exit}' "$BUNDLE/assets/index-template.md" 2>/dev/null)
RPT=$(awk '/reads_per_turn/{gsub(/[^0-9]/,"",$2); print $2; exit}' "$BUNDLE/assets/index-template.md" 2>/dev/null)
LIMITS="words_per_turn=${WPT:-?} texture_cadence=${CAD:-?} reads_per_turn=${RPT:-?}"
LABEL="commit=${COMMIT} guidance=${BHASH} spec_rev=${SPECREV:-R-0} ${LIMITS}"
{ echo "# $SCEN ($VAR) $STAMP"; echo "cwd: $WORK"; echo "label: $LABEL"
  # review-owed uses the ordinary continue prompt on purpose: nothing asks for a review, so the only
  # way it appears is the trigger firing - which is the half of I5 that "review" cannot test
  PROMPT="$HERE/prompts/$SCEN.txt"
  [ "$SCEN" = review-owed ] && PROMPT="$HERE/prompts/continue-established.txt"
  echo "## prompt"; cat "$PROMPT"
  echo "## transcript"; ( cd "$WORK" && "${CLEAN[@]}" timeout "$RUN_TIMEOUT" pi "${args[@]}" -p "$(cat "$PROMPT")" ); RC=$?
  echo "## pi exit status: $RC"
  TL=$(sed -n '/## transcript/,/## files after run/p' "$OUT" | wc -l)
  [ "$RC" = 0 ] || echo "INFRA-FAIL: pi exited nonzero (rc=$RC, timeout ${RUN_TIMEOUT}s)"
  [ "$TL" -gt 3 ] || echo "INFRA-FAIL: empty transcript ($TL lines)"
  echo "## files after run"; ( cd "$WORK" && find . -path ./.git -prune -o -type f -print | sort )
    echo "## world/ contents"; ( cd "$WORK" && for f in $(find . -path "*world*" -name "*.md" -type f | sort); do echo "--- $f"; head -c 2500 "$f"; echo; done )
} > "$OUT" 2>&1

# Verdicts are computed after the artifact is closed, then appended in one reserved section. They used
# to be echoed inside the same stream the graders read, so reviewcheck could encounter the string
# 'provoked: review' inside this script's own failure line - substring-matched as INFRA-FAIL that fakes
# an aborted run, and as the bit-4 test it erases a finding on any re-grade. Nothing a grader reads is
# written by a grader now.
{
  TL=$(sed -n '/## transcript/,/## files after run/p' "$OUT" | wc -l)
  [ "$RC" = 0 ] || echo "INFRA-FAIL: pi exited nonzero (rc=$RC, timeout ${RUN_TIMEOUT}s)"
  [ "$TL" -gt 3 ] || echo "INFRA-FAIL: empty transcript ($TL lines)"
if [ -n "$ORIG" ]; then
    python3 "$HERE/canoncheck.py" --dir "$WORK" --fixture "$ORIG" --transcript "$OUT"
  else
    python3 "$HERE/canoncheck.py" --dir "$WORK" --transcript "$OUT"
  fi
  # I5: the review contract - five memo items if asked, and the trigger if not
  case "$SCEN" in
    review|review-owed)
      python3 "$HERE/reviewcheck.py" --evidence "$OUT" --log "$WORK/world/log.md"
      RRC=$?
      [ "$RRC" = 128 ] && echo "INFRA-FAIL: reviewcheck crashed"
      [ $((RRC & 64)) != 0 ] && echo "NOT-GRADED: reviewcheck could not examine the artifact (rc=$RRC)"
      [ $((RRC & 7)) != 0 ] && echo "REVIEW-FAIL: rc=$RRC (1 owed-not-delivered, 2 memo incomplete, 3 not logged)"
      ;;
  esac

  # I4: a `new` run must leave a seeded world, not a chat message describing one
  if [ "$SCEN" = new-world ]; then
    if [ -d "$WORK/world" ]; then
      python3 "$HERE/seedcheck.py" "$WORK/world"; SR=$?
      [ "$SR" = 128 ] && echo "INFRA-FAIL: seedcheck crashed"
      [ $((SR & 15)) != 0 ] && echo "SEED-FAIL: rc=$SR (1 count, 2 spread/texture, 4 premature canon, 8 threads)"
    else
      echo "SEED-FAIL: no world/ was scaffolded - the run stayed in conversation"
    fi
  fi

  grep -q "/home/septesix" "$OUT" && echo "  note: run referenced an absolute home path (expected for kit runs)"
} > "$VDT" 2>&1

{ echo; echo "## harness verdicts"; cat "$VDT"; } >> "$OUT"

# exit contract: 0 usable run | 1 contaminated | 2 infrastructure failure | 3 both.
# INFRA is decided from the typed values the run produced, never by grepping for a word this script prints.
INFRA=0
[ "$RC" = 0 ] || INFRA=2
[ "$(sed -n '/## transcript/,/## files after run/p' "$OUT" | wc -l)" -gt 3 ] || INFRA=2
[ "$INFRA" = 2 ] && echo "INFRA-FAIL -> $OUT"
# parent-context markers only: bare paths are not a leak, since a kit run necessarily names the repo
CONT=0; grep -qiE 'SDD ledger|gate-report|Ruling [0-9]|progress\.md|worldbuilding-kit/(docs|kit|bundle)' "$OUT" && CONT=1
[ "$INFRA" = 0 ] && [ "$CONT" = 0 ] && echo "clean -> $OUT"
[ "$INFRA" = 2 ] && [ "$CONT" = 1 ] && exit 3
exit $((INFRA + CONT))