# RED baselines — worldbuilding skill (no skill installed) — v2, re-captured

**v2 supersedes the original: 4 of its 5 committed transcripts carried `INFRA-FAIL` (file-side capture never ran, gate finding I11) and one F5 quote came from a contaminated run that had been deleted (I10). Everything below is measured from re-captured runs at 2026-09-30T00:08–00:22Z, all `rc=0`, with file listings and per-file diffs verified.**

Runs: `bash tests/run.sh <scenario> control`, sandboxed `HOME`, `--no-extensions --no-skills --no-session`,
sequential (concurrent runs return empty transcripts on this box). Model: `spark-vllm/qwen3.8-flash-next`,
thinking high. Evidence files: `evidence/*-control-*.md`.

**Headline: the baseline is already competent.** With a well-shaped `world/` on disk, an agent with no
skill performs roughly 85% of the designed loop. Per writing-skills ("if the control doesn't exhibit
the failure, there is nothing to fix"), guidance is authored below only for the failures that were
actually observed. Everything else is cut.

---

## Verdicts, re-measured against valid transcripts

| Finding | Status after re-capture | Valid evidence |
|---|---|---|
| **F1** no structure from empty | **HOLDS, worse** | `continue-empty` created **one file, `bridge-toll-world.md`, and no `world/` directory at all** — 179 words, 0 questions asked, four candidate worlds in prose |
| **F2** multiple questions per turn | **HOLDS** | `continue-established` asked **3** questions in one turn ("Three questions, in priority order"); the other three runs asked 1, 0, 0 |
| **F3** verbosity | **HOLDS, worse** | 500 / 256 / 179 / 178 words against a 120 budget. The worst is **4.2×**, not the "180–350" I originally reported |
| **F4** no bookkeeping | **NARROWED to "inconsistent"** | `continue-established` appended canon to entity files and touched **index.md +0 −0, threads.md +0 −0, log.md +0 −0** — it wrote facts and updated no scoreboard. But `tone-sarcasm` and `pressure-wrapup` *did* maintain all three (index +28/−27 and +29/−29, threads +5/−2 and +7/−6, log +6 and +7). So the failure is nondeterminism, not absence |
| **F5** improvised scoring formula | **STRUCK — unsupported** (Ruling 17) | No valid control transcript contains any score arithmetic. Both quoted formulas came from the contaminated run that was deleted. The behavior may still be real, but it is not evidenced, so no guidance is authored for it |
| baseline logs `provoked:` | **was wrongly listed as a failure** | `tone-sarcasm` control wrote "`provoked: contradiction`; a `daily-life` texture question owed by turn 4" unprompted |

## Newly observed in the valid evidence (not in the original BASELINE)

- **The fixture's own index is wrong, and the control caught it.** `tone-sarcasm` logged: *"index.md was stale — 38 established lines claimed against 19 in the files."* Independent confirmation of gate finding **I12**: my fixture drifted from its entity files, which silently turns `continue-established` into a stale-index test.
- **Control runs overwrite `skill_version`** — `tone-sarcasm` set `skill_version: 0.1.0` in a `world/` file. Version metadata that the kit compares against is writer-editable data the model will happily rewrite. Needs a home the model does not touch.
- **Thread lines are edited in place in `threads.md`** (+5 −2 / +7 −6): same class as C3, one file over. Canon append-only is specified; threads are not.
- **Index churn is total, not incremental** (+28 −27, +29 −29 = whole-table rewrite). Harmless, but it makes "what changed in the scoreboard" unanswerable, which spec §7 promised.

## What this changes for the guidance

Task 6's SKILL.md keeps F1, F2, F3 as written. F4 becomes a determinism rule ("bookkeeping updates in the same turn as any canon write, always all three files") rather than an assertion that the model forgets. F5 loses its justification — if the scoring section survives, it survives as *legibility for the writer*, not as a fix for an observed failure, and it should be labeled that way.
