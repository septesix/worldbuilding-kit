# Rubric — what to ask about, and what to ask

Two tiers: a **floor** of 18 pillars that must be counted, and a **ceiling** of child generators
that turn any single entity into questions. This file supplies the vocabulary and the question
stock. `../SKILL.md` decides which question a turn actually asks.

## Tier 1 · the floor — 18 pillars

The keys are the `## Pillar coverage` rows of `../assets/index-template.md`. That file is the
single source of truth: copy the key, never a prose variant of it. "Faith & myth" is a different
string, does not match a row, and does not count.

Every pillar carries the same two probes, which always work, plus its own pair:

- **define by contrast** — what makes this unlike its neighbour's version of the same thing?
- **the failure case** — describe it on the day it goes wrong.

| Pillar | its own probes |
|:--|:--|
| geography-routes | what does the map leave out, and who gains from the blank? · which two places are joined only by a route nobody maintains? |
| ecology-resources | what runs out first here, and what do people use once it has? · what lived here that no longer does, and what filled its place? |
| history-periodisation | who decided where this period starts, and what did they want dated? · what do people date a house by that no record mentions? |
| social-structure | whose word settles a dispute, and what is it worth when they are absent? · what does an outsider have to be, to be believed here? |
| power-systems | what does using it cost the user, in a unit somebody keeps? · who is barred from it, and what do they do instead? |
| governance-law | what can the law not do at any price? · who enforces it on the day the enforcer is paid to be elsewhere? |
| economy-trade | what is bought with something that is not money, and by whom? · what leaves this place that was never meant to? |
| faith-myth | what do people swear by when the proper name of the god would not help? · which festival is really about something else? |
| language-names | what do locals call the thing before they learn the proper name? · which name is never said aloud, and what is said instead? |
| daily-life | what did someone eat today, and where did it come from? · what needs mending right now, and who is avoiding it? |
| conflicts-tensions | what is failing this month that was fine last month? · who would be surprised if nothing changed? |
| want-vs-need | what do they say they want, and what would actually end it? · what have they already traded away for the wrong one? |
| formative-past | which scene do they tell in the third person? · what did they believe at fifteen that still runs the adult? |
| relationships | who is the one person they cannot lie to, and what do they lie about to them? · whose opinion settles it, and were they there? |
| contradictions | what do they demand of others and excuse in themselves this week? · which two of their stated principles cannot both hold in one room? |
| secrets | what would they never say in this life, and who already suspects? · what is the secret protecting someone *from*? |
| competence-failure | what are they unreasonably good at, and how does that fail them here? · who is better at it, and what do they do about that? |
| voice-attention | what do they notice first in any room, and what do they always miss? · what phrase do they reach for when they are afraid? |

### Counting a pillar

Bookkeeping only; the score that uses these counts lives in `../SKILL.md`.

- **Read the numbers from `world/index.md`'s two tables, not from the entity bodies.** The tables are
  this arithmetic in standing form, rewritten by bookkeeping every turn. Opening bodies to count lines
  is how a turn ends up reading six files to decide what to ask, which `../SKILL.md` forbids at three.
  Read **one** body: the entity you are about to target, to quote it. Count from the tables; look in a
  body only to have something true to say about it.
- Rebuild the tables from the bodies only when `index.md` is missing or stale, announce the rebuild,
  and count from the result. Lines marked `superseded-by:` are history and count for nothing.
- A pillar with no lines at all, or only `proposed:` lines, is **empty**.
- 1–2 established lines: **thin**. 3 or more across 2 or more entities: **substantial**.
- `daily-life` is the texture pillar; `voice-attention` is its character-side feed.

## Tier 2 · the ceiling — 9 child generators

Ask each of any entity, about *that* entity. Pick the ones it can answer.

- who benefits, and who pays?
- what does it run out of?
- who maintains it, and how badly?
- what do people say about it when it breaks?
- what is the polite version, and the rude version?
- what happened the one time it failed?
- what does a child believe about it?
- what adjacent thing has nobody mapped?
- what did it borrow from a culture that is gone?

Every new entity must spawn ≥3 threads in `threads.md`, in the turn it is created; an entity with
no thread on it is an entity nobody will ever be asked about again.

Worked example — `severins-child-place`, named by the writer mid-turn:

- from *what does it run out of* → T-013 | what does Severin's Child keep that it cannot get again
- from *what adjacent thing has nobody mapped* → T-014 | who else is buried under the approach
- from *what do people say about it when it breaks* → T-015 | what is said about it on the far bank

## Hard rules (3)

1. A question must be answerable in one sentence. If the answer needs a paragraph, that was two
   questions.
2. A question must never imply homework — nothing that asks the writer to go read up, sketch, or
   decide later.
3. Anti-glass test: if the answer could be pasted into any published fantasy novel it is **not**
   established — ask once more for the detail that makes it un-pasteable.
