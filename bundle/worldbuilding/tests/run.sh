#!/usr/bin/env bash
# Headless skill-run harness.  Dev fixture: never copied into a writer's project.
# usage: bash tests/run.sh <scenario-id> <control|skill>
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; REPO="$(cd "$HERE/../../.." && pwd)"; BUNDLE="$HERE/.."
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
[ "$VAR" = skill ] && if [ "$SCEN" = home-dir ]; then args+=(--skill "$REPO/kit"); else args+=(--skill "$REPO/bundle/worldbuilding"); fi
RUN_TIMEOUT="${RUN_TIMEOUT:-900}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"; OUT="$REPO/evidence/$SCEN-$VAR-$STAMP.md"; mkdir -p "$REPO/evidence"
# provenance: which build produced this verdict. Without it, behavior() grades a pile of eras and
# a stale transcript can pass or fail for reasons the current code no longer has.
COMMIT="$(git -C "$REPO" rev-parse --short HEAD 2>/dev/null || echo unknown)"
[ -n "$(git -C "$REPO" status --porcelain 2>/dev/null)" ] && COMMIT="$COMMIT+dirty"
SPECREV="$(grep -ohE '^\*\*R-[0-9]+' "$REPO"/docs/superpowers/specs/*-design.md 2>/dev/null | tail -1 | tr -d '*')"
WPT=$(awk '/words_per_turn/{gsub(/[^0-9]/,"",$2); print $2; exit}' "$BUNDLE/assets/index-template.md" 2>/dev/null)
CAD=$(awk '/texture_cadence/{gsub(/[^0-9]/,"",$2); print $2; exit}' "$BUNDLE/assets/index-template.md" 2>/dev/null)
LIMITS="words_per_turn=${WPT:-?} texture_cadence=${CAD:-?}"
LABEL="commit=${COMMIT} spec_rev=${SPECREV:-R-0} ${LIMITS}"
{ echo "# $SCEN ($VAR) $STAMP"; echo "cwd: $WORK"; echo "label: $LABEL"
  echo "## prompt"; cat "$HERE/prompts/$SCEN.txt"
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
# parent-context markers only. Bare paths are NOT evidence of a leak: a kit run necessarily names
# the repo (that is where the bundle lives), and a run may legitimately `ls` its own home.
CONT=0; grep -qiE 'SDD ledger|gate-report|Ruling [0-9]|progress\.md|worldbuilding-kit/(docs|kit|bundle)|exposeSessionEnvironment' "$OUT" && { CONT=1; echo "CONTAMINATED -> $OUT"; }
grep -q "/home/septesix" "$OUT" && echo "  note: run referenced an absolute home path (expected for kit runs; verify by hand)"
[ "$INFRA" = 0 ] && [ "$CONT" = 0 ] && echo "clean -> $OUT"
[ "$INFRA" = 2 ] && [ "$CONT" = 1 ] && exit 3
exit $((INFRA + CONT))
