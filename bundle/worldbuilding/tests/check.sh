#!/usr/bin/env bash
# Mechanically checkable assertions for the worldbuilding skill. Dev fixture only.
# usage: bash tests/check.sh <harness|templates|rubric|voice|method|kit|selftest|all>
set -uo pipefail
export PYTHONDONTWRITEBYTECODE=1  # the suite imports these modules; a .pyc under bundle/ is shipped debris
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
  has "seed band applies to entity files (I4)" "$B/SKILL.md" 'entity files'
  has "seeding shape documented in the rubric (I4)" "$B/references/rubric.md" 'Seeding a new world'
  has "seed texture rule stated (I4/R-8)" "$B/references/rubric.md" 'texture pillar'
  has "seed thread floor stated (I4)" "$B/references/rubric.md" '3 threads per seeded entity'
  has "a new-world scenario exists" "$B/tests/prompts/new-world.txt" 'canal city'
  has "the new-world scenario is wired into the harness" "$B/tests/run.sh" 'new-world'
  has "a you-pick scenario exists (R-27)" "$B/tests/prompts/you-pick.txt" 'premise'
  has "the you-pick scenario is wired into the harness" "$B/tests/run.sh" 'you-pick'
  # R-27: the branch has to be readable where the model will look at it, not only in the spec's revision
  # log - a decision that lives in one file is a decision the next reader will re-litigate
  yp=$(grep -rl 'you pick' "$B/SKILL.md" "$B/references" "$B/tests/prompts" 2>/dev/null | wc -l)
  if [ "$yp" -ge 3 ]; then ok "the you-pick branch is stated in $yp shipped places"
  else no "you-pick branch thin: 'you pick' found in $yp places (want >=3)"; fi
  has "seedcheck wired into the single-turn harness" "$B/tests/run.sh" 'seedcheck'
  has "review trigger named in SKILL (I5)" "$B/SKILL.md" 'names `review`'
  has "the memo is named in SKILL (I5)" "$B/SKILL.md" 'the memo'
  has "review trigger lives in the continue procedure (I5)" "$B/SKILL.md" 'score from files. At ≥3 sessions'
  has "the trigger names the count it checks (I5)" "$B/SKILL.md" 'names .review., end the turn with the memo'
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
  for t in words_per_turn texture_cadence reads_per_turn beat_budget turns_per_session memo_item_words option_words; do
    n=$(grep -rl "$t" "$B/SKILL.md" "$B/references" "$B/assets" "$B/tests/fixtures/established/world/index.md" 2>/dev/null | wc -l)
    [ "$n" -ge 3 ] || { missing=1; no "tunable $t appears in only $n places - a rule with no home"; }
  done
  [ $missing = 0 ] && ok "every tunable is named in template, fixture and guidance"
  # Every number the skill enforces needs a stated origin, or it is a taste with a decimal point on it.
  # docs/tunables.md is generated from the corpus by tools/tunable_provenance.py; this checks coverage -
  # that each enforced name has a row, and that a row with no evidence admits it in words.
  local prov="$REPO/docs/tunables.md" pt pmiss=0 bare
  if [ -f "$prov" ]; then
    for pt in words_per_turn texture_cadence reads_per_turn beat_budget turns_per_session memo_item_words option_words lopsidedness_floor gap_weight; do
      grep -q "\`$pt" "$prov" || { pmiss=1; no "enforced tunable $pt has no provenance row"; }
    done
    [ $pmiss = 0 ] && ok "every enforced tunable has a provenance row in docs/tunables.md"
    { grep -q "absent from its sample" "$prov" && grep -q "tools/tunable_provenance.py" "$prov"; } \
      && ok "the table states the mode rule and names the command that regenerates it" \
      || no "the table lost its mode rule or its regeneration command - the numbers become folklore"
    bare=$(awk -F'|' '/^\| `/{if ($5 !~ /n=|not measured|no run varies|never emitted|n=1/) print $2}' "$prov")
    [ -z "$bare" ] && ok "no tunable row reports neither a sample nor an explicit absence" \
      || no "tunable row(s) with an empty measured column: $bare"
  else
    no "docs/tunables.md missing - tunables would be enforced with no recorded origin"
  fi
  # The spec used to carry defaults the bundle had already moved past - three of them, in the section a
  # newcomer reads first. A decision recorded only in a commit message is one that gets re-litigated
  # from stale text, so the two files are now compared key by key.
  spec=$(ls "$REPO"/docs/superpowers/specs/*.md 2>/dev/null | head -1)
  if [ -f "$spec" ]; then
    drift=$(python3 - "$spec" "$B/assets/index-template.md" <<'PYDRIFT'
import re, sys
def block(path):
    """The `tunables:` mapping in a file: keys at line start, comments ignored.

    The first version ran a key:value regex over the whole block, so a comment reading "a tripwire,
    not a ration: needing more" contributed a key called `ration` and the check reported a drift that
    existed only in its own parser.
    """
    t = open(path).read()
    m = re.search(r"tunables:\n((?:[ \t]+\S.*\n)+)", t)
    if not m:
        return None
    out = {}
    for line in m.group(1).split("\n"):
        line = line.split("#")[0].rstrip()
        km = re.match(r"^\s*([a-z_]+):\s*([^\s].*)$", line)
        if km:
            out[km.group(1)] = km.group(2).strip()
    return out
a, b = block(sys.argv[1]), block(sys.argv[2])
if a is None or b is None:
    print("no tunables block found in the " + ("spec" if a is None else "index template")
          + " - the comparison silently stopped being possible")
    sys.exit()
bad = []
for k in sorted(set(a) | set(b)):
    if k not in a:
        bad.append(k + ": shipped, absent from the spec")
    elif k not in b:
        bad.append(k + ": in the spec, not shipped")
    elif a[k] != b[k]:
        bad.append(k + ": spec says " + a[k] + ", bundle ships " + b[k])
print("; ".join(bad))
PYDRIFT
    )
    if [ -z "$drift" ]; then
      ok "spec defaults match the shipped index template (no drift from git-only decisions)"
    else
      no "spec and bundle disagree on tunables: $drift"
    fi
  fi
  # The same failure mode one file over: a provenance table whose numbers were typed from memory.
  # It quoted lopsidedness_floor 0.34 for a tunable that ships 0.6 - inside a document whose entire
  # purpose is to stop numbers becoming folklore.
  val=$(python3 - "$REPO/docs/tunables.md" "$B/assets/index-template.md" <<'PYVAL'
import re, sys
def tmpl(path):
    t = open(path).read()
    m = re.search(r"tunables:\n((?:[ \t]+\S.*\n)+)", t)
    out = {}
    for line in (m.group(1).split("\n") if m else []):
        line = line.split("#")[0].rstrip()
        km = re.match(r"^\s*([a-z_]+):\s*([^\s].*)$", line)
        if km:
            out[km.group(1)] = km.group(2).strip()
    return out
t = tmpl(sys.argv[2])
doc = open(sys.argv[1]).read()
bad = []
for k, v in re.findall(r"`([a-z_]+):?\s?([0-9][0-9.]*)`", doc):
    if k in t and t[k] != v:
        bad.append(k + ": table says " + v + ", bundle ships " + t[k])
print("; ".join(sorted(set(bad))))
PYVAL
  )
  if [ -z "$val" ]; then
    ok "docs/tunables.md quotes the shipped defaults, not remembered ones"
  else
    no "provenance table disagrees with the shipped defaults: $val"
  fi
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
  # compiled debris is the same mistake with worse consequences: a tracked .pyc under bundle/ ships to
  # the writer AND rewrites itself on every test run, so "is the tree dirty?" stops being a signal
  junk=$(find "$B" \( -name '__pycache__' -o -name '*.pyc' -o -name '*.orig' -o -name '*.rej' \) -print | head -3)
  [ -z "$junk" ] \
    && ok "the shipped bundle carries no compiled debris" \
    || no "shipped bundle carries debris: $(echo $junk | tr '\n' ' ') - delete it and ignore it"
  tj=$(git -C "$REPO" ls-files "$B" 2>/dev/null | grep -E '__pycache__|\.pyc$' | head -3)
  [ -z "${tj:-}" ] \
    && ok "no compiled debris is tracked in git" \
    || no "git still tracks compiled debris: $(echo ${tj:-} | tr '\n' ' ')"
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
  # G4: the close recap is an appendix that does not count against `words_per_turn` - which is only true
  # if a recap bullet is identifiable. Guidance said "3-6 recap bullets" and never their shape, so runs
  # wrote citations at the end of long sentences and every close turn was graded as prose (175 and 256
  # words, on runs whose recap was exempt by design). The shape is now stated in three places, and the
  # assertion below is the one that matters: it feeds the documented shape to the counter and requires
  # the counter to see an appendix. Guidance and instrument agreeing is not assumed anywhere.
  cite=$(grep -rl 'citation first' "$S" "$B/references" "$B/assets" 2>/dev/null | wc -l)
  if [ "$cite" -ge 3 ]; then ok "the close recap has one stated shape ($cite files say citation first)"
  else no "recap shape thin: 'citation first' in $cite files (want >=3)"; fi
  # a path of its own: $TMP belongs to selftest() and is not set in this function, which is how the
  # first draft of this assertion killed the whole run on an unbound variable
  rcf=$(mktemp)
  { echo "# T"; echo '## transcript'; echo; echo '## turn 1'
    echo 'One short question about the lock.'
    echo 'Session 1 closed at turn 1 of 12. Written back to `world/`:'
    for i in 1 2 3 4 5 6; do
      printf -- '- `bridge-tolls-%d`, `T-014` — the Council did not build the lock and the ledger predates it by forty years of tide tables and quiet forgery\n' "$i"
    done
    echo; echo '## files after run'; } > "$rcf"
  out=$(python3 "$B/tests/wordcount.py" "$rcf" 170 2>&1); rm -f "$rcf"
  seen=$(echo "$out" | grep -oE '[0-9]+ recap bullets' | grep -oE '[0-9]+' | head -1)
  counted=$(echo "$out" | grep -oE '[0-9]+ turn words' | grep -oE '^[0-9]+' | head -1)
  if [ "${seen:-0}" = 6 ] && [ "${counted:-999}" -lt 40 ]; then
    ok "the documented recap shape reads as an appendix (6 bullets seen, $counted turn words counted)"
  else
    no "recap exemption unverifiable: bullets recognised=${seen:-0}/6, turn words counted=${counted:-?} (want 6 and <40)"
  fi
  # R-25: reaction mode's six lines are an appendix with a bound of their own - not turn prose, and not
  # an exemption granted by shape (that was F1, where the same six lines either vanished from the cap or
  # counted against it depending on where the citation sat). Three sides, all machine-checked: a clean
  # sketch is exempt from words_per_turn and unflagged; one fat line fails sketch_words; seven lines
  # fails the count. The fat-line and long-block cases must ALSO stay out of the turn count, or the fix
  # just moved the leak.
  skmk(){ { echo "# T"; echo '## transcript'; echo; echo '## turn 1'
      echo 'One short question about the lock.'
      for i in $(seq 1 "$2"); do
        printf -- '- `bridge-tolls-%d` — the Council did not build the lock and the ledger predates it by tide tables%s\n' "$i" "$3"
      done
      echo; echo '## files after run'; } > "$1"; }
  ska=$(mktemp); skb=$(mktemp); skc=$(mktemp)
  skmk "$ska" 6 ''
  skmk "$skb" 6 ', and the sexton rang the wrong bell on purpose, which nobody had authorised at all'
  skmk "$skc" 7 ''
  oa=$(python3 "$B/tests/wordcount.py" "$ska" 170 2>&1); ra=$?
  ob=$(python3 "$B/tests/wordcount.py" "$skb" 170 2>&1); rb=$?
  oc=$(python3 "$B/tests/wordcount.py" "$skc" 170 2>&1); rc=$?
  rm -f "$ska" "$skb" "$skc"
  wa=$(echo "$oa" | grep -oE '[0-9]+ turn words' | grep -oE '^[0-9]+')
  wb=$(echo "$ob" | grep -oE '[0-9]+ turn words' | grep -oE '^[0-9]+')
  if [ "$ra" = 0 ] && [ "$(echo "$oa" | grep -c '6 sketch lines')" = 1 ] && [ "${wa:-999}" -lt 40 ]; then
    ok "a clean sketch is an appendix, not prose (6 lines, ${wa}w counted against the turn cap, rc=0)"
  else
    no "sketch path wrong: rc=$ra lines=$(echo "$oa" | grep -oE '[0-9]+ sketch lines' | head -1) counted=${wa:-?} (want rc=0, 6 lines, <40)"
  fi
  if echo "$ob" | grep -q 'over sketch_words' && [ $((rb & 2)) = 2 ] && [ "${wb:-999}" -lt 60 ]; then
    ok "a 26-word sketch line fails its own bound (${wb}w counted for the turn, so the bound is real)"
  else
    no "fat sketch line went unmeasured (rc=$rb, counted=${wb:-?}) - sketch_words is decoration"
  fi
  if echo "$oc" | grep -q 'sketch > 6' && [ $((rc & 2)) = 2 ]; then
    ok "a seven-line sketch is flagged as a count breach, not as prose"
  else
    no "seven-line sketch not flagged by count (rc=$rc) - the block has no ceiling"
  fi
  # F2, both sides: the harness echo is excluded because of where it sits, not because of the token it
  # starts with. Prose that merely begins with that token must still be counted, or the cap is opt-out.
  f2a=$(mktemp); f2b=$(mktemp)
  { echo "# T"; echo '## transcript'; echo; echo '## turn 1'
    echo 'writer: tell me about the toll house'
    echo 'One short question about the lock, which stands on two rocks.'
    echo; echo '## files after run'; } > "$f2a"
  { echo "# T"; echo '## transcript'; echo; echo '## turn 1'
    echo 'writer: tell me about the toll house'
    echo 'One short question about the lock, which stands on two rocks.'
    echo 'writer: and then the whole militia of the lower quarter walked out onto the ice at dawn, which nobody had authorised, and the sexton rang the wrong bell on purpose'
    echo; echo '## files after run'; } > "$f2b"
  wa=$(python3 "$B/tests/wordcount.py" "$f2a" 170 2>&1 | grep -oE '[0-9]+ turn words' | grep -oE '^[0-9]+' | head -1)
  wb=$(python3 "$B/tests/wordcount.py" "$f2b" 170 2>&1 | grep -oE '[0-9]+ turn words' | grep -oE '^[0-9]+' | head -1)
  d=$(( ${wb:-0} - ${wa:-0} ))
  if [ "${wa:-999}" -le 20 ] && [ "$d" -ge 25 ] && [ "$d" -le 40 ]; then
    ok "the echo is skipped by position, prose is counted by weight (${wa}w baseline, +${d}w from a 31-word line)"
  else
    no "writer: exclusion is not positional: baseline=${wa:-?}, delta=$d (want <=20 and 25-40)"
  fi
  rm -f "$f2a" "$f2b"
  # R-27, the archive-shaped version of that test. turns_of splits on the turn HEADER INCLUDING ITS
  # DIGITS, so no `^## turn` line is left above the echo - which is how prompt text silently became prose
  # for a whole revision while the transcript-shaped guard right above stayed green. Three sides, and all
  # of them in the shape real multi artifacts actually have.
  eca=$(mktemp); ecb=$(mktemp); ecc=$(mktemp)
  PROSE='**Digest.** the ledger is thin on `daily-life`: the tollhouse keeps three entities and the ninth bridge still has no kitchens, so the archive is one long corridor of bridges and nobody has described a breakfast, which is the hole that shows up later as a world nobody can inhabit.\n**Target.** `bridge-tolls`, because it cites `ninth-bridge`.\n**Question.** who is allowed to sleep under a bridge that charges a name?\n'
  { printf '# e (skill) MULTI\nlabel: commit=cafe001 guidance=23e6e3af words_per_turn=170\n\n## turn 1\n'
    printf 'writer: the harness put these nine words here, not the model, so count them not\n'
    printf "$PROSE"; } > "$eca"
  { printf '# e (skill) MULTI\nlabel: commit=cafe001 guidance=23e6e3af words_per_turn=170\n\n## turn 1\n'
    printf 'writer: the harness put these nine words here, not the model, so count them not, and here are fifteen further words of scripted prompt text that belong to nobody\n'
    printf "$PROSE"; } > "$ecb"
  { printf '# e (skill) MULTI\nlabel: commit=cafe001 guidance=23e6e3af words_per_turn=170\n\n## turn 1\n'
    printf 'writer: the harness put these nine words here, not the model, so count them not\n'
    printf "$PROSE"
    printf 'writer: and here are fifteen more words that begin with the token but sit in the middle of the answer, which is the laundering channel\n'; } > "$ecc"
  wa=$(python3 "$B/tests/wordcount.py" "$eca" 170 2>&1 | grep -oE '[0-9]+ turn words' | grep -oE '^[0-9]+')
  wb=$(python3 "$B/tests/wordcount.py" "$ecb" 170 2>&1 | grep -oE '[0-9]+ turn words' | grep -oE '^[0-9]+')
  wc_=$(python3 "$B/tests/wordcount.py" "$ecc" 170 2>&1 | grep -oE '[0-9]+ turn words' | grep -oE '^[0-9]+')
  rm -f "$eca" "$ecb" "$ecc"
  if [ "${wa:-x}" = "${wb:-y}" ]; then
    ok "the echo is excluded in ARCHIVE shape too (${wa}w either way; R-24's regression cannot return quietly)"
  else
    no "prompt text counted as prose in the multi parse path (${wa}w vs ${wb}w) - the split leaves no header above the echo"
  fi
  d=$(( ${wc_:-0} - ${wa:-0} ))
  if [ "$d" -ge 12 ] && [ "$d" -le 25 ]; then
    ok "a mid-turn writer: line still counts in archive shape (+${d}w) - the exemption is positional, not a token"
  else
    no "mid-turn writer: line delta=$d (want 12-25) - either the channel is open or the fix is over-broad"
  fi
  # R-27's behaviour: a writer who declines the premise is dealt three, never asked again.
  ypa=$(mktemp); ypb=$(mktemp); ypc=$(mktemp)
  { printf '# y (skill) MULTI\nlabel: commit=cafe002 guidance=23e6e3af words_per_turn=170 texture_cadence=4 reads_per_turn=3 beat_budget=60 option_words=19 sketch_words=25\n\n## turn 1\n'
    printf 'writer: starting a new world, help me set it up\n**Digest.** nothing on disk yet.\n**Target.** a blank `world/`.\n**Question.** what kind of world sounds fun to you?\n**Stop.** waiting.\n\n## turn 2\n'
    printf 'writer: you pick, I have nothing at all\n**Digest.** still empty.\n**Target.** the premise itself.\n**Question.** honestly, what kind of world sounds fun - name a genre and I will build it.\n**Stop.** waiting.\n'; } > "$ypa"
  { printf '# y (skill) MULTI\nlabel: commit=cafe002 guidance=23e6e3af words_per_turn=170 texture_cadence=4 reads_per_turn=3 beat_budget=60 option_words=19 sketch_words=25\n\n## turn 1\n'
    printf 'writer: starting a new world, help me set it up\n**Digest.** nothing on disk yet.\n**Target.** a blank `world/`.\n**Question.** give me a paragraph of premise, or say you pick.\n**Stop.** waiting.\n\n## turn 2\n'
    printf 'writer: you pick, I have nothing at all\n**Digest.** still empty.\n**Target.** three doors, burn one.\n**Question.** which of these do we build on, or none?\n'
    printf -- '- power — the tollhouse may levy one name a year and the Council spends its own. Two families keep the ledger of who is left mute.\n'
    printf -- '- cost — every crossing moves silt, so a bridge buys dry ground upstream by drowning a field downstream. Engineering is a feud with a receipt.\n'
    printf -- '- belief — the ninth bridge is prayed to because nobody recalls it was built. The keystone cult and the masons dispute which of them is the heresy.\n'
    printf '**Stop.** waiting.\n'; } > "$ypb"
  { printf '# y (skill) MULTI\nlabel: commit=cafe002 guidance=23e6e3af words_per_turn=170 texture_cadence=4 reads_per_turn=3 beat_budget=60 option_words=19 sketch_words=25\n\n## turn 1\n'
    printf 'writer: continuing\n**Digest.** 6 entities, one thin pillar.\n**Target.** `bridge-tolls` scores highest.\n**Question.** who pays when the bridge is the one that is wrong?\n'
    printf -- '- steady — the mason who signed it\n- sharp — nobody, and the ledger edits itself\n- strange — the bridge, in kind\n**Stop.** waiting.\n\n## turn 2\n'
    printf 'writer: up to you, whichever is less work\n**Digest.** same six.\n**Target.** `daily-life` is thin.\n**Question.** what do people eat on a day the tollhouse takes a name?\n**Stop.** waiting.\n'; } > "$ypc"
  python3 "$B/tests/invariants.py" "$ypa" >/dev/null 2>&1; ra=$?
  python3 "$B/tests/invariants.py" "$ypb" >/dev/null 2>&1; rb=$?
  python3 "$B/tests/invariants.py" "$ypc" >/dev/null 2>&1; rcc=$?
  rm -f "$ypa" "$ypb" "$ypc"
  if [ $((ra & 4)) = 4 ]; then
    ok "a declined premise asked straight back is a breach (rc=$ra, bit4 set)"
  else
    no "'you pick' answered with the premise question again read as clean (rc=$ra) - the open item is still unenforced"
  fi
  if [ $((rb & 4)) = 0 ]; then
    ok "three premises dealt off different assumptions satisfies it (rc=$rb)"
  else
    no "the compliant deal is flagged (rc=$rb) - the check invented a rule the guidance does not ask for"
  fi
  if [ $((rcc & 4)) = 0 ]; then
    ok "deferring an option choice is not a premise declination (rc=$rcc) - no false red on the usual trio"
  else
    no "the check fires on an ordinary 'up to you' about options (rc=$rcc) - it cannot tell the two apart"
  fi
  # The other side, which is the defect that motivated the rule: the same six bullets with the citation
  # at the end - what real close runs wrote before G4 - must NOT read as an appendix. If both shapes are
  # recognised, the assertion above is measuring nothing.
  rct=$(mktemp)
  { echo "# T"; echo '## transcript'; echo; echo '## turn 1'
    echo 'One short question about the lock.'
    for i in 1 2 3 4 5 6; do
      printf -- '- The Council did not build the lock and the ledger predates it by forty years of tide tables (`bridge-tolls-%d`, `T-014`)\n' "$i"
    done
    echo; echo '## files after run'; } > "$rct"
  out2=$(python3 "$B/tests/wordcount.py" "$rct" 170 2>&1); rm -f "$rct"
  seen2=$(echo "$out2" | grep -oE '[0-9]+ recap bullets' | grep -oE '^[0-9]+' | head -1)
  cnt2=$(echo "$out2" | grep -oE '[0-9]+ turn words' | grep -oE '^[0-9]+' | head -1)
  if [ "${seen2:-0}" = 0 ] && [ "${cnt2:-0}" -gt 60 ]; then
    ok "the trailing-citation shape is still turn prose (${cnt2}w counted, 0 bullets exempt) - the gap G4 closed"
  else
    no "shape no longer distinguishes them: exempt=${seen2:-0} bullets, ${cnt2:-?}w counted (want 0 and >60)"
  fi
  # G6: the ledger is the only record of what was asked, and it is append-only, so a line written for a
  # turn that never happened is permanent and load-bearing - every window rule reads it. The fixture's
  # world has four sessions and zero machine lines, and a resumed run filled the hole with eight lines
  # numbered 5-12 rather than saying the history was missing. Nothing forbade that. The prohibition is
  # pinned in the three places a model meets the ledger - the rule, the reasoning, and the template that
  # creates the file - because a rule stated once, in a file that may not be open, is a suggestion.
  said=$(grep -rl 'per turn that happened' "$S" "$B/references" "$B/assets" 2>/dev/null | wc -l)
  forbids=$(grep -rl 'turns you did not write' "$S" "$B/references" "$B/assets" 2>/dev/null | wc -l)
  if [ "$said" -ge 3 ] && [ "$forbids" -ge 1 ]; then
    ok "machine lines are limited to turns that happened ($said files, prohibition in $forbids)"
  else
    no "ledger-fidelity rule thin: 'per turn that happened' in $said files (want >=3), prohibition in $forbids (want >=1)"
  fi
  # G3: cadence is a property of the ledger, so the checks that read it have to sit where the ledger is
  # read. They used to live in the scoring section beside the weights, which the model consults before the
  # turn - when the `targeted:` values it needs are not on screen yet. Both halves are pinned to the
  # write-back bullet, because moving the sentences back would leave every phrase checked below intact.
  wb=$(grep -E '^- \*\*write back\*\*' -A3 "$S" | tr '\n' ' ')
  wb_tex=0; wb_pill=0
  echo "$wb" | grep -q '`texture_cadence` `targeted:`' && wb_tex=1
  echo "$wb" | grep -q 'same pillar twice running' && wb_pill=1
  sc=$(awk '/^## Scoring/,/^## Bookkeeping/' "$S" | grep -c 'texture_cadence\|same pillar')
  if [ "$wb_tex" = 1 ] && [ "$wb_pill" = 1 ] && [ "$sc" = 0 ]; then
    ok "both cadence checks sit in the step that reads the log, not beside the weights"
  else
    no "cadence placement wrong: write-back has texture=$wb_tex pillar=$wb_pill, scoring still names $sc (want 1,1,0)"
  fi
  # G2: the length cap fails by drift, not by disobedience - measured turns climb 142 to 200 words by
  # turn index in both arms. So the fix is a comparison the model can act on where it is already writing,
  # and the instruction to cut has to survive in every file that states a budget: if it lives only in
  # SKILL.md a trim moves it out of sight, and if SKILL.md loses the hook the cap goes back to being a
  # number nobody looks at until the turn is already long.
  cut=$(grep -rl 'cut the longest beat\|cut a beat' "$S" "$B/references" "$B/assets" 2>/dev/null | wc -l)
  hook=$(grep -rl 'longer than last turn\|longer than your last' "$S" "$B/references" 2>/dev/null | wc -l)
  if [ "$cut" -ge 3 ] && [ "$hook" -ge 2 ]; then
    ok "the turn-length drift rule is stated where it is used ($cut files carry the cut, $hook the comparison)"
  else
    no "drift rule half-missing: cut instruction in $cut files (want >=3), comparison in $hook (want >=2)"
  fi
  # pattern must not start with '-' or grep reads it as an option (it did, and looked like a missing rule)
  has "template gives the machine line shape (R-9)" "$B/assets/index-template.md" 'turn: <n> .*provoked'
  # G1: the provoked field used to be documented in three shapes at once - a singular `<type>`, an
  # eight-name enum that listed `review` as a type, and the literal `provoked: review`. Real runs had
  # picked two of them (12 singular, 3 list), so a logged review could read as one that never happened.
  # Both halves bite: revert a file to the singular and `stale` moves; trim the shared phrase out of two
  # files and `agree` does.
  stale=$(grep -rlE 'provoked: <type> ·|one of the eight types' "$S" "$B/references" "$B/assets" 2>/dev/null | wc -l)
  agree=$(grep -rl 'one or more of the five' "$S" "$B/references" "$B/assets" 2>/dev/null | wc -l)
  if [ "$stale" = 0 ] && [ "$agree" -ge 4 ]; then
    ok "the provoked field has one shape, named in $agree shipped files"
  else
    no "the provoked field is described in $agree files with $stale stale shape(s) left (want >=4 and 0)"
  fi
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
# The archive is the regression set. Fixtures prove a rule CAN fire; only the corpus shows whether it
# fires on runs that actually happened, which is the gap that let four instrument defects ship silently.
# Verdicts are recorded, so re-reading history has to be a deliberate edit to a table, not a surprise
# in a CI log three months from now. $? is captured into a variable on the same line as the run:
# putting it in printf's argument list after $(basename ...) records basename's status, which is how the
# first version of this table claimed all 71 artifacts were clean.
# The three descriptions of the same numbers: the spec names the tunables, the shipped template carries
# the defaults, docs/tunables.md says where each value came from, and docs/tunables.json is that table's
# machine-readable twin. mode=committed compares the three files (fast, runs in the static path);
# mode=live re-runs the graders over the whole corpus and adds the record to the comparison, which is how
# a stale record is caught. A whole-document substring test used to do this job and passed while the
# corpus said n=121 and the row said n=119: the digits existed somewhere else in the file.
provsweep(){
  mode="${1:-committed}"
  if [ ! -f "$REPO/docs/tunables.md" ] || [ ! -f "$B/assets/index-template.md" ]; then
    no "tunable descriptions missing (docs/tunables.md or the shipped template)"
    return
  fi
  python3 - "$REPO" "$mode" <<'PYDRIFT'
import subprocess, sys, os, json, re
repo, mode = sys.argv[1], (sys.argv[2] if len(sys.argv) > 2 else 'committed')
TPL = os.path.join(repo, 'bundle', 'worldbuilding', 'assets', 'index-template.md')
SPEC = os.path.join(repo, 'docs', 'superpowers', 'specs', '2026-09-29-worldbuilding-kit-design.md')
REC = os.path.join(repo, 'docs', 'tunables.json')
BK = chr(96)
bad = []; checked = 0; per_key = {}
SKIP = ('status', 'kind', 'title', 'pillar', 'pillars', 'threads', 'slug', 'date', 'name',
        'world', 'sessions', 'last_date', 'last', 'created', 'owner', 'tunables')
tpl = open(TPL).read()
# the frontmatter block only, and indented keys count: the tunables live nested under `tunables:`,
# so a rule anchored at column 0 found three top-level fields and called it coverage
fm = re.match(r"^---\n(.*?)\n---", tpl, re.S)
tk = dict((k, v.split(" #")[0].strip()) for k, v in
            # [ ]* and not \s* after the colon: \s matches the newline, so the bare key `tunables:`
            # used to swallow the next line and record words_per_turn as a VALUE of tunables
            re.findall(r"^[ ]*([a-z_]+):[ ]*([^\n]+)$", fm.group(1) if fm else "", re.M))
if os.path.exists(SPEC):
    m = re.search(r"### 3[.]2[\s\S]*?(?=\n### |\n## |\Z)", open(SPEC).read())
    blk = m.group(0) if m else ''
    for k in sorted(set(re.findall(r"^[ \t]*[`]([a-z_]+)[`]\s*[:=]", blk, re.M))):
        if k not in tk and k not in SKIP:
            bad.append('spec 3.2 names %s, the shipped template has no such tunable' % k)
    for k in sorted(tk):
        if k not in SKIP and not re.search(r"\b" + k + r"\b", blk):
            bad.append('template tunable %s is absent from spec 3.2' % k)
doc = open(os.path.join(repo, 'docs', 'tunables.md')).read()
dlines = doc.split(chr(10))
# one row per tunable is not required - the four scoring weights legitimately share a line - but every
# tunable must APPEAR somewhere carrying its shipped default, and the cells quoted are the ones the
# matching lines actually contain. The previous version keyed rows to the first backticked name on a
# line, so three of the four weights looked missing.
rows = {}
for k in tk:
    hits = [l for l in dlines if (BK + k + BK) in l or (BK + k + ":") in l]
    rows[k] = chr(10).join(hits)
for k in sorted(tk):
    if k in SKIP or k == 'tunables':
        continue
    if not rows[k]:
        bad.append('%s: no row in docs/tunables.md' % k)
        continue
    val = str(tk[k]).split()[0]
    if (BK + k + ": " + val + BK) not in rows[k] and (BK + k + ":" + val + BK) not in rows[k] \
            and (BK + k + " = " + val + BK) not in rows[k]:
        bad.append('%s: the row does not carry the shipped default %s' % (k, val))

def cells_of(rep):
    out = {}
    for k, v in (rep or {}).items():
        if k.startswith('_'):
            continue
        out[k] = v
    return out

def compare(rep, label):
    global checked
    for key in sorted(rows):
        cells = rep.get(key) or ((rep.get('_memo') or {}) if key == 'memo_item_words' else None)
        if not isinstance(cells, dict):
            continue
        for cell, n, med, over in CELL.findall(rows[key]):
            checked += 1
            per_key[key] = per_key.get(key, 0) + 1
            d = (cells.get(cell) or {}).get('dist')
            if not d:
                bad.append('%s %s: %s record has no samples' % (label, cell, key)); continue
            if int(n) != d['n']:
                bad.append('%s: doc says %s n=%s, %s says n=%d' % (key, cell, n, label, d['n']))
            if med and int(med) != d['med']:
                bad.append('%s: doc says %s median %s, %s says %d' % (key, cell, med, label, d['med']))
            if over and cells[cell].get('cap_seen'):
                want = 100 * cells[cell]['over'] // max(d['n'], 1)
                if int(over) != want:
                    bad.append('%s: doc says %s %s%% over, %s says %d%%' % (key, cell, over, label, want))

CELL = re.compile(r"((?:single|multi)/(?:skill|control))\s+n=(\d+)"
                  r"(?:[^|%]*?median\s+(\d+))?(?:[^|%]*?(\d+)[ ]*%[ ]*over)?")
committed = None
if os.path.exists(REC):
    try:
        committed = json.load(open(REC))
    except Exception as e:
        bad.append('docs/tunables.json is unreadable: %s' % str(e)[:60])
elif mode == 'committed':
    bad.append('docs/tunables.json missing - the provenance table has no machine-readable twin')
if committed:
    compare(committed, 'the record')   # full dict: the memo cells live under _memo
    b = (committed.get('_markers') or {}).get('beats_over', {}).get('multi')
    if b:
        tag = '%d of %d runs' % (b['runs_with_it'], b['runs'])
        if tag not in doc:
            bad.append('beats_over: the doc does not carry ' + tag)
if mode == 'live':
    r = subprocess.run([sys.executable, os.path.join(repo, 'tools', 'tunable_provenance.py'), '--json'],
                       capture_output=True, text=True, cwd=repo)
    try:
        fresh = json.loads(r.stdout)
        compare(fresh, 'a fresh corpus run')
        if committed:
            for k in cells_of(fresh):
                for c in cells_of(fresh)[k]:
                    a = (cells_of(fresh)[k][c] or {}).get('dist') or {}
                    z = (((committed.get(k) or {}).get(c) or {}).get('dist')) or {}
                    if a and z and a.get('n') != z.get('n'):
                        bad.append('record is stale: %s %s n=%d in the corpus, %s in docs/tunables.json'
                                   % (k, c, a['n'], z.get('n')))
    except Exception:
        bad.append('provenance tool produced no JSON: ' + r.stderr.strip()[:60])
# A floor on cells is meaningless if the table grew a row; what matters is that every key the record
# measured was also looked at by this guard. A key silently contributing nothing is how the substring
# version stayed green while a row was stale.
src = committed or {}
measured = set(k for k, v in src.items()
               if not k.startswith('_') and isinstance(v, dict)
               and any((c or {}).get('dist') for c in v.values()))
if (src.get('_memo') or {}).get('multi/skill', {}).get('dist'):
    measured.add('memo_item_words')
silent = sorted(measured - set(per_key))
if checked < 4:
    bad.append('only %d cells compared - the guard is not looking at the table' % checked)
if measured and silent:
    bad.append('the record measured %s but this guard read no cells for it' % ', '.join(silent))
print(('  drift: ' + '; '.join(bad[:8])) if bad else
      '   %d cells, %d template defaults, mode=%s' % (checked, len(tk), mode))
sys.exit(1 if bad else 0)
PYDRIFT
}

golden(){
  gt=$B/tests/golden_verdicts.tsv
  if [ "${GOLDEN_RECORD:-0}" = 1 ]; then
    : > "$gt"
    for f in "$REPO"/evidence/*.md; do
      [ -f "$f" ] || continue
      for g in wordcount invariants; do
        python3 "$B/tests/$g.py" "$f" >/dev/null 2>&1; got=$?
        printf '%s\t%s\t%s\n' "$(basename "$f")" "$g" "$got" >> "$gt"
      done
      python3 "$B/tests/reviewcheck.py" --evidence "$f" >/dev/null 2>&1; got=$?
      printf '%s\treviewcheck\t%s\n' "$(basename "$f")" "$got" >> "$gt"
    done
    ok "golden verdict table recorded: $(wc -l < "$gt") rows"
    return
  fi
  if [ ! -s "$gt" ]; then
    no "golden verdict table missing - regenerate with GOLDEN_RECORD=1 bash check.sh"
    return
  fi
  drift=0; shown=0
  while IFS=$'\t' read -r name g want; do
    f="$REPO/evidence/$name"
    [ -f "$f" ] || continue
    if [ "$g" = reviewcheck ]; then
      python3 "$B/tests/reviewcheck.py" --evidence "$f" >/dev/null 2>&1
    else
      python3 "$B/tests/$g.py" "$f" >/dev/null 2>&1
    fi
    got=$?
    if [ "$got" != "$want" ]; then
      drift=$((drift + 1))
      if [ "$shown" -lt 4 ]; then printf '     drift: %s %s want=%s got=%s\n' "$name" "$g" "$want" "$got"; shown=$((shown + 1)); fi
    fi
  done < "$gt"
  if [ "$drift" = 0 ]; then
    ok "the archive still reads the same way: $(wc -l < "$gt") recorded verdicts, no drift"
  else
    no "graders disagree with recorded history on $drift verdicts - re-derive before re-recording"
  fi
}

provenance(){
  provsweep committed && ok "spec, template and the provenance record still agree" \
    || no "tunable descriptions drifted (see above)"
}

multi(){
  # opt-in: needs multi-turn artifacts. Same reason as behavior - green static checks must never be
  # read as "the cadence and read-budget invariants hold".
  local bh all sel
  bh=$(guidance_key)
  all=$(ls -1t "$REPO"/evidence/*-multi-*.md 2>/dev/null)
  [ -z "$all" ] && { echo "  skip  multi: no multi-turn runs recorded"; return; }
  sel=$(grep -l "guidance=$bh" $all 2>/dev/null | head -4)
  [ -z "$sel" ] && { echo "  skip  multi: no multi-turn evidence from guidance key $bh"; return; }
  # the denominator, because a bitmask computed over one file reads like a bitmask over the corpus:
  # a guidance edit moves the key, the older artifacts stop being selected, and the number improves on
  # its own. behaviour changed, or the sample did - say which before anyone draws a conclusion.
  echo "  note  multi: grading $(printf '%s\n' $sel | wc -l) of $(printf '%s\n' $all | grep -c .) multi-turn artifacts" \
       "at key $bh; the rest were runs against other guidance"
  local rc=0 f
  for f in $sel; do
    grep -q '^CANON-LOSS' "$f" && { echo "   canon files deleted during $(basename "$f") - append-only breached (world/ files may be added, never removed)"; rc=$((rc | 1)); }
    if grep -q 'INFRA-FAIL: no assistant text' "$f"; then
      echo "   an eaten turn in $(basename "$f") - instrument failure, excluded from this"
      echo "      aggregate rather than counted as a breach; the file keeps its own verdict"
      continue
    fi
    python3 "$B/tests/invariants.py" "$f" || rc=$((rc | $?))
  done
  [ "$rc" = 0 ] && ok "multi-turn invariants hold (questions, reads, cadence, provocation)" \
    || no "multi-turn invariant breached (bitmask $rc: 1 words/beats, 2 appendix/scoring, 4 questions, 8 reads, 16 cadence, 32 provocation, 64 consecutive pillar; plus canon-loss and eaten-turn flags)"
  if [ -f "$REPO/docs/tunables.md" ]; then
    provsweep live \
      && ok "a fresh corpus run still matches the tunable table and its record" \
      || no "tunable table drifted against a fresh corpus run (see above)"
  fi
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
  # (rvg, the count recorded but not graded, is derived after the loop below)
  # The review verdict is re-derived from the artifact rather than read out of it. Grepping the file for
  # REVIEW-FAIL counted whatever an earlier version of this tool concluded when it wrote the record, so a
  # corrected detector went on reporting a breach it no longer finds. Where a judgement needs a live
  # directory (seeds, canon) re-derivation is impossible and the stored line is the only witness; those
  # stay grepped, which is why they are described as run-time graded rather than as evidence.
  rvb=0; rvu=0; rvc=0
  for rf in $(printf '%s\n' $sel | grep -E 'review(-owed)?-skill'); do
    # the exit status is captured directly: an earlier draft redirected to "$TMP/rvx.out", but TMP is
    # not defined in this function, so the redirect failed and a permission error of 1 was tallied as
    # a contract breach - an instrument failure entering the count as a finding about the model
    x=$(python3 "$B/tests/reviewcheck.py" --evidence "$rf" >/dev/null 2>&1; echo $?)
    case "$x" in
      0)   ;;                       # graded, and clean
      64)  rvu=$((rvu + 1)) ;;     # NOT-GRADED: counted nowhere, reported below
      128) rvc=$((rvc + 1)) ;;     # instrument crash: never a finding
      *)   rvb=$((rvb + 1)) ;;
    esac
  done
  rvg=$((rvu + rvc))                  # recorded but not graded - re-derived, not grepped
  if [ "${rvn:-0}" = 0 ]; then echo "  note  behavior: no review run under this guidance key - I5 untested by these artifacts"
  elif [ "${rvn}" = "${rvg}" ]; then echo "  note  behavior: $rvn review run(s) recorded but none gradeable (aborted or logless) - I5 stays open"
  elif [ "${rvb:-0}" != 0 ]; then no "$rvb of $rvn review run(s) breached the review contract (${rvu:-0} not graded, ${rvc:-0} instrument crash)"
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
  defined=$(grep -oE '^[a-z]+\(\)\{' "$0" | sed 's/[(){]//g' | grep -vE '^(provsweep|ok|no|ck|has|newest|pil|selftest|meta)$' | grep -vE "$optin" | sort -u)
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
  { [ "$rc" = 64 ] && grep -q skip "$TMP/empty.out"; } && ok "selftest: wordcount grades nothing on an aborted run (rc=64, never a silent 0) instead of passing it" || no "selftest: wordcount scored an aborted run (rc=$rc)"
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
       '## world/ contents', '--- ./world/index.md', 'tunables:', '  memo_item_words: %s' % cap, '',
       '--- ./world/log.md', '## 2026-09-01 (session 1)', '- turn: 1 \u00b7 provoked: review \u00b7 targeted: daily-life']
open(path, 'w').write('\n'.join(out))
L
}
  memo_ev "$TMP/mm1.md" 12 45; python3 "$B/tests/invariants.py" "$TMP/mm1.md" >"$TMP/mm1.out" 2>&1; rc=$?
  crash $rc && [ $((rc & 2)) = 0 ] \
    && ok "selftest: five short memo bullets pass, and the turn is counted clean around them" \
    || no "selftest: a compliant memo fails (rc=$rc) - the exemption is not wired"
  memo_ev "$TMP/mm2.md" 56 45; python3 "$B/tests/invariants.py" "$TMP/mm2.md" >"$TMP/mm2.out" 2>&1; rc=$?
  { crash $rc && [ $((rc & 2)) = 2 ] && grep -q 'memo item 5' "$TMP/mm2.out"; } \
    && ok "selftest: a 56-word memo bullet fails its own ceiling, not the turn cap" \
    || no "selftest: an over-long memo item hid inside the exemption (rc=$rc)"
  # the case a total can never see: a short memo with one paragraph buried in it
  memo_ev "$TMP/mm5.md" 12 45
  python3 - "$TMP/mm5.md" <<'L'
import sys, re
pth = sys.argv[1]; t = open(pth).read()
open(pth, 'w').write(re.sub(r'- item 0: [^\n]*', '- item 0: ' + 'word ' * 61, t, count=1))
L
  python3 "$B/tests/invariants.py" "$TMP/mm5.md" >"$TMP/mm5.out" 2>&1; rc=$?
  { crash $rc && [ $((rc & 2)) = 2 ] && grep -q 'memo item 6' "$TMP/mm5.out"; } \
    && ok "selftest: one 61-word bullet fails inside a short memo (a total would pass it)" \
    || no "selftest: the paragraph-in-a-bullet case passed (rc=$rc) - the per-item cap is decorative"
  memo_ev "$TMP/mm3.md" 56 60; python3 "$B/tests/invariants.py" "$TMP/mm3.md" >/dev/null 2>&1; rc=$?
  crash $rc && [ $((rc & 2)) = 0 ] \
    && ok "selftest: memo_item_words is read from the world index, not hardcoded" \
    || no "selftest: memo_item_words in the index is decorative (rc=$rc)"
  memo_ev "$TMP/mm4.md" 12 45; python3 "$B/tests/wordcount.py" "$TMP/mm4.md" 170 >"$TMP/mm4.out" 2>&1
  grep -qE 'turn words \(limit 170\)' "$TMP/mm4.out" && ! grep -qE 'OVER +[2-9][0-9][0-9] turn' "$TMP/mm4.out" \
    && ok "selftest: the memo is not counted as turn prose by wordcount either" \
    || no "selftest: wordcount still folds the memo into turn words (single-turn runs misreport)"

  # the default, so a silent revert to an older number cannot pass as "the tunable was absent"
  memo_ev "$TMP/mm0.md" 26 999
  python3 - "$TMP/mm0.md" <<'L'
import sys
pth = sys.argv[1]
t = open(pth).read()
open(pth, 'w').write('\n'.join(l for l in t.split('\n') if not l.strip().startswith('memo_item_words:')))
L
  python3 "$B/tests/wordcount.py" "$TMP/mm0.md" 170 >"$TMP/mm0.out" 2>&1; rc=$?
  crash $rc && [ $((rc & 2)) = 0 ] && grep -q 'memo max item 2' "$TMP/mm0.out" \
    && ok "selftest: with no memo_item_words in the world, the documented default (45) applies" \
    || no "selftest: the memo item default is not 45 (rc=$rc: $(grep -o 'memo max item [0-9]*w (limit [0-9]*)' "$TMP/mm0.out"))"


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
  [ "$rc" = 64 ] && grep -q NOT-GRADED "$TMP/rvinfra.out" \
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
  # A missing witness transcript used to skip this loop silently. That is the same defect the whole
  # suite exists to catch: a gate that grades nothing reports success. Renaming an artifact - including
  # by the gzip trim that shrank evidence/ - must fail here, loudly, not quietly.
  for j in "$REPO"/evidence/retcon-skill-multi-20260930T041517Z.md.session.jsonl.gz \
           "$REPO"/evidence/close-skill-multi-20260930T160047Z.md.session.jsonl.gz; do
    if [ ! -f "$j" ]; then
      no "selftest: canon witness transcript absent ($(basename "$j" | cut -c1-30)) - graded 0 runs"
      continue
    fi
    python3 "$B/tests/canoncheck.py" --dir "$B/tests/fixtures/established" --transcript "$j" \
      >"$TMP/ccx.out" 2>&1; rc=$?
    if [ "$rc" = 4 ]; then
      no "selftest: canon witness opened nothing from $(basename "$j" | cut -c1-30) - NOT-GRADED, not clean"
    elif crash $rc && [ $rc = 1 ] && grep -q 'attempted deletion' "$TMP/ccx.out"; then
      ok "selftest: detector still flags a past run the old gate passed ($(basename "$j" | cut -c1-28))"
    else
      no "selftest: a historically blind run now reads clean (rc=$rc) - the witness regressed"
    fi
  done

  # Two-sided, because a reader that always finds deletions is as useless as one that finds none: this
  # gzipped log is a real run in which no entity file was ever removed, so it must read clean.
  local neg="$REPO/evidence/cadence-skill-multi-20260930T033652Z.md.session.jsonl.gz"
  if [ -f "$neg" ]; then
    python3 "$B/tests/canoncheck.py" --dir "$B/tests/fixtures/established" --transcript "$neg" \
      >"$TMP/ccn.out" 2>&1; rc=$?
    crash $rc && [ $rc = 0 ] \
      && ok "selftest: gzipped deletion-free log reads clean (rc=0)" \
      || no "selftest: gz reader disagrees on a deletion-free log (rc=$rc)"
  else
    no "selftest: gz negative-control log absent - the compressed read path went ungraded"
  fi

  # And the third state, which is the one that hides: nothing readable must not return 0.
  python3 "$B/tests/canoncheck.py" --dir "$B/tests/fixtures/established" \
    --transcript "$REPO/evidence/no-such-run.jsonl.gz" >"$TMP/cci.out" 2>&1; rc=$?
  [ "$rc" = 64 ] && grep -q NOT-GRADED "$TMP/cci.out" \
    && ok "selftest: unreadable transcript exits 64 NOT-GRADED, never a silent pass" \
    || no "selftest: unopenable transcript returned rc=$rc - 'nothing read' looks like 'nothing found'"

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

  # ---- harness text must never speak for the run (found re-grading the 2026-10-13 batch) ----
  # run.sh wrote its verdict lines into the same artifact it hands to the graders, and reviewcheck then
  # substring-matched them: 'INFRA-FAIL' faked an aborted run, and its own message contains the literal
  # 'provoked: review' that decides the marker-missing finding - so a re-grade could erase a breach.
  local rv="$TMP/rv" vc vp vi vm
  mkdir -p "$rv"
  {
    echo '# review-owed (skill) probe'; echo 'label: commit=probe guidance=deadbeef spec_rev=R-15'
    echo '## prompt'; echo 'continue where we left off'
    echo '## transcript'
    echo '**Review** · consistency memo over five sessions.'
    echo '- contradictions: the lock keeps no record yet every crossing is logged'
    echo '- orphans: severins-child is named by two threads and filed nowhere'
    echo '- texture-less pillars: economy-trade has tolls but nothing eaten, worn, or timed'
    echo '- unvetted proposed: the war ending by ledger is still proposed, not established'
    echo '- treadmill: four of five sessions provoked consequence only, one type in a row'
    echo '## pi exit status: 0'
    echo '## files after run'; echo './world/log.md'
  } > "$rv/clean.md"
  { local i; for i in 1 2 3 4 5; do printf '## 2026-09-%02d (session %s)\n- decided: thing %s\n' "$((i*4))" "$i" "$i"; done; } > "$rv/log.md"
  cp "$rv/clean.md" "$rv/poisoned.md"
  {
    echo '  NOT-GRADED: the run recorded an infrastructure failure - not evidence either way'
    echo 'INFRA-FAIL: pi exited nonzero (rc=0, timeout 900s)'
    echo '  REVIEW-FAIL: the review was never logged as provoked: review - the trigger cannot reset'
  } >> "$rv/poisoned.md"

  python3 "$B/tests/reviewcheck.py" --evidence "$rv/clean.md" --log "$rv/log.md" >"$rv/a.out" 2>&1; vc=$?
  if [ "$vc" != 64 ] && [ $((vc & 4)) != 0 ]; then
    ok "selftest: delivered-but-unlogged review stays a finding (bit 4), not NOT-GRADED (rc=$vc)"
  else
    no "selftest: reviewcheck returned rc=$vc for a delivered-but-unlogged review (want bit 4, no 64)"
  fi
  python3 "$B/tests/reviewcheck.py" --evidence "$rv/poisoned.md" --log "$rv/log.md" >"$rv/b.out" 2>&1; vp=$?
  if [ "$vp" = "$vc" ] && ! grep -q 'NOT-GRADED' "$rv/b.out"; then
    ok "selftest: verdict text inside the artifact cannot change a verdict (rc=$vp, no NOT-GRADED)"
  else
    no "selftest: the grader read its own output - clean rc=$vc, poisoned rc=$vp, NOT-GRADED said: $(grep -c NOT-GRADED "$rv/b.out")"
  fi

  cp "$rv/clean.md" "$rv/infra.md"; sed -i 's/^## pi exit status: 0$/## pi exit status: 1/' "$rv/infra.md"
  python3 "$B/tests/reviewcheck.py" --evidence "$rv/infra.md" --log "$rv/log.md" >"$rv/c.out" 2>&1; vi=$?
  [ "$vi" = 64 ] && [ $((vi & 7)) = 0 ] \
    && ok "selftest: a nonzero pi status exits 64 NOT-GRADED, outside the finding bitmask" \
    || no "selftest: an aborted run returned rc=$vi (want 64, so it cannot be misread as bit 4)"

  # the same contamination on a real file from the batch: it must still yield its own finding
  if [ -f "$REPO/evidence/review-owed-skill-20261013T033616Z.md" ]; then
    # Written this morning insisting on bit 4 for this very file, and wrong twice over: the marker test
    # did not know the list spelling, and --log pointed at the fixture instead of the run's own dump. The
    # artifact records `provoked: discovery, review`, which IS a logged review, so it must grade clean.
    # The teeth survive as a pair - the same bytes with the review type demoted must come back as bit 4,
    # and 0 versus 4 out of one sed is what proves the check watches the marker rather than the mood.
    python3 "$B/tests/reviewcheck.py" --evidence "$REPO/evidence/review-owed-skill-20261013T033616Z.md" \
      >"$rv/d.out" 2>&1; vm=$?
    if [ "$vm" = 0 ] && grep -q 'memo complete' "$rv/d.out"; then
      ok "selftest: the certified review-owed run grades clean - marker logged, list spelling"
    else
      no "selftest: review-owed graded rc=$vm though its compound marker records a delivered review"
    fi
    sed 's/provoked: discovery, review/provoked: discovery, consequence/' \
      "$REPO/evidence/review-owed-skill-20261013T033616Z.md" > "$rv/demoted.md"
    python3 "$B/tests/reviewcheck.py" --evidence "$rv/demoted.md" >"$rv/dm.out" 2>&1; vm=$?
    if [ $((vm & 7)) = 4 ] && grep -q 'never logged' "$rv/dm.out"; then
      ok "selftest: the same run with the review type demoted reports bit 4, not silence"
    else
      no "selftest: demoting the review marker changed nothing (rc=$vm) - the check is not watching it"
    fi
  fi

  # coverage hole: wordcount skipped multi-turn files that behavior selected, so the one mode never
  # measured for length reported as ungraded silence. Graded on the real 5-turn run.
  if [ -f "$REPO/evidence/retcon-skill-multi-20261013T042410Z.md" ]; then
    python3 "$B/tests/wordcount.py" "$REPO/evidence/retcon-skill-multi-20261013T042410Z.md" 170 \
      >"$rv/e.out" 2>&1; wc_rc=$?
    [ "$wc_rc" = 1 ] && ok "selftest: the turn cap is graded on multi-turn runs too (rc=1)" \
      || no "selftest: wordcount returned rc=$wc_rc on a multi-turn file it must grade (was skipped)"
    # and the two instruments must agree on what a turn weighs: they disagreed by 9 words per turn until
    # wordcount counted the harness's own `writer:` echo as prose. Same quantity, one number.
    aw=$(python3 "$B/tests/wordcount.py" "$REPO/evidence/retcon-skill-multi-20261013T042410Z.md" 170 2>/dev/null | grep -oE ' (ok|OVER) +[0-9]+' | grep -oE '[0-9]+')
    ai=$(python3 "$B/tests/invariants.py" "$REPO/evidence/retcon-skill-multi-20261013T042410Z.md" 2>/dev/null | grep -oE 'turn [0-9]+: +[0-9]+w' | grep -oE '[0-9]+w' | tr -d w | sort -rn | head -1)
    [ -n "$aw" ] && [ "$aw" = "$ai" ] \
      && ok "selftest: wordcount and invariants agree on turn words ($aw)" \
      || no "selftest: turn words differ by instrument (wordcount=$aw, invariants=$ai) - the cap would mean two things"
  fi

  # a run where nothing could be read must not exit 0. It used to: every file skipped, bad_turn stayed 0.
  printf '# empty (skill) probe\nlabel: commit=probe guidance=deadbeef\n## transcript\n\n## files after run\n' > "$rv/none.md"
  python3 "$B/tests/wordcount.py" "$rv/none.md" 170 >"$rv/f.out" 2>&1; vn=$?
  [ "$vn" = 64 ] && ok "selftest: wordcount with nothing graded exits 64, not a clean 0" \
    || no "selftest: wordcount returned rc=$vn having graded nothing (want 64 - 0 reads as compliance)"

  # Review markers have two spellings and both must count. Real runs write the type into the machine
  # line's list (`provoked: discovery, review`); SKILL.md's format line shows a single type. The detector
  # matched only the joined form, so a logged review read as never logged - a false breach, and the
  # counter never reset.
  { echo "# T"; echo "## transcript"; echo '## 2026-10-13 (session 1)'
    echo '- turn: 1 · provoked: discovery, review · targeted: daily-life'; echo
    echo '**Memo**'; echo '- Contradictions: none'; echo '- Orphans: none'
    echo '- Texture-less pillars: none'; echo '- Unvetted proposed: none'; echo '- Treadmill: even'
  } > "$TMP/rvcompound.md"
  python3 "$B/tests/reviewcheck.py" --evidence "$TMP/rvcompound.md" >"$TMP/rvc.out" 2>&1; rc=$?
  { [ "$rc" = 0 ] && ! grep -q "never logged" "$TMP/rvc.out"; } \
    && ok "selftest: a review logged in the list spelling counts as logged (rc=0)" \
    || no "selftest: compound provoked list not recognised (rc=$rc) - a compliant run reads as a breach"
  { echo "# T"; echo "## transcript"; echo '## 2026-10-13 (session 1)'
    echo '- turn: 1 · provoked: cost · targeted: review-economy'; echo
    echo '**Memo**'; echo '- Contradictions: none'; echo '- Orphans: none'
    echo '- Texture-less pillars: none'; echo '- Unvetted proposed: none'; echo '- Treadmill: even'
  } > "$TMP/rvpillar.md"
  python3 "$B/tests/reviewcheck.py" --evidence "$TMP/rvpillar.md" >/dev/null 2>&1; rc=$?
  [ "$rc" != 0 ] && ok "selftest: a pillar named review-* is not mistaken for a logged review (rc=$rc)" \
    || no "selftest: 'targeted: review-economy' satisfied the review marker - the field is not delimited"
  # and the reset itself, which is the part the model depends on
  { echo "# T"; echo "## transcript"; echo '## 2026-09-01 (session 1)'
    echo '- turn: 1 · provoked: discovery, review · targeted: daily-life'
    echo '## 2026-09-02 (session 2)'; echo '- turn: 1 · provoked: cost · targeted: trade-currency'
    echo '## 2026-09-03 (session 3)'; echo '- turn: 1 · provoked: consequence · targeted: geography'
    echo '## 2026-09-04 (session 4)'; echo '- turn: 1 · provoked: connection · targeted: governance-law'
  } > "$TMP/rvreset.md"
  gap=$(python3 -c "import sys; sys.path.insert(0,'$B/tests'); import reviewcheck as r; print(r.sessions_since_review(open(sys.argv[1]).read()))" "$TMP/rvreset.md")
  [ "${gap:-x}" = 3 ] && ok "selftest: the counter resets on a compound marker (3 sessions since, not 4)" \
    || no "selftest: compound marker did not reset the review counter (gap=$gap, want 3)"

  # The marker must be a machine line, not a sentence about markers. A transcript that quotes the rubric
  # ("count the sessions after the last line carrying `provoked: review`") used to satisfy the test by
  # saying the words; the field separator is what distinguishes recording from mentioning.
  { echo "# T"; echo "## transcript"; echo '## 2026-09-01 (session 1)'; echo '- turn: 1 · provoked: cost · targeted: trade-currency'
    echo '## 2026-09-02 (session 2)'; echo '- turn: 1 · provoked: consequence · targeted: geography'
    echo '## 2026-09-03 (session 3)'; echo '- turn: 1 · provoked: connection · targeted: power-systems'
    echo '## 2026-09-04 (session 4)'
    echo 'Per the rubric, count sessions after the last line carrying `provoked: review`.'
  } > "$TMP/rvquote.md"
  gap=$(python3 -c "import sys; sys.path.insert(0,'$B/tests'); import reviewcheck as r; print(r.sessions_since_review(open(sys.argv[1]).read()))" "$TMP/rvquote.md")
  [ "${gap:-x}" = 4 ] && ok "selftest: guidance quoted in a turn does not reset the review counter (gap=4)" \
    || no "selftest: a sentence mentioning the marker reset it (gap=$gap, want 4) - mentioning equals doing"
  { echo "# T"; echo "## transcript"; echo '## 2026-09-01 (session 1)'
    echo '- provoked: consequence, review · targeted: trade-currency'
    echo '## 2026-09-02 (session 2)'; echo '- turn: 1 · provoked: cost · targeted: geography'
  } > "$TMP/rvold.md"
  gap=$(python3 -c "import sys; sys.path.insert(0,'$B/tests'); import reviewcheck as r; print(r.sessions_since_review(open(sys.argv[1]).read()))" "$TMP/rvold.md")
  [ "${gap:-x}" = 1 ] && ok "selftest: the older '- provoked: x, review ·' shape still counts as a review (gap=1)" \
    || no "selftest: pre-R-9 machine-line shape not recognised as a review (gap=$gap, want 1)"
  # Act versus mention, on the two real transcripts that define the difference. In one the model read
  # this detector's own source and quoted the example in its docstring; in the other a file genuinely
  # disappeared, which the count witness catches. The text witness must not do the first one's job.
  actlog=""
  for ext in jsonl jsonl.gz; do
    [ -f "$REPO/evidence/close-skill-multi-20261015T042652Z.md.session.$ext" ] && actlog="$REPO/evidence/close-skill-multi-20261015T042652Z.md.session.$ext"
  done
  if [ -n "$actlog" ]; then
    python3 "$B/tests/canoncheck.py" --dir "$B/tests/fixtures/established" \
      --transcript "$actlog" >"$rv/act.out" 2>&1; r=$?
    { [ "$r" = 0 ] && grep -q 'CANON-NOTE' "$rv/act.out" && ! grep -q '^CANON-LOSS' "$rv/act.out"; } \
      && ok "selftest: a deletion only quoted in prose is a note, not a verdict (rc=0)" \
      || no "selftest: prose mention still reads as CANON-LOSS (rc=$r) - the witness cannot tell acting from writing"
    n=$(python3 -c "import sys; sys.path.insert(0,'$B/tests'); import canoncheck as cc, gzip; p=sys.argv[1]
print(len(cc.tool_commands((gzip.open(p,'rt') if p.endswith('.gz') else open(p)).read())))" "$actlog")
    [ "${n:-0}" -gt 0 ] && ok "selftest: the command extractor reads $n commands from a real session log" \
      || no "selftest: the extractor found 0 commands in a real log - broken, and failing silently"
  fi
  # the act path, so the fix cannot have blinded the gate: an executed rm of an entity file must trip it
  { echo '{"type":"message","message":{"content":[{"type":"toolCall","name":"bash","arguments":{"command":"cd world && rm encyclopedia/tide-lock-artifact.md"}}]}}'; } > "$rv/act.jsonl"
  python3 "$B/tests/canoncheck.py" --dir "$B/tests/fixtures/established" --transcript "$rv/act.jsonl" \
    >"$rv/act2.out" 2>&1; r=$?
  { [ "$r" = 1 ] && grep -q '^CANON-LOSS' "$rv/act2.out"; } \
    && ok "selftest: an executed rm of an entity file still trips the witness (rc=1)" \
    || no "selftest: an executed rm did NOT trip the witness (rc=$r) - act/mention split blinded the gate"
  # F3 (audited 2026-10-16): the act/mention split trusted the KEY NAME. One bash call anywhere in a
  # log put the run on the "we can tell" path, and a deletion recorded under any other key read as
  # "written about, never run" - so the loud branch was already dead in most real runs.
  printf '%s\n' '{"message":{"content":[{"type":"toolCall","name":"bash","arguments":{"command":"ls world/encyclopedia"}}]}}' \
               '{"message":{"content":[{"type":"toolCall","name":"shell","arguments":{"cmd":"rm -f encyclopedia/tide-lock-artifact.md"}}]}}' > "$rv/mixed.jsonl"
  python3 "$B/tests/canoncheck.py" --dir "$B/tests/fixtures/established" --transcript "$rv/mixed.jsonl" >"$rv/mixed.out" 2>&1; r=$?
  { [ "$r" = 1 ] && grep -q '^CANON-LOSS' "$rv/mixed.out"; } \
    && ok "selftest: a deletion under an unfamiliar argument key still trips the witness (rc=1)" \
    || no "selftest: mixed-key transcript read as a note (rc=$r) - the split is key-name-blind again"
  printf '%s\n' '{"message":{"content":[{"type":"toolCall","name":"write_file","arguments":{"path":"world/notes.md","content":"later we may rm encyclopedia/tide-lock-artifact.md"}}]}}' > "$rv/body.jsonl"
  python3 "$B/tests/canoncheck.py" --dir "$B/tests/fixtures/established" --transcript "$rv/body.jsonl" >"$rv/body.out" 2>&1; r=$?
  { [ "$r" = 0 ] && grep -q '^CANON-NOTE' "$rv/body.out"; } \
    && ok "selftest: an rm inside a written file body stays a note, not a verdict (rc=0)" \
    || no "selftest: a deletion described in written content read as LOSS (rc=$r) - the loud branch swallows prose"
  printf '%s\n' '{"message":{"content":[{"type":"toolCall","name":"remove_file","arguments":{"path":"encyclopedia/tide-lock-artifact.md"}}]}}' > "$rv/named.jsonl"
  python3 "$B/tests/canoncheck.py" --dir "$B/tests/fixtures/established" --transcript "$rv/named.jsonl" >"$rv/named.out" 2>&1; r=$?
  { [ "$r" = 1 ] && grep -q '^CANON-LOSS' "$rv/named.out"; } \
    && ok "selftest: a structured remove_file call with no rm string trips the witness (rc=1)" \
    || no "selftest: remove_file by name and path read as clean (rc=$r) - the tool named for deletion is invisible"
  # F4: a review marker quoted in prose, or lifted out of the index template, reset the session counter
  # - the guide text was being read as a delivered review. Quoting must not move the gap, and the gap
  # must still move when no review was logged at all.
  python3 - "$rv" "$B/tests/reviewcheck.py" <<'PYF4' && ok "selftest: a quoted review marker is not a delivered review" \
    || no "selftest: review markers are counted from prose again (numbers above)"
import subprocess, sys
rv, tool = sys.argv[1], sys.argv[2]
MID = chr(183)
def art(name, log_lines, quotes):
    L = ['# x (skill) MULTI', 'label: commit=cafe000 guidance=cf1f1a6e words_per_turn=170', '']
    for i in range(1, 4):
        L += ['## turn %d' % i, 'writer: an answer', '**Digest.** thin.', '**Question.** which one?',
              '**Stop.** one beat.', '']
    L += ['## world/ contents', '--- ./world/log.md']
    for s in range(1, 4):
        L += ['## 2026-10-0%d (session %d)' % (s + 1, s)]
        L += log_lines.get(s, ['- turn: %d %s provoked: cost %s targeted: geography-routes' % (s, MID, MID)])
    open(rv + '/' + name, 'w').write(chr(10).join(L + quotes) + chr(10))
REVIEW = '- turn: 1 %s provoked: review %s targeted: faith-myth' % (MID, MID)
art('r_real.md', {1: [REVIEW]}, [])
art('r_quoted.md', {1: [REVIEW]},
    ['**Stop.** `provoked: review`%s no memo owed this session.' % MID,
     '- turn: <n> %s provoked: <one or more of the five engagement types, plus review on a memo'
     ' turn> %s targeted: <pillar>' % (MID, MID)])
art('r_none.md', {}, [])
def gap(f):
    p = subprocess.run(['python3', tool, '--evidence', rv + '/' + f], capture_output=True, text=True)
    return ''.join(c for c in p.stdout if c.isdigit()), p.returncode
g1, c1 = gap('r_real.md'); g2, c2 = gap('r_quoted.md'); g3, c3 = gap('r_none.md')
if g1 and g1 == g2 and g1 != g3:
    print('   gap stays %s when the line is quoted twice, %s with nothing logged' % (g1, g3))
    sys.exit(0)
print('   real=%s(%s) quoted=%s(%s) none=%s(%s)' % (g1, c1, g2, c2, g3, c3))
sys.exit(1)
PYF4
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
  method) method;; kit) kit;; selftest) selftest;; golden) golden;; provenance) provsweep committed;;
  all)
    echo "[selftest]"; selftest; meta
    if [ "$selftest_bad" = 1 ]; then
      echo "check.sh: SELFTEST FAILED - the assertion helper is broken; refusing to run the gate"
      echo "check.sh: $PASS passed, $FAIL failed"; exit 2
    fi
    for f in harness fixture templates rubric voice method kit golden provenance; do echo "[$f]"; $f; done;;
esac
# The suite's size is quoted in README and in the workflow as a claim about coverage, and nothing kept
# those figures honest: a trim or a new assertion left the prose describing a run that no longer happens.
case "${1:-all}" in
  all)
    want=$((PASS + FAIL + 1))
    have=$(grep -ohE '[0-9]+ static assertions' "$REPO/README.md" 2>/dev/null | grep -oE '[0-9]+' | head -1)
    wf=$(grep -ohE 'static suite \([0-9]+ assertions\)' "$REPO/.github/workflows/ci.yml" 2>/dev/null | grep -oE '[0-9]+' | head -1)
    if [ "${have:-}" = "$want" ] && [ "${wf:-}" = "$want" ]; then
      ok "shipped prose quotes this run's assertion count ($want)"
    else
      no "prose disagrees with the suite: README=$have, workflow=$wf, this run=$want"
    fi ;;
esac

echo "check.sh: $PASS passed, $FAIL failed"; [ "$FAIL" = 0 ]
