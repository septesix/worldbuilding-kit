# Where every number in the skill came from

The `multi` path of the static suite re-derives two of these figures against a live run of the
tool, so a corpus that grows without the table being regenerated fails the suite rather than quietly
aging. Not in the fast (static-only) path: it costs about a minute over 62 records.

Regenerate the measurements with `python3 tools/tunable_provenance.py` (62 run records, 21 guidance keys,
2 empty turns excluded as infrastructure). Numbers below are as of 2026-10-15, guidance key `5e29a642`.

**The rule this table enforces: a cap may not be applied to a mode that is absent from its sample.**
Every value here was measured somewhere specific. Carrying it into a situation that was never measured is
an unrecorded guess with a decimal point on it. Where a cell says *not measured*, no experiment in this
repo has looked at that mode, and that is a statement about the evidence, not about the skill's behaviour.

| tunable | what it limits | stated in | measured | verdict |
|---|---|---|---|---|
| `words_per_turn: 170` | assistant prose per turn, recap/memo excluded | `SKILL.md`, `voice.md`, `rubric.md`, `index-template.md` | single/skill n=30: median 127, p90 185, **23% over** · multi/skill n=121: median 172, p90 217, **58% over** · multi/control n=17: median 208, p90 250, **70% over** | **supported for single, wrong for long sessions.** Set from four single-turn runs (128, 164, 164, 188). These are corrected figures, not new behaviour: until 2026-10-16 the counter exempted any bullet that merely OPENED with a slug, and that is reaction mode's shape as much as a close recap's, so the same 19 multi/skill runs read 41% over instead of 58% (n moved 119→121 because two turns had nothing but exempt-shaped lines and produced no measurement at all). Control arms, which are not given the rule, sit 20% higher at the median - the rule moves behaviour; its level is not validated above ~155 |
| `texture_cadence: 4` | turns allowed between texture pillars | `SKILL.md`, `rubric.md` | multi: **10 of 19 runs** contain a cadence breach · single: flag never emitted | **measured in multi only.** Single-turn runs cannot show it (one turn, no window). Placement was moved to the write-back step (G3, key `52805797`); n=1 verified there, unverified at 12 turns |
| pillar repetition (same rule, 2-turn window) | same pillar on consecutive turns | `SKILL.md` | multi: **12 of 19 runs** breach | **weakest point in the guidance**, and the reason G3 is provisional. Observed repeats end at turns 2 and 7 of a long session |
| `reads_per_turn: 3` | entity files opened per turn | `SKILL.md`, `rubric.md` | multi/skill n=123: median 0, p90 2, max 4, **0% over** · multi/control n=17: median 0, max 1 · single: not measured | **supported, and loose.** Nobody gets near 3. Median 0 reads per turn means the budget describes a fear, not a behaviour — the interesting number here is 0, not 3 |
| `beat_budget: 60` | words in one labelled beat | `rubric.md`, `voice.md`, `SKILL.md` | n=627 beats, every one named by the instrument (cap forced to 1 in throwaway copies so nothing hides): median `digest` 22 · `question` 14 · `target` 27 · `stop` 9 · `write back` 40 · `reflect` 41. Share over: at 45 -> reflect 37%, write back 30%, target 20%, the three lean beats 0%; at 60 -> 12% / 7% / 3% / 0% | **raised 45 -> 60 (R-23).** 45 was biting the two beats the contract *requires* to carry content, while the monologues it existed to stop (p95 70-72, p99 104-107) were already rare. Best-supported number in the skill now, and the only one where cap and behaviour were measured in the same pass |
| `option_words: 19` | each offered direction's length | `rubric.md`, `index-template.md`, `SKILL.md` | single/skill n=26: median 15, max 18 · multi/skill n=13: median 14, max 18 · single/control n=2, multi/control n=1 — n=42 longest-option samples, 0% over **by the length column** · all 318 options in multi/skill runs: median 13, p99 19, max 19 · multi: **3 of 19 runs** contain `option 19w > option_words 18` **at the cap in force then (18)** | **the ceiling behaviour actually has** (R-26). The two columns disagreed because they measured different things — longest option per turn vs any option anywhere; measured per option across 318 samples the max is 19, so the cap now sits on the observed ceiling and 0% over is a true statement rather than an artefact of which column was read. Cost if wrong: a 20-word option passes unnoticed |
| `sketch_words: 25` | each line of a reaction-mode sketch block, six lines to a block | `SKILL.md`, `rubric.md`, `index-template.md` | **one block on record** (`cadence-skill-multi-20261015T035948Z.md` turn 5): 6 lines, 17-20 words each, median 18. The count is honest: n=6, one run. Provisional, not a distribution · sketch lines are exempt from `words_per_turn` and bounded here instead | **provisional, stated as such** (R-25). 25 is headroom over a single observation, and the reason it exists at all is that F1 proved the corpus was silently exempting this shape by *accident*; an explicit allowance is cheaper to revisit than an invisible one. Re-measure after 5 more reaction-mode turns |
| `memo_item_words: 45` | each line of a review memo | `rubric.md` | single/skill n=13: median 38, max **60**, 3 items over · multi/skill n=1: 50w, over | **measured, breached 4 times in 14 items.** The shape cap is real and roughly right; the misses are one clause long. n=1 for multi — do not read it as a mode difference |
| `turns_per_session: 12` | when the close cue fires | `SKILL.md`, `index-template.md` | n=1: one 12-turn session observed end-to-end, cue fired, recap followed | **n=1.** Nothing about a 30-turn or 6-turn session is measured |
| `sarcasm: on` | the archivist's temperature, not a countable rule | `SKILL.md`, `voice.md` | **not measured.** Nothing in the graders reads this key: no artefact feature is gated on it, so raising or lowering it changes no verdict. Open item in the spec - either bind it to something the instrument can see or delete the knob |
| `weight_gap: 1.0`, `weight_hook: 1.0`, `weight_contradiction: 1.5`, `lopsidedness_floor: 0.6` | how much each score term counts, and the bar for "another candidate is nearly as good" | `index-template.md`, `SKILL.md` | no run varies them; `invariants` prints the decomposition (`gap_weight 3` is the **term**, 0–3, not a tunable) and nothing compares the products | **unmeasured.** Never tested against an alternative, only against the fixture's shape. Note the two layers: the *terms* `gap_weight` (0–3) and `hook_weight` (0–4) are what a candidate scores; the `weight_*` keys multiply them. Conflating them once put a value of 0.34 in this table for a tunable that ships 0.6 |

## Corrections this table forced

- **"Single-turn runs hold the cap."** Wrong as a corpus claim: 26% over, n=30. The earlier statement came
  from four samples in one batch and was repeated in a commit message before this measurement existed.
- **"The instrument's numbers are the world's numbers."** The 41% above was itself folklore: the counter
  exempted any bullet opening with a slug, so reaction-mode prose (six lines, the shape `SKILL.md:52`
  asks for) left the transcript invisible to `words_per_turn`. Same 19 runs, same turns, 58% once the
  exemption is keyed to position instead of shape. Every behavioural number in this repo predating
  2026-10-16 should be read as a floor on turn length, not a measure of it. Found by an independent
  audit of the graders; see `GRADER-20261016.md` and R-24.
- **"Beats sit at the limit."** Wrong twice over: 15 of 19 runs (multi/skill) did contain a beat over
  the budget recorded in that run's own dump,
  but the beats breaching were mostly `reflect` and `write back` doing the work they are asked to do. The
  single number was aimed at the wrong tail; resolved by R-23 (45 -> 60).
- **"0 breaches" in single-turn cells.** An artefact of the instrument: `invariants` only emits the
  beat/option flags on its multi-turn path. Absence of the token is absence of measurement.
- `canon_loss` shows 0 of 19 multi runs *by the invariant's reading*; canon incidents are graded by
  `canoncheck` at run time, and the one real deletion in the corpus was caught by the count witness. See
  `CANON-20261015.md` for the case where the text witness reported a deletion that never happened.

## What would change if the numbers moved

Raising `words_per_turn` launders drift into a quota (see `G2-20261015.md`): the 41% over-cap in long
sessions is not the cap being too small, it is the length comparison failing to hold as turns accumulate.
`beat_budget` was the tunable with strong evidence that its level was wrong; R-23 moved it to 60. Note that raising a default barely moves the corpus breach count (18 to 15 runs with an
over-budget beat), because every artifact is judged by the `beat_budget` value in its own dump - 45 for
the older ones. That asymmetry is the standing rule, not a bug: the gate reports what the run was told.
The number takes effect on worlds scaffolded from here on, and the evidence for it is the measured beat
lengths above, not the marker count. The one with evidence that
it is unenforced in practice is `reads_per_turn`, whose median is 0.
