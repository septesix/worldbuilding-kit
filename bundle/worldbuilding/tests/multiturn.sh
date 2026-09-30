#!/usr/bin/env bash
# Multi-turn scenario harness: N real turns against ONE world directory and ONE session, so the
# invariants that need history (texture cadence, no three consecutive same-type turns, lopsidedness,
# entity reads per turn) can actually be observed. A fabricated transcript cannot test them - that is
# how five pinned invariants ended up untestable (gate finding I8).
#
#   bash tests/multiturn.sh <scenario> <skill|control> [turns]
#   TURN_TIMEOUT=600 bash tests/multiturn.sh cadence skill 5
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; REPO="$(cd "$HERE/../../.." && pwd)"; BUNDLE="$HERE/.."
SCEN="${1:?scenario}"; VAR="${2:-skill}"; N="${3:-4}"
TURN_TIMEOUT="${TURN_TIMEOUT:-600}"
FIX="$HERE/fixtures/established"; TL="$HERE/prompts/$SCEN-turns.txt"
[ -f "$TL" ] || { echo "INFRA-FAIL: no turn script $TL"; exit 2; }
mapfile -t TURNS < "$TL"
[ "${#TURNS[@]}" -ge "$N" ] || { echo "INFRA-FAIL: turn script has ${#TURNS[@]} lines, asked for $N"; exit 2; }

WORK="$(mktemp -d)"; FAKEHOME="$(mktemp -d)"; SESS="$(mktemp -d)"
trap 'rm -rf "$WORK" "$FAKEHOME" "$SESS"' EXIT
mkdir -p "$FAKEHOME/.pi/agent"
ln -s "$HOME/.pi/agent/models.json" "$FAKEHOME/.pi/agent/models.json" 2>/dev/null
printf '{}' > "$FAKEHOME/.pi/agent/settings.json"
cp -R "$FIX/." "$WORK/"
SID="$(cat /proc/sys/kernel/random/uuid)"

args=(--no-extensions --no-skills)
[ "$VAR" = skill ] && args+=(--skill "$BUNDLE")
CLEAN=(env -u PI_SESSION_ID -u PI_SESSION_FILE -u PI_CODING_AGENT -u PI_MODEL -u PI_PROVIDER -u PI_REASONING_LEVEL -u PI_API_KEY HOME="$FAKEHOME")

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"; OUT="$REPO/evidence/$SCEN-$VAR-multi-$STAMP.md"; mkdir -p "$REPO/evidence"
COMMIT="$(git -C "$REPO" rev-parse --short HEAD 2>/dev/null || echo unknown)"
[ -n "$(git -C "$REPO" status --porcelain 2>/dev/null)" ] && COMMIT="$COMMIT+dirty"
# keyed to the bundle's tree, not the repo HEAD: a docs-only commit must not void behavioral evidence
BHASH="$(git -C "$REPO" rev-parse "HEAD:bundle" 2>/dev/null | cut -c1-8)"
WPT=$(awk '/words_per_turn/{gsub(/[^0-9]/,"",$2); print $2; exit}' "$BUNDLE/assets/index-template.md")
CAD=$(awk '/texture_cadence/{gsub(/[^0-9]/,"",$2); print $2; exit}' "$BUNDLE/assets/index-template.md")

{ echo "# $SCEN ($VAR) MULTI-TURN $STAMP"
  echo "label: commit=$COMMIT bundle=$BHASH spec_rev=$(grep -ohE '^\*\*R-[0-9]+' "$REPO"/docs/superpowers/specs/*-design.md | tail -1 | tr -d '*') words_per_turn=${WPT:-?} texture_cadence=${CAD:-?}"
  echo "cwd: $WORK"; echo "turns: $N"
  for i in $(seq 0 $((N - 1))); do
    echo "## turn $((i + 1))"
    echo "writer: ${TURNS[$i]}"
    ( cd "$WORK" && "${CLEAN[@]}" timeout "$TURN_TIMEOUT" pi "${args[@]}" --session-dir "$SESS" --session-id "$SID" -p "${TURNS[$i]}" ) \
      || echo "INFRA-FAIL: turn $((i + 1)) exited nonzero or timed out"
    echo
  done
  echo "## files after run"; ( cd "$WORK" && find . -path ./.git -prune -o -type f -print | sort )
  echo "## world/ contents"; ( cd "$WORK" && for f in $(find . -path '*world*' -name '*.md' -type f | sort); do echo "--- ./$f"; head -c 3000 "$f"; echo; done )
  echo "## session log"; S=$(find "$SESS" -name '*.jsonl' | head -1)
  if [ -n "$S" ]; then cp "$S" "$OUT.session.jsonl"; echo "copied: $(basename "$OUT").session.jsonl ($(wc -l < "$OUT.session.jsonl") records)"; else echo "MISSING: no session log written"; fi
} > "$OUT" 2>&1

CONT=0
INFRA=0; grep -q 'INFRA-FAIL\|MISSING: no session' "$OUT" && { INFRA=1; echo "INFRA-FAIL -> $OUT"; }
grep -qiE "SDD ledger|gate-report|Ruling [0-9]|progress\.md" "$OUT" && { CONT=1; echo "CONTAMINATED -> $OUT"; }
[ "$INFRA" = 0 ] && echo "clean -> $OUT"
exit $((INFRA + CONT))
