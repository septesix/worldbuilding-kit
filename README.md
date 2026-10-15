# worldbuilding-kit

A worldbuilding interview that builds an encyclopedia on disk, installed into a writing project on
demand so unrelated projects never load it.

- `kit/` — the global trigger (~130 words in the system prompt list). Finds the project, installs
  the bundle, hands off, never acts again.
- `bundle/worldbuilding/` — what lands in `<project>/.pi/skills/worldbuilding/`: the turn contract
  (`SKILL.md`), the 18-pillar rubric and entity-child generators (`references/rubric.md`), the voice
  and engagement contract (`references/voice.md`), and `world/` scaffolding templates (`assets/`).

Your world's data is never in this repo. It lives at `<project_root>/world/`.

## Install

Either way, only the small installer trigger (`kit/`, ~130 words of description) loads into every
session. The real skill is copied into the project that asks for a world, and nowhere else.

**As a pi package:**

    pi install git:github.com/septesix/worldbuilding-kit

**From a clone:**

    git clone https://github.com/septesix/worldbuilding-kit
    ln -s ~/worldbuilding-kit/kit ~/.pi/agent/skills/worldbuilding-kit

Then start pi in a writing project and ask it to build a world. It installs the project copy itself.
`/reload` if pi was already running.

## Uninstall

    pi remove git:github.com/septesix/worldbuilding-kit   # if installed as a package
    rm ~/.pi/agent/skills/worldbuilding-kit        # if installed by symlink; both stop NEW installs
    rm -rf <project>/.pi/skills/worldbuilding      # per project; leaves <project>/world/ alone

## Development

    bash bundle/worldbuilding/tests/check.sh all        # 186 static assertions, incl. self-tests of the gates
    bash bundle/worldbuilding/tests/check.sh behavior   # grade recorded runs at THIS guidance hash only
    bash bundle/worldbuilding/tests/multi               # 12-turn runs against one persistent world

    bash bundle/worldbuilding/tests/run.sh <scenario> <control|skill>   # one headless run, ~3 min
    cat evidence/BASELINE.md                            # what the model does with no skill

Scenarios: `continue-established`, `continue-empty`, `stale-index`, `reaction-mode`, `tone-sarcasm`,
`pressure-wrapup`, `home-dir`, `new-world`, `review`, `review-owed`, and the multi-turn `retcon`,
`close`, `cadence` scripts. Runs are sequential by design — concurrent headless runs on this box return
empty transcripts.

Behavioural evidence is keyed to a hash of the guidance files, not the commit: `check.sh behavior`
reports how many transcripts still apply to the build being graded and refuses to count the rest as
passing. A green static suite therefore never implies "tested recently" — read both lines.

## The evidence corpus

`evidence/` is why "tested" means something here: 56 run dumps plus 10 raw session logs, each `.md`
recording the guidance key and commit it ran at. The raw logs are stored gzipped (2.9 MB of machine
transcripts, 0.7 MB on disk) and both readers accept either form, so compressing an artifact can never
make a detector blind by changing its name. History is untouched - the originals stay in their commits,
and the 23 evidence files that cite a commit SHA still resolve. `check.sh` grades the compressed
witness logs and fails if one goes missing, because a regression check that silently skips reports
success on nothing.

Read `check.sh behavior`'s first line before believing any green tick: it says how many of the 42
recorded skill-arm transcripts carry the guidance key being graded, and the rest are excluded rather
than counted. Two states are never merged into a pass: a run whose model never spoke (there was one in
the 2026-10-13 batch, turn 9 of a 12-turn `close`) is excluded as infrastructure, and a run that
breached is reported as a breach. As of that batch, 7 of 42 apply to the current key and 5 of those 7
carry a verdict - so the static suite is 186 green assertions about text, and behaviour is graded on a
handful of runs, which is the honest shape of this evidence and not a problem to be phrased away.

## Licence and ownership of your writing

MIT — see [LICENSE](LICENSE). Free to use, copy, modify, redistribute, commercially or not.

**Nothing you write with this is encumbered.** The licence covers the kit: the skill text, the
templates, the scripts. Your `world/` directory — entities, threads, the ledger, everything the
interview produces — is yours, in a project folder this repo never touches.

Two kinds of content in `evidence/` and `bundle/.../fixtures/` are worth naming, since publishing them
is a choice rather than an oversight: the fixture world (*nine bridges*) is fictional test material, and
the transcripts are real recorded runs of a language model building and repairing that world, kept
because a claim of "tested" is worth little without the artifacts behind it. Both are MIT-licensed like
everything else.

## Version

`v0.1.0` — every mode in the spec has a scenario that reaches it; the two that didn't (`new`, `review`)
were found by looking for the test rather than by looking for the behaviour.
