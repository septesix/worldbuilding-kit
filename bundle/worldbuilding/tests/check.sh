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
newest(){ ls -1t "$REPO"/evidence/"$1"-${2:-control}-*.md 2>/dev/null | head -1; }

harness(){
  # capture integrity + contamination only. The "baseline ignores the files" assertion was
  # dropped: clean-context runs READ and WROTE the encyclopedia correctly (evidence/BASELINE.md).
  local e; e="$(newest continue-established control)"; [ -n "$e" ] || { no "no control evidence; run tests/run.sh continue-established control"; return; }
  grep -q "INFRA-FAIL" "$e" && { no "control evidence is an infra failure: $e"; return; }
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
  has "close trigger stated in the rubric" "$B/references/rubric.md" 'Close at .turns_per_session'
  has "beat budget stated in the rubric" "$B/references/rubric.md" 'per-beat cap|beat_budget'
  has "beat budget is a tunable" "$T/index-template.md" 'beat_budget:'
  has "beat budget named in SKILL" "$B/SKILL.md" 'beat_budget'
  has "append-only covers files, not just lines (F6)" "$B/SKILL.md" 'never delete one under'
  has "entity template says the file survives (F6)" "$B/assets/entity-template.md" 'never delete the'
  has "score disclosure named in SKILL (I7)" "$B/SKILL.md" 'Show all three terms'
  has "scoring honesty documented in the rubric (I7)" "$B/references/rubric.md" 'Scoring honesty'
  has "gap_weight stated as a table lookup (I7)" "$B/references/rubric.md" 'coverage'
  # ERE: '|' alternates, '\|' is a literal bar. An earlier guard used the escaped form and failed a
  # rule that was present - the same class of false alarm as a grep pattern starting with '-'
  # the number and the noun sit on opposite sides of a line wrap in SKILL.md, so one grep cannot see
  # both - asserting the pair separately keeps the guard honest instead of lucky
  has "seed band named in SKILL (I4)" "$B/SKILL.md" '5[–-]8'
  has "seed band applies to entity files (I4)" "$B/SKILL.md" 'entity files from'
  has "seeding shape documented in the rubric (I4)" "$B/references/rubric.md" 'Seeding a new world'
  has "seed texture rule stated (I4/R-8)" "$B/references/rubric.md" 'texture pillar'
  has "seed thread floor stated (I4)" "$B/references/rubric.md" '3 threads per seeded entity'
  has "a new-world scenario exists" "$B/tests/prompts/new-world.txt" 'canal city'
  has "the new-world scenario is wired into the harness" "$B/tests/run.sh" 'new-world'
  has "seedcheck wired into the single-turn harness" "$B/tests/run.sh" 'seedcheck'
  has "review trigger named in SKILL (I5)" "$B/SKILL.md" 'provoked: review'
  has "the memo is named in SKILL (I5)" "$B/SKILL.md" 'the memo'
  has "review trigger lives in the continue procedure (I5)" "$B/SKILL.md" 'score from files. At ≥3 sessions'
  has "the trigger names the count it checks (I5)" "$B/SKILL.md" 'provoked: review., end the turn with the memo'
  has "the five memo items are enumerated in the rubric (I5)" "$B/references/rubric.md" 'treadmill'
  has "review contract computed in the rubric (I5)" "$B/references/rubric.md" '## Review mode'
  has "reviewcheck wired into the harness" "$B/tests/run.sh" 'reviewcheck'
  has "a review scenario exists (asked)" "$B/tests/prompts/review.txt" 'review'
  has "canoncheck wired into the single-turn harness" "$B/tests/run.sh" 'canoncheck'
  has "canoncheck wired into the multi-turn harness" "$B/tests/multiturn.sh" 'canoncheck'
  # a rule may live in SKILL or in references - what is not allowed is living in neither. SKILL alone
  # is where rules go to die, because the word budget eventually trades them away: that is how the
  # close trigger nearly left the kit entirely, and F6's neighbours already did.
  local q homes
  for q in 'dump tables into chat' 'existing entities and the nine child generators'; do
    homes=$(grep -rl "$q" "$B/SKILL.md" "$B/references" 2>/dev/null | wc -l)
    [ "$homes" -ge 1 ] && ok "rule survives somewhere: $q" || no "rule deleted from every file: $q"
  done
  local t missing=0
  for t in words_per_turn texture_cadence reads_per_turn beat_budget turns_per_session; do
    n=$(grep -rl "$t" "$B/SKILL.md" "$B/references" "$B/assets" "$B/tests/fixtures/established/world/index.md" 2>/dev/null | wc -l)
    [ "$n" -ge 3 ] || { missing=1; no "tunable $t appears in only $n places - a rule with no home"; }
  done
  [ $missing = 0 ] && ok "every tunable is named in template, fixture and guidance"
  local ln; ln=$(awk '/^## Entities/{print NR; exit}' "$T/index-template.md"); [ "$ln" -lt 60 ] && ok "entity table at line $ln (<60)" || no "entity table at line $ln, not <60"
  grep -q '^## Canon' "$T/entity-template.md" && ok "entity template has Canon" || no "entity template lacks ## Canon"
  grep -q 'proposed:' "$T/entity-template.md" && ok "entity template shows provenance" || no "no proposed: provenance"
  grep -q 'superseded-by:' "$T/entity-template.md" && ok "append-only marker documented" || no "no superseded-by: marker"
  grep -q 'Append only' "$T/entity-template.md" && grep -q 'Never edit' "$T/entity-template.md" && ok "template states append-only" || no "template dropped the append-only rule"
  # the demonstrated shape: a retcon must appear as its OWN bullet, never as an annotation on an old one
  grep -qE '^- revised:' "$T/entity-template.md" && ok "retcon demonstrated as a standalone line" || no "no standalone revised: example in template"
  grep -qE '^- established:.*superseded-by:' "$T/entity-template.md" && no "template annotates an existing bullet (C3 regression)" || ok "no annotation written into an old bullet"
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
  # F9: the counting instruction used to send the model into the entity files, which cannot fit the
  # ≤3-bodies-per-turn rule. Both rules are satisfiable only by counting from the index tables.
  has "counting reads index tables, not bodies (F9)" "$R" 'index\.md.{0,3}s two tables|two tables'
  has "one body per turn is stated (F9)" "$R" 'Read \*\*one\*\* body'
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
  # a documented default must equal the real default. voice.md said 160 for two steps after the
  # default became 170, because a self-test restored the file with `git checkout --` and ate the
  # uncommitted edit; nothing compared the two numbers, so nothing noticed.
  local tv d
  for tv in words_per_turn texture_cadence reads_per_turn; do
    d=$(awk -v k="$tv" '$1==k":"{gsub(/[^0-9]/,"",$2); print $2; exit}' "$B/assets/index-template.md")
    if [ "$tv" = words_per_turn ]; then
      grep -q "default $d" "$B/references/voice.md" && ok "$tv documented default matches the template ($d)" \
        || no "$tv: voice.md states a default other than the template's $d"
    else
      # the real risk is two copies of a default disagreeing, not the phrasing around them
      local fx; fx=$(awk -v k="$tv" '$1==k":"{gsub(/[^0-9]/,"",$2); print $2; exit}' "$B/tests/fixtures/established/world/index.md")
      [ "$fx" = "$d" ] && ok "$tv: template and fixture agree ($d)" || no "$tv: template says $d, fixture says $fx"
      grep -rqE "$tv|[0-9] (turns|bodies) a turn" "$B/references" && ok "$tv named in guidance" \
        || no "$tv never named in guidance"
    fi
  done
  # test debris must never reach shipped guidance: a probe that mutates references/ and fails to
  # restore leaves its marker in the file the model reads. This is the guard that was missing.
  local g debris=0
  for g in "$S" "$B/references/"*.md "$B/assets/"*.md; do
    grep -qE 'probe -->|SELFTEST|<!-- (mutation|probe)' "$g" && { debris=1; no "guidance carries test debris: ${g#"$REPO"/}"; }
  done
  [ $debris = 0 ] && ok "no test debris in shipped guidance (SKILL, references, assets)"
  grep -qi 'empty' "$S" && grep -qi 'gap_weight' "$S" && ok "gap_weight polarity documented" || no "gap_weight polarity missing"
  has "write boundary names world/" "$S" 'world/'
  # R-4: the consecutive-pillar rule is only obeyable if the target is recorded
  has "turn log records the targeted pillar (R-4)" "$S" 'targeted: <pillar>'
  has "log line shape documented in the template" "$B/assets/index-template.md" 'targeted: <pillar>'
  # R-6: the read cap became a scale tripwire wired to a tunable, in guidance, template and fixture
  has "the body-read tripwire names the tunable (R-6)" "$S" 'reads_per_turn'
  has "cadence is computed from logged targets, not felt (R-8)" "$B/references/rubric.md" 'last .texture_cadence. entries|arithmetic on .log\.md.'
  has "body routes cadence to the log (R-8)" "$S" 'last .texture_cadence. .targeted:|targeted:. lines in .log.md'
  has "bookkeeping demands one machine line per turn (R-9)" "$S" 'one machine line per turn'
  # pattern must not start with '-' or grep reads it as an option (it did, and looked like a missing rule)
  has "template gives the machine line shape (R-9)" "$B/assets/index-template.md" 'turn: <n> .*provoked'
  has "rubric treats a ledger hole as unknown, not satisfied (R-9)" "$B/references/rubric.md" 'hole in the log'
  has "index-template carries the reads tunable" "$B/assets/index-template.md" 'reads_per_turn: [0-9]+'
  has "fixture carries the reads tunable" "$B/tests/fixtures/established/world/index.md" 'reads_per_turn: [0-9]+'
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
  grep -qi 'write nothing\|do not scaffold' "$B/SKILL.md" && ok "guard present in the BUNDLE" || no "bundle still scaffolds anywhere (C2)"
  grep -q 'home-dir' "$B/tests/run.sh" && grep -q 'skill "$REPO/kit"' "$B/tests/run.sh" && ok "home-dir routed to the kit" || no "home-dir still loads the bundle only"
  grep -q 'worldbuilding' "$K" && ok "kit names the bundle" || no "kit does not name the bundle"
}

selftest_bad=0
multi(){
  # opt-in: needs multi-turn artifacts. Same reason as behavior - green static checks must never be
  # read as "the cadence and read-budget invariants hold".
  local bh all sel
  bh=$(guidance_key)
  all=$(ls -1t "$REPO"/evidence/*-multi-*.md 2>/dev/null)
  [ -z "$all" ] && { echo "  skip  multi: no multi-turn runs recorded"; return; }
  sel=$(grep -l "guidance=$bh" $all 2>/dev/null | head -4)
  [ -z "$sel" ] && { echo "  skip  multi: no multi-turn evidence from guidance key $bh"; return; }
  local rc=0 f
  for f in $sel; do
    grep -q '^CANON-LOSS' "$f" && { echo "   canon files deleted during $(basename "$f") - append-only breached (world/ files may be added, never removed)"; rc=$((rc | 1)); }
    grep -q 'INFRA-FAIL: no assistant text' "$f" && { echo "   an eaten turn in $(basename "$f") - instrument failure, not scored as a finding"; rc=$((rc | 2)); }
    python3 "$B/tests/invariants.py" "$f" || rc=$((rc | $?))
  done
  [ "$rc" = 0 ] && ok "multi-turn invariants hold (questions, reads, cadence, provocation)" \
    || no "multi-turn invariant breached (bitmask $rc: 1 words/beats, 2 appendix/scoring, 4 questions, 8 reads, 16 cadence, 32 provocation, 64 consecutive pillar; plus canon-loss and eaten-turn flags)"
}

behavior(){
  # opt-in only: needs run artifacts. Deliberately NOT in the all loop, so "all green" can never
  # mean "the budget held" - it is checked by name: bash tests/check.sh behavior
  local head bh all sel tot nsel lim rc
  head=$(git -C "$REPO" rev-parse --short HEAD 2>/dev/null || echo unknown)
  bh=$(guidance_key)
  all=$(ls -1t "$REPO"/evidence/*-skill-*.md 2>/dev/null)
  [ -z "$all" ] && { echo "  skip  behavior: no skill runs recorded yet"; return; }
  # only transcripts labelled with this build count as evidence about it
  # keyed to the BUNDLE tree hash: a docs-only commit must not void behavioral evidence
  sel=$(grep -l "guidance=$bh" $all 2>/dev/null | head -8)
  tot=$(echo "$all" | grep -c .); nsel=$(printf '%s\n' "$sel" | grep -c '[^[:space:]]')
  if [ "$nsel" = 0 ]; then
    echo "  skip  behavior: none of the $tot skill transcripts carry guidance key $bh (HEAD $head) - re-run the scenarios to grade this build"
    return
  fi
  [ "$nsel" != "$tot" ] && echo "  note  behavior: grading $nsel of $tot transcripts ($((tot-nsel)) belong to other builds; their 'label:' line says which)"
  # I4: a new-world run that never seeded must not read as a pass just because its words were fine.
  # Three states are named separately: untested, tested-and-failed, tested-and-good.
  local nw sbad; nw=$(printf '%s\n' $sel | grep -c 'new-world-skill')
  sbad=$(grep -l 'SEED-FAIL' $sel 2>/dev/null | wc -l)
  local rvn rvb; rvn=$(printf '%s\n' $sel | grep -cE 'review(-owed)?-skill')
  # an aborted run is not a pass and not a breach; grading it as either is the same lie twice
  local rvg; rvg=$(grep -l 'NOT-GRADED\|INFRA-FAIL' $sel 2>/dev/null | wc -l)
  rvb=$(grep -lE 'REVIEW-OWED|REVIEW-FAIL' $sel 2>/dev/null | wc -l)
  if [ "${rvn:-0}" = 0 ]; then echo "  note  behavior: no review run under this guidance key - I5 untested by these artifacts"
  elif [ "${rvn}" = "${rvg}" ]; then echo "  note  behavior: $rvn review run(s) recorded but none gradeable (aborted or logless) - I5 stays open"
  elif [ "${rvb:-0}" != 0 ]; then no "$rvb of $rvn review run(s) breached the review contract"
  else ok "the recorded review run(s) met the contract (trigger and five-item memo)"; fi
  if [ "${nw:-0}" = 0 ]; then echo "  note  behavior: no new-world run under this guidance key - I4 untested by these artifacts"
  elif [ "${sbad:-0}" != 0 ]; then no "$sbad of $nw new-world run(s) failed the seed band (see SEED-FAIL in the evidence)"
  else ok "the recorded new-world run seeded inside the band (5-8 entities, spread, texture, threads)"; fi
  lim=$(awk '/words_per_turn/{gsub(/[^0-9]/,"",$2); print $2; exit}' "$B/assets/index-template.md")
  rc=0
  python3 "$B/tests/wordcount.py" $sel "${lim:-160}" || rc=$?
  case $rc in
    0) ok "recorded skill turns within ${lim} turn words and their appendix limits";;
    1) no "a recorded turn exceeds the ${lim}-word TURN cap";;
    2) no "turn words within ${lim}; an APPENDIX limit is breached (options over 18 words, or recap over 6 bullets)";;
    3) no "both the turn cap and an appendix limit are breached";;
    *) no "wordcount.py could not run (rc=$rc)";;
  esac
}

meta(){
  # a check that exists but is not in the all-loop is a silent exclusion (it happened once)
  local defined run optin
  # behavior is a deliberate opt-in: it needs run artifacts, so "all green" must never be read as
  # "the word budget held". Exempting a name here is a decision, made visible.
  optin='^(behavior|multi)$'
  defined=$(grep -oE '^[a-z]+\(\)\{' "$0" | sed 's/[(){]//g' | grep -vE '^(ok|no|ck|has|newest|pil|selftest|meta)$' | grep -vE "$optin" | sort -u)
  run=$(sed -n '/for f in /s/.*for f in \([a-z ]*\);.*/\1/p' "$0" | tr ' ' '\n' | sort -u | grep -v '^$')
  local missing; missing=$(comm -23 <(echo "$defined") <(echo "$run"))
  [ -z "$missing" ] && ok "every defined check runs in 'all'" || no "SILENTLY EXCLUDED from all: $(echo $missing)"
}

# Instrument self-tests — appended to check.sh's selftest()
guidance_key(){
  # Hash the WORKING TREE contents of what the model reads - not git's committed copy. Evidence
  # produced against uncommitted guidance used to carry the pre-edit key, which made "graded against
  # the current build" false on every dirty step (that is: all of them). Locates the bundle from this
  # script's own path, so it must not depend on $B / $BUNDLE being defined by the caller.
  local d; d=$(cd "$(dirname "$0")/.." && pwd)
  { cat "$d/SKILL.md" 2>/dev/null; cat "$d"/references/*.md 2>/dev/null; cat "$d"/assets/*.md 2>/dev/null; } \
    | cksum | awk '{printf "%08x", $1}'
}
selftest(){
  # NOTE: probes must NOT save-and-restore the counters - an earlier draft did, so every red probe
  # printed a failure that was then erased from the total and the exit status. Helper-behaviour
  # probes run in subshells instead, so their intentional FAIL never reaches the suite total.
  local rc TMP; selftest_bad=0
  ( ck 0 1 probe >/dev/null; [ "$FAIL" = 1 ] ) || selftest_bad=1
  ( PASS=0 FAIL=0; ck 1 1 probe >/dev/null; [ "$PASS" = 1 ] ) || selftest_bad=1
  ( PASS=0 FAIL=0; ck 18 18 probe >/dev/null; [ "$PASS" = 1 ] ) || selftest_bad=1
  [ "$selftest_bad" = 1 ] && no "selftest: ck does not assert (wrong comparison passed or failed)" || ok "selftest: ck asserts correctly"

  # has() must go both ways, and newest() must honour the variant it was asked for
  TMP=$(mktemp -d); printf 'alpha\nbeta gamma\n' > "$TMP/f"
  ( PASS=0 FAIL=0; has present "$TMP/f" 'beta.*gamma' >/dev/null; [ "$PASS" = 1 ] && [ "$FAIL" = 0 ] ) && ok "selftest: has() detects a match" || no "selftest: has() cannot report a match"
  ( PASS=0 FAIL=0; has absent "$TMP/f" 'zzz-not-present' >/dev/null; [ "$FAIL" = 1 ] ) && ok "selftest: has() fails on no match" || no "selftest: has() is vacuous (passes anything)"
  local nc ns; nc=$(newest continue-established control); ns=$(newest continue-established skill)
  case "$nc" in *-control-*.md) ok "selftest: newest() honours 'control'";; *) no "selftest: newest() ignored the control variant ($nc)";; esac
  case "$ns" in *-skill-*.md) ok "selftest: newest() honours 'skill'";; *) no "selftest: newest() ignored the skill variant ($ns)";; esac

  # scoreboard.py must fail a mutated index, in two distinct ways
  local W="$TMP/world"; cp -R "$B/tests/fixtures/established/world" "$W"
  python3 "$B/tests/scoreboard.py" "$W" --diff >/dev/null 2>&1; rc=$?
  [ "$rc" = 0 ] && ok "selftest: scoreboard accepts a faithful index" || no "selftest: scoreboard rejects the clean fixture (rc=$rc) - it cannot be trusted"
  sed -i 's/^| geography-routes | 3 |/| geography-routes | 99 |/' "$W/index.md"
  python3 "$B/tests/scoreboard.py" "$W" --diff >/dev/null 2>&1; rc=$?
  [ "$rc" != 0 ] && ok "selftest: scoreboard catches a wrong count" || no "selftest: scoreboard MISSES a wrong count (vacuous gate)"
  cp -R "$B/tests/fixtures/established/world" "$W" && sed -i '/^| pillar | entries/d' "$W/index.md"
  python3 "$B/tests/scoreboard.py" "$W" --diff >/dev/null 2>&1; rc=$?
  [ "$rc" != 0 ] && ok "selftest: scoreboard catches a dropped table header" || no "selftest: scoreboard MISSES a missing header (vacuous gate)"

  # invariants.py must pass a genuinely valid 5-turn run and catch each breach. Files are built by
  # python, not sed: an earlier draft did open(p,'w').write(open(p).read()...), which truncated the
  # file before reading it, so the probe was asserting on an empty transcript.
  local rc; rc=0
  build_ev(){
    python3 - "$1" "$2" "$3" <<'L'
import sys, json
path, mode, sess = sys.argv[1], sys.argv[2], sys.argv[3]
BASE_T = ['history-periodisation', 'politics-power', 'geography-routes', 'daily-life', 'voice-attention']
BASE_P = ['connection', 'constraint', 'cost', 'consequence', 'discovery']
ALT = {
    # a pillar that RECURS without ever being consecutive is legal under spec §4; an earlier fixture
    # had turns 1-2 identical and so "proved" the tool did not invent rules by breaking them itself
    'same-pillar':       ['geography-routes', 'daily-life', 'geography-routes', 'voice-attention', 'politics-power'],
    'consecutive-logged':['history-periodisation', 'politics-power', 'politics-power', 'daily-life', 'voice-attention'],
    'unlogged':          ['history-periodisation', 'politics-power', 'daily-life', 'voice-attention', 'geography-routes'],
    'no-machine':        BASE_T,
    'no-texture':        ['history-periodisation', 'politics-power', 'geography-routes', 'institutions-law', 'ecology-resources'],
}
out = ['# x (skill) MULTI',
       'label: commit=deadbe bundle=abcd1234 spec_rev=R-9 words_per_turn=160 texture_cadence=4']
eff_t, eff_p = [], []
for i in range(5):
    t = ALT.get(mode, BASE_T)[i]
    p = 'connection' if mode == 'provoked-repeat' else BASE_P[i]
    q = '**Question.** Which crossing is oldest?'
    if mode == 'double-question' and i == 2:
        q = '**Question.** Which crossing is oldest? And which is widest?'
    body = '**Digest.** ' + ('word ' * 200 if mode == 'long-turn' and i == 1 else 'ok.')
    stop = '**Stop.** `provoked: ' + p + ('' if mode in ('unlogged', 'no-machine') else ' \u00b7 targeted: ' + t) + '`'
    eff_t.append(t); eff_p.append(p)
    out += ['## turn %d' % (i + 1), 'writer: an answer', body, '**Target.** %s.' % t,
            stop, q, '- steady \u2014 one two three', '']
# the ledger dump in the R-9 machine shape, built from the EFFECTIVE per-turn values. The first draft
# wrote the base lists, so the mode adjustments never reached the log and four probes went green on
# data the builder had quietly overwritten.
if mode in ('no-machine', 'unlogged'):
    mach = []
elif mode == 'machine-hole':
    mach = range(1, 4)
else:
    mach = range(1, 6)
log = ['## 2026-09-30 (session 5)'] + ['- turn: %d \u00b7 provoked: %s \u00b7 targeted: %s'
                                       % (j, eff_p[j - 1], eff_t[j - 1]) for j in mach]
open(path, 'w').write('\n'.join(out) + '## files after run\n## world/ contents\n'
                      + '--- ./world/log.md\n' + '\n'.join(log) + '\n')
if int(sess):
    n = int(sess)
    recs = []
    for i in range(5):
        recs.append('{"type":"message","message":{"role":"user","content":[]}}')
        calls = [{'type': 'toolCall', 'name': 'read', 'arguments': {'path': 'world/encyclopedia/x%d.md' % j}}
                 for j in range(n)]
        recs.append('{"type":"message","message":{"role":"assistant","content":%s}}' % json.dumps(calls))
    open(path + '.session.jsonl', 'w').write('\n'.join(recs) + '\n')
L
  }
  crash(){ [ $(( $1 & 128 )) = 0 ] || { no "selftest: invariants.py CRASHED (rc=$1) - a broken tool, not a finding"; return 1; }; return 0; }
  rm -f "$TMP"/*.session.jsonl
  build_ev "$TMP/a.md" ok 2; rc=0; python3 "$B/tests/invariants.py" "$TMP/a.md" >/dev/null 2>&1; rc=$?
  crash $rc && [ "$rc" = 0 ] && ok "selftest: invariants accepts a valid 5-turn run" || no "selftest: invariants rejects a valid run (rc=$rc) - untrustworthy"
  build_ev "$TMP/b.md" double-question 2; python3 "$B/tests/invariants.py" "$TMP/b.md" >/dev/null 2>&1; rc=$?
  crash $rc && [ $((rc & 4)) = 4 ] && ok "selftest: invariants catches two questions in one turn" || no "selftest: invariants MISSES a double question (rc=$rc)"
  build_ev "$TMP/c.md" long-turn 2; python3 "$B/tests/invariants.py" "$TMP/c.md" >/dev/null 2>&1; rc=$?
  crash $rc && [ $((rc & 1)) = 1 ] && ok "selftest: invariants catches an over-budget turn" || no "selftest: invariants MISSES an over-budget turn (rc=$rc)"
  build_ev "$TMP/d.md" provoked-repeat 2; python3 "$B/tests/invariants.py" "$TMP/d.md" >/dev/null 2>&1; rc=$?
  crash $rc && [ $((rc & 32)) = 32 ] && ok "selftest: invariants catches 3 identical provoked types" || no "selftest: invariants MISSES a provoked repeat (rc=$rc)"
  # the written rule is CONSECUTIVE turns, not three running (spec §4) - so a file that alternates
  # must pass even when one pillar recurs, and a logged repeat must be adjudicable, not silent
  build_ev "$TMP/e.md" same-pillar 2; python3 "$B/tests/invariants.py" "$TMP/e.md" >/dev/null 2>&1; rc=$?
  crash $rc && [ $((rc & 64)) = 0 ] && ok "selftest: alternating pillar with a recurring one is not a breach" \
    || no "selftest: invariants invented a rule (rc=$rc) - spec says consecutive, not 3 running"
  build_ev "$TMP/e2.md" consecutive-logged 2; python3 "$B/tests/invariants.py" "$TMP/e2.md" >/dev/null 2>&1; rc=$?
  crash $rc && [ $((rc & 64)) = 64 ] && ok "selftest: invariants catches a logged consecutive repeat" \
    || no "selftest: invariants MISSES a logged repeat (rc=$rc)"
  build_ev "$TMP/e3.md" unlogged 2; python3 "$B/tests/invariants.py" "$TMP/e3.md" >"$TMP/e3.out" 2>&1; rc=$?
  crash $rc && [ $((rc & 64)) = 0 ] && grep -q 'targeted:.*logged in' "$TMP/e3.out" \
    && ok "selftest: an unlogged target is announced as missing state, never scored silently" \
    || no "selftest: invariants scored targets it could not see (rc=$rc)"
  build_ev "$TMP/f.md" no-texture 2; python3 "$B/tests/invariants.py" "$TMP/f.md" >/dev/null 2>&1; rc=$?
  crash $rc && [ $((rc & 16)) = 16 ] && ok "selftest: invariants catches texture never asked within cadence" || no "selftest: invariants MISSES a cadence breach (rc=$rc)"
  # a write is not a read. Bookkeeping edits 2-3 entity files every turn; counting those as reads is
  # what manufactured F9 and then two spec revisions went out to fix a bug in this file.
  build_ev "$TMP/w.md" ok 1
  python3 - "$TMP/w.md.session.jsonl" <<'L'
import sys, json
p = sys.argv[1]; recs = open(p).read().split('\n')
out = []
for r in recs:
    if not r.strip(): continue
    d = json.loads(r); m = d.get('message', {})
    if m.get('role') == 'assistant':
        m['content'] = ([{'type': 'toolCall', 'name': 'edit', 'arguments': {'path': 'world/encyclopedia/x%d.md' % i}}
                         for i in range(4)]
                        + [{'type': 'toolCall', 'name': 'write', 'arguments': {'path': 'world/encyclopedia/y.md'}}]
                        + [{'type': 'toolCall', 'name': 'bash', 'arguments': {'command': 'grep -c . encyclopedia/*.md'}}])
        r = json.dumps(d)
    out.append(r)
open(p, 'w').write('\n'.join(out) + '\n')
L
  python3 "$B/tests/invariants.py" "$TMP/w.md" >/dev/null 2>&1; rc=$?
  crash $rc && [ $((rc & 8)) = 0 ] && ok "selftest: 4 edits + a write + bash do not count as reads" \
    || no "selftest: the read tripwire counts writes as reads (rc=$rc) - F9 will come back"
  build_ev "$TMP/g.md" ok 1
  python3 - "$TMP/g.md.session.jsonl" <<'L'
import sys, json
p = sys.argv[1]; out = []
for r in open(p).read().split('\n'):
    if not r.strip(): continue
    d = json.loads(r); m = d.get('message', {})
    if m.get('role') == 'assistant':
        m['content'] = [{'type': 'toolCall', 'name': 'read', 'arguments': {'path': 'world/encyclopedia/x%d.md' % i}} for i in range(4)]
        r = json.dumps(d)
    out.append(r)
open(p, 'w').write('\n'.join(out) + '\n')
L
  python3 "$B/tests/invariants.py" "$TMP/g.md" >/dev/null 2>&1; rc=$?
  crash $rc && [ $((rc & 8)) = 8 ] && ok "selftest: 4 actual reads do trip the wire" \
    || no "selftest: the read tripwire is blind to real reads (rc=$rc)"
  rm -f "$TMP/g.md.session.jsonl"
  # the close contract must be able to fail, and must stay silent when close is not owed
  local cbad; cbad=$(python3 - "$TMP" "$B" 2>&1 <<'L3' | tail -1
import sys, subprocess
tmp, b = sys.argv[1], sys.argv[2]
def build(path, n, recap_at=None, cue=False):
    out = ['# x (skill) MULTI', 'label: commit=deadbe guidance=abcd1234 spec_rev=R-7 words_per_turn=170 texture_cadence=4 reads_per_turn=3']
    for i in range(1, n + 1):
        out += [f'## turn {i}', 'writer: ' + ("that's all I have for today, wrap it up" if cue and i == n else 'an answer'),
                '**Digest.** ok.', f'**Target.** geography-routes.', f'**Stop.** `provoked: c{i}`',
                '**Question.** Which crossing is oldest?']
        if recap_at and i >= recap_at:
            out += ['- `nine-bridges-place`: settled.', '- `bridge-tolls-custom`: revised.',
                    '- new `tenth-bridge-custom`, all `proposed:`.', '**Next: T-014** - whose name.']
        out += ['']
    open(path, 'w').write('\n'.join(out) + '## files after run\n')
build(tmp+'/k1.md',12,recap_at=12); build(tmp+'/k2.md',12); build(tmp+'/k3.md',6)
build(tmp+'/k4.md',5,recap_at=5,cue=True); build(tmp+'/k5.md',5,cue=True)
bad=[]
for f,want in (('k1',0),('k2',2),('k3',0),('k4',0),('k5',2)):
    rc=subprocess.run(['python3', b+'/tests/invariants.py', tmp+'/%s.md'%f],capture_output=True,text=True)
    if (rc.returncode & 2)!=want: bad.append('%s: want bit2=%d got %d'%(f,want,rc.returncode&2))
print('OK' if not bad else 'BAD '+'; '.join(bad))
L3
)
  [ "$cbad" = OK ] && ok "selftest: close contract fails when unmet (k2,k5) and stays silent when not owed (k1,k3,k4)" || no "selftest: close-contract assertion wrong - $cbad"

  # reads are measured against reads_per_turn from the label, not a hardcoded constant
  build_ev "$TMP/g0.md" ok 4
  sed -i 's/texture_cadence=4$/texture_cadence=4 reads_per_turn=6/' "$TMP/g0.md"
  python3 "$B/tests/invariants.py" "$TMP/g0.md" >/dev/null 2>&1; rc=$?
  crash $rc && [ $((rc & 8)) = 0 ] && ok "selftest: reads_per_turn=6 lets 4 reads pass (tunable, not constant)" \
    || no "selftest: invariants ignores reads_per_turn - the cap is still hardcoded (rc=$rc)"
  # same 4 reads, threshold lowered to 3: must bite. (3 reads vs a cap of 3 is COMPLIANT - my first
  # draft asserted that as a breach, which would have had the tool failing a rule it never broke.)
  build_ev "$TMP/g1.md" ok 4
  sed -i 's/texture_cadence=4$/texture_cadence=4 reads_per_turn=3/' "$TMP/g1.md"
  python3 "$B/tests/invariants.py" "$TMP/g1.md" >/dev/null 2>&1; rc=$?
  crash $rc && [ $((rc & 8)) = 8 ] && ok "selftest: 4 reads bite when reads_per_turn=3" \
    || no "selftest: reads_per_turn=3 does not bite on 4 reads (rc=$rc)"
  build_ev "$TMP/g.md" ok 4; python3 "$B/tests/invariants.py" "$TMP/g.md" >/dev/null 2>&1; rc=$?
  crash $rc && [ $((rc & 8)) = 8 ] && ok "selftest: invariants catches a 4th entity read in one turn" || no "selftest: invariants MISSES the read budget (rc=$rc)"
  # regression: the last turn's chunk used to run to end-of-file and absorb the whole "## world/
  # contents" dump (~2000 words), which read as one gigantic turn rather than a parsing bug.
  build_ev "$TMP/i.md" ok 2; printf '## files after run\n## world/ contents\n%s\n' "$(yes filler | head -2500 | tr '\n' ' ')" >> "$TMP/i.md"
  python3 "$B/tests/invariants.py" "$TMP/i.md" > "$TMP/i.out" 2>&1; rc=$?
  crash $rc && [ "$rc" = 0 ] && ! grep -qE 'turn 5: *[0-9]{4}w' "$TMP/i.out" && ok "selftest: trailing world/ dump stays out of the last turn" || no "selftest: file tail leaks into turn words (rc=$rc)"
  # R-9: a ledger with holes must be announced, and the windows it can't compute must stay unscored
  build_ev "$TMP/m1.md" ok 5; python3 "$B/tests/invariants.py" "$TMP/m1.md" >"$TMP/m1.out" 2>&1; rc=$?
  crash $rc && [ $((rc & 2)) = 0 ] && grep -q 'machine' "$TMP/m1.out" \
    && ok "selftest: a complete machine log is read as machine, not prose" \
    || no "selftest: complete machine log misread (rc=$rc)"
  build_ev "$TMP/m2.md" machine-hole 5; python3 "$B/tests/invariants.py" "$TMP/m2.md" >"$TMP/m2.out" 2>&1; rc=$?
  crash $rc && [ $((rc & 2)) = 2 ] && grep -q 'BOOKKEEPING HOLE' "$TMP/m2.out" \
    && ok "selftest: 3 machine lines for 5 turns is announced as a hole, not a clean window" \
    || no "selftest: a gapped ledger passed quietly (rc=$rc) - R-9 detection is inert"
  grep -qE 'BOOKKEEPING HOLE|OMITTED' "$TMP/m2.out" && ok "selftest: windows are not scored across a ledger hole" \
    || no "selftest: cadence was computed anyway, from a log with holes"
  build_ev "$TMP/h.md" ok 0; python3 "$B/tests/invariants.py" "$TMP/h.md" >/dev/null 2>&1; rc=$?
  crash $rc && [ $((rc & 8)) = 8 ] && ok "selftest: no session log reads UNKNOWN, never silent" || no "selftest: invariants PASSes with no session log (rc=$rc)"
  rm -f "$TMP"/*.session.jsonl
  # wordcount.py must fail on each thing it claims to measure, and skip what it cannot see
  { echo "# x"; echo '## transcript'; echo "body words here"; echo "- steady — $(yes word | head -26 | tr '\n' ' ')"; echo '## files after run'; } > "$TMP/opt.md"
  python3 "$B/tests/wordcount.py" "$TMP/opt.md" 160 >/dev/null 2>&1; rc=$?
  [ "$((rc & 2))" = 2 ] && ok "selftest: wordcount catches a long option (rc=$rc)" || no "selftest: wordcount MISSES a long option (rc=$rc)"
  { echo "# x"; echo '## transcript'; yes word | head -240 | tr '\n' ' '; echo; echo '## files after run'; } > "$TMP/turn.md"
  python3 "$B/tests/wordcount.py" "$TMP/turn.md" 160 >/dev/null 2>&1; rc=$?
  [ "$((rc & 1))" = 1 ] && ok "selftest: wordcount catches an over-budget turn (rc=$rc)" || no "selftest: wordcount MISSES an over-budget turn (rc=$rc)"
  { echo "# x"; echo '## transcript'; echo; echo '## files after run'; } > "$TMP/empty.md"
  python3 "$B/tests/wordcount.py" "$TMP/empty.md" 160 >"$TMP/empty.out" 2>&1; rc=$?
  { [ "$rc" = 0 ] && grep -q skip "$TMP/empty.out"; } && ok "selftest: wordcount skips an aborted run instead of passing it" || no "selftest: wordcount scored an aborted run (rc=$rc)"
  { echo "# x"; echo '## transcript'; echo '- steady — one two three'; echo "- sharp — $(yes word | head -22 | tr '\n' ' ')"; echo '## files after run'; } > "$TMP/both.md"
  python3 "$B/tests/wordcount.py" "$TMP/both.md" 160 >/dev/null 2>&1
  [ $? = 2 ] && ok "selftest: wordcount separates turn from appendix failures" || no "selftest: wordcount cannot say which limit rang"

  # the beat budget must bite on the bloated beat and name it, and stay quiet on a compliant one
  beat_ev(){ python3 - "$1" "$2" "$3" <<'L'
import sys
path, kind, cap = sys.argv[1], sys.argv[2], sys.argv[3]
fat = 'word ' * 60
lean = 'word ' * 30
b = fat if kind == 'fat' else lean
out = ['# x (skill) MULTI',
       'label: commit=deadbe guidance=abcd1234 spec_rev=R-9 words_per_turn=170 texture_cadence=4 reads_per_turn=3']
for i in range(2):
    out += [f'## turn {i+1}', 'writer: an answer',
            '**Digest.** ' + lean, '**Target.** ' + lean,
            '**Write back.** ' + b, '**Reflect.** ' + lean,
            '**Question.** Which crossing is oldest?', '**Stop.** `provoked: cost \u00b7 targeted: geography-routes`',
            '- steady \u2014 one two three', '']
out += ['## world/ contents', '--- ./world/index.md', 'tunables:', f'  beat_budget: {cap}', '']
out += ['- turn: 1 \u00b7 provoked: cost \u00b7 targeted: geography-routes',
        '- turn: 2 \u00b7 provoked: consequence \u00b7 targeted: daily-life', '']
open(path, 'w').write('\n'.join(out))
L
}
  beat_ev "$TMP/b1.md" fat 45; python3 "$B/tests/invariants.py" "$TMP/b1.md" >"$TMP/b1.out" 2>&1; rc=$?
  crash $rc && [ $((rc & 1)) = 1 ] && grep -q 'write back 60w > beat 45' "$TMP/b1.out" \
    && ok "selftest: the beat budget bites the bloated beat and names it" \
    || no "selftest: a 60-word beat inside a legal turn went unreported (rc=$rc) - beat budget inert"
  beat_ev "$TMP/b2.md" lean 45; python3 "$B/tests/invariants.py" "$TMP/b2.md" >"$TMP/b2.out" 2>&1; rc=$?
  crash $rc && [ $((rc & 1)) = 0 ] && grep -q 'beat budget 45' "$TMP/b2.out" \
    && ok "selftest: 30-word beats pass - the cap is not invented from thin air" \
    || no "selftest: compliant beats flagged (rc=$rc) - the beat rule is broken"
  beat_ev "$TMP/b3.md" lean 20; python3 "$B/tests/invariants.py" "$TMP/b3.md" >"$TMP/b3.out" 2>&1; rc=$?
  crash $rc && [ $((rc & 1)) = 1 ] && grep -q 'beat 20' "$TMP/b3.out" \
    && ok "selftest: beat budget is read from the world index, not hardcoded (20w bites)" \
    || no "selftest: beat_budget in the dumped index was ignored (rc=$rc) - the tunable is decorative"

  # F6: canon is append-only at the file level too, and the witness must see a file that only ever
  # existed during the run - a fixture-only check called the retcon runs clean while they deleted one
  cc(){ python3 "$B/tests/canoncheck.py" "$@" >"$TMP/cc.out" 2>&1; echo $?; }
  local CD="$TMP/cc"; rm -rf "$CD"; mkdir -p "$CD/fix/world/encyclopedia" "$CD/work/world/encyclopedia"
  for f in bridge toll; do echo '- established: one fact' > "$CD/fix/world/encyclopedia/$f.md"
    cp "$CD/fix/world/encyclopedia/$f.md" "$CD/work/world/encyclopedia/$f.md"; done
  echo '- established: transient' > "$CD/work/world/encyclopedia/generated.md"
  printf './world/encyclopedia/generated.md\n./world/encyclopedia/bridge.md\n./world/log.md\n' > "$CD/seen.txt"
  [ "$(cc --dir "$CD/work" --fixture "$CD/fix" --seen "$CD/seen.txt")" = 0 ] \
    && ok "selftest: canoncheck passes a whole world (known good, no false alarms)" \
    || no "selftest: canoncheck cries wolf on an untouched world (out: $(head -1 "$TMP/cc.out"))"
  rm "$CD/work/world/encyclopedia/toll.md"
  r=$(cc --dir "$CD/work" --fixture "$CD/fix" --seen "$CD/seen.txt")
  { [ "$r" = 1 ] && grep -q 'toll.md present at the start' "$TMP/cc.out"; } \
    && ok "selftest: canoncheck catches a fixture file deleted" || no "selftest: a deleted entity passed (rc=$r)"
  cp "$CD/fix/world/encyclopedia/toll.md" "$CD/work/world/encyclopedia/"
  rm "$CD/work/world/encyclopedia/generated.md"
  r=$(cc --dir "$CD/work" --fixture "$CD/fix" --seen "$CD/seen.txt")
  { [ "$r" = 1 ] && grep -q 'generated.md seen during the run' "$TMP/cc.out"; } \
    && ok "selftest: created-then-deleted is loss even though the fixture is intact" \
    || no "selftest: the created-then-deleted blind spot is still open (rc=$r)"
  echo '- established: transient' > "$CD/work/world/encyclopedia/generated.md"
  printf 'lighthouse-place\n' > /dev/null
  echo '- established: lighthouse' > "$CD/work/world/encyclopedia/lighthouse-place.md"
  printf './world/encyclopedia/lighthouse-place.md\n' >> "$CD/seen.txt"
  printf 'tool: bash\n{"command":"cd world && rm lighthouse-place.md"}\n' > "$CD/tr.md"
  r=$(cc --dir "$CD/work" --fixture "$CD/fix" --seen "$CD/seen.txt" --transcript "$CD/tr.md")
  { [ "$r" = 1 ] && grep -q 'attempted deletion' "$TMP/cc.out"; } \
    && ok "selftest: a bare 'rm lighthouse-place.md' is caught by name, not path" \
    || no "selftest: bare-path deletion slipped past (rc=$r) - the retcon case is unguarded"
  printf 'tool: bash\n{"command":"ls -1 world/encyclopedia && rm /tmp/scratch.md"}\n' > "$CD/tr2.md"
  r=$(cc --dir "$CD/work" --fixture "$CD/fix" --seen "$CD/seen.txt" --transcript "$CD/tr2.md")
  [ "$r" = 0 ] && ok "selftest: rm of an unrelated temp file is not canon loss" \
    || no "selftest: canoncheck flags unrelated deletions (rc=$r) - the gate will be worked around"
  printf 'tool: python\nos.remove("world/encyclopedia/bridge.md")\n' > "$CD/tr3.md"
  r=$(cc --dir "$CD/work" --fixture "$CD/fix" --seen "$CD/seen.txt" --transcript "$CD/tr3.md")
  [ "$r" = 1 ] && ok "selftest: os.remove of an entity is caught, not just shell rm" \
    || no "selftest: a python-side delete is invisible (rc=$r)"

  # I7: a printed score is arithmetic, so it is checkable. Three probes: the disclosure, the value,
  # and the bare-number form that hid improvised scoring for two revisions.
  score_ev(){ python3 - "$1" "$2" "$3" <<'L'
import sys
path, kind, gap = sys.argv[1], sys.argv[2], sys.argv[3]
shown = ('ecology-resources scores highest' if kind == 'bare'
         else 'ecology-resources scores %.1f (gap %s x 1.0 + hook 1 x 1.0 + contradiction 0 x 1.5)'
              % (int(gap) * 1.0 + 1.0, gap))
out = ['# x (skill) MULTI',
       'label: commit=deadbe guidance=abcd1234 spec_rev=R-11 words_per_turn=170 texture_cadence=4 reads_per_turn=3',
       '## turn 1', 'writer: an answer',
       '**Digest.** The ledger keeps its own word for a name.',
       '**Target.** ' + shown + '.',
       '**Write back.** Filed under ecology-resources.',
       '**Question.** Which crossing does the toll count twice?',
       '**Stop.** `provoked: cost`',
       '- steady \u2014 one two three', '',
       '## world/ contents', '--- ./world/index.md', '## Pillar coverage',
       '| pillar | entries | established | proposed | status |', '|---|---|---|---|---|',
       '| ecology-resources | 1 | 2 | 0 | thin |',
       '--- ./world/log.md', '## 2026-09-30 (session 5)',
       '- turn: 1 \u00b7 provoked: cost \u00b7 targeted: ecology-resources', '']
open(path, 'w').write('\n'.join(out))
L
}
  score_ev "$TMP/s1.md" terms 2; python3 "$B/tests/invariants.py" "$TMP/s1.md" >"$TMP/s1.out" 2>&1; rc=$?
  crash $rc && [ $((rc & 2)) = 0 ] && ! grep -q 'gap_weight' "$TMP/s1.out" \
    && ok "selftest: a correct disclosed score passes (thin pillar, gap 2)" \
    || no "selftest: the right arithmetic fails (rc=$rc) - the audit is not reading the table"
  score_ev "$TMP/s2.md" terms 3; python3 "$B/tests/invariants.py" "$TMP/s2.out" >/dev/null 2>&1
  python3 "$B/tests/invariants.py" "$TMP/s2.md" >"$TMP/s2.out" 2>&1; rc=$?
  crash $rc && [ $((rc & 2)) = 2 ] && grep -q 'gap_weight 3 contradicts index' "$TMP/s2.out" \
    && ok "selftest: gap 3 on a thin pillar is caught - the stale-index symptom, named" \
    || no "selftest: a wrong gap_weight slipped through (rc=$rc) - I7 unpinned"
  score_ev "$TMP/s3.md" bare 2; python3 "$B/tests/invariants.py" "$TMP/s3.md" >"$TMP/s3.out" 2>&1; rc=$?
  crash $rc && [ $((rc & 2)) = 2 ] && grep -q 'bare score' "$TMP/s3.out" \
    && ok "selftest: a score with no terms is flagged, not admired" \
    || no "selftest: 'scores highest' passed as evidence (rc=$rc) - the disclosure rule is decorative"

  score_ev "$TMP/s4.md" terms 3; python3 "$B/tests/invariants.py" "$TMP/s4.md" >"$TMP/s4.out" 2>&1; rc=$?
  { [ $((rc & 2)) = 2 ] && grep -q 'gap_weight 3 contradicts index' "$TMP/s4.out"; } \
    && ok "selftest: an undisciplined 'gap 3' is still checked against the table" \
    || no "selftest: value-only disclosure escapes the audit (rc=$rc) - I7's real form is unguarded"

  # the memo's own ceiling. It is exempt from the turn budget for the same reason options are, so it
  # needs a limit of its own or the exemption is just a hiding place - the longest memo on file is 203w
  memo_ev(){ python3 - "$1" "$2" "$3" <<'L'
import sys
path, per, cap = sys.argv[1], int(sys.argv[2]), sys.argv[3]
bullets = '\n'.join('- item %d: %s' % (i, 'word ' * (per - 2)) for i in range(5))
out = ['# x (skill) MULTI',
       'label: commit=deadbe guidance=abcd1234 spec_rev=R-14 words_per_turn=170 texture_cadence=4 reads_per_turn=3',
       '## transcript',
       '## turn 1', 'writer: an answer', '**Digest.** ' + 'filler ' * 26, '**Target.** faith-myth.',
       '**Memo** (review owed):', bullets,
       '**Question.** Which crossing is oldest?', '**Stop.** `provoked: review \u00b7 targeted: daily-life`',
       '- steady \u2014 one two three', '',
       '## world/ contents', '--- ./world/index.md', 'tunables:', '  memo_words: %s' % cap, '',
       '--- ./world/log.md', '## 2026-09-01 (session 1)', '- turn: 1 \u00b7 provoked: review \u00b7 targeted: daily-life']
open(path, 'w').write('\n'.join(out))
L
}
  memo_ev "$TMP/mm1.md" 12 120; python3 "$B/tests/invariants.py" "$TMP/mm1.md" >"$TMP/mm1.out" 2>&1; rc=$?
  crash $rc && [ $((rc & 2)) = 0 ] \
    && ok "selftest: a 5-bullet memo inside memo_words passes with its turn counted clean" \
    || no "selftest: a compliant memo fails (rc=$rc) - the exemption is not wired"
  memo_ev "$TMP/mm2.md" 30 120; python3 "$B/tests/invariants.py" "$TMP/mm2.md" >"$TMP/mm2.out" 2>&1; rc=$?
  { crash $rc && [ $((rc & 2)) = 2 ] && grep -q 'memo 15' "$TMP/mm2.out"; } \
    && ok "selftest: a 150-word memo fails on its own ceiling, not the turn cap" \
    || no "selftest: an over-long memo hid inside the exemption (rc=$rc)"
  memo_ev "$TMP/mm3.md" 30 200; python3 "$B/tests/invariants.py" "$TMP/mm3.md" >/dev/null 2>&1; rc=$?
  crash $rc && [ $((rc & 2)) = 0 ] \
    && ok "selftest: memo_words is read from the world index, not hardcoded" \
    || no "selftest: memo_words in the index is decorative (rc=$rc)"
  memo_ev "$TMP/mm4.md" 30 120; python3 "$B/tests/wordcount.py" "$TMP/mm4.md" 170 >"$TMP/mm4.out" 2>&1
  grep -qE 'turn words \(limit 170\)' "$TMP/mm4.out" && ! grep -qE 'OVER +[2-9][0-9][0-9] turn' "$TMP/mm4.out" \
    && ok "selftest: the memo is not counted as turn prose by wordcount either" \
    || no "selftest: wordcount still folds the memo into turn words (single-turn runs misreport)"

  # I5: the review contract, both halves. One probe per failure mode, plus the reset that proves the
  # trigger is arithmetic on log.md and not a mood.
  rv(){ printf '%s' "$1" > "$TMP/rv.md"; python3 "$B/tests/reviewcheck.py" --evidence "$TMP/rv.md" >"$TMP/rv.out" 2>&1; echo $?; }
  rvhdr(){ local n=$1 reset=${2:-0} body=''; for k in $(seq 1 "$n"); do body+=$(printf '\n## 2026-09-0%s (session %s)\n- turn: %s \u00b7 provoked: cost \u00b7 targeted: faith-myth' "$k" "$k" "$k"); [ "$reset" = 1 ] && [ "$k" = 2 ] && body+=$(printf '\n- turn: 2 \u00b7 provoked: review \u00b7 targeted: faith-myth'); done; printf '%s\n' "$body"; }
  MEMO='**Review.** Consistency memo: - contradictions: none found, by two checks - orphans: one, the lock-keeper links one way - texture-less pillars: power-systems has six facts and no kitchen - unvetted proposed: 12 lines waiting on you - treadmill: five of the last eight turns provoked cost'
  r=$(rv "# x$(rvhdr 2)
## transcript
writer: continue"; )
  [ "$r" = 0 ] && ok "selftest: two sessions in, no review owed - and not counted as a pass" \
    || no "selftest: a not-yet-due world scored as a failure (rc=$r)"
  r=$(rv "# x$(rvhdr 4)
## transcript
writer: continue"); [ "$r" = 1 ] && ok "selftest: four sessions with no review is REVIEW-OWED (trigger fires)" \
    || no "selftest: the owed-review case passed quietly (rc=$r) - I5's trigger is inert"
  r=$(rv "# x$(rvhdr 4 1)
## transcript
writer: continue
$MEMO"); [ "$r" = 0 ] && ok "selftest: a delivered review resets the count, and a full memo passes" \
    || no "selftest: a complete review after the reset fails (rc=$r)"
  r=$(rv "# x$(rvhdr 4 1)
## transcript
writer: continue
**Review.** Memo: - contradictions: none - orphans: two - proposed: some lines unvetted")
  { [ "$r" = 2 ] && grep -q 'texture-less pillars, treadmill' "$TMP/rv.out"; } \
    && ok "selftest: a three-item memo fails with the missing two named, not a shrug" \
    || no "selftest: an incomplete memo passed (rc=$r) - the five items are decorative"

  cat > "$TMP/rvinfra.md" <<'RV'
# x (skill) MULTI
## 2026-09-01 (session 3)
- turn: 9 · provoked: cost · targeted: faith-myth
INFRA-FAIL: turn 2 timed out
RV
  python3 "$B/tests/reviewcheck.py" --evidence "$TMP/rvinfra.md" >"$TMP/rvinfra.out" 2>&1; rc=$?
  [ "$rc" = 4 ] && grep -q NOT-GRADED "$TMP/rvinfra.out" \
    && ok "selftest: an aborted run is NOT-GRADED, neither a pass nor a breach" \
    || no "selftest: an aborted run was scored as evidence (rc=$rc)"
  # heredocs, not printf '%s\n' with escapes in the ARGUMENT: printf leaves \\n literal there, so the
  # fixture file was one long line and no session header matched - the probe failed, not the tool
  cat > "$TMP/rvthin.md" <<'RV'
# x (skill) MULTI
## transcript
writer: continue
RV
  cat > "$TMP/rvlog.md" <<'RV'
## 2026-09-01 (session 1)
## 2026-09-02 (session 2)
## 2026-09-03 (session 3)
## 2026-09-04 (session 4)
- turn: 4 · provoked: cost · targeted: faith-myth
RV
  python3 "$B/tests/reviewcheck.py" --evidence "$TMP/rvthin.md" --log "$TMP/rvlog.md" >"$TMP/rvthin.out" 2>&1; rc=$?
  [ "$rc" = 1 ] && ok "selftest: sessions are read from the log, not the evidence dump (ordering bug)" \
    || no "selftest: reviewcheck graded a half-written artifact and said 'not owed' (rc=$rc)"

  # the marker case, found on real evidence: an excellent memo that forgot to log itself
  cat > "$TMP/rvnomark.md" <<'RV'
# x (skill) MULTI
## transcript
writer: continue
**Memo** (review owed, sessions 1-4):
- contradictions: none found, by two checks
- orphans: one
- texture-less pillars: power-systems has six facts and no kitchen
- unvetted proposed: 12 lines waiting
- treadmill: five of the last eight provoked cost
**Stop.** `provoked: cost \u00b7 targeted: faith-myth`
## world/ contents
--- ./world/log.md
## 2026-09-01 (session 1)
## 2026-09-02 (session 2)
## 2026-09-03 (session 3)
## 2026-09-04 (session 4)
- turn: 4 \u00b7 provoked: cost \u00b7 targeted: faith-myth
RV
  python3 "$B/tests/reviewcheck.py" --evidence "$TMP/rvnomark.md" >"$TMP/rvnomark.out" 2>&1; rc=$?
  crash $rc && [ $((rc & 4)) = 4 ] \
    && ok "selftest: a complete memo that never logged provoked: review still fails" \
    || no "selftest: an unlogged review reads as done (rc=$rc) - next session reviews again"
  cat > "$TMP/rvalt.md" <<'RV'
# x (skill) MULTI
## transcript
writer: continue
**Memo** (review owed):
1. contradictions - two, cited
2. orphans - one
3. texture-less - fifteen pillars carry canon, one pair of hands carries it
4. unvetted proposed - none by the rule
5. treadmill - unverifiable, the ledger is short
## world/ contents
--- ./world/log.md
## 2026-09-01 (session 1)
## 2026-09-02 (session 2)
## 2026-09-03 (session 3)
RV
  python3 "$B/tests/reviewcheck.py" --evidence "$TMP/rvalt.md" >"$TMP/rvalt.out" 2>&1; rc=$?
  crash $rc && [ $((rc & 2)) = 0 ] \
    && ok "selftest: a memo numbered 1-5 passes; the detector matches the artifact, not a heading" \
    || no "selftest: a complete memo failed on formatting (rc=$rc: $(head -2 "$TMP/rvalt.out" | tr '\n' ' '))"

  # option length: the cap counts the option, not the '- steady —' that labels it. The first version
  # of this instrument added a flat +3 to every line and manufactured breaches (F9's twin).
  opt_ev(){ python3 - "$1" "$2" "$3" <<'L'
import sys
path, words, cap = sys.argv[1], int(sys.argv[2]), sys.argv[3]
body = 'word ' * words
out = ['# x (skill) MULTI',
       'label: commit=deadbe guidance=abcd1234 spec_rev=R-13 words_per_turn=170 texture_cadence=4 reads_per_turn=3',
       '## transcript', '## turn 1', 'writer: an answer', '**Digest.** Filed.', '**Target.** faith-myth.',
       '**Question.** Which crossing is oldest?',
       '- steady \u2014 ' + body.strip(), '- sharp \u2014 one two three', '',
       '## files after run', '## world/ contents', '--- ./world/index.md', 'tunables:', f'  option_words: {cap}', '']
open(path, 'w').write('\n'.join(out))
L
}
  opt_ev "$TMP/o1.md" 18 18; python3 "$B/tests/invariants.py" "$TMP/o1.md" >"$TMP/o1.out" 2>&1; rc=$?
  crash $rc && [ $((rc & 2)) = 0 ] && ok "selftest: an 18-word option passes with its label counted out (21 tokens)" \
    || no "selftest: markup is still counted as words (rc=$rc) - the +3 inflation is back"
  python3 "$B/tests/wordcount.py" "$TMP/o1.md" 170 >"$TMP/o1w.out" 2>&1
  grep -q 'longest 18' "$TMP/o1w.out" && ok "selftest: wordcount reports the option, not the bullet" \
    || no "selftest: wordcount still reports label tokens ($(grep -o 'longest [0-9]*' "$TMP/o1w.out"))"
  opt_ev "$TMP/o2.md" 19 18; python3 "$B/tests/invariants.py" "$TMP/o2.md" >"$TMP/o2.out" 2>&1; rc=$?
  crash $rc && [ $((rc & 2)) = 2 ] && grep -q 'option 19w' "$TMP/o2.out" \
    && ok "selftest: a genuinely long option still fails" || no "selftest: the fix swallowed real breaches (rc=$rc)"
  opt_ev "$TMP/o3.md" 14 12; python3 "$B/tests/invariants.py" "$TMP/o3.md" >"$TMP/o3.out" 2>&1; rc=$?
  crash $rc && [ $((rc & 2)) = 2 ] && ok "selftest: option_words is read from the world, not hardcoded" \
    || no "selftest: option_words in the index is decorative (rc=$rc)"

  # I4: the seed validator must bite in both directions, on synthetic worlds it builds itself
  seed_mk(){ python3 - "$1" "$2" "$3" "$4" <<'L'
import sys, os, shutil, glob
d, n, mode, threads = sys.argv[1], int(sys.argv[2]), sys.argv[3], int(sys.argv[4])
shutil.rmtree(d, ignore_errors=True); os.makedirs(d + '/encyclopedia')
P = ['geography-routes', 'power-systems', 'faith-myth', 'ecology-resources', 'daily-life', 'history-periodisation']
for i in range(n):
    pl = ['geography-routes'] if mode == 'onepillar' else [P[i % len(P)]]
    head = '' if mode == 'notags' else 'pillars: [%s]' % ', '.join(pl)
    lines = ['# entity %d' % i, '', '---', 'kind: place ' + head, '---', '',
             '- proposed: a claim the writer has not confirmed']
    if mode == 'canon': lines.append('- established: canon a seed may not declare')
    open('%s/encyclopedia/entity-%02d.md' % (d, i), 'w').write('\n'.join(lines) + '\n')
rows = '\n'.join('| T-%03d | q | seed | x |' % k for k in range(threads))
open(d + '/threads.md', 'w').write('# Threads\n\n| id | q | from | p |\n|---|---|---|---|\n' + rows + '\n')
open(d + '/index.md', 'w').write('# idx\n')
L
}
  seed_run(){ python3 "$B/tests/seedcheck.py" "$1" >"$TMP/seed.out" 2>&1; echo $?; }
  seed_mk "$TMP/sg" 6 ok 18; r=$(seed_run "$TMP/sg")
  crash $r && [ "$r" = 0 ] && ok "selftest: a 6-entity seed with spread and threads passes (known good)" \
    || no "selftest: a correct seed fails (rc=$r) - the band is wrong or the parser is broken"
  seed_mk "$TMP/s3" 3 ok 9;  r=$(seed_run "$TMP/s3");  crash $r && [ $((r & 1)) = 1 ] \
    && ok "selftest: a 3-entity seed is under-band" || no "selftest: an under-seeded world passed (rc=$r)"
  seed_mk "$TMP/s9" 9 ok 27; r=$(seed_run "$TMP/s9"); crash $r && [ $((r & 1)) = 1 ] \
    && ok "selftest: a 9-entity seed is over-band - volume is not rigour" \
    || no "selftest: an over-seeded world passed (rc=$r)"
  seed_mk "$TMP/sp" 6 onepillar 18; r=$(seed_run "$TMP/sp")
  crash $r && [ $((r & 2)) = 2 ] && ok "selftest: nine bridges and no kitchens is caught (texture absent)" \
    || no "selftest: a seed with no texture pillar passed (rc=$r) - R-8 does not reach turn one"
  seed_mk "$TMP/sc" 6 canon 18; r=$(seed_run "$TMP/sc")
  crash $r && [ $((r & 4)) = 4 ] && ok "selftest: a seed that declares established canon is caught" \
    || no "selftest: premature canon passed (rc=$r)"
  seed_mk "$TMP/st" 6 ok 6; r=$(seed_run "$TMP/st")
  crash $r && [ $((r & 8)) = 8 ] && ok "selftest: 6 entities with 6 threads is under-provisioned" \
    || no "selftest: a thread-starved seed passed (rc=$r) - rotation will starve later"
  seed_mk "$TMP/sn" 6 notags 18; r=$(seed_run "$TMP/sn")
  crash $r && [ $((r & 2)) = 2 ] && ok "selftest: an entity file with no pillars: line cannot hide" \
    || no "selftest: untagged entities passed the spread check (rc=$r)"
  r=$(seed_run "$TMP/does-not-exist"); crash $r && [ $((r & 1)) = 1 ] \
    && ok "selftest: an empty world is under-band, not a crash" || no "selftest: no-world case mishandled (rc=$r)"
  python3 "$B/tests/seedcheck.py" 2>/dev/null; r=$?
  [ "$r" != 0 ] && ok "selftest: seedcheck refuses to report success with no arguments (rc=$r)" \
    || no "selftest: seedcheck exits 0 with no world dir - a gate that passes on nothing"

  # regression witness, on evidence rather than synthetic input: two runs the old fixture-only check
  # certified as canon-clean did `rm encyclopedia/lighthouse-place.md` mid-session. If the detector ever
  # drifts back to blindness, this fails on real transcripts, not just on my hand-built ones.
  for j in "$REPO"/evidence/retcon-skill-multi-20260930T041517Z.md.session.jsonl \
           "$REPO"/evidence/close-skill-multi-20260930T160047Z.md.session.jsonl; do
    if [ -f "$j" ]; then
      python3 "$B/tests/canoncheck.py" --dir "$B/tests/fixtures/established" --transcript "$j" \
        >"$TMP/ccx.out" 2>&1; rc=$?
      crash $rc && [ $rc = 1 ] && grep -q 'attempted deletion' "$TMP/ccx.out" \
        && ok "selftest: detector still flags a past run the old gate passed ($(basename "$j" | cut -c1-28))" \
        || no "selftest: a historically blind run now reads clean (rc=$rc) - the witness regressed"
    fi
  done

  # guidance_key() must move when guidance moves, and NOT move when only a test moves
  local k1 k2; k1=$(guidance_key)
  cp "$B/references/voice.md" "$TMP/voice.bak"
  printf '\n<!-- probe -->\n' >> "$B/references/voice.md"; k2=$(guidance_key)
  [ "$k1" != "$k2" ] && ok "selftest: guidance key tracks a change to references/" || no "selftest: guidance key ignores edited guidance - evidence would be mislabelled"
  # the BACKUP LINE WAS MISSING for four runs: the marker was appended, the restore no-op'd (|| true hid
  # it), voice.md accumulated four '<!-- probe -->' blocks the model then read as guidance, and the
  # suite reported a key round-trip it had not performed
  cp "$TMP/voice.bak" "$B/references/voice.md"
  [ "$(guidance_key)" = "$k1" ] && ok "selftest: guidance key restored with the file" || no "selftest: guidance key unstable across a restore"
  k2=$( { cd "$REPO" && git rev-parse HEAD:bundle/worldbuilding/tests | cksum; } | awk '{printf "%08x",$1}')
  [ "$k1" != "$k2" ] && ok "selftest: guidance key is not the bundle tree hash (tests excluded)" || no "selftest: guidance key degenerated to a bundle hash"

  rm -rf "$TMP"
}
fixture(){
  # I12: derived tables must equal what the entity files imply. scoreboard.py owns the counting rule.
  if python3 "$B/tests/scoreboard.py" "$B/tests/fixtures/established/world" --diff >/tmp/fx.$$ 2>&1; then
    ok "fixture index agrees with its entity files"
  else
    no "fixture index drifts from the files (I12): $(grep -c 'index' /tmp/fx.$$) rows"; sed 's/^/       /' /tmp/fx.$$ | head -6
  fi; rm -f /tmp/fx.$$
  local d; d=$(grep -rl 'lockkeepers-daughter' "$B/tests/fixtures/established/world" | wc -l)
  [ "$d" -ge 3 ] && ok "the daughter the log claims is a real entity ($d files reference her)" || no "log.md canon still unbacked ($d files)"
}

case "${1:-all}" in
  harness) harness;; fixture) fixture;; behavior) behavior;; multi) multi;; templates) templates;; rubric) rubric;; voice) voice;;
  method) method;; kit) kit;; selftest) selftest;;
  all)
    echo "[selftest]"; selftest; meta
    if [ "$selftest_bad" = 1 ]; then
      echo "check.sh: SELFTEST FAILED - the assertion helper is broken; refusing to run the gate"
      echo "check.sh: $PASS passed, $FAIL failed"; exit 2
    fi
    for f in harness fixture templates rubric voice method kit; do echo "[$f]"; $f; done;;
esac
echo "check.sh: $PASS passed, $FAIL failed"; [ "$FAIL" = 0 ]
