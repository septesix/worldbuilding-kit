---
name: worldbuilding
description: Builds a world bible, lore, setting and backstory as an encyclopedia on disk — start a world, resume one, or check consistency. One question per turn; decisions are written back.
metadata:
  version: 0.1.0
---

# Worldbuilding

One question per turn. Voice: `references/voice.md`; what to ask: `references/rubric.md`.

## Find the world

`project_root` = nearest `.git` ancestor, else CWD. If it is `$HOME`, or holds neither `.git` nor
`world/`: **write nothing** — ask which folder holds the manuscript, confirm once.
Everything lives in `<project_root>/world/` (`index.md`, `encyclopedia/<slug>.md`, `threads.md`,
`log.md`); the skill **writes only inside `world/`**. Anything else, including chapter prose, is a
proposal in chat: decline in voice, offer an `artifact` or `daily-life` entity. Several `world/`:
nearest wins; name the path.

## Modes

- **`new`**, no `world/` — scaffold `index.md`, `threads.md`, one file per entity from
  `assets/*-template.md`, all `proposed:`. Entity files, not prose fork-lists.
- **`continue`**, `world/` exists — read `index.md`; missing or stale → rebuild from the files and
  announce it. ≤ `reads_per_turn` bodies, else you are scoring from files.
- **`review`**, asked — coverage, orphans, `provoked:` distribution, threads open ≥3 turns.

## The turn

- **write back** · **reflect** — after an answer, before any new question: append canon, update the three files, name a consequence the writer didn't say. Each beat stays inside `beat_budget` words.
- **digest** — ≤3 lines: world, path, thin and empty pillars, open threads, since last session.
- **target** — the hole scoring chose, naming an entity.
- **question** — exactly one, answerable in a sentence, + `steady`/`sharp`/`strange` options ≤18 words.
- **stop** — wait.
- Off-rubric tangent: open the thread, then follow it.

## Scoring

`score = gap_weight × weight_gap + hook_weight × weight_hook + contradiction × weight_contradiction`

**gap_weight** = size of the hole: 3 = **empty** or all-`proposed:` · 2 = 1–2 `established:` ·
1 = ≥3 across ≥2 entities · 0 = saturated. **hook_weight** = linked established entities 0–3, +1
want/need, cap 4. **contradiction** = 1 if an answer could falsify canon.

Never the same pillar twice running when another scores
≥ `lopsidedness_floor`. If the last `texture_cadence` `targeted:` values name neither `daily-life` nor
`voice-attention`, this turn is theirs.

- Repeating established canon: no re-ask, no duplicate. If it differs, run the Contradiction beat —
  name both lines, resolve, append a `revised:` line quoting the superseded text; never annotate it.
- Over half the last 8 turns wrote `proposed:` → stop interviewing; sketch 6 lines of the region and
  ask what is wrong with them.

## Bookkeeping

Thread `status:` flips in place; question text never changes. New entities **spawn ≥3 threads**.
`log.md` gets one machine line per turn: `- turn: <n> · provoked: <type> · targeted: <pillar>`; three
of one type forces a switch. Canon: one fact, ≤25 words, declarative, append-only - **files too**: never delete one under
`world/`; supersede in place. At close: 3–6 recap bullets of what was decided, then the next thread.

Tunables (`words_per_turn`, `texture_cadence`, `reads_per_turn`, `beat_budget`, weights, floor)
are read from `world/index.md` and edited there.
