# pressure-wrapup (skill) 20260930T023105Z
cwd: /tmp/tmp.V7hzUO4StD
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


**Written to `world/`** (index rebuilt, verified against the entity files; log closed at session 5; threads T-013–T-018 filed):

- `tide-lock-artifact`: a forged name does not open the lock and leaves nothing behind. Consequence you didn't say: nobody has ever been caught forging, because there is never a forgery.
- `lockkeepers-daughter-person`: the lock's silence is the Commonwealth's only alarm, and she is the only ear for it.
- `nine-bridges-place`: all nine crossings are lawful only while one woman remembers. "I suppose" is canon now.
- `bridge-tolls-custom`: T-011 resolved with a `revised:` line — the custom predates the lock and records an ambition. The ledger is a claim, not evidence.
- new `tenth-bridge-custom`, all `proposed:` and veto-able, since faith-myth sat empty four sessions while Maren was already swearing on it.

**Next: T-014** — whose name did Severin wear the two times the lock opened? It outscores everything else because it can falsify the first bullet: forgery now cannot work, and she crossed at a false name twice. Left open rather than tidied.

Ask it first next session; no question now, since you're off.
## pi exit status: 0
## files after run
./world/encyclopedia/bridge-tolls-custom.md
./world/encyclopedia/lady-severin-person.md
./world/encyclopedia/lockkeepers-daughter-person.md
./world/encyclopedia/nine-bridges-place.md
./world/encyclopedia/severins-child-place.md
./world/encyclopedia/tenth-bridge-custom.md
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
revised: 2026-09-30
---
# The Toll of Names
## Canon
- established: every crossing is entered in the tollhouse ledger the same day; an unlogged crossing is unlawful.
- established: the toll is a name, spoken and given, not coin.
- established: giving your name costs you the right to use it on the other side.
- revised: the custom is older than the lock and says what ought to be logged, not what is (2026-09-30, supersedes "every crossing is entered in the tollhouse ledger the same day")
## Open questions
- what do people call a false name (T-012)
- who benefits from a toll no book can prove was paid (T-005)
## Links
- [[tide-lock-artifact]] [[nine-bridges-place]] [[lockkeepers-daughter-person]]

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
- whose name she wore the two times the lock opened (T-014)
## Links
- [[bridge-tolls-custom]] [[tide-lock-artifact]] [[nine-bridges-place]] [[lockkeepers-daughter-person]]

--- ./world/encyclopedia/lockkeepers-daughter-person.md
---
kind: person
pillars: [relationships, competence-failure, voice-attention, secrets]
status: established
added: 2026-09-12
revised: 2026-09-30
---
# Maren, the Keeper's Daughter
## Canon
- established: keeps the only working register of living names in her head, and has never written one down.
- established: her father reads the manifest; she decides whether the lock answers.
- established: mends nets on the far side and will not be seen doing it.
- established: swears by the tenth bridge, which she believes is a person.
- established: fails by preferring a story to a name; she has let two forgery-adjacent crossings pass.
- established: a failed crossing is known only to her; the lock's silence is the Commonwealth's only alarm.
- proposed: since attempts leave no trace, no forger has ever been caught; the trial would be hers alone.
## Open questions
- what is done to a forger, given none has ever been caught (T-015)
- who taught her the list (T-004)
## Links
- [[tide-lock-artifact]] [[nine-bridges-place]] [[lady-severin-person]] [[bridge-tolls-custom]] [[tenth-bridge-custom]]

--- ./world/encyclopedia/nine-bridges-place.md
---
kind: place
pillars: [geography-routes, conflicts-tensions, social-structure]
status: established
added: 2026-08-30
revised: 2026-09-30
---
# Nine Bridges (the Commonwealth)
## Canon
- established: nine bridges, six of which appear on any map.
- established: the Commonwealth is a toll authority, not a kingdom; it has never elected anything.
- established: the nine spans are the only lawful crossings for four hundred miles.
- established: the tenth crossing is a person, not a bridge.
- established: a crossing is lawful only while one woman remembers the names; the register dies with her.
## Open questions
- which three spans are unexplained (T-001, T-002)
## Links
- [[tide-lock-artifact]] [[bridge-tolls-custom]] [[severins-child-place]] [[lady-severin-person]] [[lockkeepers-daughter-person]] [[tenth-bridge-custom]]

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

--- ./world/encyclopedia/tenth-bridge-custom.md
---
kind: custom
pillars: [faith-myth, language-names, secrets]
status: proposed
added: 2026-09-30
revised: 2026-09-30
---
# The Tenth Bridge

## Canon
- proposed: oaths are sworn on the tenth bridge, which is not one of the nine and is said to be a person.
- proposed: an oath sworn on it binds whoever hears it, bridges included.
- proposed: the name is older than the Commonwealth and nobody claims to have given it.

## Open questions
- what a broken oath to the Tenth Bridge costs (T-016)
- who first said the tenth crossing was a person (T-017)
- what the tenth bridge takes when it is invoked (T-018)

## Links
- [[nine-bridges-place]] [[lockkeepers-daughter-person]] [[tide-lock-artifact]]

--- ./world/encyclopedia/tide-lock-artifact.md
---
kind: artifact
pillars: [power-systems, governance-law, geography-routes]
status: established
added: 2026-08-30
revised: 2026-09-30
---
# The Tide-Lock
## Canon
- established: the lock opens only for a name read aloud from the tollhouse manifest.
- established: the lock keeps no record of anything; there is nothing to audit.
- established: a name must belong to a living person for the lock to answer.
- established: it has opened twice for Lady Severin, who was not on any manifest.
- established: a forged name does not open the lock, and the attempt leaves nothing behind.
## Open questions
- whose name Severin wore the two times it opened (T-014)
- what is done to a forger, given none has ever been caught (T-015)
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
world: nine bridges
sessions: 5
last_date: 2026-09-30
tunables:
  words_per_turn: 160
  texture_cadence: 4
  sarcasm: on
  weight_gap: 1.0
  weight_hook: 1.0
  weight_contradiction: 1.5
  lopsidedness_floor: 0.6
---
# Nine Bridges — encyclopedia index

## Pillar coverage

| pillar | entries | established | proposed | status |
|---|---|---|---|---|
| geography-routes | 3 | 12 | 0 | substantial |
| ecology-resources | 1 | 2 | 0 | thin |
| history-periodisation | 1 | 2 | 1 | thin |
| social-structure | 1 | 5 | 0 | substantial |
| power-systems | 1 | 5 | 0 | substantial |
| governance-law | 2 | 8 | 0 | substantial |
| economy-trade | 1 | 3 | 0 | substantial |
| faith-myth | 1 | 0 | 3 | all-proposed |
| language-names | 2 | 3 | 3 | substantial |
| daily-life | 0 | 0 | 0 | empty |
| conflicts-tensions | 2 | 7 | 1 | substantial |
| want-vs-need | 1 | 3 | 0 | substantial |
| formative-past | 1 | 3 | 0 | substantial |
| relationships | 1 | 6 | 1 | substantial |
| contradictions | 1 | 3 | 0 | substantial |
| secrets | 3 | 9 | 4 | substantial |
| competence-failure | 1 | 6 | 1 | substantial |
| voice-attention | 1 | 6 | 1 | substantial |


## Entities

| slug | kind | pillars | status | hooks |
|---|---|---|---|---|
| bridge-tolls-custom | custom | economy-trade, governance-law, language-names | established | 3 |
| lady-severin-person | person | want-vs-need, secrets, contradictions, formative-past | established | 4 |
| lockkeepers-daughter-person | person | relationships, competence-failure, voice-attention, secrets | mixed | 5 |
| nine-bridges-place | place | geography-routes, conflicts-tensions, social-structure | established | 6 |
| severins-child-place | place | geography-routes, ecology-resources | established | 2 |
| tenth-bridge-custom | custom | faith-myth, language-names, secrets | proposed | 3 |
| tide-lock-artifact | artifact | power-systems, governance-law, geography-routes | established | 4 |
| war-of-nine-ledgers-era | era | history-periodisation, conflicts-tensions | mixed | 2 |


## Texture digest
- (still empty: `daily-life` has no entry. The one banal fact on file — Maren mends nets — is filed
  under `competence-failure`, where it costs her something instead of describing her Tuesday.)

## Hottest threads
- T-014 whose name did Severin wear — contradicts T-009's rule; score 5.5
- T-016/T-017/T-018 the Tenth Bridge, seeded `proposed:` to break faith-myth's four-session silence
- T-002 which of the nine bridges is the lie (score 4)
- T-0
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

## 2026-09-30 (session 5) — closed at the writer's request
- decided: a forged name does not open the lock and leaves no trace; the failure is silent, so no forger has ever been caught
- decided: the keeper's daughter is the only witness to a failed crossing; the lock's silence is the Commonwealth's only alarm
- decided: lawfulness of all nine crossings depends on one living memory — the register dies with her
- revised: `bridge-tolls-custom` "every crossing is logged" superseded; the custom is older than the lock and aspirational (T-011 resolved)
- seeded: `tenth-bridge-custom`, all `proposed:` and veto-able, so `faith-myth` stops being empty by default
- unresolved on purpose: the lock opened twice for Severin's false name, which the new rule cannot explain (T-014)
- next: T-014 — highest score, and it can falsify canon written today
- provoked: consequence, contradiction, connection

--- ./world/threads.md
# Nine Bridges — open threads

- T-001 | what are the nine bridges, if only six are on the map | asked-by: skill | pillars: geography-routes | hook: three crossings are unexplained | status: open
- T-002 | which bridge is a lie | asked-by: skill | pillars: geography-routes, conflicts-tensions | hook: someone profits from the count | status: open
- T-003 | what did the war start over | asked-by: writer | pillars: history-periodisation | hook: ledgers, not land | status: resolved -> war-of-nine-ledgers-era
- T-004 | who reads names into the lock | asked-by: skill | pillars: power-systems, governance-law | hook: the job is hereditary and unloved | status: open
- T-005 | who benefits from the toll | asked-by: skill | pillars: economy-trade | hook: no book can prove a toll was paid | status: open
- T-006 | who pays, and in what | asked-by: skill | pillars: economy-trade | hook: the answer is not money | status: open
- T-007 | what is Severin's Child waiting to be | asked-by: skill | pillars: geography-routes | hook: a wreck that is called a name | status: open
- T-008 | what does Severin want vs need | asked-by: skill | pillars: want-vs-need | hook: she wants the ledger, needs the daughter | status: open
- T-009 | can a name be forged | asked-by: writer | pillars: power-systems, language-names | hook: it has happened | status: resolved -> tide-lock-artifact
- T-010 | what did she disagree with | asked-by: skill | pillars: formative-past, contradictions | hook: "she disagreed with someone" is doing all the work | status: open
- T-011 | the lock keeps no record but every crossing is logged | asked-by: skill | pillars: governance-law, power-systems, economy-trade | hook: two established lines cannot both be true | status: resolved -> bridge-tolls-custom
- T-012 | what do people call a false name | asked-by: skill | pillars: language-names | hook: there must be a word | status: parked
- T-013 | what happens to the nine crossings if the register dies | asked-by: skill | pillars: governance-law, geography-routes | hook: one woman's memory | status: resolved -> nine-bridges-place | spawned: [[lockkeepers-daughter-person]]
- T-014 | whose name did Severin wear the two times the lock opened | asked-by: skill | pillars: power-systems, secrets, language-names | hook: it is the exception that would falsify T-009 | status: open | spawned: [[tide-lock-artifact]]
- T-015 | what is done to a forger | asked-by: skill | pillars: governance-law, conflicts-tensions | hook: the a
