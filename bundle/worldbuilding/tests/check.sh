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
  grep -qi 'empty' "$S" && grep -qi 'gap_weight' "$S" && ok "gap_weight polarity documented" || no "gap_weight polarity missing"
  has "write boundary names world/" "$S" 'world/'
  # R-4: the consecutive-pillar rule is only obeyable if the target is recorded
  has "turn log records the targeted pillar (R-4)" "$S" 'targeted: <pillar>'
  has "log line shape documented in the template" "$B/assets/index-template.md" 'targeted: <pillar>'
  # R-6: the read cap became a scale tripwire wired to a tunable, in guidance, template and fixture
  has "the body-read tripwire names the tunable (R-6)" "$S" 'reads_per_turn'
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
    || no "multi-turn invariant breached (bitmask $rc: 1 words, 2 appendix, 4 questions, 8 reads, 16 cadence, 32 provocation, 64 consecutive pillar; plus canon-loss and eaten-turn flags)"
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
import sys
path, mode, sess = sys.argv[1], sys.argv[2], sys.argv[3]
tg = ['history-periodisation', 'politics-power', 'geography-routes', 'daily-life', 'voice-attention']
pv = ['connection', 'constraint', 'cost', 'consequence', 'stake']
out = ['# x (skill) MULTI',
       'label: commit=deadbe bundle=abcd1234 spec_rev=R-3 words_per_turn=160 texture_cadence=4']
for i in range(5):
    t, p = tg[i], pv[i]
    # a pillar that RECURS without ever being consecutive: legal under spec §4, and the old probe
    # asserted the opposite because I wrote a list with turns 1-2 identical
    if mode == 'same-pillar': t = ['geography-routes', 'daily-life', 'geography-routes',
                                   'voice-attention', 'politics-power'][i]
    if mode == 'consecutive-logged': t = ['history-periodisation', 'politics-power', 'politics-power',
                                          'daily-life', 'voice-attention'][i]
    if mode == 'unlogged': t = ['history-periodisation', 'politics-power', 'daily-life',
                               'voice-attention', 'geography-routes'][i]
    if mode == 'no-texture':  t = ['history-periodisation', 'politics-power', 'geography-routes',
                                   'institutions-law', 'ecology-resources'][i]
    if mode == 'provoked-repeat': p = 'connection'
    q = '**Question.** Which crossing is oldest?'
    if mode == 'double-question' and i == 2: q = '**Question.** Which crossing is oldest? And which is widest?'
    body = '**Digest.** ok.'
    if mode == 'long-turn' and i == 1: body = '**Digest.** ' + 'word ' * 200
    stop = f'**Stop.** `provoked: {p}'
    stop += f' · targeted: {t}`' if mode != 'unlogged' else '`'
    out += [f'## turn {i+1}', 'writer: an answer', body, f'**Target.** {t}.',
            stop, q, '- steady — one two three', '']
open(path, 'w').write('\n'.join(out) + '## files after run\n')
if int(sess):
    n = int(sess)
    recs = []
    for i in range(5):
        recs.append('{"type":"message","message":{"role":"user","content":[]}}')
        calls = [{'type': 'toolCall', 'name': 'read', 'arguments': {'path': f'world/encyclopedia/x{j}.md'}}
                 for j in range(n)]
        recs.append('{"type":"message","message":{"role":"assistant","content":%s}}' % __import__('json').dumps(calls))
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
  crash $rc && [ $((rc & 64)) = 0 ] && grep -q 'targeted:. logged in' "$TMP/e3.out" \
    && ok "selftest: an unlogged target is announced as missing state, never scored silently" \
    || no "selftest: invariants scored targets it could not see (rc=$rc)"
  build_ev "$TMP/f.md" no-texture 2; python3 "$B/tests/invariants.py" "$TMP/f.md" >/dev/null 2>&1; rc=$?
  crash $rc && [ $((rc & 16)) = 16 ] && ok "selftest: invariants catches texture never asked within cadence" || no "selftest: invariants MISSES a cadence breach (rc=$rc)"
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

  # guidance_key() must move when guidance moves, and NOT move when only a test moves
  local k1 k2; k1=$(guidance_key)
  printf '\n<!-- probe -->\n' >> "$B/references/voice.md"; k2=$(guidance_key)
  [ "$k1" != "$k2" ] && ok "selftest: guidance key tracks a change to references/" || no "selftest: guidance key ignores edited guidance - evidence would be mislabelled"
  git -C "$REPO" checkout -- "$B/references/voice.md" 2>/dev/null || true
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
