#!/usr/bin/env bash
# Headless skill-run harness.  Dev fixture: never copied into a writer's project.
# usage: bash tests/run.sh <scenario-id> <control|skill>
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; REPO="$(cd "$HERE/../../.." && pwd)"
SCEN="$1"; VAR="${2:-control}"; WORK="$(mktemp -d)"; FAKEHOME="$(mktemp -d)"
mkdir -p "$FAKEHOME/.pi/agent"
ln -s "$HOME/.pi/agent/models.json" "$FAKEHOME/.pi/agent/models.json" 2>/dev/null
printf '{}' > "$FAKEHOME/.pi/agent/settings.json"
trap 'rm -rf "$WORK" "$FAKEHOME"' EXIT
case "$SCEN" in
  established|continue-established|stale-index|tone-sarcasm|reaction-mode|pressure-wrapup)
    cp -R "$HERE/fixtures/established/." "$WORK/" ;;
  continue-empty) : ;;                       # empty project dir
  home-dir) : ;;                             # non-project dir == the refuse-to-scaffold predicate
esac
[ "$SCEN" = stale-index ] && rm -f "$WORK/world/index.md"
CLEAN=(env -u PI_API_KEY -u PI_SESSION_ID -u PI_SESSION_FILE -u PI_CODING_AGENT -u PI_MODEL -u PI_PROVIDER -u PI_REASONING_LEVEL HOME="$FAKEHOME")
args=(--no-extensions --no-skills --no-session)
[ "$VAR" = skill ] && args+=(--skill "$REPO/bundle/worldbuilding")
RUN_TIMEOUT="${RUN_TIMEOUT:-900}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"; OUT="$REPO/evidence/$SCEN-$VAR-$STAMP.md"; mkdir -p "$REPO/evidence"
{ echo "# $SCEN ($VAR) $STAMP"; echo "cwd: $WORK"; echo "## prompt"; cat "$HERE/prompts/$SCEN.txt"
  echo "## transcript"; ( cd "$WORK" && "${CLEAN[@]}" timeout "$RUN_TIMEOUT" pi "${args[@]}" -p "$(cat "$HERE/prompts/$SCEN.txt")" ); RC=$?
  echo "## pi exit status: $RC"
  TL=$(sed -n '/## transcript/,/## files after run/p' "$OUT" | wc -l)
  [ "$RC" = 0 ] || echo "INFRA-FAIL: pi exited nonzero (rc=$RC, timeout ${RUN_TIMEOUT}s)"
  [ "$TL" -gt 3 ] || echo "INFRA-FAIL: empty transcript ($TL lines)"
  echo "## files after run"; ( cd "$WORK" && find . -path ./.git -prune -o -type f -print | sort )
  echo "## world/ contents"; ( cd "$WORK" && for f in $(find . -path "*world*" -name "*.md" -type f | sort); do echo "--- $f"; head -c 2500 "$f"; echo; done )
} > "$OUT" 2>&1
# exit contract: 0 usable run | 1 contaminated | 2 infrastructure failure | 3 both
INFRA=0; grep -q 'INFRA-FAIL' "$OUT" && { INFRA=2; echo "INFRA-FAIL -> $OUT"; }
CONT=0; grep -qiE 'SDD|worldbuilding-kit|superpowers|/home/septesix' "$OUT" && { CONT=1; echo "CONTAMINATED -> $OUT"; }
[ "$INFRA" = 0 ] && [ "$CONT" = 0 ] && echo "clean -> $OUT"
[ "$INFRA" = 2 ] && [ "$CONT" = 1 ] && exit 3
exit $((INFRA + CONT))
