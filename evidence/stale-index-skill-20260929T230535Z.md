# stale-index (skill) 20260929T230535Z
cwd: /tmp/tmp.4GcSQ7i3ds
## prompt
Continue building my world. (no index file, the encyclopedia files are still there)
## transcript


Rebuilding the index before anything else — `world/index.md` was gone.

**Write back.** `index.md` rebuilt from the entity files (7 now, `sessions: 5`). Session 4's line *"the lock-keeper's daughter is the only living register"* had no file anywhere, so `lockkeepers-daughter-person` now carries it, back-linked from `tide-lock-artifact`, `lady-severin-person` and `nine-bridges-place`, with T-013–T-016 opened on it.

**Reflect.** A register that is one breathing girl makes all nine bridge-ledgers copies of her, and makes a four-hundred-mile monopoly contingent on her pulse.

**Digest.** Nine Bridges · `world/` · nothing new since 2026-09-12. Empty: faith-myth, daily-life, voice-attention, competence-failure; six pillars hang on a single entity. 15 open threads, T-012 parked.

**Target.** T-016 — the lock answers only for a living name off the manifest, and it opened twice for Severin, who was on no manifest.

**Question.** Whose living name did Severin spend on the second crossing?

- steady — the lock-keeper's own; she took it from the man she disagreed with, and he never noticed
- sharp — her daughter's, given at nine and never returned, which is the whole reason for the exile
- strange — a drown victim's, which is why the lock hesitates now

**Stop.** `provoked: discovery`
## files after run
./world/encyclopedia/bridge-tolls-custom.md
./world/encyclopedia/lady-severin-person.md
./world/encyclopedia/lockkeepers-daughter-person.md
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
- [[bridge-tolls-custom]] [[tide-lock-artifact]] [[nine-bridges-place]] [[lockkeepers-daughter-person]]

--- ./world/encyclopedia/lockkeepers-daughter-person.md
---
kind: person
pillars: [relationships, power-systems, language-names]
status: established
added: 2026-09-29
revised: 2026-09-29
---
# The Lock-Keeper's Daughter

## Canon
- established: the lock-keeper's daughter is the only living register.

## Open questions
- is she the tenth crossing that nine-bridges-place says is a person (T-013)
- where a spent name goes once she has carried it (T-014)
- who inherits the register if she refuses (T-015)

## Links
- [[tide-lock-artifact]] [[lady-severin-person]] [[nine-bridges-place]]

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
- [[tide-lock-artifact]] [[bridge-tolls-custom]] [[severins-child-place]] [[lady-severin-person]] [[lockkeepers-daughter-person]]

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
- [[bridge-tolls-custom]] [[nine-bridges-place]] [[lady-severin-person]] [[lockkeepers-daughter-person]]

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
world: nine-bridges
skill_version: 0.1.0
sessions: 5
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
# Nine Bridges — encyclopedia index

Derived from `encyclopedia/*.md`. If counts disagree with the entity files, rebuild from them.
Rebuilt 2026-09-29: `index.md` was missing; counts below come from the entity files, not memory.

## Pillar coverage
| pillar | entries | established | proposed | status |
|---|---|---|---|---|
| geography-routes | 4 | 10 | 0 | substantial |
| ecology-resources | 2 | 2 | 0 | thin |
| history-periodisation | 1 | 2 | 1 | thin |
| social-structure | 1 | 4 | 0 | thin (one entity) |
| power-systems | 2 | 7 | 0 | thin (one entity) |
| governance-law | 3 | 7 | 0 | substantial |
| economy-trade | 1 | 3 | 0 | thin (one entity) |
| faith-myth | 1 | 0 | 0 | empty |
| language-names | 2 | 3 | 0 | thin |
| daily-life | 0 | 0 | 0 | empty |
| conflicts-tensions | 2 | 6 | 1 | substantial |
| want-vs-need | 1 | 3 | 0 | thin (one entity) |
| formative-past | 1 | 3 | 0 | thin (one entity) |
| relationships | 2 | 1 | 0 | empty (no pair named) |
| contradictions | 1 | 3 | 0 | thin (one entity) |
| secrets | 1 | 3 | 0 | thin (one entity) |
| competence-failure | 0 | 0 | 0 | empty |
| voice-attention | 0 | 0 | 0 | empty |

## Entities
| slug | kind | pillars | status | hooks |
|---|---|---|---|---|
| nine-bridges-place | place | geography-routes, conflicts-tensions, social-structure | established | 5 |
| tide-lock-artifact | artifact | power-systems, governance-law, geography-routes | established | 4 |
| bridge-tolls-custom | custom | economy-trade, governance-law, language-names | established | 2 |
| lady-severin-person | person | want-vs-need, secrets, contradictions, formative-past | established | 4 |
| severins-child-place | place | geography-routes, ecology-resources | established | 2 |
| war-of-nine-ledgers-era | era | history-periodisation, conflicts-tensions | mixed | 2 |
| lockkeepers-daughter-person | person | relationships, power-systems, language-names | established | 3 |

## Texture digest
- (nothing banal on record; `daily-life` and `voice-attention` have never been asked)

## Hottest threads
- T-011 the lock keeps no record, yet every crossing is logged — 1.0·3 + 1.0·3 + 1.5·1 = 6.0
- T-016 whose living name Severin spent — 1.0·3 + 1.0·4 + 1.5·1 = 8.5 (target, session 5)
- T-007 what Se
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
## 2026-09-29 (session 5)
- bookkeeping: `index.md` was missing; rebuilt from the 6 entity files. Session 4's register line had no file, so `lockkeepers-daughter-person` now exists with that one canon line; T-013–T-016 opened.
- provoked: discovery

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
- T-013 | is the lock-keeper's daughter the tenth crossing that is a person | asked-by: skill | pillars: relationships, geography-routes | hook: two established lines may describe one girl | status: open | spawned: [[lockkeepers-daughter-person]]
- T-014 | where does a spent name go after the register carries it | asked-by: skill | pillars: language-names, faith-myth | hook: names are given away and do not come back | status: open | spawned: [[lockkeepers-daughter-person]]
- T-015 | who inherits the register if the daughter refuses | asked-by: skill | pillars: relationships, governance-law | hook: hereditary, unloved, and one person deep | status: open | 
