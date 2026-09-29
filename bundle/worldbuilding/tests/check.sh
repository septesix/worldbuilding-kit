#!/usr/bin/env bash
# Mechanically checkable assertions for the worldbuilding skill. Dev fixture only.
# usage: bash tests/check.sh <harness|templates|rubric|voice|method|kit|selftest|all>
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; REPO="$(cd "$HERE/../../.." && pwd)"
B="$REPO/bundle/worldbuilding"; PASS=0; FAIL=0
ok(){ printf '  ok   %s\n' "$1"; PASS=$((PASS+1)); }
no(){ printf '  FAIL %s\n' "$1"; FAIL=$((FAIL+1)); }
# ck <actual> <expected> <label> - exact equality, for counts that ARE the invariant
ck(){ if [ "$1" = "$2" ]; then ok "$3"; else no "$3 (got $1, want $2)"; fi; }
# has <label> <file> <ERE> - presence, for rules that only need to appear somewhere
has(){ if grep -qE "$3" "$2" 2>/dev/null; then ok "$1"; else no "$1"; fi; }
newest(){ ls -1t "$REPO"/evidence/"$1"-*.md 2>/dev/null | head -1; }

harness(){
  # capture integrity + contamination only. The "baseline ignores the files" assertion was
  # dropped: clean-context runs READ and WROTE the encyclopedia correctly (evidence/BASELINE.md).
  local e; e="$(newest continue-established)"; [ -n "$e" ] || { no "no control evidence; run tests/run.sh continue-established control"; return; }
  local n; n=$(awk '/## transcript/,/## files after run/' "$e" | wc -l); [ "$n" -gt 4 ] && ok "transcript captured ($n lines)" || no "transcript empty ($n lines) - infra failure"
  grep -q 'lockkeepers-daughter\|## files after run' "$e" && ok "file listing captured" || no "file listing missing"
  grep -qiE 'SDD ledger|worldbuilding-kit/|superpowers|pi/agent/skills' "$e" && no "CONTAMINATED: parent context reached the control run" || ok "control context clean"
  grep -q 'superseded-by:\|proposed:' "$e" && ok "baseline already uses provenance (F: no guidance needed)" || echo "  note  provenance absent from this transcript"
}

templates(){
  local T="$B/assets"
  for f in index-template entity-template threads-template; do
    [ -f "$T/$f.md" ] && ok "$f.md exists" || no "$f.md missing"
  done
  [ -f "$T/index-template.md" ] || return
  # canonical pillar keys: the template is the single source of truth
  pil(){ awk '/^## Pillar coverage/{f=1;next} /^## /{f=0} f && /^\| [a-z-]+ /{gsub(/ /,"",$2); print $2}' "$1" | sort -u; }
  pil "$T/index-template.md" > /tmp/p.t
  pil "$B/tests/fixtures/established/world/index.md" > /tmp/p.f
  diff -q /tmp/p.t /tmp/p.f >/dev/null && ok "fixture pillar rows == template rows (18)" || no "pillar vocabularies drift: $(comm -3 /tmp/p.t /tmp/p.f | tr '\n' ' ')"
  has "index template has Pillar coverage section" "$T/index-template.md" '^## Pillar coverage'
  has "index template has Hottest threads" "$T/index-template.md" '^## Hottest threads'
  has "index template carries tunables" "$T/index-template.md" 'words_per_turn'
  local ln; ln=$(awk '/^## Entities/{print NR; exit}' "$T/index-template.md"); [ "$ln" -lt 60 ] && ok "entity table at line $ln (<60)" || no "entity table at line $ln, not <60"
  grep -q '^## Canon' "$T/entity-template.md" && ok "entity template has Canon" || no "entity template lacks ## Canon"
  grep -q 'proposed:' "$T/entity-template.md" && ok "entity template shows provenance" || no "no proposed: provenance"
  grep -q 'superseded-by:' "$T/entity-template.md" && ok "append-only marker documented" || no "no superseded-by: marker"
  grep -q '^## Links' "$T/entity-template.md" && ok "entity template has Links" || no "no Links section"
  grep -q 'status: open' "$T/threads-template.md" && ok "threads template carries status" || no "threads template lacks status"
  local k; for k in person place era custom conflict institution artifact text creature; do
    grep -q "$k" "$T/entity-template.md" && : || no "kind '$k' absent from entity template"
  done
}

rubric(){
  local R="$B/references/rubric.md"; [ -f "$R" ] && ok "rubric exists" || { no "rubric missing"; return; }
  local n; n=$(grep -cE '^\| *[a-z-]+ *\|' "$R"); ck "$n" 18 "rubric lists all 18 pillars ($n)"
  has "child-spawn rule present" "$R" 'must spawn'
  has "anti-glass test present" "$R" '[Aa]nti-glass'
}
voice(){
  local V="$B/references/voice.md"; [ -f "$V" ] || { no "voice.md missing"; return; }
  local t; t=$(awk '/^### Turn/{f=1} f' "$V" | grep -ciE 'consequence|contradiction|connection|cost|discovery')
  [ "$t" -ge 1 ] && ok "transcript names an engagement type" || no "transcript does not log engagement"
  grep -q 'proposed:' "$V" && ok "transcript demonstrates provenance" || no "transcript lacks provenance"
}
method(){
  local S="$B/SKILL.md"; [ -f "$S" ] || { no "bundle SKILL.md missing"; return; }
  local w; w=$(wc -w < "$S"); [ "$w" -lt 500 ] && ok "bundle SKILL.md $w words (<500)" || no "bundle SKILL.md $w words"
  grep -qi 'empty' "$S" && grep -qi 'gap_weight' "$S" && ok "gap_weight polarity documented" || no "gap_weight polarity missing"
  has "write boundary names world/" "$S" 'world/'
  for k in contradiction rebuild proposed 3; do grep -qi "$k" "$S" && ok "Review Focus rule: $k" || no "Review Focus rule missing: $k"; done
}
kit(){
  # nothing developmental may live inside the bundle: it is copied verbatim into a writer's project
  local junk; junk=$(find "$B" -maxdepth 1 -name evidence -o -maxdepth 1 -name '*.log' | wc -l)
  [ "$junk" = 0 ] && ok "bundle carries no run evidence" || no "bundle contains dev artifacts: $(ls "$B")"
  local K="$REPO/kit/SKILL.md"; [ -f "$K" ] || { no "kit/SKILL.md missing"; return; }
  local w; w=$(wc -w < "$K"); [ "$w" -lt 150 ] && ok "kit $w words (<150)" || no "kit $w words"
  local d; d=$(awk '/^description:/{sub(/^description: */,"");print}' "$K" | wc -w)
  [ "$d" -le 35 ] && ok "kit description $d words (<=35)" || no "kit description $d words"
  grep -q 'worldbuilding' "$K" && ok "kit names the bundle" || no "kit does not name the bundle"
}

selftest_bad=0
selftest(){
  # the ck helper must actually assert; it previously compared its own expected
  # argument to 1, which made every count assertion vacuous or unsatisfiable
  local p f; p=$PASS; f=$FAIL
  PASS=0; FAIL=0; ck 0 1 probe >/dev/null; [ "$FAIL" = 1 ] || selftest_bad=1
  PASS=0; FAIL=0; ck 1 1 probe >/dev/null; [ "$PASS" = 1 ] || selftest_bad=1
  PASS=0; FAIL=0; ck 18 18 probe >/dev/null; [ "$PASS" = 1 ] || selftest_bad=1
  PASS=$p; FAIL=$f
  [ "$selftest_bad" = 1 ] && no "selftest: ck does not assert (it passed or failed the wrong comparison)" || ok "selftest: ck asserts correctly (0 vs 1 fails; 1 vs 1 and 18 vs 18 pass)"
}

case "${1:-all}" in
  harness) harness;; templates) templates;; rubric) rubric;; voice) voice;;
  method) method;; kit) kit;; selftest) selftest;;
  all)
    echo "[selftest]"; selftest
    if [ "$selftest_bad" = 1 ]; then
      echo "check.sh: SELFTEST FAILED - the assertion helper is broken; refusing to run the gate"
      echo "check.sh: $PASS passed, $FAIL failed"; exit 2
    fi
    for f in harness templates rubric voice method kit; do echo "[$f]"; $f; done;;
esac
echo "check.sh: $PASS passed, $FAIL failed"; [ "$FAIL" = 0 ]
