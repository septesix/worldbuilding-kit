# RED baselines — worldbuilding skill (no skill installed)

Runs: `bash tests/run.sh <scenario> control`, sandboxed `HOME`, `--no-extensions --no-skills --no-session`,
sequential (concurrent runs return empty transcripts on this box). Model: `spark-vllm/qwen3.8-flash-next`,
thinking high. Evidence files: `evidence/*-control-*.md`.

**Headline: the baseline is already competent.** With a well-shaped `world/` on disk, an agent with no
skill performs roughly 85% of the designed loop. Per writing-skills ("if the control doesn't exhibit
the failure, there is nothing to fix"), guidance is authored below only for the failures that were
actually observed. Everything else is cut.

## Did NOT fail — do not write guidance for these

| Planned guidance | Baseline evidence |
|---|---|
| Contradiction detection as the engagement beat | `pressure-wrapup`: *"One thing you didn't say and should look at: 'a forged name gets silence' cannot be true beside 'Severin crossed at a false name twice'."* |
| Append-only provenance (`proposed:` / `superseded-by:`) | same run: *"`proposed:` her death leaves no lawful crossing… You said 'I suppose', so it's veto-able, not canon"* and *"the old ledger line is marked `superseded-by:`, in part only"* |
| Write-back before the recap | *"Written back. `world/` now holds five sessions."* + 5-bullet session recap + named next thread |
| Wit that targets the world, never the writer | `tone-sarcasm` (given "the toll is paid in grapes"): *"Grapes rot, so someone must harvest, weigh and spoil them"* — the joke lands on the world's logistics. **No "that's bold"/"interesting choice" anywhere in any transcript.** |
| Steady/sharp/strange candidate options | appeared unprompted in `continue-established` and `tone-sarcasm` |

## DID fail — these own the guidance

### F1 · No encyclopedia structure when there is nothing to read (resume contract)
`continue-empty` wrote a single `world/00-forks.md` containing four parallel candidate worlds. No
`index.md`, no `threads.md`, no per-entity files, no kinds. A second session cannot resume, score
coverage, or avoid re-asking. **Owns:** `assets/*-template.md`, the scaffolding rule in `new` mode,
entity-kind vocabulary.

### F2 · Multiple questions per turn
`continue-established`: *"Three questions, in priority order. Say 'yes', 'no', or fix it."* — three
questions plus a fourth implied. The spec's single-question beat is violated in 2 of 4 transcripts.
**Owns:** the one-question rule and the `exactly one` phrasing in the turn contract.

### F3 · Verbosity
Observed turn lengths ≈ 180–350 words against the 120-word budget; the `continue-empty` turn is the
worst (four worlds, ~350 words). **Owns:** `words_per_turn` and the "liveliness is not volume" rule.

### F4 · No coverage bookkeeping, no cadence, no engagement log
The baseline notices *that* pillars are empty (*"Two of eighteen pillars are still empty — and the
texture digest is blank after four sessions"*) but only because the fixture's `index.md` said so.
With no index (F1) it never builds one; nothing logs `provoked:`; nothing enforces the texture
cadence; nothing prevents three consecutive `cost` turns. It also silently invented a new entity
(`lockkeepers-daughter-person.md`) with no thread record. **Owns:** the rubric floor as a *counting*
mechanism, `must spawn ≥3 threads`, the cadence rule, the `log.md` `provoked:` line.

### F5 · Scoring is improvised per turn
`tone-sarcasm` shows *"Score: gap 2 + hook 3 + contradiction 1 = 5.5"* while `continue-established`
shows *"gap 2 (power-systems thin) + hook 4 + contradiction ×1.5 = 7.5"* — the same design, two
different formulas, one of them missing the weight. Not wrong, but unreproducible: the writer cannot
be told why this question came next. **Owns:** the single §4 formula in `SKILL.md`.

## Consequences for the plan

- Task 4 (`rubric.md`) keeps the pillar floor **as bookkeeping** and the child generators **as
  question supply**; probe prose is trimmed where the baseline already generates good questions.
- Task 5 (`voice.md`) keeps the budget, the no-evaluation rule and the engagement log. The
  sarcasm-target rule is kept as a one-line guardrail with **no worked anti-example** — there is no
  observed failure to illustrate.
- Task 6 (`SKILL.md`) is where F1–F3 and F5 are actually fixed; it stays the largest deliverable.
- Task 9 (voice micro-test) is reduced to the word budget and the one-question rule, because the
  tone control did not fail.

## Infra notes found while running

- `pi` exports `PI_SESSION_*` into subprocesses by default (`exposeSessionEnvironment ?? true`); the
  first sweep's "baselines" were the parent session talking to itself. Scrubbed.
- The repo sitting under `$HOME` let a control run find the spec by `ls`. Sandboxed `HOME` per run.
- Concurrent headless runs return empty transcripts; the sweep is sequential, ~2.5–4 min per run.
