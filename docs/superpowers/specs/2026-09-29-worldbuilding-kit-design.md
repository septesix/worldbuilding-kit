# Worldbuilding Kit — Design Spec

**Version:** 0.1.0
**Date:** 2026-09-29 (host clock)
**Status:** approved for implementation planning
**Owner:** septesix

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
| **3 Question** | **Exactly one** question, plus 2–3 candidate answers labelled `steady / sharp / strange` (faithful · dangerous · weird), each ≤18 words |
| **4 Stop** | Wait. The writer's move is always a single reply |

The turn *after* an answer begins with two beats of its own:

- **Write back** — append canon and update `index.md` **before** any new question. A crash costs
  at most one exchange. Facts are declarative bullet lines, never dialogue.
- **Reflect** — state one consequence or connection the writer did not say. This beat is where
  "surprising" lives; it is structure, not aspiration.

### 3.1 Session close

When the writer ends a session (or 12 turns pass without one), append to `log.md` and show in
chat: 3–6 bullets of **what we just decided**, then **the next thread I would pull and why**.
Closing the laptop mid-novel must cost nothing.

### 3.2 Tunables

Read at session start from `world/index.md` frontmatter. The writer edits the file directly;
there is no command surface.

```yaml
tunables:
  words_per_turn: 120      # excluding candidate options
  texture_cadence: 4       # every Nth turn must be a texture question
  sarcasm: on
  weight_gap: 1.0
  weight_hook: 1.0
  weight_contradiction: 1.5
  lopsidedness_floor: 0.6  # never same pillar twice running if another scores ≥ this ratio
```

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
with it. Being stuck must not become an interrogation.

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

1. ≤120 words per turn (candidate options excluded). Jokes may appear anywhere in the turn,
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

Each turn appends `provoked: <type>` to its `log.md` line. **Three consecutive turns of one type
forces a switch.** `review` reports the distribution.

## 7. Data model

```
<project_root>/world/
  index.md                  # DERIVED registry + scoreboard
  encyclopedia/<slug>.md    # one file per entity
  threads.md                # open-question ledger (authoritative for what is unresolved)
  log.md                    # append-only session recaps
```

- **`index.md`** — frontmatter (`world`, `skill_version`, `sessions`, `last_date`, `tunables`),
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
