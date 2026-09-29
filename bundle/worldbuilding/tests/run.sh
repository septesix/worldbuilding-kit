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
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"; OUT="$REPO/evidence/$SCEN-$VAR-$STAMP.md"; mkdir -p "$REPO/evidence"
{ echo "# $SCEN ($VAR) $STAMP"; echo "cwd: $WORK"; echo "## prompt"; cat "$HERE/prompts/$SCEN.txt"
  echo "## transcript"; ( cd "$WORK" && "${CLEAN[@]}" timeout 600 pi "${args[@]}" -p "$(cat "$HERE/prompts/$SCEN.txt")" ) || echo "INFRA-FAIL: pi exited nonzero"
  [ "$(sed -n '/## transcript/,/## files after run/p' "$OUT" | wc -l)" -gt 3 ] || echo "INFRA-FAIL: empty transcript"
  echo "## files after run"; ( cd "$WORK" && find . -path ./.git -prune -o -type f -print | sort )
  echo "## world/ contents"; ( cd "$WORK" && for f in $(find . -path "*world*" -name "*.md" -type f | sort); do echo "--- $f"; head -c 2500 "$f"; echo; done )
} > "$OUT" 2>&1
grep -qiE 'SDD|worldbuilding-kit|superpowers|/home/septesix' "$OUT" && echo "CONTAMINATED (parent context present in run) -> $OUT" || echo "clean -> $OUT"
