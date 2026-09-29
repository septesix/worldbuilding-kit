# worldbuilding-kit

A worldbuilding interview that builds an encyclopedia on disk, installed into a writing project on
demand so unrelated projects never load it.

- `kit/` — the global trigger (~130 words in the system prompt list). Finds the project, installs
  the bundle, hands off, never acts again.
- `bundle/worldbuilding/` — what lands in `<project>/.pi/skills/worldbuilding/`: the turn contract
  (`SKILL.md`), the 18-pillar rubric and entity-child generators (`references/rubric.md`), the voice
  and engagement contract (`references/voice.md`), and `world/` scaffolding templates (`assets/`).

Your world's data is never in this repo. It lives at `<project_root>/world/`.

## Install (once, per machine)

    ln -s ~/worldbuilding-kit/kit ~/.pi/agent/skills/worldbuilding-kit

Then start pi in a writing project and ask it to build a world. It installs the project copy itself.
`/reload` if pi was already running.

## Uninstall

    rm ~/.pi/agent/skills/worldbuilding-kit        # stop new installs
    rm -rf <project>/.pi/skills/worldbuilding      # per project; leaves <project>/world/ alone

## Development

    bash bundle/worldbuilding/tests/check.sh all        # static gates (self-tests the comparator)
    bash bundle/worldbuilding/tests/run.sh <scenario> <control|skill>   # one headless run, ~3 min
    cat evidence/BASELINE.md                            # what the model does with no skill

Scenarios: `continue-established`, `continue-empty`, `stale-index`, `reaction-mode`, `tone-sarcasm`,
`pressure-wrapup`, `home-dir`. Runs are sequential by design — concurrent headless runs on this box
return empty transcripts.
