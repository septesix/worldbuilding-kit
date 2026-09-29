# Worldbuilding Kit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the two-artifact worldbuilding skill — a tiny global trigger that installs a full project-local interviewing skill, which writes and resumes a `world/` encyclopedia.

**Architecture:** `kit/SKILL.md` (global, symlinked into `~/.pi/agent/skills/`) detects a writing project, copies `bundle/worldbuilding/` into `<cwd>/.pi/skills/`, then hands off by reading it. The bundle holds the turn contract, the two-tier rubric, the voice contract, and three scaffolding templates; all world data is written at runtime into `<project_root>/world/`.

**Tech Stack:** Agent Skills markdown, pi CLI (`pi -p --no-extensions --no-skills --skill <path>`), bash harness, git.

**Spec:** `docs/superpowers/specs/2026-09-29-worldbuilding-kit-design.md` — the plan argues from it; read both.

## Global Constraints

- Skill names: lowercase `a-z0-9-` only, ≤64 chars. `kit` frontmatter name `worldbuilding-kit`; bundle name `worldbuilding`.
- Both descriptions ≤1024 chars; kit description ≤35 words; bundle `metadata.version: 0.1.0`.
- Word budgets: `kit/SKILL.md` <150 words; `bundle/worldbuilding/SKILL.md` <500 words; candidate options ≤18 words each; turn ≤`words_per_turn` (default 120).
- Defaults for tunables, verbatim from spec §3.2: `words_per_turn: 120`, `texture_cadence: 4`, `sarcasm: on`, `weight_gap: 1.0`, `weight_hook: 1.0`, `weight_contradiction: 1.5`, `lopsidedness_floor: 0.6`.
- The repo never contains world data. `world/` is created only at runtime inside a writing project.
- Canon lines are append-only: changes add `revised:` and mark the old line `superseded-by:`; nothing is edited in place.
- Entity kinds, exactly nine: `person · place · era · custom · conflict · institution · artifact · text · creature`.
- Every task's RED evidence is committed before its GREEN phase may begin.

## Review Focus

The spec implies these, no task's happy path tests them. Each gets a pinned test in the task named:

1. **Writer restates something already canon, differently** → must become a Contradiction beat, never a duplicate entry or a re-ask (Task 6).
2. **CWD is `$HOME` or a non-project dir** → must not scaffold; must ask for the manuscript folder and confirm the absolute path once (Task 7).
3. **`world/` exists but `index.md` is missing or stale** → rebuild from entity files and announce the rebuild (Task 6).
4. **Writer answers "you decide" more than half of the last 8 turns** → switch from interviewing to reaction mode (Task 6).
5. **A 200-entity world** → read ≤3 entity bodies per turn and never dump index tables into chat (Task 6).
6. **A deliberately weak writer idea** → wit may target the world, never the author (Task 9).

---

### Task 1: Test harness and fixtures

**Files:**
- Create: `bundle/worldbuilding/tests/run.sh`, `tests/check.sh`, `tests/scorecard.md`, `tests/fixtures/empty/.gitkeep`, `tests/fixtures/established/world/{index.md,threads.md,log.md}`, `tests/fixtures/established/world/encyclopedia/{nine-bridges-place.md,lady-severin-person.md,tide-lock-artifact.md,bridge-tolls-custom.md,war-of-nine-ledgers-era.md,severins-child-place.md}`
- Modify: none

**Interfaces:**
- Produces: `bash tests/run.sh <scenario-id> <control|skill>` → writes `evidence/<scenario-id>-<variant>-<utc>.md` (transcript + files the run created), exits 0. `<scenario-id>` ∈ `continue-empty` (empty dir), `continue-established` (fixture world), `pressure-wrapup`, `tone-sarcasm`, `stale-index`, `home-dir`, `reaction-mode`. Variant `control` runs `pi --no-extensions --no-skills -p`; variant `skill` appends `--skill bundle/worldbuilding/SKILL.md`. Both run with `cd` into a `mktemp -d` copy of the fixture, `--no-session --session-dir <tmp>`.
- Produces: fixture world — 6 entities, ≥1 `proposed:` line, one pair of canon lines that cannot both be true (the tide-lock entry vs the bridge-tolls entry), deliberately no entry under *daily & material life* and none under *faith, myth & meaning*.

- [ ] **Step 1: Write the failing check.** `tests/check.sh` asserting: `run.sh` on `continue-established control` creates no files under `world/encyclopedia/` and asks ≥2 questions whose text also appears verbatim-ish in the fixture (baseline ignorance).
- [ ] **Step 2: Run it, expect FAIL** (no `run.sh` yet): `bash bundle/worldbuilding/tests/check.sh`
- [ ] **Step 3: Implement `run.sh`** — copies fixture to a tmp dir, runs pi headless with the flags above, tees stdout plus a `find` of the tmp dir into the evidence file.
- [ ] **Step 4: Author the fixture world** to the spec above, hand-written, small (≤12 canon lines per entity).
- [ ] **Step 5: Run check, verify PASS**, and read `evidence/continue-established-control-*.md` once to confirm the failure is real, not a harness artifact.
- [ ] **Step 6: Commit** `git commit -m "test: headless skill harness + nine-bridges fixture world"`

### Task 2: RED baselines (no skill)

**Files:**
- Create: `evidence/BASELINE.md`

**Interfaces:**
- Consumes: Task 1's `run.sh`.
- Produces: named failure patterns reused by Tasks 6–9 as `expected-baseline` strings.

- [ ] **Step 1:** Run `control` for `continue-established`, `continue-empty`, `pressure-wrapup`, `tone-sarcasm`.
- [ ] **Step 2:** Record in `BASELINE.md`, per scenario, verbatim quotes of: questions re-asking established facts, persistence that never happened, `proposed:` facts presented as settled, and any evaluation of the writer's idea ("that's bold"). Tag each quote with the rationalization the run gave.
- [ ] **Step 3:** Add to `check.sh` one assertion per scenario keyed to those strings, so the baseline stays reproducible.
- [ ] **Step 4: Commit** `"docs: record RED baselines for worldbuilding skill"`

### Task 3: Scaffolding templates

**Files:**
- Create: `bundle/worldbuilding/assets/index-template.md`, `assets/entity-template.md`, `assets/threads-template.md`

**Interfaces:**
- Produces exact section names Tasks 4–6 key off: index frontmatter keys (`world`, `skill_version`, `sessions`, `last_date`, `tunables`), index sections `## Pillar coverage`, `## Entities`, `## Texture digest`, `## Hottest threads` (tables within the first 60 lines); entity sections `## Canon`, `## Open questions`, `## Links` with `established:` / `proposed:` / `revised:` / `superseded-by:` line prefixes; thread fields `status:`, `asked-by:`, `pillars:`, `hook:`, `spawned:`.
`tests/` scripts are development fixtures only: nothing in the shipped skill body may reference them, and Task 7 strips them at install time (`cp -R` then `rm -rf <target>/tests`).

- [ ] **Step 1: Failing check** — `check.sh`: a template-scaffolded `world/` must satisfy `grep -c '^## Pillar coverage' == 1`, index tables inside 60 lines, all 11 world + 7 character pillar rows present, all nine kinds listed in `entity-template.md`.
- [ ] **Step 2: Run, expect FAIL.**
- [ ] **Step 3:** Write the three templates. Each carries one worked example line so the executor of the skill sees the shape, not a blank field.
- [ ] **Step 4: Run, expect PASS. Commit** `"feat: encyclopedia scaffolding templates"`.

### Task 4: `references/rubric.md` — the two-tier guide

**Files:**
- Create: `bundle/worldbuilding/references/rubric.md`

**Interfaces:**
- Produces: the 11 world + 7 character pillar names (the canonical strings Tasks 3, 5, 6 grep against), 4–5 probe patterns per pillar, the 9 child generators, the 3 hard rules, the anti-glass test.

- [ ] **Step 1: Failing check** — pillar-name set matches Task 3 exactly; every pillar has ≥4 probes; exactly 9 child generators; the phrase "must spawn ≥3 threads" present.
- [ ] **Step 2: Run, expect FAIL.**
- [ ] **Step 3:** Write it. Probes must be question-shaped, not topic-shaped ("what does it run out of?", not "resources").
- [ ] **Step 4: Run, expect PASS. Commit** `"feat: pillar floor + entity-child rubric"`.

### Task 5: `references/voice.md` — contract and worked transcript

**Files:**
- Create: `bundle/worldbuilding/references/voice.md`

**Interfaces:**
- Consumes: fixture entity names from Task 1, pillar strings from Task 4.
- Produces: the 4 voice rules, the warranted-sarcasm definition, the 5 engagement types (`consequence · contradiction · connection · cost · discovery`), the 3-consecutive-type switch rule, and a 3-turn worked transcript that is the calibration artifact and the Task 9 fixture.

- [ ] **Step 1: Failing check** — transcript contains all four beats in order, is ≤120 words per beat-triple excluding options, options ≤18 words, and uses the fixture entities by name.
- [ ] **Step 2: Run, expect FAIL.**
- [ ] **Step 3:** Write contract then transcript. Transcript is the only narrative content allowed in the bundle.
- [ ] **Step 4: Run, expect PASS. Commit** `"feat: voice contract + worked transcript"`.

### Task 6: `bundle/worldbuilding/SKILL.md` — the method

**Files:**
- Create: `bundle/worldbuilding/SKILL.md`

**Interfaces:**
- Consumes: every section name from Tasks 3–5.
- Produces: the installable skill. Frontmatter `name: worldbuilding`, `metadata.version: 0.1.0`, description naming world bible / lore / setting / backstory / consistency and resume. Body: modes `new | continue | review`, the four beats, write-back-before-next-question, the §4 scoring formula with the gap_weight polarity that makes an *empty* pillar score 3, the mode-switch rule, the world-discovery rule (`project_root` = nearest `.git` ancestor else CWD), ≤3 entity bodies per turn, tunables block.

- [ ] **Step 1: Failing check** — `wc -w < 500`; each Review Focus item 1, 3, 4, 5 has a grep-able rule (contradiction-not-duplicate; index rebuild-and-announce; >50% `proposed:` in the last 8 turns switches to reaction mode; ≤3 entity bodies per turn); the session-close rule from spec §3.1 exists; "writes only inside `world/`" exists.
- [ ] **Step 2: Run, expect FAIL.**
- [ ] **Step 3:** Write it, addressing only the failures recorded in Task 2. Body cross-references `references/rubric.md` and `references/voice.md` by relative path; no duplicated rubric text.
- [ ] **Step 4:** Run variants `continue-empty`, `stale-index`, `reaction-mode` — score against `scorecard.md`; every one must pass the rules that the control run violated.
- [ ] **Step 5: Commit** `"feat: worldbuilding project skill (turn contract)"`.

### Task 7: `kit/SKILL.md` — trigger, installer, handoff

**Files:**
- Create: `kit/SKILL.md`, `README.md`
- Modify: none

**Interfaces:**
- Consumes: `bundle/worldbuilding/` (copied verbatim).
- Produces: `~/.pi/agent/skills/worldbuilding-kit` → symlink to this `kit/`. Detection order per spec §2.1 (resolve `project_root`, check `world/`, refuse-in-non-project, install to `<cwd>/.pi/skills/worldbuilding/` with `cp -R` + `rm -rf` of the copied `tests/`, version offer, then `read` and hand off).

- [ ] **Step 1: Failing check** — `home-dir` scenario run from `$HOME` creates nothing under `~/.pi/skills/` or `~/world/` and asks where the manuscript lives; `continue-established` run with only the kit available installs the bundle and its reply cites a fixture entity name; `wc -w kit/SKILL.md < 150`; description ≤35 words.
- [ ] **Step 2: Run, expect FAIL.**
- [ ] **Step 3:** Write `kit/SKILL.md` and the `README.md` install/uninstall lines, then create the symlink: `ln -s ~/worldbuilding-kit/kit ~/.pi/agent/skills/worldbuilding-kit`.
- [ ] **Step 4:** Run both scenarios, verify PASS; confirm `pi` at that CWD lists `worldbuilding` after install (proof pi resolves the copied dir).
- [ ] **Step 5: Commit** `"feat: kit trigger with on-demand project install"`.

### Task 8: GREEN — full scenario sweep

**Files:**
- Modify: `bundle/worldbuilding/SKILL.md`, `references/*` (only where a scenario failed), `tests/scorecard.md`

- [ ] **Step 1:** Run all seven scenarios with variant `skill`; fill `scorecard.md` (rows = scenarios, columns = beats present / write-back / engagement type logged / texture cadence / word cap / proposed tagging / no re-ask).
- [ ] **Step 2:** Any red cell: fix the wording that failed, not the scenario. Re-run.
- [ ] **Step 3:** Re-run every `control` to prove no check passes vacuously.
- [ ] **Step 4: Commit** `"test: GREEN sweep for worldbuilding kit v0.1.0"`.

### Task 9: Voice micro-test (5 reps, variance is the metric)

**Files:**
- Create: `evidence/voice-microtest.md`
- Modify: `references/voice.md` (only if wording fails to converge)

- [ ] **Step 1:** 5 fresh-context runs of one digest turn on the fixture, plus 5 of `tone-sarcasm` fed a deliberately weak idea ("the toll is paid in grapes").
- [ ] **Step 2:** Read every output by hand. Record word counts, engagement types, and any line where the joke landed on the writer.
- [ ] **Step 3:** Converged shape → commit. Five different interpretations → tighten the *form* (recipe, not prohibition) and repeat Step 1.
- [ ] **Step 4: Commit** `"test: voice micro-test + wording fixes"`.

### Task 10: REFACTOR and deploy

**Files:**
- Create: `CHANGELOG.md`
- Modify: skill files as dictated by residual rationalizations

- [ ] **Step 1:** Harvest every rationalization from Tasks 8–9 into counters or a table in `SKILL.md`; add the red-flag list.
- [ ] **Step 2:** Re-run `pressure-wrapup` 3×; zero write-back misses required.
- [ ] **Step 3:** Write `CHANGELOG.md` (v0.1.0) and the one-line upgrade path (`metadata.version` compare, `world/` untouched).
- [ ] **Step 4: Commit** `"release: worldbuilding kit v0.1.0"`, then tag `v0.1.0`.
