#!/usr/bin/env bash
# Multi-turn scenario harness: N real turns against ONE world directory and ONE session, so the
# invariants that need history (texture cadence, no three consecutive same-type turns, lopsidedness,
# entity reads per turn) can actually be observed. A fabricated transcript cannot test them - that is
# how five pinned invariants ended up untestable (gate finding I8).
#
#   bash tests/multiturn.sh <scenario> <skill|control> [turns]
#   TURN_TIMEOUT=600 bash tests/multiturn.sh cadence skill 5
set -uo pipefail
export PYTHONDONTWRITEBYTECODE=1  # the suite imports these modules; a .pyc under bundle/ is shipped debris
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
# Passing a brand-new --session-id makes pi print "No project session found ... creating" and it has
# been seen to consume the turn with no assistant text at all - an eaten turn then looks like a
# 0-question violation of the turn contract. Turn 1 creates the session; later turns name the file.
SID=""
TURNFAIL=""   # turns whose pi call failed - a typed fact, not a string to grep later

args=(--no-extensions --no-skills)
[ "$VAR" = skill ] && args+=(--skill "$BUNDLE")
CLEAN=(env -u PI_SESSION_ID -u PI_SESSION_FILE -u PI_CODING_AGENT -u PI_MODEL -u PI_PROVIDER -u PI_REASONING_LEVEL -u PI_API_KEY HOME="$FAKEHOME")

EMPTY=""
guidance_key(){
  # Hash the WORKING TREE contents of what the model reads - not git's committed copy. Evidence
  # produced against uncommitted guidance used to carry the pre-edit key, which made "graded against
  # the current build" false on every dirty step (that is: all of them). Locates the bundle from this
  # script's own path, so it must not depend on $B / $BUNDLE being defined by the caller.
  local d; d=$(cd "$(dirname "$0")/.." && pwd)
  { cat "$d/SKILL.md" 2>/dev/null; cat "$d"/references/*.md 2>/dev/null; cat "$d"/assets/*.md 2>/dev/null; } \
    | cksum | awk '{printf "%08x", $1}'
}
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"; OUT="$REPO/evidence/$SCEN-$VAR-multi-$STAMP.md"; mkdir -p "$REPO/evidence"
COMMIT="$(git -C "$REPO" rev-parse --short HEAD 2>/dev/null || echo unknown)"
[ -n "$(git -C "$REPO" status --porcelain 2>/dev/null)" ] && COMMIT="$COMMIT+dirty"
# keyed to the bundle's tree, not the repo HEAD: a docs-only commit must not void behavioral evidence
BHASH="$(guidance_key)"
WPT=$(awk '/words_per_turn:/{gsub(/[^0-9]/,"",$2); print $2; exit}' "$BUNDLE/assets/index-template.md")
CAD=$(awk '/texture_cadence:/{gsub(/[^0-9]/,"",$2); print $2; exit}' "$BUNDLE/assets/index-template.md" 2>/dev/null)
RPT=$(awk '/reads_per_turn:/{gsub(/[^0-9]/,"",$2); print $2; exit}' "$BUNDLE/assets/index-template.md" 2>/dev/null)

{ echo "# $SCEN ($VAR) MULTI-TURN $STAMP"
  echo "label: commit=$COMMIT guidance=$BHASH spec_rev=$(grep -ohE '^\*\*R-[0-9]+' "$REPO"/docs/superpowers/specs/*-design.md | tail -1 | tr -d '*') words_per_turn=${WPT:-?} texture_cadence=${CAD:-?} reads_per_turn=${RPT:-?}"
  echo "cwd: $WORK"; echo "turns: $N"
  SEEN="$WORK.seen"; : > "$SEEN"      # every encyclopedia path observed at any point in the run
  for i in $(seq 0 $((N - 1))); do
    echo "## turn $((i + 1))"
    echo "writer: ${TURNS[$i]}"
    sidargs=(); [ -n "$SID" ] && sidargs=(--session "$SID")
    TOUT="$SESS/turn$((i + 1)).txt"
    ( cd "$WORK" && "${CLEAN[@]}" timeout "$TURN_TIMEOUT" pi "${args[@]}" --session-dir "$SESS" "${sidargs[@]}" -p "${TURNS[$i]}" ) > "$TOUT" 2>&1 \
      || { TURNFAIL="$TURNFAIL $((i + 1))"; echo "INFRA-FAIL: turn $((i + 1)) exited nonzero or timed out"; }
    [ -z "$SID" ] && SID=$(find "$SESS" -name '*.jsonl' | head -1)
    cat "$TOUT"
    # text the writer would actually read - excludes the scripted reply and pi's own notices.
    # A turn with none was eaten by the harness; scoring it as "0 questions" once blamed the skill
    # for a session-priming bug, so emptiness is instrument failure, never evidence.
    tw=$(grep -vE '^(writer:|Warning:|INFRA-FAIL:)' "$TOUT" | wc -w)
    [ "$tw" -le 1 ] && EMPTY="$EMPTY $((i + 1))"
    ( cd "$WORK" && find world/encyclopedia -name '*.md' 2>/dev/null ) >> "$SEEN"
    echo
  done
  echo "## files after run"; ( cd "$WORK" && find . -path ./.git -prune -o -type f -print | sort )
  # append-only canon at the file level (F6). The old loop compared only against the fixture, so the
  # retcon runs could `rm encyclopedia/lighthouse-place.md` - a file created earlier in the same
  # session - and the canon counts stayed green. Three witnesses now: start state, ever-seen, tool calls.
  # canoncheck runs after this artifact closes - note below the block
  echo "## encyclopedia files seen"; sort -u "$SEEN"
  [ -n "${EMPTY:-}" ] && echo "INFRA-FAIL: no assistant text in turn(s)$EMPTY - session/launch issue, not a contract breach"
  echo "## canon counts"
  echo "# file\testablished\tproposed\trevised\tsupersedes"
  python3 "$HERE/scoreboard.py" "$FIX/world" --counts | tail -n +2 | sed 's/^/fixture\t/'
  python3 "$HERE/scoreboard.py" "$WORK/world" --counts | tail -n +2 | sed 's/^/produced\t/'
  echo "## world/ contents"; ( cd "$WORK" && for f in $(find . -path '*world*' -name '*.md' -type f | sort); do echo "--- $f"; head -c 3000 "$f"; echo; done )
  echo "## session log"; S=$(find "$SESS" -name '*.jsonl' | head -1)
  if [ -n "$S" ]; then cp "$S" "$OUT.session.jsonl"; echo "copied: $(basename "$OUT").session.jsonl ($(wc -l < "$OUT.session.jsonl") records)"; else echo "MISSING: no session log written"; fi
} > "$OUT" 2>&1

# Graders run against a closed artifact and their output lands in one reserved section. The CANON-LOSS
# verdict used to be echoed into the stream and read back out of the same file by this script's own grep,
# which is a verdict citing itself as a fact about the run.
VDT="$(mktemp)"; CCRC=0
python3 "$HERE/canoncheck.py" --dir "$WORK" --fixture "$FIX" --seen "$SEEN" --transcript "$SESS" >"$VDT" 2>&1 || CCRC=$?
# canoncheck's own lines already say WHICH witness fired, and they are in $VDT; this used to assert
# "file count went down" for any rc=1, which is how a text witness began a sentence about the count
[ "$CCRC" = 64 ] && echo "NOT-GRADED: canoncheck could not examine the run (rc=64)" >>"$VDT"
{ echo; echo "## harness verdicts"; cat "$VDT"; } >> "$OUT"

CONT=0
# Decided from typed state, not by grepping the artifact. The old test searched the file for INFRA-FAIL
# (a string this script writes from several places) and for MISSING: no session, which the session-log
# branch does emit - so both facts now arrive as variables instead of as prose to pattern-match.
INFRA=0
[ -z "${TURNFAIL:-}" ] || INFRA=1
[ -z "${EMPTY:-}" ] || INFRA=1
ls "$SESS"/*.jsonl >/dev/null 2>&1 || INFRA=1
[ "$INFRA" = 1 ] && echo "INFRA-FAIL -> $OUT"
grep -qiE "SDD ledger|gate-report|Ruling [0-9]|progress\.md" "$OUT" && { CONT=1; echo "CONTAMINATED -> $OUT"; }
[ "$INFRA" = 0 ] && echo "clean -> $OUT"
CANONLOST=0; grep -q '^CANON-LOSS' "$OUT" && { CANONLOST=4; echo "CANON-LOSS (append-only breached) -> $OUT"; }
exit $((INFRA + CONT + CANONLOST))
