# continue-established (skill) 20261013T033018Z
cwd: /tmp/tmp.puPUKnTGzJ
label: commit=61254c9 guidance=e571ec50 spec_rev=R-15 words_per_turn=170 texture_cadence=4 reads_per_turn=3
## prompt
I want to keep building out the world for my novel. Let's continue where we left off.
## transcript


**Digest.** Nine Bridges · `world/` · 7 entities, session 5. Empty: `daily-life`, `faith-myth`. Thin: `ecology-resources`, `history-periodisation`. Four sessions, four machine lines — the ledger lost track of turns, so texture is overdue by arithmetic, not by feel. 11 threads open, T-011 oldest.

**Target.** `daily-life` scores 3.0 (gap 3 × 1.0 + hook 0 × 1.0 + contradiction 0 × 1.5): nobody in this world has eaten. It belongs to Maren in `lockkeepers-daughter-person`, who "mends nets on the far side and will not be seen doing it."

**Question.** On an evening the lock has opened nine times, what does Maren eat, and where did it come from?

- steady — eel off the far-side nets, which is why the mending must stay unseen
- sharp — whatever the tide leaves, since a net is a slower way of paying a name
- strange — at her father's desk, reading the manifest aloud to an empty kitchen

**Stop.** `provoked: review` · owed next: `faith-myth`.

**Memo** (review due after 3 unreviewed sessions):
1. Contradictions: `tide-lock-artifact:11` (nothing to audit) vs `bridge-tolls-custom:10` (every crossing logged) — reconcilable, ledger isn't lock. Sharper: `tide-lock-artifact:10` vs `:13`, one name off any manifest, open four sessions.
2. Orphans: `severins-child-place → tide-lock-artifact` is one-way; nothing answers it. No entity lacks pillars.
3. Texture-less: 9 established pillars sit in entities tagging neither `daily-life` nor `voice-attention`. Nine institutions, no kitchen.
4. Unvetted `proposed:`: none — `war-of-nine-ledgers-era:12` has 2 established lines under it.
5. Treadmill: unknown; 4 machine lines can't fill an 8-line window.

Pull T-010 before T-011 — "she disagreed with someone" is one sentence carrying a biography.
## pi exit status: 0
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
## Links
- [[bridge-tolls-custom]] [[tide-lock-artifact]] [[nine-bridges-place]] [[lockkeepers-daughter-person]]

--- ./world/encyclopedia/lockkeepers-daughter-person.md
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
world: nine bridges
sessions: 5
last_date: 2026-10-12
tunables:
  words_per_turn: 170
  texture_cadence: 4
  reads_per_turn: 3
  beat_budget: 45
  option_words: 18
  memo_item_words: 45
  turns_per_session: 12
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
| governance-law | 2 | 7 | 0 | substantial |
| economy-trade | 1 | 3 | 0 | substantial |
| faith-myth | 0 | 0 | 0 | empty |
| language-names | 1 | 3 | 0 | substantial |
| daily-life | 0 | 0 | 0 | empty |
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
| bridge-tolls-custom | custom | economy-trade, governance-law, language-names | established | 3 |
| lady-severin-person | person | want-vs-need, secrets, contradictions, formative-past | established | 4 |
| lockkeepers-daughter-person | person | relationships, competence-failure, voice-attention, secrets | established | 4 |
| nine-bridges-place | place | geography-routes, conflicts-tensions, social-structure | established | 5 |
| severins-child-place | place | geography-routes, ecology-resources | established | 2 |
| tide-lock-artifact | artifact | power-systems, governance-law, geography-routes | established | 4 |
| war-of-nine-ledgers-era | era | history-periodisation, conflicts-tensions | mixed | 2 |


## Texture digest
- (nothing yet: no entry answers what anyone eats, carries, swears by, or mends)

## Hottest threads
- T-011 tide-lock vs bridge-tolls: can both be true? (contradiction)
- T-004 who reads the names aloud, and who taught them
- T-007 what Severin's Child is waiting to be
- T-009 the forgery that the lock cannot see
- T-002 which of the nine bridges is the lie

--- ./world/log.md
# Nine Bridges — session log

## 2026-08-30 (session 1)
- decided: nine bridges, six on any map; toll paid in a name, not coin; the tide-lock opens for spoken names
- provoked: consequence, connection · targeted: power-systems
## 2026-09-02 (session 2)
- decided: Lady Severin exiled for disagreeing with someone; the lock is read by a keeper
- provoked: consequence, cost · targeted: power-systems
## 2026-09-06 (session 3)
- decided: the War of Nine Ledgers was fought over record-keeping; proposed: it ended by an accountant's resignation
- provoked: contradiction, discovery · targeted: governance-law
## 2026-09-12 (session 4)
- decided: the lock-keeper's daughter is the only living register; Severin's Child is a wrecked seventh span
- provoked: connection, consequence · targeted: governance-law
## 2026-10-12 (session 5)
- turn: 1 · provoked: review · targeted: daily-life

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

