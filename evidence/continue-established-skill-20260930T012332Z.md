# continue-established (skill) 20260930T012332Z
cwd: /tmp/tmp.9eYI7qCDtD
## prompt
I want to keep building out the world for my novel. Let's continue where we left off.
## transcript


**Digest.** Nine Bridges · `world/` · 6 entities, session 5. Nothing new since 2026-09-12, and the index was lying: rebuilt from the files. Five pillars are actually empty — faith-myth, daily-life, relationships, competence-failure, voice-attention. `severins-child-place` and `war-of-nine-ledgers-era` were sitting on too few threads; T-013–T-017 opened.

**Target.** T-011. `tide-lock-artifact` says the lock keeps no record and there is nothing to audit; `bridge-tolls-custom` says every crossing is entered the same day, and an unlogged crossing is unlawful. Two established lines, one bridge, and the gap is where your novel happens.

**Question.** What does the tollhouse do with a crossing the lock admits and the ledger denies?

- steady — nothing; the ledger only ever recorded lawful crossings anyway
- sharp — it enters the lock's name, not the traveller's, and audits the stone
- strange — it tears out the page; nine blanks in nine books are the real register

`provoked: consequence` — next owed: a `daily-life` texture question.
## pi exit status: 0
## files after run
./world/encyclopedia/bridge-tolls-custom.md
./world/encyclopedia/lady-severin-person.md
./world/encyclopedia/nine-bridges-place.md
./world/encyclopedia/severins-child-place.md
./world/encyclopedia/tide-lock-artifact.md
./world/encyclopedia/war-of-nine-ledgers-era.md
./world/index.md
./world/log.md
./world/threads.md
## world/ contents
--- ./world/encyclopedia/bridge-tolls-custom.md
---
kind: custom
pillars: [economy-trade, governance-law, language-names]
status: established
added: 2026-08-30
revised: 2026-09-02
---
# The Toll of Names
## Canon
- established: every crossing is entered in the tollhouse ledger the same day; an unlogged crossing is unlawful.
- established: the toll is a name, spoken and given, not coin.
- established: giving your name costs you the right to use it on the other side.
## Open questions
- what do people call a false name (T-012)
- who benefits from the toll (T-005)
## Links
- [[tide-lock-artifact]] [[nine-bridges-place]]

--- ./world/encyclopedia/lady-severin-person.md
---
kind: person
pillars: [want-vs-need, secrets, contradictions, formative-past]
status: established
added: 2026-09-02
revised: 2026-09-06
---
# Lady Severin
## Canon
- established: exiled from the Commonwealth for disagreeing with someone.
- established: wants the toll ledger, the original one, with the first nine names.
- established: crossed at a false name twice, and the lock opened both times.
## Open questions
- whom she disagreed with, and what the argument was (T-010)
## Links
- [[bridge-tolls-custom]] [[tide-lock-artifact]] [[nine-bridges-place]]

--- ./world/encyclopedia/nine-bridges-place.md
---
kind: place
pillars: [geography-routes, conflicts-tensions, social-structure]
status: established
added: 2026-08-30
revised: 2026-09-12
---
# Nine Bridges (the Commonwealth)
## Canon
- established: nine bridges, six of which appear on any map.
- established: the Commonwealth is a toll authority, not a kingdom; it has never elected anything.
- established: the nine spans are the only lawful crossings for four hundred miles.
- established: the tenth crossing is a person, not a bridge.
## Open questions
- which three spans are unexplained (T-001, T-002)
## Links
- [[tide-lock-artifact]] [[bridge-tolls-custom]] [[severins-child-place]] [[lady-severin-person]]

--- ./world/encyclopedia/severins-child-place.md
---
kind: place
pillars: [geography-routes, ecology-resources]
status: established
added: 2026-09-12
revised: 2026-09-12
---
# Severin's Child
## Canon
- established: the wrecked seventh span, half in the water, called a name it never earned.
- established: smugglers use it; the lock cannot see it.
## Open questions
- what is it waiting to be (T-007)
## Links
- [[tide-lock-artifact]] [[nine-bridges-place]]

--- ./world/encyclopedia/tide-lock-artifact.md
---
kind: artifact
pillars: [power-systems, governance-law, geography-routes]
status: established
added: 2026-08-30
revised: 2026-09-12
---
# The Tide-Lock
## Canon
- established: the lock opens only for a name read aloud from the tollhouse manifest.
- established: the lock keeps no record of anything; there is nothing to audit.
- established: a name must belong to a living person for the lock to answer.
- established: it has opened twice for Lady Severin, who was not on any manifest.
## Open questions
- can a name be forged, and what happens to the forger (T-009)
- who reads, and who taught them (T-004)
## Links
- [[bridge-tolls-custom]] [[nine-bridges-place]] [[lady-severin-person]]

--- ./world/encyclopedia/war-of-nine-ledgers-era.md
---
kind: era
pillars: [history-periodisation, conflicts-tensions]
status: mixed
added: 2026-09-06
revised: 2026-09-06
---
# The War of Nine Ledgers
## Canon
- established: fought for eleven years over record-keeping, not territory.
- established: each bridge kept its own ledger and each insisted the others were copies.
- proposed: it ended when one accountant resigned, and nobody noticed for a season.
## Open questions
- which ledger won
## Links
- [[bridge-tolls-custom]] [[nine-bridges-place]]

--- ./world/index.md
---
world: nine bridges
sessions: 5
last_date: 2026-09-30
tunables:
  words_per_turn: 120
  texture_cadence: 4
  sarcasm: on
  weight_gap: 1.0
  weight_hook: 1.0
  weight_contradiction: 1.5
  lopsidedness_floor: 0.6
---
# Nine Bridges — encyclopedia index

Derived from `encyclopedia/*.md`. Rebuilt 2026-09-30: the previous rows credited 17 pillars with
lines the entity files do not contain. 6 entities, 18 `established:` lines, 1 `proposed:`.

## Pillar coverage
| pillar | entries | established | proposed | status |
|---|---|---|---|---|
| geography-routes | 3 | 10 | 0 | substantial |
| ecology-resources | 1 | 2 | 0 | thin |
| history-periodisation | 1 | 2 | 1 | thin |
| social-structure | 1 | 4 | 0 | thin |
| power-systems | 1 | 4 | 0 | thin |
| governance-law | 2 | 7 | 0 | substantial |
| economy-trade | 1 | 3 | 0 | thin |
| faith-myth | 0 | 0 | 0 | empty |
| language-names | 1 | 3 | 0 | thin |
| daily-life | 0 | 0 | 0 | empty |
| conflicts-tensions | 2 | 6 | 1 | substantial |
| want-vs-need | 1 | 3 | 0 | thin |
| formative-past | 1 | 3 | 0 | thin |
| relationships | 0 | 0 | 0 | empty |
| contradictions | 1 | 3 | 0 | thin |
| secrets | 1 | 3 | 0 | thin |
| competence-failure | 0 | 0 | 0 | empty |
| voice-attention | 0 | 0 | 0 | empty |

## Entities
| slug | kind | pillars | status | hooks |
|---|---|---|---|---|
| nine-bridges-place | place | geography-routes, conflicts-tensions, social-structure | established | 4 |
| lady-severin-person | person | want-vs-need, secrets, contradictions, formative-past | established | 3 |
| tide-lock-artifact | artifact | power-systems, governance-law, geography-routes | established | 3 |
| bridge-tolls-custom | custom | economy-trade, governance-law, language-names | established | 2 |
| war-of-nine-ledgers-era | era | history-periodisation, conflicts-tensions | mixed | 2 |
| severins-child-place | place | geography-routes, ecology-resources | established | 2 |

## Texture digest
- (nothing yet: no entry answers what anyone eats, carries, swears by, or mends)

## Hottest threads
- T-011 tide-lock vs bridge-tolls: two established lines, one must move (contradiction, 5.5)
- T-004 who reads the names aloud, and who taught them
- T-009 the forgery that the lock cannot see
- T-002 which of the nine bridges is the lie
- T-007 what Severin's Child is waiting to be

--- ./world/log.md
# Nine Bridges — session log

## 2026-08-30 (session 1)
- decided: nine bridges, six on any map; toll paid in a name, not coin; the tide-lock opens for spoken names
- provoked: consequence, connection
## 2026-09-02 (session 2)
- decided: Lady Severin exiled for disagreeing with someone; the lock is read by a keeper
- provoked: consequence, cost
## 2026-09-06 (session 3)
- decided: the War of Nine Ledgers was fought over record-keeping; proposed: it ended by an accountant's resignation
- provoked: contradiction, discovery
## 2026-09-12 (session 4)
- decided: the lock-keeper's daughter is the only living register; Severin's Child is a wrecked seventh span
- provoked: connection, consequence
## 2026-09-30 (session 5)
- decided: nothing yet; index.md rebuilt from the entity files (18 established, 1 proposed, 5 empty pillars), T-013–T-017 opened for severins-child-place and war-of-nine-ledgers-era
- provoked: consequence

--- ./world/threads.md
# Nine Bridges — open threads

- T-001 | what are the nine bridges, if only six are on the map | asked-by: skill | pillars: geography-routes | hook: three crossings are unexplained | status: open
- T-002 | which bridge is a lie | asked-by: skill | pillars: geography-routes, conflicts-tensions | hook: someone profits from the count | status: open
- T-003 | what did the war start over | asked-by: writer | pillars: history-periodisation | hook: ledgers, not land | status: resolved -> war-of-nine-ledgers-era
- T-004 | who reads names into the lock | asked-by: skill | pillars: power-systems, governance-law | hook: the job is hereditary and unloved | status: open
- T-005 | who benefits from the toll | asked-by: skill | pillars: economy-trade | hook: nobody named | status: open
- T-006 | who pays, and in what | asked-by: skill | pillars: economy-trade | hook: the answer is not money | status: open
- T-007 | what is Severin's Child waiting to be | asked-by: skill | pillars: geography-routes | hook: a wreck that is called a name | status: open
- T-008 | what does Severin want vs need | asked-by: skill | pillars: want-vs-need | hook: she wants the ledger, needs the daughter | status: open
- T-009 | can a name be forged | asked-by: writer | pillars: power-systems, language-names | hook: it has happened | status: open
- T-010 | what did she disagree with | asked-by: skill | pillars: formative-past, contradictions | hook: "she disagreed with someone" is doing all the work | status: open
- T-011 | the lock keeps no record but every crossing is logged | asked-by: skill | pillars: governance-law, power-systems, economy-trade | hook: two established lines cannot both be true | status: open
- T-012 | what do people call a false name | asked-by: skill | pillars: language-names | hook: there must be a word | status: parked
- T-013 | what does the wreck run out of that a bridge should have | asked-by: skill | pillars: geography-routes, ecology-resources | hook: added 2026-09-12 with one thread on it | status: open
- T-014 | who keeps Severin's Child from falling the rest of the way, and how badly | asked-by: skill | pillars: geography-routes, social-structure | hook: maintenance nobody is paid for | status: open
- T-015 | what lies under the north approach that the lock never logged | asked-by: skill | pillars: geography-routes, secrets | hook: unmapped adjacent thing | status: open
- T-016 | who got richer over eleven years of ledgers | asked-by: skill | pillars: economy-tr
