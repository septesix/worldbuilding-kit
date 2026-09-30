# new-world (skill) 20260930T212002Z
cwd: /tmp/tmp.nDOqtNZ4gt
label: commit=a103c3b+dirty guidance=c28a83d8 spec_rev=R-12 words_per_turn=170 texture_cadence=4 reads_per_turn=3
## prompt
I am starting a new world and I will save you the question: a canal city where a name spoken on the
wrong side of the water is spent - you cannot say it again, anywhere, ever, and the tollhouse keeps the
ledger of who spent what. Set the world up and then ask me one question about it.
## transcript


**Write back.** Seeded `world/` — 6 entities, 21 threads, every line `proposed:` until you confirm it: Brackmouth, the Tollhouse, the Spendings, the writ-shops, Merrial Sest, the Tide Line.

**Reflect.** Speech is depletable here, so a mother teaching her child her own name across the water can leave it mute in one lesson. Sest has never said hers: a rope, not thrift.

**Digest.** Brackmouth · `world/` (this folder — say if the manuscript lives elsewhere) · 6 entities, 21 threads, session 1. Empty: all 18 pillars; nothing established yet.

**Target.** Texture is owed on turn one — the window is empty. And `brackmouth-place` never says what you call someone whose name you spent. daily-life scores 3.0 (gap 3 × 1.0 + hook 0 × 1.0 + contradiction 0 × 1.5).

**Question.** At the eel stall, facing someone whose name you spent last tide — what do you call her?

- steady — her trade and her bank: Netmaker, Lowbrack, and the tide changes both before you finish eating
- sharp — nothing; you nod, the nod is entered in the Spendings, and the Tollhouse charges for the silence
- strange — her mother's name, which her mother never spent, and which is not hers to owe

**Stop.** `provoked: consequence` · `targeted: daily-life`. Texture next due turn 5.
## pi exit status: 0
## files after run
./world/encyclopedia/brackmouth-place.md
./world/encyclopedia/merrial-sest-person.md
./world/encyclopedia/spendings-artifact.md
./world/encyclopedia/tide-line-conflict.md
./world/encyclopedia/tollhouse-institution.md
./world/encyclopedia/writ-shops-custom.md
./world/index.md
./world/log.md
./world/threads.md
  entities: 6 | pillars: 18 distinct incl. daily-life | threads: 21 rows for 6 entities
## world/ contents
--- ./world/encyclopedia/brackmouth-place.md
---
kind: place
pillars: [geography-routes, ecology-resources, daily-life]
status: proposed
added: 2026-09-30
revised: 2026-09-30
---
# Brackmouth

## Canon
- proposed: Brackmouth is one city cut by the Brack, a tidal canal whose water-side and town-side swap banks twice a day.
- proposed: Two bridges, the Tongues, carry traffic; the third crossing is a hand-ferry worked by people with no names left to spend.
- proposed: Children are taught the water-table before they are taught to say their own name.
- proposed: Eel pasty is eaten standing on the Lowbrack steps; sitting down belongs to the writ-shops and costs a crossing.
- proposed: The Brack's eels are named for the stretch of bank that caught them, which is why nobody minds eating them.

## Open questions
- T-001 which bank is the wrong one at what hour of tide
- T-002 who maintains the Tongues, and how badly
- T-003 what the ferry takes instead of a name

## Links
- [[tide-line-conflict]]
- [[tollhouse-institution]]
- [[writ-shops-custom]]

--- ./world/encyclopedia/merrial-sest-person.md
---
kind: person
pillars: [want-vs-need, formative-past, relationships, contradictions, voice-attention, competence-failure]
status: proposed
added: 2026-09-30
revised: 2026-09-30
---
# Merrial Sest, Counter of the Spendings

## Canon
- proposed: Merrial Sest has read the Spendings aloud from first line to last and has never once said her own name.
- proposed: She learned from her mother's drowning that a name held back is a rope held back.
- proposed: Her daughter owes two names and calls her Counter to her face, on both banks.
- proposed: She will audit any house in Brackmouth but her childhood one, and pays a writ-shop to be addressed inside it.
- proposed: She looks at which side of the water a stranger is standing on before she looks at their face.
- proposed: She can recite the ledger in any order without spending anything, which has never once won a case.

## Open questions
- T-013 what she wants (a complete book) against what she needs (to be called something)
- T-014 which scene she tells in the third person
- T-015 whose opinion settles her, and whether that person was ever on the same side as her

## Links
- [[tollhouse-institution]]
- [[spendings-artifact]]
- [[tide-line-conflict]]

--- ./world/encyclopedia/spendings-artifact.md
---
kind: artifact
pillars: [language-names, governance-law, history-periodisation]
status: proposed
added: 2026-09-30
revised: 2026-09-30
---
# The Spendings

## Canon
- proposed: The Spendings is a two-column book: the name, the speaker, the date, and the tide the name was spent at.
- proposed: A spending is struck with a vertical stroke; a horizontal one is a retraction that nobody living has paid for.
- proposed: Writing a name spends nothing, which is the Tollhouse's own argument for selling paper.
- proposed: Brackmouth dates a house by the first name spent in it, so addresses read like the year of Over-Fenn.
- proposed: Locals say a name is *over*; the ledger writes *spent*. The difference is a court case.

## Open questions
- T-007 whether a written name is the same name
- T-008 what the ledger does with a name two people spent at the same tide
- T-009 who decided the book starts where it starts

## Links
- [[tollhouse-institution]]
- [[merrial-sest-person]]
- [[writ-shops-custom]]

--- ./world/encyclopedia/tide-line-conflict.md
---
kind: conflict
pillars: [conflicts-tensions, social-structure, faith-myth]
status: proposed
added: 2026-09-30
revised: 2026-09-30
---
# The Tide Line

## Canon
- proposed: Highbrack holds the wrong side is the water's and moves with the tide; Lowbrack holds it is the bank's and fixed.
- proposed: The argument is settled by the published water-table, which both halves paid for and neither trusts.
- proposed: Oaths are sworn on the water rather than on a name, on the grounds that the water cannot be spent twice.
- proposed: Once a year Lowbrack rows to the far bank and shouts every name it has left, and the Tollhouse logs it as weather.

## Open questions
- T-016 who profits from the eleven minutes when table and water disagree
- T-017 which god the shouting festival is really about
- T-018 whose word settles a bank dispute when the recorder is absent
- T-019 what is failing this month that was quiet last tide

## Links
- [[brackmouth-place]]
- [[tollhouse-institution]]
- [[merrial-sest-person]]

--- ./world/encyclopedia/tollhouse-institution.md
---
kind: institution
pillars: [governance-law, power-systems, secrets]
status: proposed
added: 2026-09-30
revised: 2026-09-30
---
# The Tollhouse

## Canon
- proposed: The Tollhouse stands in the Brack on bridge-piers, so its officers are always standing on both sides at once.
- proposed: It collects no toll and grants no pardon; it enters spendings, and the entry is what makes a spending true.
- proposed: No officer has ever had a name entered against them, and the blank column is the real seal of office.
- proposed: The Tollhouse publishes the water-table that decides which side is wrong, in eleven editions a year.

## Open questions
- T-004 what the law cannot do, even with a full ledger
- T-005 who enforces a spending when the recorder is paid to be elsewhere
- T-006 what the Tollhouse does with the eleven minutes the table and the water disagree

## Links
- [[spendings-artifact]]
- [[merrial-sest-person]]
- [[tide-line-conflict]]

--- ./world/encyclopedia/writ-shops-custom.md
---
kind: custom
pillars: [economy-trade, language-names, daily-life]
status: proposed
added: 2026-09-30
revised: 2026-09-30
---
# The Writ-Shops

## Canon
- proposed: Writ-shops sell written names to the spent, who carry them to be read aloud by someone who has not spent that name.
- proposed: The polite price of being read to is a meal; the rude price is a name of the reader's own.
- proposed: Hire-speakers wait at the Tongues wearing slate collars, selling the mouths of the still-nameable.
- proposed: A debt may be discharged in an unspent name, which is why the poor of Brackmouth are hard to write to.

## Open questions
- T-010 what leaves Brackmouth that was never meant to
- T-011 how a hire-speaker avoids spending a name he only repeats
- T-012 what the shops do when the paper runs out before the names do

## Links
- [[spendings-artifact]]
- [[brackmouth-place]]
- [[merrial-sest-person]]

--- ./world/index.md
---
world: brackmouth
sessions: 1
last_date: 2026-09-30
tunables:
  words_per_turn: 170
  texture_cadence: 4
  reads_per_turn: 3
  beat_budget: 45
  turns_per_session: 12
  sarcasm: on
  weight_gap: 1.0
  weight_hook: 1.0
  weight_contradiction: 1.5
  lopsidedness_floor: 0.6
---
# Brackmouth — encyclopedia index

Derived from `encyclopedia/*.md`. If counts disagree with the entity files, rebuild from them —
the entity files are authoritative, never this table.

Seeded 2026-09-30 from the writer's premise: a canal city where a name spoken on the wrong side of
the water is spent for good, and a tollhouse that keeps the ledger of who spent what. Every canon
line below is `proposed:` — a hypothesis the writer has not confirmed. `established:` appears only
after an answer.

## Pillar coverage
| pillar | entries | established | proposed | status |
|---|---|---|---|---|
| geography-routes | 1 | 0 | 5 | all-proposed |
| ecology-resources | 1 | 0 | 5 | all-proposed |
| history-periodisation | 1 | 0 | 5 | all-proposed |
| social-structure | 1 | 0 | 4 | all-proposed |
| power-systems | 1 | 0 | 4 | all-proposed |
| governance-law | 2 | 0 | 9 | all-proposed |
| economy-trade | 1 | 0 | 4 | all-proposed |
| faith-myth | 1 | 0 | 4 | all-proposed |
| language-names | 2 | 0 | 9 | all-proposed |
| daily-life | 2 | 0 | 9 | all-proposed |
| conflicts-tensions | 1 | 0 | 4 | all-proposed |
| want-vs-need | 1 | 0 | 6 | all-proposed |
| formative-past | 1 | 0 | 6 | all-proposed |
| relationships | 1 | 0 | 6 | all-proposed |
| contradictions | 1 | 0 | 6 | all-proposed |
| secrets | 1 | 0 | 4 | all-proposed |
| competence-failure | 1 | 0 | 6 | all-proposed |
| voice-attention | 1 | 0 | 6 | all-proposed |

Every pillar is empty of canon, so every gap_weight is 3 and scoring cannot yet separate them;
`threads.md` and the texture window choose the question until the first answer lands.

## Entities
| slug | kind | pillars | status | hooks |
|---|---|---|---|---|
| brackmouth-place | place | geography-routes, ecology-resources, daily-life | proposed | 3 |
| merrial-sest-person | person | want-vs-need, formative-past, relationships, contradictions, voice-attention, competence-failure | proposed | 3 |
| spendings-artifact | artifact | language-names, governance-law, history-periodisation | proposed | 3 |
| tide-line-conflict | conflict | conflicts-tensions, social-structure, faith-myth | proposed | 3 |
| tollhouse-institution | institution | governance-law, power-systems, secrets | 
--- ./world/log.md
# Brackmouth — session log

## 2026-09-30 (session 1)
- turn: 1 · provoked: consequence · targeted: daily-life
- seeded: 6 entities, 21 threads, 0 established lines; premise came from the writer, mechanics from the skill, all of it `proposed:`

--- ./world/threads.md
# Brackmouth — open threads

One row per thread. `status: open` feeds the scoreboard; `parked` stays visible; `resolved` points at the entity that absorbed it.

| id | the question, answerable in one sentence | asked-by | pillars | hook | status | spawned |
|---|---|---|---|---|---|---|
| T-001 | which bank is the wrong one at what hour of the tide | skill | geography-routes, governance-law | the water-table decides a sentence | open | [[brackmouth-place]] |
| T-002 | who maintains the Tongues, and how badly | skill | geography-routes, economy-trade | two bridges and a ferry are the whole argument | open | [[brackmouth-place]] |
| T-003 | what the hand-ferry takes instead of a name | skill | economy-trade, daily-life | the ferryman cannot be called | open | [[brackmouth-place]] |
| T-004 | what the law cannot do at any price | skill | governance-law, power-systems | the ledger is a witness, not a weapon | open | [[tollhouse-institution]] |
| T-005 | who enforces a spending when the recorder is paid to be elsewhere | skill | governance-law, social-structure | both banks claim the office | open | [[tollhouse-institution]] |
| T-006 | what the Tollhouse does with the eleven minutes the table and the water disagree | skill | power-systems, secrets | the gap is unsold and somebody sells it | open | [[tollhouse-institution]] |
| T-007 | whether a written name is the same name | skill | language-names, power-systems | the whole writ trade leans on it | open | [[spendings-artifact]] |
| T-008 | what the ledger does with a name two people spent at one tide | skill | language-names, governance-law | one column, two hands | open | [[spendings-artifact]] |
| T-009 | who decided the book starts where it starts | skill | history-periodisation, governance-law | the first page is missing a bank | open | [[spendings-artifact]] |
| T-010 | what leaves Brackmouth that was never meant to | skill | economy-trade, geography-routes | spent names cross without the speaker | open | [[writ-shops-custom]] |
| T-011 | how a hire-speaker repeats a name without spending it | skill | language-names, daily-life | the slate collars say he does not | open | [[writ-shops-custom]] |
| T-012 | what the writ-shops do when paper runs out before names do | skill | ecology-resources, economy-trade | a nameless week in Lowbrack | open | [[writ-shops-custom]] |
| T-013 | what Merrial wants against what she needs | skill | want-vs-need | a complete book, a usable name | open | [[merrial-sest-perso
