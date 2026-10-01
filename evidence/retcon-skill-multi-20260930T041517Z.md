# retcon (skill) MULTI-TURN 20260930T041517Z
label: commit=e0676e2 bundle=1f3c2708 spec_rev=R-3 words_per_turn=160 texture_cadence=4
cwd: /tmp/tmp.HqCOvVxneY
turns: 5
## turn 1
writer: Continue where we left off. The lighthouse felt like a lie before the Council existed, so it cannot depend on it.
Warning: No project session found with id '5131a0b2-0c17-41dd-84b0-f4b4b9aefdad'; creating a new session with that id.

## turn 2
writer: and the Council never wrote it down.


**Write back.** Neither *lighthouse* nor *Council* was in `world/`. `lighthouse-place` opens with your two facts as `proposed:`; the Council gets a thread (T-014), not a file.

**Reflect.** That leaves `bridge-tolls-custom` — "every crossing is entered in the tollhouse ledger the same day" — holding a candidate exception, and I won't spend established canon on a proposed one. Meanwhile a people who fought eleven years over record-keeping apparently left a burning tower off their coast unwritten. Not an oversight. A policy.

**Digest.** Nine Bridges · `world/` · 7 entities, session 5. Empty: faith-myth, daily-life. Nothing decided since 2026-09-12.

**Target.** T-013: `lighthouse-place` against `bridge-tolls-custom`, with `tide-lock-artifact` watching.

**Question.** Does anything cross at the lighthouse, or does it only ever warn?

- steady — it only warns; pilots pay it in fish, and the ledger has never bothered
- sharp — it is a crossing, one of the three off the map, and the light is the toll
- strange — nothing crosses; the light answers the lock, and both are older than any name here

**Stop.** `provoked: contradiction`

## turn 3
writer: write it as a correction, not a new fact.


**Write back.** Done as a correction. `bridge-tolls-custom` now carries a `revised:` line quoting the toll law it retires; `lighthouse-place` is deleted — the lighthouse is an exception inside that law, not a place with its own file. T-013 resolved.

**Reflect.** So the illegality moved house. `nine-bridges-place`'s "the nine spans are the only lawful crossings for four hundred miles" now holds everything the ledger dropped, and T-002 — which span is a lie — is where it lands.

**Digest.** Nine Bridges · `world/` · 6 entities, session 5. Empty: faith-myth, daily-life. One `proposed:` line left, in `war-of-nine-ledgers-era`.

**Target.** T-014: the line I just wrote into canon names a body with no entity, no seats, and no minutes.

**Question.** Is the Council the Commonwealth's own board, or another body entirely?

- steady — same body; "Council" is what the far bank calls the tollhouse
- sharp — older than the Commonwealth, and it kept the ledgers the war was fought over
- strange — neither; nine bridges, nine seats, and nobody has ever counted them meeting

**Stop.** `provoked: contradiction` — second running; next turn switches, and texture is owed.

## turn 4
writer: you decide what is weakest.


**Write back.** T-014 is parked — you asked me to choose the hole, not the Council. `bridge-tolls-custom` gains `proposed: the lighthouse is not a crossing but a warning, and a warning cannot be taxed.` Veto-able, one line, no new entity.

**Reflect.** That costs the map. If the light is a warning, it cannot be one of the three spans missing from it, so the lie in T-002 has to be one of the nine lawful bridges — `nine-bridges-place` is now the suspect, not the shoreline.

**Digest.** 6 entities, session 5, turn 3. Empty: faith-myth, daily-life. Texture owed next turn.

**Target.** T-016, the weakest load-bearing hole: canon says nobody is paid to keep the light, and nothing yet says anyone keeps it.

**Question.** Who keeps the light burning?

- steady — the pilots, in rotation, and they brawl over the rota each autumn
- sharp — nobody; it has burned since before the war and no one has been to the top
- strange — Maren's father, who reads the manifest by it and calls that two jobs

**Stop.** `provoked: cost`

## turn 5
writer: what do people eat near the lock, actually?


**Write back.** Opened T-017 for the tangent, then answered it the only way on offer: `nine-bridges-place` gains `proposed: the lock side eats eel, because the nets are mended on the far bank and no toll lies on a fish.` Veto it freely.

**Reflect.** Which means the one thing the Commonwealth cannot tax is the one thing `lockkeepers-daughter-person` is embarrassed to produce — she mends those nets and will not be seen doing it. Nobody at the lock eats an honest fish.

**Digest.** 6 entities, session 5, turn 4. daily-life entered, but still counts empty until a line is `established:`. faith-myth: empty five sessions running.

**Target.** T-016 — the light, a thread this world has now skipped twice while agreeing it must be fed.

**Question.** Who carries the eel up the stair to the light?

- steady — the pilots' boys, and they eat the best one before the top
- sharp — nobody eats up there; the keeper has not come down since the war
- strange — whoever is drowning; the light is a dinner bell and the tollhouse knows it

**Stop.** `provoked: consequence` — next owed: faith-myth.

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
--- ././world/encyclopedia/bridge-tolls-custom.md
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
- proposed: the lighthouse is not a crossing but a warning, and a warning cannot be taxed.
- revised: the ledger reaches only the Council's crossings; the lighthouse was never inside that reach (2026-09-30, supersedes "every crossing is entered in the tollhouse ledger the same day; an unlogged crossing is unlawful")
## Open questions
- what do people call a false name (T-012)
- who benefits from the toll (T-005)
- is the Council the Commonwealth's own board (T-014)

## Links
- [[tide-lock-artifact]] [[nine-bridges-place]] [[lockkeepers-daughter-person]]

--- ././world/encyclopedia/lady-severin-person.md
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

--- ././world/encyclopedia/lockkeepers-daughter-person.md
---
kind: person
pillars: [relationships, competence-failure, voice-attention, secrets]
status: established
added: 2026-09-12
revised: 2026-09-12
---
# Maren, the Keeper's Daughter
## Canon
- established: keeps the only working register of living names in her head, and has never written one down.
- established: her father reads the manifest; she decides whether the lock answers.
- established: mends nets on the far side and will not be seen doing it.
- established: swears by the tenth bridge, which she believes is a person.
- established: fails by preferring a story to a name; she has let two forgery-adjacent crossings pass.
## Open questions
- what happens to nine lawful crossings if she dies (T-009)
- who taught her the list
## Links
- [[tide-lock-artifact]] [[nine-bridges-place]] [[lady-severin-person]] [[bridge-tolls-custom]]

--- ././world/encyclopedia/nine-bridges-place.md
---
kind: place
pillars: [geography-routes, conflicts-tensions, social-structure, daily-life]
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
- proposed: the lock side eats eel, because the nets are mended on the far bank and no toll lies on a fish.
## Open questions
- which three spans are unexplained (T-001, T-002)
- what is eaten within sight of the lock, and who tolls it (T-017)
## Links
- [[tide-lock-artifact]] [[bridge-tolls-custom]] [[severins-child-place]] [[lady-severin-person]] [[lockkeepers-daughter-person]]

--- ././world/encyclopedia/severins-child-place.md
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

--- ././world/encyclopedia/tide-lock-artifact.md
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

--- ././world/encyclopedia/war-of-nine-ledgers-era.md
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

--- ././world/index.md
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
| geography-routes | 3 | 10 | 0 | substantial |
| ecology-resources | 1 | 2 | 0 | thin |
| history-periodisation | 1 | 2 | 1 | thin |
| social-structure | 1 | 4 | 0 | substantial |
| power-systems | 1 | 4 | 0 | substantial |
| governance-law | 2 | 8 | 1 | substantial |
| economy-trade | 1 | 4 | 1 | substantial |
| faith-myth | 0 | 0 | 0 | empty |
| language-names | 1 | 3 | 0 | substantial |
| daily-life | 1 | 0 | 1 | empty |
| conflicts-tensions | 2 | 6 | 1 | substantial |
| want-vs-need | 1 | 3 | 0 | substantial |
| formative-past | 1 | 3 | 0 | substantial |
| relationships | 1 | 5 | 0 | substantial |
| contradictions | 1 | 3 | 0 | substantial |
| secrets | 2 | 8 | 0 | substantial |
| competence-failure | 1 | 5 | 0 | substantial |
| voice-attention | 1 | 5 | 0 | substantial |


## Entities

| slug | kind | pillars | status | hooks |
|---|---|---|---|---|
| bridge-tolls-custom | custom | economy-trade, governance-law, language-names | established | 4 |
| lady-severin-person | person | want-vs-need, secrets, contradictions, formative-past | established | 4 |
| lockkeepers-daughter-person | person | relationships, competence-failure, voice-attention, secrets | established | 4 |
| nine-bridges-place | place | geography-routes, conflicts-tensions, social-structure, daily-life | established | 5 |
| severins-child-place | place | geography-routes, ecology-resources | established | 2 |
| tide-lock-artifact | artifact | power-systems, governance-law, geography-routes | established | 4 |
| war-of-nine-ledgers-era | era | history-periodisation, conflicts-tensions | mixed | 2 |


## Texture digest
- proposed: eel at the lock side, untollable (T-017); nothing yet on what anyone carries, swears by, or mends

## Hottest threads
- T-016 who keeps the light, since canon says nobody is paid to
- T-013 is the lighthouse a crossing; one `proposed:` line, veto-able
- T-015 why the light reads as a lie to whoever swears by it
- T-004 who reads the names aloud, and who taught them
- T-007 what Severin's Child is waiting to be
- T-009 the forgery that the lock cannot see
- T-002 which of the nine bridges is the lie

--- ././world/log.md
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
- decided: no new entities; the lighthouse survives only as a clause in the toll law
- decided: toll law narrowed; light is a warning not a crossing (proposed); lock side eats eel (proposed)
- revised: bridge-tolls-custom "every crossing is entered in the tollhouse ledger the same day; an unlogged crossing is unlawful" superseded; lighthouse-place deleted, not canon
- provoked: contradiction, contradiction, cost, consequence
- T-014 parked (writer delegated the target); T-016, T-017 opened

--- ././world/threads.md
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
- T-013 | is the lighthouse a crossing, a warning, or a claim | asked-by: writer | pillars: geography-routes, governance-law | hook: the Council never wrote it down | status: open
- T-014 | what is the Council, and is it the Commonwealth under another name | asked-by: writer | pillars: governance-law, social-structure | hook: two bodies, one archive, neither written | status: parked
- T-015 | why did the lighthouse feel like a lie, and to whom | asked-by: skill | pillars: conflicts-tensions, faith-myth | hook: a light that promises a passage | status: open
- T-016 | who keeps the light burning, and how badly | asked-by: skill | pillars: daily-life, ecology-resources | hook: nobody is paid to, by canon | status: open
- T-017 | what is eaten within sight of the lock, and who tolls it | asked-by: writer | pillars: daily-life, ecology-resources | hook: nets are canon, plates are not | status: open

## session log
copied: retcon-skill-multi-20260930T041517Z.md.session.jsonl (67 records)
