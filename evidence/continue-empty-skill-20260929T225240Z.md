# continue-empty (skill) 20260929T225240Z
cwd: /tmp/tmp.vveye5vzyq
## prompt
I have a vague idea for a novel about a bridge toll. Help me build the world around it.
## transcript


**Write back.** Nothing to write back yet — so the scaffold instead: `world/encyclopedia/` now holds four files, every canon line `proposed:`, all of it veto-able.

**Reflect.** A toll is two banks agreeing to be poor together, which means `toll-keeper-person` inherits an office and `the-toll-custom` already owes someone an explanation.

**Digest.** *The Bridge Toll* · `world/` · 4 entities, 14 threads, session 1 · all 18 pillars empty, 9 of them touched only by guesses.

**Target.** `the-toll-custom` — three lines about when it is charged, none about what is surrendered at the bar.

**Question.** When a crossing is paid for, what leaves the payer's hands?

- steady — coin, counted in a unit no mint recognises
- sharp — nothing; the debt is entered, and the ledger does the collecting
- strange — one word, spoken to the water, which the bridge keeps

**Stop.** `provoked: consequence`
## files after run
./world/encyclopedia/the-span-place.md
./world/encyclopedia/the-toll-custom.md
./world/encyclopedia/toll-keeper-person.md
./world/encyclopedia/toll-ledger-artifact.md
./world/index.md
./world/log.md
./world/threads.md
## world/ contents
--- ./world/encyclopedia/the-span-place.md
---
kind: place
pillars: [geography-routes, ecology-resources]
status: proposed
added: 2026-09-29
revised: 2026-09-29
---
# The Bridge at the Narrow

## Canon
- proposed: one bridge crosses here, at the only narrowing for a day's walk in either direction.
- proposed: the piers are replacements; the river took the original ones and no one wrote down which year.

## Open questions
- T-002 what is wearing out under the span that nobody can replace
- T-003 what crossing exists beside the bridge that no ledger counts
- T-013 who lives on the far bank, and what the toll did to them
- T-014 what the bridge is called, and by whom

## Links
- [[the-toll-custom]] [[toll-ledger-artifact]]

--- ./world/encyclopedia/the-toll-custom.md
---
kind: custom
pillars: [economy-trade, governance-law, language-names]
status: proposed
added: 2026-09-29
revised: 2026-09-29
---
# The Toll

## Canon
- proposed: the toll is charged per crossing, at a rate older than the law that now enforces it.
- proposed: nothing is charged on the return; the debt is only ever for coming.
- proposed: in polite speech the toll is "the custom"; the rude word for it is the bridge's own name.

## Open questions
- T-001 what leaves the payer's hands when a crossing is paid for
- T-004 what happened the one day the toll was not collected
- T-005 what the toll is called when the payer may not say "toll"
- T-006 what children believe the bridge takes from someone too poor to pay

## Links
- [[the-span-place]] [[toll-keeper-person]] [[toll-ledger-artifact]]

--- ./world/encyclopedia/toll-keeper-person.md
---
kind: person
pillars: [want-vs-need, secrets, voice-attention]
status: proposed
added: 2026-09-29
revised: 2026-09-29
---
# The Toll-Keeper (name pending)

## Canon
- proposed: the office is inherited, and its holder has never once crossed the bridge.
- proposed: the keeper weighs a cart before he looks at whoever rides it.

## Open questions
- T-007 what the keeper says he wants, and what would actually end it
- T-008 which scene about the bridge the keeper tells in the third person
- T-009 which rule of the toll the keeper breaks weekly without noticing
- T-010 which crossing the keeper has entered but never collected

## Links
- [[the-toll-custom]] [[toll-ledger-artifact]]

--- ./world/encyclopedia/toll-ledger-artifact.md
---
kind: artifact
pillars: [history-periodisation, contradictions]
status: proposed
added: 2026-09-29
revised: 2026-09-29
---
# The Toll Ledger

## Canon
- proposed: the ledger lists crossings, not payers, and the two totals have not matched in living memory.
- proposed: it is copied forward by hand each generation, and every copy loses a page.

## Open questions
- T-011 who may read the ledger aloud, and to whom
- T-012 whose numbering the ledger still uses, now those people are gone

## Links
- [[the-toll-custom]] [[toll-keeper-person]]

--- ./world/index.md
---
world: the-bridge-toll
skill_version: 0.1.0
sessions: 1
last_date: 2026-09-29
tunables:
  words_per_turn: 120
  texture_cadence: 4
  sarcasm: on
  weight_gap: 1.0
  weight_hook: 1.0
  weight_contradiction: 1.5
  lopsidedness_floor: 0.6
---
# The Bridge Toll — encyclopedia index

Derived from `encyclopedia/*.md`. If counts disagree with the entity files, rebuild from them.
Every line below is `proposed:` until the writer confirms or vetoes it. Working title only; the
bridge's real name is T-014.

## Pillar coverage
| pillar | entries | established | proposed | status |
|---|---|---|---|---|
| geography-routes | 1 | 0 | 2 | empty |
| ecology-resources | 1 | 0 | 2 | empty |
| history-periodisation | 1 | 0 | 2 | empty |
| social-structure | 0 | 0 | 0 | empty |
| power-systems | 0 | 0 | 0 | empty |
| governance-law | 1 | 0 | 3 | empty |
| economy-trade | 1 | 0 | 3 | empty |
| faith-myth | 0 | 0 | 0 | empty |
| language-names | 1 | 0 | 3 | empty |
| daily-life | 0 | 0 | 0 | empty |
| conflicts-tensions | 0 | 0 | 0 | empty |
| want-vs-need | 1 | 0 | 2 | empty |
| formative-past | 0 | 0 | 0 | empty |
| relationships | 0 | 0 | 0 | empty |
| contradictions | 1 | 0 | 2 | empty |
| secrets | 1 | 0 | 2 | empty |
| competence-failure | 0 | 0 | 0 | empty |
| voice-attention | 1 | 0 | 2 | empty |

## Entities
| slug | kind | pillars | status | hooks |
|---|---|---|---|---|
| the-span-place | place | geography-routes, ecology-resources | proposed | 0 |
| the-toll-custom | custom | economy-trade, governance-law, language-names | proposed | 0 |
| toll-keeper-person | person | want-vs-need, secrets, voice-attention | proposed | 0 |
| toll-ledger-artifact | artifact | history-periodisation, contradictions | proposed | 0 |

## Texture digest
- (banal details, newest first: food, mending, swearing, queueing, what stinks) — nothing yet.

## Hottest threads
- T-001 what leaves the payer's hands when a crossing is paid for
- T-004 what happened the one day the toll was not collected
- T-010 which crossing the keeper has entered in the ledger but never collected

--- ./world/log.md
# The Bridge Toll — session log

## 2026-09-29 (session 1)
- decided: nothing yet — 4 entities scaffolded from "a novel about a bridge toll"; every canon line is `proposed:`
- provoked: consequence

--- ./world/threads.md
# The Bridge Toll — open threads

One line per thread. `status: open` feeds the scoreboard; `parked` stays visible; `resolved`
points at the entity that absorbed it.

- T-001 | what leaves the payer's hands when a crossing is paid for | asked-by: skill | pillars: economy-trade, governance-law | hook: the toll charges per crossing and collects nothing yet | status: open | spawned: [[the-toll-custom]]
- T-002 | what is wearing out under the span that nobody can replace | asked-by: skill | pillars: ecology-resources, geography-routes | hook: the piers are already replacements | status: open | spawned: [[the-span-place]]
- T-003 | what crossing exists beside the bridge that no ledger counts | asked-by: skill | pillars: geography-routes, conflicts-tensions | hook: a toll makes an untolled crossing valuable | status: open | spawned: [[the-span-place]]
- T-013 | who lives on the far bank, and what the toll did to them | asked-by: skill | pillars: social-structure, daily-life | hook: nothing is charged on the return | status: open | spawned: [[the-span-place]]
- T-014 | what the bridge is called, and by whom it is called that | asked-by: skill | pillars: language-names, geography-routes | hook: two banks, one span, two names | status: open | spawned: [[the-span-place]]
- T-004 | what happened the one day the toll was not collected | asked-by: skill | pillars: conflicts-tensions, governance-law | hook: the rate is older than the law enforcing it | status: open | spawned: [[the-toll-custom]]
- T-005 | what the toll is called when the payer may not say "toll" | asked-by: skill | pillars: language-names | hook: polite "the custom", rude something else | status: open | spawned: [[the-toll-custom]]
- T-006 | what children believe the bridge takes from someone too poor to pay | asked-by: skill | pillars: faith-myth, language-names | hook: a crossing refused is a story made | status: open | spawned: [[the-toll-custom]]
- T-007 | what the keeper says he wants, and what would actually end it | asked-by: skill | pillars: want-vs-need | hook: he holds an inherited office he never chose | status: open | spawned: [[toll-keeper-person]]
- T-008 | which scene about the bridge the keeper tells in the third person | asked-by: skill | pillars: formative-past | hook: he has never crossed it | status: open | spawned: [[toll-keeper-person]]
- T-009 | which rule of the toll the keeper breaks weekly without noticing | asked-by: skill | pillars: contradictions | hook: he weighs carts be
