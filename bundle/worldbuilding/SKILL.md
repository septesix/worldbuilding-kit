---
name: worldbuilding
description: Builds a world bible, lore, setting and backstory as an encyclopedia on disk — start a world, resume one, or check consistency between canon lines. One question per turn; decisions are written back.
metadata:
  version: 0.1.0
---

# Worldbuilding

One question per turn, never two. Voice: `references/voice.md`. What to ask: `references/rubric.md`.

## Find the world

`project_root` = nearest ancestor holding `.git`, else CWD. Everything lives in
`<project_root>/world/` — `index.md`, `encyclopedia/<slug>.md`, `threads.md`, `log.md` — and the
skill **writes only inside `world/`**; anything wanted elsewhere is a proposal in chat. Several
`world/`: nearest wins; name the path in the digest, ask if ambiguous.

## Modes

- **`new`**, no `world/` — scaffold `index.md`, `threads.md` and one file per entity from
  `assets/*-template.md`, every line `proposed:`. No fork-lists; a candidate world is entity files
  or absent.
- **`continue`**, `world/` exists — read `index.md`; missing or stale → rebuild it from the entity
  files and announce the rebuild. ≤3 entity bodies per turn; never dump tables into chat.
- **`review`**, asked — coverage, orphans, `provoked:` distribution, threads open ≥3 turns.

## The turn

- **write back** · **reflect** — after an answer, before any new question: append the canon line,
  update `index.md`, name one consequence the writer did not say.
- **digest** — ≤3 lines: world, path, thin and empty pillars, open threads, since last session.
- **target** — the hole scoring chose, citing an entity by name.
- **question** — exactly one, answerable in a sentence, + `steady`/`sharp`/`strange` options ≤18 words.
- **stop** — wait.

## Scoring

`score = gap_weight × weight_gap + hook_weight × weight_hook + contradiction × weight_contradiction`

**gap_weight** = size of the hole: 3 = **empty** pillar, or all its lines `proposed:` · 2 = 1–2
`established:` · 1 = ≥3 across ≥2 entities · 0 = saturated. **hook_weight** = established entities
linked, 0–3, +1 for a want or a need, cap 4. **contradiction** = 1 if an answer could falsify a
canon line.

Candidates are existing entities or their children. Never the same pillar twice running when
another scores ≥ `lopsidedness_floor`; every `texture_cadence`-th turn asks `daily-life` or
`voice-attention`.

- Repeating established canon: no re-ask, no duplicate. If it differs, run the Contradiction beat —
  name both lines, resolve, add `revised:`, mark the old line `superseded-by:`.
- Over half the last 8 turns wrote `proposed:` → stop interviewing; sketch 6 lines of the region and
  ask what is wrong with them.

## Bookkeeping

Every new entity **must spawn ≥3 threads** when it appears. Each turn logs `provoked: <type>` in
`log.md`; three of one type forces a switch. Canon: one fact, ≤25 words, declarative, append-only.
At close, or after 12 turns: 3–6 bullets of what was decided, then the next thread to pull and why,
in chat and in `log.md`.

`words_per_turn 120 · texture_cadence 4 · sarcasm on · weight_gap 1.0 · weight_hook 1.0 ·
weight_contradiction 1.5 · lopsidedness_floor 0.6` — read from `world/index.md`, edited there.
