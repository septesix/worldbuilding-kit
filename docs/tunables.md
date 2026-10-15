# Where every number in the skill came from

Regenerate the measurements with `python3 tools/tunable_provenance.py` (62 run records, 21 guidance keys,
2 empty turns excluded as infrastructure). Numbers below are as of 2026-10-15, guidance key `5e29a642`.

**The rule this table enforces: a cap may not be applied to a mode that is absent from its sample.**
Every value here was measured somewhere specific. Carrying it into a situation that was never measured is
an unrecorded guess with a decimal point on it. Where a cell says *not measured*, no experiment in this
repo has looked at that mode, and that is a statement about the evidence, not about the skill's behaviour.

| tunable | what it limits | stated in | measured | verdict |
|---|---|---|---|---|
| `words_per_turn: 170` | assistant prose per turn, recap/memo excluded | `SKILL.md`, `voice.md`, `rubric.md`, `index-template.md` | single/skill n=30: median 125, p90 185, **20% over** · multi/skill n=119: median 158, p90 203, **41% over** · multi/control n=17: median 198, 58% over | **supported for single, wrong for long sessions.** Set from four single-turn runs (128, 164, 164, 188). Across the whole corpus single turns exceed it a fifth of the time; twelve-turn sessions exceeded in 10 of 12 turns in one measured run. Control arms, which are not given the rule, sit ~25% higher — the rule moves behaviour, its level is not validated above ~155 |
| `texture_cadence: 4` | turns allowed between texture pillars | `SKILL.md`, `rubric.md` | multi: **10 of 19 runs** contain a cadence breach · single: flag never emitted | **measured in multi only.** Single-turn runs cannot show it (one turn, no window). Placement was moved to the write-back step (G3, key `52805797`); n=1 verified there, unverified at 12 turns |
| pillar repetition (same rule, 2-turn window) | same pillar on consecutive turns | `SKILL.md` | multi: **12 of 19 runs** breach | **weakest point in the guidance**, and the reason G3 is provisional. Observed repeats end at turns 2 and 7 of a long session |
| `reads_per_turn: 3` | entity files opened per turn | `SKILL.md`, `rubric.md` | multi/skill n=123: median 0, p90 2, max 4, **0% over** · multi/control n=17: median 0, max 1 · single: not measured | **supported, and loose.** Nobody gets near 3. Median 0 reads per turn means the budget describes a fear, not a behaviour — the interesting number here is 0, not 3 |
| `beat_budget: 45` | words in one beat (the ask, or a write-back block) | `rubric.md`, `voice.md` | multi: **18 of 19 runs** contain `target NNw > beat 45` · single: flag never emitted | **breached in almost every session, and by the instrument's own arithmetic.** Observed beats: 47, 48, 50, 53, 56, 68, 74. Either beats are written longer than the budget intends, or 45 was never about the thing now being measured (write-back blocks count as beats). Highest-value unexamined number in the skill |
| `option_words: 18` | each offered direction's length | `rubric.md` | n=41 longest-option samples: median 15, max 18, 0% over **by the length column** · multi: **3 of 19 runs** contain `option 19w > option_words 18` | **at the limit, not under it.** The aggregate and the flag disagree because they measure different things (longest option vs any option); 19-word options exist. Do not tighten this to "fix" 3 breaches without deciding which reading is the rule |
| `memo_item_words: 45` | each line of a review memo | `rubric.md` | single/skill n=13: median 38, max **60**, 3 items over · multi/skill n=1: 50w, over | **measured, breached 4 times in 14 items.** The shape cap is real and roughly right; the misses are one clause long. n=1 for multi — do not read it as a mode difference |
| `turns_per_session: 12` | when the close cue fires | `SKILL.md`, `index-template.md` | n=1: one 12-turn session observed end-to-end, cue fired, recap followed | **n=1.** Nothing about a 30-turn or 6-turn session is measured |
| `lopsidedness_floor: 0.34`, `gap_weight: 3`, `hook_weight: 2`, `contradiction weight` | what the scanner ranks worth asking about | `rubric.md` | no run varies them; `invariants` prints the decomposition, nothing compares it | **unmeasured.** These numbers have never been tested against alternatives, only against the world the fixture happens to contain |

## Corrections this table forced

- **"Single-turn runs hold the cap."** Wrong as a corpus claim: 20% over, n=30. The earlier statement came
  from four samples in one batch and was repeated in a commit message before this measurement existed.
- **"Beats sit at the limit."** Wrong: 18 of 19 multi-run records contain a beat over budget, some by
  60%+. `beat_budget` is the most breaching number in the skill and the least examined.
- **"0 breaches" in single-turn cells.** An artefact of the instrument: `invariants` only emits the
  beat/option flags on its multi-turn path. Absence of the token is absence of measurement.
- `canon_loss` shows 0 of 19 multi runs *by the invariant's reading*; canon incidents are graded by
  `canoncheck` at run time, and the one real deletion in the corpus was caught by the count witness. See
  `CANON-20261015.md` for the case where the text witness reported a deletion that never happened.

## What would change if the numbers moved

Raising `words_per_turn` launders drift into a quota (see `G2-20261015.md`): the 41% over-cap in long
sessions is not the cap being too small, it is the length comparison failing to hold as turns accumulate.
The one tunable with strong evidence that its level is wrong is `beat_budget`. The one with evidence that
it is unenforced in practice is `reads_per_turn`, whose median is 0.
