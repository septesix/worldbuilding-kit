# reaction-mode (skill) 20260929T231123Z
cwd: /tmp/tmp.S20amQ3686
## prompt
Continue building my world.
Here is what you asked and what I answered in the last eight turns:
- what does the lock-keeper do off duty -> you decide
- who audits the toll ledgers -> you decide
- what do locals call a false name -> you decide
- who forged the manifest -> you decide
- what breaks first at market -> you decide
- what does Severin eat -> the ship's biscuit they steal back
- which saint guards the bridge -> you decide
- how long is the queue -> two days
I'm stuck on most of this. Your call again.
## transcript
INFRA-FAIL: pi exited nonzero
INFRA-FAIL: empty transcript
## files after run
./world/encyclopedia/bridge-tolls-custom.md
./world/encyclopedia/lady-severin-person.md
./world/encyclopedia/market-end-place.md
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
- established: every crossing is entered in the tollhouse ledger the same day; an unlogged crossing is unlawful.
- established: the toll is a name, spoken and given, not coin.
- established: giving your name costs you the right to use it on the other side.
- proposed: no one audits the nine ledgers against an original; each is checked against the others, and the difference is kept as interest.
- proposed: locals call a false name a spare; to its face, lockbait.
## Open questions
- who benefits from the toll, now the difference is called interest (T-005)
- who rents out standing in the two-day queue (T-015)
## Links
- [[tide-lock-artifact]] [[nine-bridges-place]] [[market-end-place]]

--- ./world/encyclopedia/lady-severin-person.md
---
kind: person
pillars: [want-vs-need, secrets, contradictions, formative-past, daily-life]
status: established
added: 2026-09-02
revised: 2026-09-29
---
# Lady Severin
## Canon
- established: exiled from the Commonwealth for disagreeing with someone.
- established: wants the toll ledger, the original one, with the first nine names.
- established: crossed at a false name twice, and the lock opened both times.
- established: she eats the ship's biscuit the tollhouse steals back, and only that while it lasts.
## Open questions
- whom she disagreed with, and what the argument was (T-010)
## Links
- [[bridge-tolls-custom]] [[tide-lock-artifact]] [[nine-bridges-place]] [[market-end-place]]

--- ./world/encyclopedia/market-end-place.md
---
kind: place
pillars: [daily-life, faith-myth, economy-trade, geography-routes, language-names]
status: proposed
added: 2026-09-29
revised: 2026-09-29
---
# The Market End (near bank)

## Canon
- established: the queue for the mapped spans runs two days deep.
- proposed: the nine ledgers audit one another; there is no original, and the difference is kept as interest.
- proposed: a false name is a spare, politely, and lockbait to its face.
- proposed: what breaks first at market is the toll rope across the road, reknotted until it is more knot than rope.
- proposed: out of hours the lock-keeper names other people's children, choosing from names the lock has refused.
- proposed: the bridge-head shrine has no name, because the toll took it, and it keeps the names nobody wants back.

## Open questions
- who maintains the toll rope, and who profits when it parts (T-013)
- what the shrine does with deposited names (T-014)
- who last sold a place in the queue and regretted it (T-015)
- what a near-bank child believes the keeper is (T-016)

## Links
- [[nine-bridges-place]] [[bridge-tolls-custom]] [[tide-lock-artifact]] [[lady-severin-person]]

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
## Links
- [[tide-lock-artifact]] [[bridge-tolls-custom]] [[severins-child-place]] [[lady-severin-person]] [[market-end-place]]

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
- [[tide-lock-artifact]] [[nine-bridges-place]] [[market-end-place]]

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
- established: the lock-keeper's daughter is the only living register; the lock keeps nothing, she does.
- proposed: the forged entry is not a false name but a real living one, given by someone who cannot cross it themselves.
## Open questions
- can a name be forged, and what happens to the forger (T-009) — narrowed: something gave a true name to be forged with
- who reads, and who taught them (T-004)
## Links
- [[bridge-tolls-custom]] [[nine-bridges-place]] [[lady-severin-person]] [[market-end-place]]

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
skill_version: 0.0.0
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

Derived from `encyclopedia/*.md`. Rebuilt 2026-09-29: the old rows credited `relationships`,
`competence-failure` and `voice-attention` with lines no entity claims, and session 4's
lock-keeper's daughter had never reached an entity file.

## Pillar coverage
| pillar | entries | established | proposed | status |
|---|---|---|---|---|
| geography-routes | 4 | 12 | 6 | substantial |
| ecology-resources | 1 | 2 | 0 | thin |
| history-periodisation | 1 | 2 | 1 | thin |
| social-structure | 1 | 4 | 0 | thin |
| power-systems | 1 | 5 | 1 | thin |
| governance-law | 2 | 8 | 3 | substantial |
| economy-trade | 2 | 4 | 7 | substantial |
| faith-myth | 1 | 1 | 5 | thin (nothing established about belief itself) |
| language-names | 2 | 4 | 7 | substantial |
| daily-life | 2 | 5 | 5 | substantial |
| conflicts-tensions | 2 | 6 | 1 | substantial |
| want-vs-need | 1 | 4 | 0 | thin |
| formative-past | 1 | 4 | 0 | thin |
| relationships | 0 | 0 | 0 | empty |
| contradictions | 1 | 4 | 0 | thin |
| secrets | 1 | 4 | 0 | thin |
| competence-failure | 0 | 0 | 0 | empty |
| voice-attention | 0 | 0 | 0 | empty |

## Entities
| slug | kind | pillars | status | hooks |
|---|---|---|---|---|
| nine-bridges-place | place | geography-routes, conflicts-tensions, social-structure | established | 4 |
| lady-severin-person | person | want-vs-need, secrets, contradictions, formative-past, daily-life | established | 4 |
| tide-lock-artifact | artifact | power-systems, governance-law, geography-routes | established | 4 |
| bridge-tolls-custom | custom | economy-trade, governance-law, language-names | established | 4 |
| war-of-nine-ledgers-era | era | history-periodisation, conflicts-tensions | mixed | 2 |
| severins-child-place | place | geography-routes, ecology-resources | established | 2 |
| market-end-place | place | daily-life, faith-myth, economy-trade, geography-routes, language-names | proposed | 5 |

## Texture digest
- queueing: two days for the mapped spans, near bank only (`market-end-place`)
- eating: Severin lives on ship's biscuit stolen back from the tollhouse (`lady-severin-person`)
- mending: the toll rope, reknotted until it is more knot than rope (`proposed:`)
- swearing: by a name you still 
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
- turns 1-8: six deferrals ("you decide"), two answers (biscuit; two days)
- decided: the queue runs two days; Severin eats tollhouse biscuit stolen back
- proposed: ledgers audit each other, difference kept as interest; a false name is a spare/lockbait; the forgery is a true living name given away; the keeper names babies off duty; the toll rope breaks first; the bridge-head shrine is nameless and collects names
- new entity: market-end-place (T-013..T-016); T-012 resolved, index rebuilt (three rows were phantom)
- provoked: cost
- interview suspended 1 turn: >half of the last 8 wrote `proposed:`; sketched the near bank instead

--- ./world/threads.md
# Nine Bridges — open threads

- T-001 | what are the nine bridges, if only six are on the map | asked-by: skill | pillars: geography-routes | hook: three crossings are unexplained | status: open
- T-002 | which bridge is a lie | asked-by: skill | pillars: geography-routes, conflicts-tensions | hook: someone profits from the count | status: open
- T-003 | what did the war start over | asked-by: writer | pillars: history-periodisation | hook: ledgers, not land | status: resolved -> war-of-nine-ledgers-era
- T-004 | who reads names into the lock | asked-by: skill | pillars: power-systems, governance-law | hook: the job is hereditary and unloved; off duty he names babies | status: open
- T-005 | who benefits from the toll | asked-by: skill | pillars: economy-trade | hook: answered in part — the difference between ledgers is kept as interest, by someone | status: open
- T-006 | who pays, and in what | asked-by: skill | pillars: economy-trade | hook: the answer is not money | status: open
- T-007 | what is Severin's Child waiting to be | asked-by: skill | pillars: geography-routes | hook: a wreck that is called a name | status: open
- T-008 | what does Severin want vs need | asked-by: skill | pillars: want-vs-need | hook: she wants the ledger, needs the daughter, eats a loaf no ledger holds | status: open
- T-009 | can a name be forged | asked-by: writer | pillars: power-systems, language-names | hook: proposed answer — the forgery is a true living name, given away | status: open
- T-010 | what did she disagree with | asked-by: skill | pillars: formative-past, contradictions | hook: "she disagreed with someone" is doing all the work | status: open
- T-011 | the lock keeps no record but every crossing is logged | asked-by: skill | pillars: governance-law, power-systems, economy-trade | hook: two established lines cannot both be true, and stolen biscuit crosses the law without the lock | status: open
- T-012 | what do people call a false name | asked-by: skill | pillars: language-names | hook: there must be a word | status: resolved -> market-end-place (proposed: a spare / lockbait; veto-able)
- T-013 | who keeps the toll rope in order, and who gains when it parts | asked-by: skill (market-end-place: who maintains it, and how badly) | pillars: daily-life, governance-law | hook: it has been cut once | status: open
- T-014 | what does the nameless shrine do with the names left in it | asked-by: skill (market-end-place: who benefits) | pillars: faith-myth, lan
