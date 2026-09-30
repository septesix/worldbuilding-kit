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
  body only to have something true to say about it. If you find yourself opening more than
  `reads_per_turn` bodies, that is not a ration you exceeded - it is evidence you are scoring from
  files. Stop, rebuild `index.md` from the bodies, announce it, and score from the result.
- Rebuild the tables from the bodies only when `index.md` is missing or stale, announce the rebuild,
  and count from the result. Lines marked `superseded-by:` are history and count for nothing.
- A pillar with no lines at all, or only `proposed:` lines, is **empty**.
- 1–2 established lines: **thin**. 3 or more across 2 or more entities: **substantial**.
- `daily-life` is the texture pillar; `voice-attention` is its character-side feed.
- **Cadence is arithmetic on `log.md`, not a feeling.** Take `targeted:` from the last
  `texture_cadence` machine lines. If none is `daily-life` or `voice-attention`, the next turn belongs
  to texture and outranks any gap or hook score. If the file is shorter than the window, count from the
  first line. Rotation alone does not satisfy this: twelve turns that each pick a different institution
  is exactly how a world ends up with nine bridges and nothing to eat.
- **A hole in the log is not a clean bill of health.** If there are fewer machine lines than turns, the
  window cannot be computed. Do not conclude texture is satisfied: ask the texture question this turn
  and say, in one clause, that the ledger lost track.

## Closing the session

Close at `turns_per_session` turns (default 12), or earlier on the writer's cue to wrap up. The count
comes from the machine lines in `log.md`, so a session that stopped writing them cannot know it has
reached the limit. Then: 3-6 recap bullets of what was decided, the next thread named with the reason
to pull it, `status: active` in `world/index.md`, and the last turn's `stop` beat unanswered.

## Word budget: why the beats, not the turn

`words_per_turn` alone produced turns of 171-211 words that every measurement called compliant-ish,
because the total is easy to satisfy by shrinking one beat and inflating another. The per-beat cap is
the one that changes behaviour: a 45-word `reflect` is a lecture no matter how short the `digest` was.
The beat whose words you may spend freely is the **question** - it is the only part the writer answers.

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

- **Never dump tables into chat.** The index holds the counts; a turn that pastes a pillar table is
  a report, not an interview.
- **Candidates** are existing entities and the nine child generators below - not new inventions on the
  spot, which is how a world acquires a fourteenth bridge.

## Review mode (I5)

**When.** Count the `## <date> (session N)` headers in `log.md` after the last line carrying
`provoked: review`. If that count is >= 3, a review is owed and you offer it at the end of the turn -
after the question, never instead of it. `provoked: review` is already one of the eight types, so the
trigger needs no new state: a session that never writes the machine line will never be asked to review,
which is R-9's argument repeated.

**The memo** is five items, each a computation over `world/`, printed as five short bullets, chat not
file. Anything the computation cannot answer is said as unknown, never omitted in silence:

1. **contradictions** - pairs of `established:` lines in different entities that cannot both be true.
   Cite `entity:line` for both sides, or report "none found, by these two checks".
2. **orphans** - entity files whose `[[links]]` are one-way, or whose `pillars:` list is empty.
3. **texture-less pillars** - a pillar with >=1 `established:` line whose entities never tag
   `daily-life` or `voice-attention`: the world's systems exist and nobody eats.
4. **unvetted `proposed:`** - `proposed:` lines whose entity still has 0 `established:`, i.e. canon the
   writer has been quoted at for sessions without confirming.
5. **treadmill** - over the last 8 machine lines, one provoke type at >= 5. That is the same failure
   the switch rule catches mid-session; here it is reported as history.

Then one line: what to do about it, as a thread reference, not a task list.

The memo totals ≤ `memo_words` (120) and never counts against `words_per_turn`: it is an appendix, and
an exempt artifact still needs a ceiling - the longest memo in the archive ran 180 words, which is a
page, not a glance. Five items, one line each, citations over prose.
**Log the review you gave.** The memo turn's machine line carries `provoked: review`. Without it the
count never resets and the next session reviews again - the trigger is arithmetic, so it obeys the
ledger and nothing else, least of all your memory of having just done this.

## Seeding a new world (I4)

`SKILL.md` gives the number; the shape is here. After the premise paragraph, before any second
question:

- **5-8 entity files**, each from `assets/entity-template.md` with `pillars:` filled in. Not a
  fork-list of options in chat: the writer is answering questions, not reading a menu.
- **Spread over at least 3 pillars, including one texture pillar** (`daily-life` or
  `voice-attention`). This is R-8's cadence rule applied at turn one: with no `targeted:` lines yet,
  the window is empty, so texture is owed immediately. A seed of nine bridges and no kitchens fails
  cadence on the first turn and then spends the session chasing it.
- **Every canon line `proposed:`** - a seeded world is a hypothesis, not canon. `established:` appears
  only when the writer confirms it.
- **At least 3 threads per seeded entity** (the standing rule), so 15-24 threads exist to rotate
  over. Under-provisioned threads are what make a session hammer one pillar for twelve turns.
- 6 is the target: 5-8 is the pass band, and the difference between 5 and 8 is which premise the
  writer emphasises, not how much you wanted to write.

## Scoring honesty (F5/I7)

- **`gap_weight` is a lookup, not an impression.** Read the pillar row in `world/index.md`'s coverage
  table - `entries` counts the entities touching the pillar, `established` counts canon facts:
  0 established (or all `proposed:`) -> **3** | 1-2 established -> **2** | >=3 established across >=2
  entities -> **1** | anything else -> **0**. A thin pillar is 2, never 3: 3 means *nothing is there*.
- **Show the three terms wherever you show a score**, labelling the first one, which is the one that
  gets improvised: `faith-myth scores 7.5 (gap 3 x 1.0 + hook 2 x 1.0 + contradiction 1 x 1.5)`, not
  `faith-myth scores highest`. A bare number cannot be checked by the writer or by the harness, and an
  unchecked number is how improvised scoring survived two revisions.

## Hard rules (3)

1. A question must be answerable in one sentence. If the answer needs a paragraph, that was two
   questions.
2. A question must never imply homework — nothing that asks the writer to go read up, sketch, or
   decide later.
3. Anti-glass test: if the answer could be pasted into any published fantasy novel it is **not**
   established — ask once more for the detail that makes it un-pasteable.
