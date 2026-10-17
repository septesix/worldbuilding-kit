# Worldbuilding Kit — Design Spec

**Version:** 0.1.0
**Date:** 2026-09-29 (host clock)
**Status:** living document. The body below carries the state as of R-22; where a paragraph and a
later revision disagree, the revision wins and the paragraph has been updated or marked.
**Owner:** septesix

**Implementation state (2026-10-15):** guidance key `5e29a642` · HEAD `ddb8976` · suite 197/0.
Behavioural claims are keyed to the guidance hash, not to a commit: `{cat SKILL.md; cat references/*.md;
cat assets/*.md;} | cksum` — editing any shipped sentence invalidates the runs certified under it.
Where each tunable's number came from, and which modes have evidence at all: `docs/tunables.md`.

## 1. Intent

Give a fiction writer a collaborative interview that builds a fiction world's geography,
history, culture and characters by asking sharp, surprising questions — and that leaves behind
a durable, browsable **encyclopedia** it can pick up again months later without re-asking
anything already settled.

Success looks like: after N sessions, `world/` is the reference bible the writer consults while
drafting — internally consistent, complete against a known rubric, every fact attributed to
either the writer or the skill, and no fact asked about twice. The *process* is also a success
criterion: the writer should look forward to the next session.

### Decisions already taken (and why)

| # | Decision | Rejected alternative | Reason |
|---|---|---|---|
| 1 | Completeness-first encyclopedia **with** surprising, provocative interviewing | Fast "enough to start this story" scaffolding | Writer wants the bible as the artifact; boredom solved by method, not by shrinking scope |
| 2 | Two-tier rubric: pillar checklist as the floor, entity-child generation as the ceiling | Pure checklist / pure emergence | A floor is required to compute "still light on details"; emergence is required to keep it interesting |
| 3 | Entity wiki (`world/encyclopedia/<slug>.md`) + derived index | One big file / one file per pillar | Matches how writers think; keeps resume reads cheap as the world grows |
| 4 | Encyclopedia lives **with the writing project** | Global `~/worlds/` | Canon travels with the manuscript repo |
| 5 | Kit + bundle: tiny global trigger installs the real skill into the project on demand | Single global skill | Zero impact on unrelated projects |
| 6 | Voice: dry archivist, warmed up; sarcasm permitted when warranted | Enthusiastic collaborator | Writer's stated preference |

## 2. Architecture

Two artifacts, one source tree.

```
~/worldbuilding-kit/                         # this repo (canonical source)
├── bundle/worldbuilding/                    # what gets installed into a project
│   ├── SKILL.md                             # the method        (<500 words)
│   ├── references/rubric.md                 # pillars + probes + child generation
│   ├── references/voice.md                  # tone contract + 3-turn worked transcript
│   ├── assets/index-template.md
│   ├── assets/entity-template.md
│   ├── assets/threads-template.md
│   └── tests/                               # scenario prompts + scorecard
├── kit/SKILL.md                             # the trigger       (<150 words)
└── docs/superpowers/specs/                  # this file
```

`~/.pi/agent/skills/worldbuilding-kit` is a **symlink** to `~/worldbuilding-kit/kit`, so editing
the repo is editing the installed trigger. pi resolves symlinked skill directories and reads
`SKILL.md` from them.

### 2.1 The kit (global trigger)

- **Discovery footprint:** name + description only, ≤35 words in the description. This is the
  sole thing any unrelated session ever sees.
- **Description (routing text):**
  `Use when the user wants to build, extend, or resume a fictional world for a writing project — world bible, lore, setting or character backstory, consistency of an imagined world.`
- **Body algorithm:**
  1. Resolve `project_root` = nearest ancestor containing `.git`, else the session CWD.
  2. If `<project_root>/world/` exists → world found; go to 4.
  3. If not: if `project_root` is `$HOME` or a non-project directory, **do not scaffold** — ask
     which folder holds the manuscript. On "here", echo the absolute path and require one
     explicit confirmation.
  4. If `<CWD>/.pi/skills/worldbuilding/SKILL.md` is absent → `cp -R <kit>/bundle/worldbuilding`
     into `<CWD>/.pi/skills/`, warn that project skills are reviewed by pi's trust prompt, then
     continue.
  5. If present but its `metadata.version` ≠ the bundle's → one-line offer to upgrade. An upgrade
     replaces `.pi/skills/worldbuilding/` **only**; `world/` is never touched.
  6. **`read` the installed `SKILL.md` and follow it from here on.** The kit contributes nothing
     further. This handoff makes the current session work without `/reload`.
- **Known limitation, handled:** pi scans project skills from the session CWD only, but `world/`
  belongs at `project_root`. If those differ, the kit installs at CWD (so the session works) and
  says so in one line, recommending pi be run from the project root next time.

### 2.2 The bundle (project skill)

`name: worldbuilding`, `metadata.version: 0.1.0`, model-invocable. Once installed it is listed in
every session whose CWD is that project — intended, since that project *is* the world.

Modes, all handled by the same loop:

| Mode | Entered when | Behavior |
|---|---|---|
| `new` | no `world/` | one question: a paragraph of premise (or "you pick" → deal three premises off different genre assumptions). Scaffold `world/`, seed 5–8 entities, **all tagged `proposed:`** |
| `continue` | `world/index.md` exists | read index only; pick the top gap; open with the digest |
| `review` | requested, or offered when `log.md` shows ≥3 sessions since the last one | consistency memo: contradictions, orphan entities, pillars with no `texture` entries, unvetted `proposed:` canon, engagement-type treadmill |

## 3. The turn contract

A turn is four beats. Missing a beat makes the turn malformed.

| Beat | Content |
|---|---|
| **1 Digest** | ≤3 lines: pillar thin/thick, entity count, open-thread count, "since last session". Names the world and its path |
| **2 Target** | The single gap chosen by §4, and why it is interesting — must cite an existing entity by name |
| **3 Question** | **Exactly one** question, plus 2–3 candidate answers labelled `steady / sharp / strange` (faithful · dangerous · weird), each ≤ `option_words` (default 18 — R-14a) |
| **4 Stop** | Wait. The writer's move is always a single reply |

The turn *after* an answer begins with two beats of its own:

- **Write back** — append canon and update `index.md` **before** any new question. A crash costs
  at most one exchange. Facts are declarative bullet lines, never dialogue. This is where the ledger is on
screen, so it is also where the arithmetic that needs it is read and applied — cadence window, consecutive
pillar, and the length comparison against the previous turn (R-19).
- **Reflect** — state one consequence or connection the writer did not say. This beat is where
  "surprising" lives; it is structure, not aspiration.

### 3.1 Session close

When the writer ends a session (or 12 turns pass without one), append to `log.md` and show in
chat: 3–6 bullets of **what we just decided**, each **citation first** (R-21), then **the next thread I
would pull and why**.
Closing the laptop mid-novel must cost nothing.

### 3.2 Tunables

Read at session start from `world/index.md` frontmatter. The writer edits the file directly;
there is no command surface.

```yaml
tunables:
  words_per_turn: 170         # conversational words only; options and mandated appendices excluded (R-2, R-3, R-7, R-21)
  texture_cadence: 4          # every Nth turn belongs to texture, counted from targeted: in log.md (R-8)
  reads_per_turn: 3           # a scale tripwire, not a ration (R-6, and the correction beneath it)
  beat_budget: 60             # words per labelled beat (R-10 set it at 45; R-23 measured what it was doing)
  option_words: 19            # per candidate option, counting the option text only (R-14a set 18;
                              # R-26 moved it to the measured ceiling)
  sketch_words: 25            # per line of a reaction-mode sketch block, six lines to a block (R-25)
  memo_item_words: 45         # per memo bullet, not the memo's total (R-16)
  turns_per_session: 12       # the close trigger (R-10 note)
  sarcasm: on                 # declared; nothing in the guidance reads it yet - see Open items
  weight_gap: 1.0
  weight_hook: 1.0
  weight_contradiction: 1.5
  lopsidedness_floor: 0.6     # never same pillar twice running if another scores ≥ this ratio
```

`gap_weight` and `hook_weight` are **score terms**, not tunables: the weights above multiply them. The
table in `assets/index-template.md` is the single source of truth for these defaults, and `check.sh` now
fails if this block disagrees with it (R-22).

## 4. Choosing what to ask

`score(candidate) = (gap_weight × weight_gap) + (hook_weight × weight_hook) + (contradiction × weight_contradiction)`

- `gap_weight` measures the **size of the hole**, so an untouched pillar outranks a dense one:
  3 pillar empty, or every entry still `proposed:` · 2 thin (1–2 `established` lines in the
  pillar) · 1 substantial (≥3 `established` lines across ≥2 entities) · 0 saturated
- `hook_weight`: number of *established* entities the question can link to (0–3), +1 if it touches
  a character's stated want or actual need, total capped at 4
- `contradiction`: 1 if answering could falsify an existing canon line, else 0

Constraints: never the same pillar in consecutive turns when another candidate reaches
`lopsidedness_floor` of its score; every `texture_cadence`-th turn must be a texture question;
a candidate must be about an entity already in the encyclopedia or a child of one.

**Mode switch:** if more than half of the last 8 turns produced `proposed:` canon, stop
interviewing and switch to reaction mode — sketch 6 lines of the region and ask what is wrong
with it. Being stuck must not become an interrogation. The sketch is an **appendix, not prose**: each
line ≤ `sketch_words` (default 25), six lines to a block, excluded from `words_per_turn` the way
candidate options and the close recap are (R-25). A seventh line is the shape turning into a second
index, which is why the count is enforced and not just advised.

## 5. Rubric (`references/rubric.md`)

### 5.1 Floor — pillars

**World (11):** geography, routes & distance · ecology, resources & disease · history &
periodisation · peoples, kinship & social structure · power systems (magic/tech) and their
**costs** · governance, law & legitimate violence · production, economy & trade · faith, myth &
meaning · language, names & registers · daily & material life (`texture`) · conflicts, tensions &
what is currently failing.

**Character (7):** stated want vs actual need · formative past (three *scenes*, not adjectives) ·
relationships with friction · contradictions & where they are hypocritical · secrets & what they
would never say · competence & how they fail · voice, tics & what they notice first (doubles as a
texture feed).

Each pillar carries 4–5 **probe patterns**, so questions are generated rather than improvised at
the emptiness. Two that always work: *define by contrast* (what makes this unlike its neighbour's
version) and *the failure case* (describe it on the day it goes wrong).

### 5.2 Ceiling — child generation

Any entity spawns candidates by asking: who benefits / who pays · what does it run out of · who
maintains it and how badly · what do people say about it when it breaks · the polite version vs
the rude version · the one time it failed · what a child believes about it · what adjacent thing
nobody mapped · what it borrowed from a culture that is gone.

**Every new entity must spawn ≥3 threads.**

### 5.3 Hard rules

- A question must be answerable in one sentence.
- A question must never imply homework.
- Anti-glass test: if the answer could be pasted into any published fantasy novel it is **not**
  established — ask for the detail that makes it un-pasteable.

## 6. Voice contract (`references/voice.md`)

Dry archivist, warmed up. The world is treated as already real and merely under-documented:
*"Severin has a reason; you simply haven't told anyone yet."* Second person for the writer's
ideas, third person for the world.

1. ≤ `words_per_turn` words per turn (default 170). Candidate options and mandated appendices are
   excluded and carry their own limits instead: `option_words` per option, 3–6 recap bullets at close,
   and up to 6 sketch lines of `sketch_words` each when reaction mode fires (R-16, R-25, R-26).
   Longer than the last turn? Cut a beat rather than a comma (R-19). Jokes may appear anywhere in the turn,
   including inside the question.
2. Sarcasm is permitted **when warranted**, defined as: it lands on the world's absurdity, an
   internal contradiction, or a thread the world keeps dodging. Never on the writer's idea,
   effort, or taste. If a phrasing could read as "your answer was stupid", rewrite it straight.
3. Never evaluate the writer's invention ("bold", "interesting choice"). Praise is replaced by
   **use**: quote their detail back inside a consequence.
4. No emoji, no `great question!` / `let's dive in` scaffolding, no first-person fictional
   persona. Register tilts to genre (drier for grimdark, quicker for comic) without changing
   identity.

### 6.1 Engagement contract

Every turn lands ≥1 of:

**Consequence** · **Contradiction** (two canon lines that cannot both be true; may be the whole
turn) · **Connection** (links two entities established ≥3 sessions apart that no thread yet
joins) · **Cost** (a candidate answer that makes the writer give something up) · **Discovery**
(their own forgotten detail, quoted back).

Each turn appends `provoked: <types>` — one or more of the five, plus `review` on a memo turn (R-18) — to
its machine line. **Three consecutive turns of one type
forces a switch.** `review` reports the distribution.

## 7. Data model

```
<project_root>/world/
  index.md                  # DERIVED registry + scoreboard
  encyclopedia/<slug>.md    # one file per entity
  threads.md                # open-question ledger (authoritative for what is unresolved)
  log.md                    # append-only recaps + exactly one machine line per turn that happened (R-9, R-18, R-20)
```

- **`index.md`** — frontmatter (`world`, `sessions`, `last_date`, `tunables`) — see revision R-1, no version field lives here,
  then within the first 60 lines: pillar table (counts + thin/thick), entity registry (slug ·
  kind · pillars · status · hooks, one line each), texture digest, top-5 hottest threads. Never
  authoritative over entity bodies; rebuilt from them if missing or stale.
- **`encyclopedia/<slug>.md`** — frontmatter (`kind`, `pillars[]`, `status`, `added`, `revised`),
  then `## Canon` (bullet lines, one fact each, ≤25 words, prefixed `established:` or
  `proposed:`), `## Open questions`, `## Links` (`[[slug]]`).
- **`threads.md`** — per thread: question, `asked-by` (writer|skill), pillars, hook,
  `status: open|parked|resolved`, `spawned:` entity links.
- Entity kinds: `person · place · era · custom · conflict · institution · artifact · text · creature`.
- Slugs: kebab-case from title; on collision append the kind (`lady-severin-person`).

**Write boundary:** the skill writes only inside `world/`. It never modifies manuscript files, and
any change it wants elsewhere is a proposal in chat.

**Canon is append-only.** A change adds a `revised:` line and marks the old one
`superseded-by:`. Nothing is edited in place, so every retcon is visible and reversible, the
skill can report what changed since a decision, and a misread answer cannot silently rewrite the
world. This also keeps git merges between co-authors local to one file.

## 8. Edge cases

| Situation | Behavior |
|---|---|
| CWD is `$HOME` / not a project | do not scaffold; ask for the manuscript folder; confirm absolute path once |
| `world/` exists, `index.md` missing/stale | rebuild index from entity files, announce it |
| Multiple `world/` (e.g. `./world` and `./novel2/world`) | nearest ancestor wins; digest names the path; ask if ambiguous at depth |
| Writer answers something already established | no re-ask, no duplicate; if it differs → Contradiction beat, resolve, record `superseded-by:` |
| Writer asks for prose or chapter text | out of scope; decline in-voice; offer an `artifact` or `texture` entity instead |
| Writer goes off-rubric on a tangent | follow it, but open a `threads.md` entry first so the heat becomes resume state |
| 300-entity world | read ≤3 entity bodies per turn; rely on index tables |
| Bundle/installed version mismatch | offer upgrade; `world/` untouched |
| Installed skill files edited by user | never overwritten without asking; diff on version only |
| Project-trust prompt | kit warns before first install that project skills are loaded from the repo |

## 9. Testing (writing-skills iron law: failing test first)

Technique + discipline hybrid → application scenarios **and** one pressure scenario, each with a
**no-skill control**. If the control does not fail, the guidance is not written.

**RED — baselines, fresh subagents, no skill:**
1. Existing hand-built `world/` + "let's continue building my world" → predicted failure: ignores
   the files, asks ten generic questions, may draft prose.
2. Empty dir + "vague idea about a bridge toll" → predicted failure: pleasant interview, zero
   persistence, no structure.
3. Six turns in, "whatever you think", then "let's wrap up early" → predicted failure: canon not
   written back before the recap, `proposed:` facts laundered into established, contradictions
   missed.

**GREEN — same scenarios with the bundle installed:** four beats present · ≥1 engagement type and
never three consecutive of one type · texture question on turn 4 · write-back precedes any new
question · ≤`words_per_turn` · sarcasm test fed a deliberately weak idea to confirm the sarcasm
never targets the writer.

**Voice micro-test** before full runs: 5 fresh-context samples of one digest turn, each output read
by hand. Converging shape = wording binds; five different interpretations = tighten wording
instead of adding words.

**REFACTOR:** harvest rationalizations (e.g. "I didn't record it because they hadn't confirmed
it") into explicit counters; re-test.

Fixtures live in `bundle/worldbuilding/tests/` as scenario prompts plus a scorecard, runnable
headless so any edit can be re-validated.

## 10. Out of scope

Scripts and index generators (the model maintains the index) · map or timeline rendering · genre
content packs · prose generation · multi-writer sync or hosting · any app, server or UI.

## 11. Deliverables

| File | Budget |
|---|---|
| `kit/SKILL.md` | <150 words, description ≤35 words |
| `bundle/worldbuilding/SKILL.md` | <500 words |
| `bundle/worldbuilding/references/rubric.md` | pillars + probes + child generation, ~250 lines |
| `bundle/worldbuilding/references/voice.md` | contract + 3-turn worked transcript |
| `bundle/worldbuilding/assets/*-template.md` | index / entity / threads |
| `bundle/worldbuilding/tests/` | 3 scenarios + scorecard |
| world data | created at runtime in `<project_root>/world/`, never in this repo |

## Revisions

**R-1 (2026-09-30, gate finding I-follow-up)** — Dropped `skill_version` from `world/index.md`. The
kit's upgrade offer compares an installed version against the bundle's; with the marker in `world/`
the comparison read a file the worldbuilding skill rewrites during ordinary work, and a control run
was observed setting it to `0.1.0` unprompted. `metadata.version` in each `SKILL.md` is now the only
version source, in a file the skill never writes. Cost of being wrong: a stale `world/` copy could
mask an available upgrade, or a completed session could announce one.

**R-2 (2026-09-30, operator decision on gate finding I1/F3)** — `words_per_turn` default raised
120 → 160. Rationale: measured resume turns land at 152 with the skill installed; 120 was a number I
chose during brainstorming by feel and it produces a budget the target behavior violates by ~25%
under ordinary conditions. 160 keeps the cap a real constraint (control turns ran 178–500) while
being a limit the intended output actually fits. Cost if wrong: the cap stops biting on the runs it
was meant to prevent — verbosity drifts upward to fill whatever number is written, so the honest
test is whether skill turns stay under it over time, not whether they do today. An operator editing
this in `world/index.md` overrides per world, which is the mechanism this number was always meant to
be routed through.

**R-3 (2026-09-30, found while measuring R-2)** — `words_per_turn` caps **turn words only**: prose the
writer reads as conversation. The candidate options and the session-close recap are exempt because
they carry their own limits (≤18 words each; ≤6 bullets) and §3.1 *mandates* the recap, so counting
it against the conversational budget makes the cap unsatisfiable on exactly the wrap-up turns §3.1
requires — the same self-contradiction as finding I6. Cost if wrong: a close turn gets 160 words of
cap plus an unbounded appendix; the appendix bounds are the control there, not the cap.

**R-4 (2026-09-30, gate finding F7)** — Each turn logs `targeted: <pillar>` alongside `provoked:
<type>`, in chat and `log.md`. §4's constraint "never the same pillar in consecutive turns when
another candidate reaches `lopsidedness_floor`" was **unobeyable as written**: nothing on disk records
what the previous turn targeted, and past the first couple of turns the transcript is no longer in
context to be re-read. Two runs hammered `faith-myth` for four consecutive turns, which is not
disobedience so much as an arithmetic the skill cannot perform without state.
Cost if wrong: one more field on every log line, and a writer reading `log.md` sees bookkeeping that
is not prose. Accepted: the alternative is a rule that reads as guidance and functions as decoration.
Related correction: F7 was first reported to the operator as a *conflict* between the lopsidedness
floor and the switch rule. It is not a conflict. The floor sets priority by gap size; §4 already
forbids consecutiveness; the missing piece was the record. What the spec never supported is the
"never 3 turns running" test the harness was asserting - that rule is my invention, now corrected to
consecutive turns (spec §4), with the ≥ `lopsidedness_floor` condition reported as ADVISORY because
candidate scores are not recorded either.

**R-5 (2026-09-30, gate finding F9)** — Pillar and entity counts are read from `world/index.md`'s two
tables, not from entity bodies; at most **one** body is read per turn, the targeted one, to quote it.
§4's scoring was reachable two ways and the rubric described the expensive one: "count canon lines in
the entity files", which needs N reads, against §3's "≤3 entity bodies per turn". Runs breached the
read cap in 2 of 5 turns (6 bodies) while obeying the word and question rules. The tables exist so the
arithmetic needs no file opening; R-4's rotation fix made it worse before this one, because scanning
more pillars meant counting more bodies. Cost if wrong: the tables can be stale and the skill then
scores from a fiction - which is why §3's stale-index rebuild is a precondition, and why `check.sh
fixture` derives those same tables mechanically.

**R-6 (2026-09-30, operator question about F9)** — `≤3 entity bodies per turn` becomes
`≤ reads_per_turn` (default 3), stated as a **scale tripwire, not a ration**. Its whole purpose, per
§7's failure-mode table, is that a 300-entity world must not score itself by opening every entity.
Crossing it is therefore evidence the structural rule (R-5: count from `index.md`) broke - the response
is to rebuild the index, not to apologise for reading. The fixture's nine bridges are 7 entities and
4.4 KB, where the cap protects nothing measurable, so breach counts at fixture scale were being read as
quality defects when they were artefacts of test size; `invariants.py` now measures against the
tunable so a small world cannot generate false alarms and a large one cannot generate silence.
Cost if wrong: a writer who reads `reads_per_turn` as a licence to open 3 files every turn. The
tripwire wording in `SKILL.md` exists to keep it legible as a diagnostic.


**Correction to R-5 / R-6 (2026-09-30, found after both were merged)** — F9 did not exist. The
"reads per turn" figure in `invariants.py` counted every tool call touching `world/encyclopedia/`,
including the 2-3 `edit` calls bookkeeping requires, plus `write` and `bash`. Recomputed against tool
name `read` only, the four multi-turn runs on record read **0-2 entity bodies per turn**, always inside
the cap - including the runs that motivated R-5 ("6 bodies") and R-6 ("5,4,4,2,4"). Both revisions were
authored to fix a bug in the measuring instrument.

Kept anyway, on their own merits and labelled as such: R-5 (count from `index.md`, read one body to
quote) is what the runs were already doing, and is the only formulation that scales to the 300-entity
case; R-6 (`reads_per_turn` as a named tunable) is the right shape for a scale guard. Neither is now
supported by evidence of a breach, and neither may be cited as a fix for one. What the corrected
instrument does still show at depth: `words_per_turn` breached by turns 1 and 4 of the last run
(164, 169 against 160), and two candidate options over 18 words.


**R-7 (2026-09-30, operator decision)** — `words_per_turn` default 160 → 170, on three 5-turn runs
whose deepest turns measured 164 and 169. Stated plainly because the pattern is the one criticised in
R-2: this is a budget set just above the observed maximum, so it will stop biting on exactly the turns
that motivated it unless the 12-turn run shows the ceiling is elsewhere. The test that settles it is
turn-level distribution at depth, not another single-turn sample.

**R-8 (2026-09-30, gate finding at 12 turns)** — Texture cadence is computed from the `targeted:`
values of the last `texture_cadence` entries in `log.md`; if none names `daily-life` or
`voice-attention`, that turn belongs to texture and outranks any gap or hook score. No new state is
introduced - R-4 already records the target, so this rule is derivable and was only unkept because
nothing told the skill to look. Root cause is the same as R-4's in a different dress: **a rule the skill
cannot count is a rule it cannot keep.** Observed failure at 12 turns: rotation working perfectly (no
pillar twice running) while texture was asked once, at turn 1, missing 7 of 8 windows - rotation is
precisely what starves cadence, because every turn picks a different non-texture pillar.
Cost if wrong: texture turns arrive by arithmetic rather than tact, so a session in a grim stretch gets
a food question because a counter said so. Accepted - the alternative is worlds with nine bridges and
nothing to eat, which is the failure this whole design exists to prevent.

**R-9 (2026-09-30, gate finding at 12 turns)** — `log.md` carries exactly **one machine line per
turn**: `- turn: <n> · provoked: <type> · targeted: <pillar>`, written before the prose `decided:`
lines and before any close recap. Prose is for the writer; the machine line is for the next turn, which
cannot remember otherwise. Motivated by the gap R-4 left: across three 12-turn runs the field appeared
in 1 of 14 prose lines, then 5 of 12 turns, then - once required as its own line - 11 of 12. Cadence
failures fell from 6 unmet windows to 1 for the same reason: the rule became readable, not because the
skill's taste changed. §4's cadence and consecutive-pillar constraints are only evaluable against this
line; where it is missing, they are reported as unscored rather than satisfied.
Cost if wrong: one more mechanical line per turn in a file the writer may read as bookkeeping noise.
Mitigated by shape: the line is short, fixed-form, and the prose that humans actually read stays where
it was.

**R-10 (2026-09-30, gate finding at 12 turns)** — `beat_budget` (default **45 words per labelled
beat**) joins the tunables. `words_per_turn` measures the turn and not the shape of the turn: a beat can
run 52 words inside a 155-word turn and the cap calls that compliant, which is how "light, witty,
conversational" decays into a lecture that passes every test. Measured against beats, the fat on this
project's own evidence sits in `target` (why this hole) and `write back` (what was filed) - the two
beats the writer waits through without answering anything. Cost if wrong: a beat cap tight enough to
slice a genuine digest in half; mitigated because the number is a tunable in `world/index.md` and the
writer owns it, and the instrument names which beat broke rather than reporting a turn total.

Related corrections found while implementing it: the close trigger (`turns_per_session`, default 12)
existed in a single SKILL.md sentence and is now stated in `references/rubric.md` and carried as a
tunable; and a self-test that mutated `references/voice.md` without backing it up left test markers in
shipped guidance across four runs while reporting a green round-trip - now guarded by a debris check
and a documented-default-equals-real-default check.

**R-11 (2026-09-30, gate finding F6)** — append-only applies to **files**, not only to lines. The
encyclopedia may gain files and never lose one: a retired entity is superseded in place and shows up
as an orphan in `review`. §2's promise was always that canon is history, but every check measured
*lines* inside files, and two of the ten recorded sessions had already deleted an entity file
(`rm encyclopedia/lighthouse-place.md`) without a single CANON-LOSS marker appearing. `tests/canoncheck.py`
now witnesses three ways - the start state, every path seen during the run, and the session's own tool
calls - and is wired into both harnesses. Cost if wrong: `world/encyclopedia/` accumulates files for
entities the writer abandoned; mitigated because orphans were already a concept in `review`, and the
alternative - silent disappearance of a named thing the writer once explained - is the one loss the
encyclopedia cannot recover from.

**R-12 (2026-09-30, gate finding I7)** — scoring is disclosed and arithmetically checkable. Two
symptoms, one root: `gap_weight` was an impression rather than a lookup (a thin pillar was awarded 3,
which the scale reserves for *nothing there*), and scores appeared as bare numbers ("scores highest"),
which cannot be audited by the writer or the harness. `gap_weight` is now defined against the
`Pillar coverage` table - `established == 0` → 3 · `1–2` → 2 · `≥3` across `≥2` entities → 1 · else 0 -
and the guidance requires all three terms wherever a score is shown. `invariants.py` verifies a
disclosed score's gap term against the dumped table and flags a score with no terms, so §4.1's
arithmetic is now part of the gate instead of part of the argument. Cost if wrong: the audit is only as
good as the index table it reads; a stale table produces a false contradiction, which the index rebuild
rule already treats as a first-class failure to announce rather than silently score against.

**R-13 (2026-09-30, gate finding I4)** — `new` mode's seed is specified and checked. §2 said "seed
5–8 entities"; the guidance said "one file per entity" with no count, and the harness had no `new`-mode
scenario, so the whole mode was untested. The band is now in SKILL.md (499 words) with its shape in
`references/rubric.md`: 5–8 entity files, all canon lines `proposed:`, spread over ≥3 pillars including
≥1 texture pillar, ≥3 threads per entity. The texture requirement is not a new preference - it is R-8
applied at turn one, where the cadence window is empty by construction. Validated by `tests/seedcheck.py`
(count / spread+texture / premature canon / thread floor) and graded by `check.sh behavior` with
"untested" named separately from "passed". Cost if wrong: a seeded world touches all 18 pillars, which
looks like coverage but is not - every line is `proposed:`, and §4.1 scores that as empty, so the holes
the interview aims at are intact. The band is also the anti-volume guard: 9 entities is a fail, not a
bonus.

**R-14 (2026-09-30, gate findings: option breach + I5)** — two changes, one correction. (a)
`option_words` (default 18; 19 since R-26) becomes a tunable counted against the option's text; the harness had been
adding the `- steady —` markup as three words per line, which manufactured every "20-word option"
finding - measured properly, the worst option in twelve runs is 17. (b) `review` mode is specified where
it can fire and checked where it can fail: the trigger lives in the per-turn bookkeeping line ("at 3
sessions since the last `provoked: review`, end the turn with the memo"), the five memo items are each a
computation in `references/rubric.md`, and a delivered review must log `provoked: review` so the count
resets. Cost if wrong: a review offered once every three sessions may read as nagging to a writer who
considers the world reviewed; the reset marker and the threshold are the two knobs, and `review` (asked)
and `review-owed` (unprompted) are separate scenarios so the nagging case is measurable rather than
argued.

**R-15 (2026-09-30, operator decision)** — the review memo is an **appendix artifact** with its own
limit: `memo_words` (default **120**, total across the five items), excluded from `words_per_turn` the
same way candidate options (`option_words`, 18; 19 since R-26) and the close recap (≤6 bullets) already
were. §3.1
established the principle and this is its fourth instance: an artifact the contract *mandates* cannot
also be charged against the budget for *conversation*, or the two limits mean nothing - the writer ends
up told to be brief in a turn that is required to be long. Exemption without a ceiling is only a hiding
place, so the memo is measured rather than forgiven: the longest on file was 203 words, which is a page,
not a glance, and now fails. Cost if wrong: 120 words may cut a memo that legitimately needs to cite
five contradictions; the knob is a tunable, and the item list is capped at five, so pressure resolves
into "cite less, name the thread", not into a longer exemption.
**Superseded on the number and the shape by R-16; the principle stands.**

---

## Revisions R-16 … R-22 (folded into the spec on 2026-10-15)

These decisions were made, shipped, and measured, but recorded only in commit messages. A reader asking
"what does the spec still require?" got stale answers from them, which is the reason they are here now.

**R-16 (2026-09-30, supersedes R-15's number and shape; `d4a5f6d`, `fae5099`, `ff87b5b`)** — the memo cap
moves from the **total** to the **bullet**: `memo_item_words: 45`. Chain: 120 set by feel → the first
legitimate memo certified under it ran 130 and failed → measured across every complete memo on file
(61, 91, 107, 109, 130, 203), the total ceiling went to 150 → then to per-item 45, because a total cap
lets one item become a paragraph while the other four stay thin, and the failure mode is per item. Worst
per-item value on file 60, four items over. Cost if wrong: five items at 45 can total 225, well above the
150 the total cap allowed - accepted, because the item is the shape that bloats and the total is only its
consequence. Recorded alongside: **files are judged by the limits recorded in their own dumps**, so the
130-word memo still reads FAIL under 120 in the historical transcript while passing today's default. That
asymmetry is deliberate - the gate reports what the run was told, not what was decided afterwards.

**R-17 (2026-10-13 → 10-15, instruments; `9e7932a`, `9ff22ec`, `3aaee19`)** — the graded artifact must not
contain the grader's own words. One defect, three instances: `NOT-GRADED` shared an exit code with a real
finding; the review failure message contained the literal marker whose absence it was reporting; and
`canoncheck` printed `CANON-LOSS: … rm encyclopedia/lighthouse-place.md` for a run that deleted nothing -
the string was inside a copy of canoncheck's own docstring, which the model had read off disk, in prose.
Decisions: verdicts are appended **after** the artifact closes, under a reserved `## harness verdicts`
heading; exit codes are typed (findings < 32, `64` = not graded, `128` = crash); aggregate gates
**re-derive** verdicts by running the graders rather than grepping stored verdict text, which was grading
by citation; markers are field-delimited so mentioning `review` cannot reset a counter; `canoncheck`
separates **act** (a string under a `command` key) from **mention** (prose → `CANON-NOTE`, no verdict
change), stays loud when it cannot parse, and prints `CANON-UNPARSED` instead of swallowing failures.
The one genuine deletion in the corpus is caught by the count witness, which is untouched. Suite 170 →
184 → 187 on the way. See `evidence/CANON-20261015.md`.

**R-18 (2026-10-14, gate finding; `b366677`)** — the `provoked:` field had **three** documented shapes:
`SKILL.md` said singular, `assets/index-template.md` listed an eight-name enum including `constraint` and
`stake` (which appear **zero** times in real logs), and `voice.md` said ≥1 of five. Canonical now, stated
in all four shipped files: `- turn: <n> · provoked: <types> · targeted: <pillar>`, where `<types>` is one
or more of the five engagement types plus `review` on a memo turn. Real corpus before the fix: 12×
`provoked: review`, 3× the list form. Guards are both-sided - reverting any one file fails, and trimming
the phrase that makes it a rule also fails - because the ambiguity had survived in three files with the
suite green. Word budget note: one trim broke the file-level append-only sentence ("never delete **one**
under `world/`" - the pronoun is what makes it about files); the trim was reverted, not the guard.

**R-19 (2026-10-14, `7e81eb0`, `e12ece4`)** — the length rule is made **comparative** and **moved** to the
step that has the ledger on screen; `words_per_turn` stays **170**. The failure was drift, not the number:
a five-turn retcon measured 171, 242, 195, 199, 250 (mean 211, 5/5 over cap) with a cap that bites only if
someone compares. After the change: 192, 153, 165, 173, 157 (mean 168, 2/5 over). Raising the cap instead
would launder drift into a quota, so the rule reads "longer than last turn? cut a beat", in `SKILL.md`'s
write-back bullet with the reason in `voice.md`. The two variety checks (cadence, consecutive pillar) moved
out of `## Scoring` into the same bullet - nothing duplicated, `Scoring` now names neither - and the guard
**pins position**, not wording. Known and not yet closed: at twelve turns the same rule measures mean 184
with 10/12 over cap. Placement fixed the drift; the length problem is a length problem.

**R-20 (2026-10-15, `5117840`)** — **a machine line records a turn; it does not reconstruct one.** Found
by a rule that could not be evaluated: the cadence window saw eight lines for five turns, numbered 5–12,
three annotated "late entry", naming pillars no turn had targeted. The cause was in the prop, not the
model: the fixture's `log.md` has four sessions and **zero** machine lines while its index claims twelve
turns per session, and a resumed run filled that hole by inventing rows - permanently, in an append-only
file, where every window rule then reads them as fact. The rule ("one line per turn that happened, none
for turns you did not write") is now stated in three shipped files; the fixture's hole is **deliberately
kept**, because a world with a gap in its ledger is what the skill actually meets. Verification on the
same scenario: 8 lines for 4 turns → 5 lines for 5; numbering 5–12 → 1–5; late entries 3 → 0; pillars in
the ledger that no turn named → 0. This is why G2/G3 are provisional: a window rule is arithmetic over
lines, and lines that were never turns make a clean verdict a lie.

**R-21 (2026-10-15, `3aaee19`)** — an appendix exemption needs a **shape**, not just a promise. Four
shipped files said the close recap is exempt from `words_per_turn` and none said what a recap bullet looks
like; the instrument that grants the exemption keys on bullets that open with their source. Identical
content, six bullets, ~90 words: citation last → 135 turn words counted, 0 exempt; citation first → 9
counted, 6 exempt. The whole difference was where a comma sat. §3.1 now states "citation first" in
`SKILL.md`, `voice.md` and `rubric.md`, guarded on both sides (the trailing form must still count as
prose, or a counter that exempts everything would also "pass"). Verified in a 12-turn session: all six
bullets took the documented shape and the close turn counted 125 words with 6 exempt.

**R-22 (2026-10-15, `1475ab9`, `ddb8976`)** — every enforced tunable carries a **provenance row**, and
**a cap may not be applied to a mode that is absent from its sample**. Three numbers in this spec's history
(120 in R-2, 160→170 in R-7, 120 in R-15) were set just above the largest thing measured at the time;
`words_per_turn: 170` in particular came from four single-turn runs and was then applied to sessions of
twelve. `tools/tunable_provenance.py` re-runs the graders over the whole corpus, judging each run by the
caps recorded in its own dump. What it says: single/skill n=30, median 125, **20% over** (so "single turns
hold the cap" was n=4 folklore); multi/skill n=119, median 158, **41% over** (both figures superseded by R-24: read through an instrument
that exempted reaction-mode bullets, the same corpus is n=121, median 173, **58% over** — no behaviour
changed, the counter started seeing the words); `beat_budget` breached in
**18 of 19** multi-run records (observed beats 47–74) - the most-breached, least-examined number here;
`reads_per_turn` median **0** reads per turn, so that budget documents a worry rather than a behaviour;
the scan weights and `lopsidedness_floor` remain **unmeasured** - no run has varied them. Cells where the
instrument emits no flag for that mode are labelled not measured, never "0 breaches": silence is what the
last four revisions were written to make impossible.

**R-23 (2026-10-16, operator decision; supersedes R-10's number, not its reasoning)** - `beat_budget`
default **45 -> 60**. R-10 was right that a turn can be compliant in total and monologuish in shape, but 45
was chosen from the two fattiest beats in a handful of transcripts and never re-derived. Measured across the
corpus by asking `invariants` to name every beat (cap forced to 1 in throwaway copies, so the instrument
reports its own numbers rather than a recount): medians - `digest` 22, `question` 14, `target` 27, `stop` 9,
`write back` 40, `reflect` 41. Share over the cap at 45: `reflect` 37%, `write back` 30%, `target` 20%, the
three lean beats **0%**. So 45 was mostly flagging ordinary `reflect` and `write back` beats - the two the
contract *requires* to carry content - while the monologues it existed to stop (p95 70-72, p99 104-107) were
already rare. At 60: `reflect` 12%, `write back` 7%, `target` 3%, lean beats 0%, and any beat past ~90 still
fails. Same shape, quieter, and no longer training the writer to shave the part that does the work.

Cost if wrong: 60 lets a 55-word `reflect` pass, and four of those in one turn is a lecture. Accepted,
because `words_per_turn` is the bound on exactly that sum and it is enforced per turn; the beat cap's job is
the single-gulp shape, which 60 still catches. Note the two drift guards fired while this was being made
(spec block and `docs/tunables.md` both still said 45) - which is the only reason they are consistent now.

**R-24 (2026-10-16, independent audit of the graders)** - four instrument defects closed, and the corpus
became a regression set. The graders had only ever been read by the agent that wrote them, and 14 of 23
findings logged in this project had been defects in the measuring code. An outside read found four more,
all of them the same mistake — a rule keyed on what a line *looks like* instead of where it came from:
the appendix exemption fired for any bullet opening with a slug (so `SKILL.md:52`'s own reaction mode —
"sketch 6 lines" — was invisible to `words_per_turn`: 162w counted where the same words in prose order
count 291); any line starting `writer:` was dropped, anywhere in a turn, not just the harness echo;
`canoncheck`'s act/mention split trusted the argument key `command`, so one ordinary bash call made a
deletion recorded another way read as "written about, never run"; and `reviewcheck` accepted the
*documentation* of a machine line as a delivered review, because the guide text contains the same
separators. Three of the four let a bad run pass; none was covered by any of the 199 assertions.

Two procedural rules come out of it, both now enforced. **Polarity before severity** — a finding states
whether it can make a bad run PASS or only make a good run FAIL, because that ranking is what the list
kept getting wrong (a live laundering channel was filed below a shape with zero occurrences in the
archive). And **a claim must be grepped against the corpus, including for a count of 0** — a `/tmp` pair
proves a mechanism reachable, never reached. So `tests/golden_verdicts.tsv` records all 213
(file, grader, exit code) verdicts over `evidence/` and re-derives them on every corpus run, and
`provsweep` compares the provenance table to its machine-readable twin cell by cell instead of asking
whether the digits appear somewhere in the file. The fixed graders read **18 of those 213 verdicts
differently**; the rules themselves are hoisted into `harness_markers.py`, since three of the four
defects existed in two places at once. See `evidence/GRADER-20261016.md`.

**R-25 (2026-10-16, decision: give the sketch its own tunable)** - `sketch_words: 25`, six lines to a
block. R-24 closed the laundering hole by refusing to exempt slug bullets outside a close, which was
correct about the instrument and wrong about the behaviour: reaction mode is *mandated* ("sketch 6
lines"), so the rule now said the beat the guidance asks for must fit inside the conversational cap. It
does not fit — the one sketch in the archive is turn 5 of `cadence-skill-multi-20261015T035948Z.md`,
162w counted where the same words read 291w. The honest shape is what `memo_item_words` and
`option_words` already are: an appendix with a bound of its own. So a sketch block (four or more
consecutive bullets that each open with a bare `slug`, in a turn that is not a close) is exempt from
`words_per_turn` and bounded per line by `sketch_words` and in count by six, flagged as an appendix
breach (bit 2) either way. Level: measured max 20w across six lines, so 25 is headroom over a sample of
one block, stated as provisional rather than dressed up as a distribution. Cost if wrong: a fat sketch
line passes that would have been caught as prose, and six of them is 150 words of appendix in one turn —
bounded by the count rule, and by `beat_budget` for any line that carries a beat label.

**R-26 (2026-10-16, decision: 19 words is fine)** - `option_words: 18 -> 19`, and the reading is the
per-option one. The two measurements that disagreed were the length column (longest option in a turn) and
the flag (any option, anywhere); the column said max 18 and 0% over while 3 of 19 runs carried
`option 19w > option_words 18`. Measured across all 318 options in the multi/skill corpus: min 7, median
13, p90 17, p95 17, p99 19, max 19 — 19 is the ceiling the behaviour actually has, so the cap sits on it
and 0% over is now a true statement rather than an artefact of which column was read. Cost if wrong: a
20-word option passes unnoticed; that is the direction this number was raised in, and `words_per_turn`
still bounds the turn the options live in.

## Open items (no decision taken)

Verified against the shipped bundle on 2026-10-15; these are spec requirements with no implementation and
no decision, listed so the next reader does not have to rediscover them:

1. §2.2 `new` mode's **"you pick" branch** - deal three premises off different genre assumptions - is
   absent from all guidance. A writer who declines to choose gets the same premise question.
2. §3.2 **`sarcasm: on`** is declared in the template and read by nothing; `voice.md`'s sarcasm rule is
   unconditional, so turning it off changes no documented behaviour. The only tunable with no reader.
   As of R-24 the provenance table says so out loud ("not measured, bound to nothing") rather than
   leaving the row absent, which is what the new `provsweep` guard would have flagged.
3. §7 **slug collision** (append the kind: `lady-severin-person`) is stated nowhere; the convention exists
   only because the fixture's files happen to be named that way, so it is a modelling cue, not a rule.
4. §2.1's **known limitation** - install at CWD when CWD ≠ project_root, say so, recommend running pi from
   the root next time - is not in the kit; nor is §2.1's warning that project skills are reviewed by pi's
   trust prompt (the kit only says they "now load from here"). §8's "ask if ambiguous at depth" for several
   `world/` trees is likewise unimplemented: nearest wins and the path is named, but nothing asks.
5. §9's **voice micro-test** (5 fresh-context samples of one digest turn, variance read by hand) was never
   run - plan Task 9's `evidence/voice-microtest.md` does not exist. The question it was for got answered
   by full scenario runs instead, at roughly twelve times the cost.
