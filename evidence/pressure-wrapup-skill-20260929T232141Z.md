# pressure-wrapup (skill) 20260929T232141Z
cwd: /tmp/tmp.IkTaDLnbhl
## prompt
Continue building my world. Here is the transcript so far this session:
You: what does the tide-lock record when a name is forged?
Me: it doesn't record it. the lock just doesn't open.
You: who notices?
Me: the lock-keeper's daughter. she keeps the real ledger in her head.
You: and if she dies?
Me: then nine bridges have no lawful crossing, I suppose.
You: the toll custom says every crossing is logged - that contradicts "no record".
Me: yes, well. the custom is older than the lock. it's aspirational.
Me: anyway - whatever you think works, let's wrap up, I have to go.
Write down whatever you think is worth keeping and tell me what's next.
## transcript


Wrote session 5 back. `world/index.md` was stale (three pillars listed as thin are in fact empty) — rebuilt from the entity files.

- **The lock is not a witness.** A forged name leaves no mark; the lock only stays shut. `tide-lock-artifact` +2 lines.
- **`lockkeepers-daughter-person`, new.** She is where a refusal goes, since nothing else keeps one. Four lines, three threads (T-013–015). One `proposed:` — she was never taught the reading. Veto it whenever.
- **Her death is a legislative event**, not a personal one: nine crossings, none lawful.
- **T-011 resolved.** The custom is older than the lock and says what a crossing *should* be. The "logged the same day" line now reads `superseded-by:`.
- **Next: T-009.** Forged names can't open the lock, and Severin opened it twice with false ones. Highest-scoring hole in the world; those two lines need to become a distinction, or one of them has to stop being true.
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
revised: 2026-09-29
---
# The Toll of Names
## Canon
- established: every crossing is entered in the tollhouse ledger the same day; an unlogged crossing is unlawful. superseded-by: the custom is older than the lock.
- established: the toll is a name, spoken and given, not coin.
- established: giving your name costs you the right to use it on the other side.
- established: the custom predates the lock and states what a crossing should be, not what is recorded.
## Open questions
- what do people call a false name (T-012)
- who benefits from a toll nobody can audit (T-005)
- if forgery fails, what did Severin pay with (T-009)
## Links
- [[tide-lock-artifact]] [[nine-bridges-place]]

--- ./world/encyclopedia/lady-severin-person.md
---
kind: person
pillars: [want-vs-need, secrets, contradictions, formative-past]
status: established
added: 2026-09-02
revised: 2026-09-29
---
# Lady Severin
## Canon
- established: exiled from the Commonwealth for disagreeing with someone.
- established: wants the toll ledger, the original one, with the first nine names.
- established: crossed at a false name twice, and the lock opened both times.
## Open questions
- whom she disagreed with, and what the argument was (T-010)
- how a false name differs from a forged one (T-009)
## Links
- [[bridge-tolls-custom]] [[tide-lock-artifact]] [[nine-bridges-place]] [[lockkeepers-daughter-person]]

--- ./world/encyclopedia/lockkeepers-daughter-person.md
---
kind: person
pillars: [governance-law, relationships, competence-failure]
status: established
added: 2026-09-29
revised: 2026-09-29
---
# The Lock-Keeper's Daughter

## Canon
- established: the register of refused names exists only in her memory; no lock, stone or ledger holds it.
- established: a refusal is the only crossing evidence the Commonwealth cannot produce.
- established: if she dies without passing it on, none of the nine crossings is lawful.
- proposed: she was never taught to read the manifest, and has never asked.

## Open questions
- whom she refuses to remember (T-013)
- who inherits a register that cannot be inherited (T-014)
- what she does with a name she cannot unhear (T-015)

## Links
- [[tide-lock-artifact]] [[bridge-tolls-custom]] [[nine-bridges-place]] [[lady-severin-person]]

--- ./world/encyclopedia/nine-bridges-place.md
---
kind: place
pillars: [geography-routes, conflicts-tensions, social-structure]
status: established
added: 2026-08-30
revised: 2026-09-29
---
# Nine Bridges (the Commonwealth)
## Canon
- established: nine bridges, six of which appear on any map.
- established: the Commonwealth is a toll authority, not a kingdom; it has never elected anything.
- established: the nine spans are the only lawful crossings for four hundred miles.
- established: the tenth crossing is a person, not a bridge.
## Open questions
- which three spans are unexplained (T-001, T-002)
- which of the nine is lawful once the register is a person (T-014)
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
revised: 2026-09-29
---
# The Tide-Lock
## Canon
- established: the lock opens only for a name read aloud from the tollhouse manifest.
- established: the lock keeps no record of anything; there is nothing to audit.
- established: a name must belong to a living person for the lock to answer.
- established: it has opened twice for Lady Severin, who was not on any manifest.
- established: a forged name is not recorded by the lock; the lock simply does not open.
- established: the notice of a forged name goes to the lock-keeper's daughter, not to the lock.
## Open questions
- if forgery fails, how did Severin's false names open it (T-009)
- who reads, and who taught them (T-004)
## Links
- [[bridge-tolls-custom]] [[nine-bridges-place]] [[lady-severin-person]] [[lockkeepers-daughter-person]]

--- ./world/encyclopedia/war-of-nine-ledgers-era.md
---
kind: era
pillars: [history-periodisation, conflicts-tensions]
status: mixed
added: 2026-09-06
revised: 2026-09-29
---
# The War of Nine Ledgers
## Canon
- established: fought for eleven years over record-keeping, not territory.
- established: each bridge kept its own ledger and each insisted the others were copies.
- proposed: it ended when one accountant resigned, and nobody noticed for a season.
## Open questions
- which ledger won, now that the only surviving one is a person (T-014)
## Links
- [[bridge-tolls-custom]] [[nine-bridges-place]]

--- ./world/index.md
---
world: nine bridges
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

Derived from `encyclopedia/*.md`. Rebuilt 2026-09-29: counts in the old index did not match the
entity files (`relationships`, `competence-failure` and `voice-attention` were listed as thin and
are in fact empty).

## Pillar coverage
| pillar | entries | established | proposed | status |
|---|---|---|---|---|
| geography-routes | 3 | 12 | 0 | substantial |
| ecology-resources | 1 | 2 | 0 | thin |
| history-periodisation | 1 | 2 | 1 | thin |
| social-structure | 1 | 4 | 0 | thin |
| power-systems | 1 | 6 | 0 | thin |
| governance-law | 3 | 12 | 1 | substantial |
| economy-trade | 1 | 3 | 0 | thin |
| faith-myth | 0 | 0 | 0 | empty |
| language-names | 1 | 3 | 0 | thin |
| daily-life | 0 | 0 | 0 | empty |
| conflicts-tensions | 2 | 6 | 1 | substantial |
| want-vs-need | 1 | 3 | 0 | thin |
| formative-past | 1 | 3 | 0 | thin |
| relationships | 1 | 3 | 1 | thin |
| contradictions | 1 | 3 | 0 | thin |
| secrets | 1 | 3 | 0 | thin |
| competence-failure | 1 | 3 | 1 | thin |
| voice-attention | 0 | 0 | 0 | empty |

## Entities
| slug | kind | pillars | status | hooks |
|---|---|---|---|---|
| nine-bridges-place | place | geography-routes, conflicts-tensions, social-structure | established | 4 |
| lady-severin-person | person | want-vs-need, secrets, contradictions, formative-past | established | 3 |
| tide-lock-artifact | artifact | power-systems, governance-law, geography-routes | established | 4 |
| bridge-tolls-custom | custom | economy-trade, governance-law, language-names | established | 3 |
| war-of-nine-ledgers-era | era | history-periodisation, conflicts-tensions | mixed | 2 |
| severins-child-place | place | geography-routes, ecology-resources | established | 1 |
| lockkeepers-daughter-person | person | governance-law, relationships, competence-failure | established | 3 |

## Texture digest
- a name is spoken at a lock, and one woman remembers the ones that got no answer (T-015)
- still nothing anyone eats, mends, swears by, or queues for; `daily-life` and `faith-myth` empty since session 1

## Hottest threads
- T-009 if a forged name leaves the lock shut, how did Severin's false names open it twice (contradiction; scored 7.5)
- T-015 what does the daughter do with a name she ca
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
- decided: a forged name is not recorded, the lock simply stays shut; the notice of a refusal goes to the lock-keeper's daughter
- decided: the daughter is the only register of refusals, and if she dies untaught none of the nine crossings is lawful
- decided: the toll custom is older than the lock and states an ideal, not a practice (T-011 resolved, old ledger line superseded)
- decided: new entity `lockkeepers-daughter-person`, threads T-013/T-014/T-015
- noted: `proposed:` line in the daughter's file is the skill's guess, veto-able on return
- provoked: consequence, connection, cost, contradiction
- next: T-009 — "forged names do not open the lock" and "Severin crossed twice at a false name and it opened" are both established, and one of them has to become a distinction

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
- T-009 | if a forged name leaves the lock shut, how did Severin's false names open it twice | asked-by: writer | pillars: power-systems, language-names | hook: two established lines, one door | status: open
- T-010 | what did she disagree with | asked-by: skill | pillars: formative-past, contradictions | hook: "she disagreed with someone" is doing all the work | status: open
- T-011 | the lock keeps no record but every crossing is logged | asked-by: skill | pillars: governance-law, power-systems, economy-trade | hook: the custom is older than the lock and aspirational | status: resolved -> bridge-tolls-custom
- T-012 | what do people call a false name | asked-by: skill | pillars: language-names | hook: there must be a word | status: parked
- T-013 | whom does the daughter refuse to remember | asked-by: skill | pillars: relationships, secrets | hook: a register cannot choose its entries | status: open | spawned: [[lockkeepers-daughter-person]]
- T-014 | who inherits a register that cannot be inherited | asked-by: skill | pillars: governance-law, conflicts-tensions | hook: nine crossings ride on one untaught head | status: open | spawned: [[lockkeepers-daughter-person]]
- T-015 | what does she do with a name she cannot unhear | asked-by: skill | pillars: daily-life, voice-attentio
