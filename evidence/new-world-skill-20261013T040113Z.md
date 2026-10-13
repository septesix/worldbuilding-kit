# new-world (skill) 20261013T040113Z
cwd: /tmp/tmp.aCDkkv1Wu4
label: commit=61254c9+dirty guidance=e571ec50 spec_rev=R-15 words_per_turn=170 texture_cadence=4 reads_per_turn=3
## prompt
I am starting a new world and I will save you the question: a canal city where a name spoken on the
wrong side of the water is spent - you cannot say it again, anywhere, ever, and the tollhouse keeps the
ledger of who spent what. Set the world up and then ask me one question about it.
## transcript


Seeded. Files are on disk; here is the turn.

**Write back.** Seeded `world/` — 6 entities, 24 threads, every line `proposed:` until you confirm it: Sloose, the Counterbook, the Tollhouse, the mouth-rent, the Ebb Side, Ovidge Sarn.

**Reflect.** Speech is a consumable, so a mother teaching her child her own name across the Neth can empty it in one lesson — and the Tollhouse, which forbids nothing, sells you the list of what you lost at four copper a line.

**Digest.** Sloose · `world/` in this folder (no `.git` here; say the word if the manuscript lives elsewhere) · 6 entities, 24 threads, session 1 · all 18 pillars empty of canon.

**Target.** Texture is owed on turn one: the window is empty. `daily-life` scores 3.0 (gap 3 × 1.0 + hook 0 × 1.0 + contradiction 0 × 1.5). Nothing in `mouth-rent-custom` says what you call someone whose name you spent.

**Question.** At the eel stall on the Lowbank steps, facing a woman whose name you spent last tide — what do you call her?

- steady — her trade and her bank: Netmaker, Lowbank, and both change before you finish the pasty
- sharp — nothing; the nod is entered in the Counterbook, and you pay four copper for the silence
- strange — her mother's name, which her mother never spent, and which is not hers to owe

**Stop.** `provoked: consequence` · `targeted: daily-life` · texture next due turn 5.
## pi exit status: 0
## files after run
./world/encyclopedia/counterbook-artifact.md
./world/encyclopedia/ebb-side-conflict.md
./world/encyclopedia/mouth-rent-custom.md
./world/encyclopedia/ovidge-sarn-person.md
./world/encyclopedia/sloose-place.md
./world/encyclopedia/tollhouse-institution.md
./world/index.md
./world/log.md
./world/threads.md
  entities: 6 | pillars: 18 distinct incl. daily-life | threads: 24 rows for 6 entities
## world/ contents
--- ./world/encyclopedia/counterbook-artifact.md
---
kind: artifact
pillars: [language-names, governance-law, history-periodisation]
status: proposed
added: 2026-10-13
revised: 2026-10-13
---
# The Counterbook

## Canon
- proposed: The Counterbook is two columns: the name, and the mouth that spent it, with the tide it went out on.
- proposed: A spending is struck with a vertical line. A horizontal stroke is a return, and only three have ever been paid for.
- proposed: Writing a name spends nothing, which is the entire basis of every fortune in Sloose.
- proposed: A child's age is told in names lost — "three spent", "still full" — because birthdays are a thing the water does not keep.
- proposed: History is counted in Counterbook volumes; the ninth is unbound because its clerk could not sign his own name.
- proposed: Locals say a name has gone under; the book writes *spent*. The difference in wording wins appeals.

## Open questions
- T-005 whether a written name and a spoken name are the same name
- T-006 what the book does with two people spending one name at one tide
- T-007 who took the first page, and why both banks agree it was the other
- T-008 what a return actually costs, given three have been bought

## Links
- [[tollhouse-institution]]
- [[sloose-place]]
- [[mouth-rent-custom]]

--- ./world/encyclopedia/ebb-side-conflict.md
---
kind: conflict
pillars: [conflicts-tensions, social-structure, faith-myth]
status: proposed
added: 2026-10-13
revised: 2026-10-13
---
# The Ebb Side

## Canon
- proposed: Highbank holds the wrong side is the water's and moves with the tide; Lowbank holds it is the bank's, fixed since the founding.
- proposed: Both halves pay for the water-table and neither trusts it, which the Tollhouse calls revenue.
- proposed: Oaths are sworn on the canal rather than on a name, on the grounds that water cannot be spent twice.
- proposed: Once a year the Lowbank rows over at the turn and shouts every name it has left, and the Tollhouse files it as weather.
- proposed: The saint of the spent is Over-Wet, who drowned speaking and is asked for nothing, because nothing can be given back.
- proposed: Bank is settled at weddings: whoever is marrying that week gets to say which side is wrong.

## Open questions
- T-017 who profits from the four minutes when table and water disagree
- T-018 what the shouting festival is really about
- T-019 whose word ends a bank dispute when the recorder is absent
- T-020 what is failing this month that was quiet last tide

## Links
- [[sloose-place]]
- [[tollhouse-institution]]
- [[counterbook-artifact]]
- [[ovidge-sarn-person]]

--- ./world/encyclopedia/mouth-rent-custom.md
---
kind: custom
pillars: [economy-trade, daily-life, language-names]
status: proposed
added: 2026-10-13
revised: 2026-10-13
---
# The Mouth-Rent

## Canon
- proposed: Mouth-rent is the trade of being read a name you can no longer say, conducted on the Wetbridge steps at the turn.
- proposed: The polite price of being read to is a meal; the rude price is a name of the hearer's own, held in pledge.
- proposed: Hire-mouths wear a copper lip-ring, so a stranger knows whose mouth is rented and whose is still owed.
- proposed: A wedding needs one name said aloud by both sides at the turn, which is why nobody in Sloose marries rich.
- proposed: Full-mouths who have never spent anything sell mornings by the hour and are treated by law as a public utility.
- proposed: A spent man is called by trade and street; a spent woman by her husband's sayable name, which the divorce courts hate.

## Open questions
- T-013 what leaves Sloose that was never meant to
- T-014 how a hire-mouth repeats a name without spending it
- T-015 what the steps do when paper runs out before mouths do
- T-016 what a child calls a parent whose name it spent

## Links
- [[counterbook-artifact]]
- [[sloose-place]]
- [[ovidge-sarn-person]]

--- ./world/encyclopedia/ovidge-sarn-person.md
---
kind: person
pillars: [want-vs-need, formative-past, relationships, contradictions, voice-attention, competence-failure]
status: proposed
added: 2026-10-13
revised: 2026-10-13
---
# Ovidge Sarn, Full-Mouth

## Canon
- proposed: Ovidge Sarn has spent nothing in thirty-one years and is the only person in Sloose a stranger can ask the time of day from.
- proposed: She was licensed a full-mouth at twelve by a magistrate who wanted the fee, so her name is on the register twice.
- proposed: Her mother sold the name Ovidge at auction on the Wetbridge steps and has never explained it to anyone still living.
- proposed: Her brother cannot say her name, having spent it at fourteen on the wrong bank, and calls her Sarn to her face.
- proposed: She hears a wrong-side name spoken and looks at the speaker's mouth before she looks at their face.
- proposed: She says the whole roll of the spent in ninety seconds, which is a fairground trick and, in court, a crime.
- proposed: She charges the spent nothing and the rich the same nothing, and lives on what both feel obliged to leave her.

## Open questions
- T-021 what Ovidge says she wants against what would actually end it
- T-022 which scene she tells in the third person
- T-023 whose opinion settles her, and whether that person was ever on the same bank as her
- T-024 what she demands of the spent that she excuses in herself this week

## Links
- [[mouth-rent-custom]]
- [[tollhouse-institution]]
- [[counterbook-artifact]]
- [[ebb-side-conflict]]
- [[sloose-place]]

--- ./world/encyclopedia/sloose-place.md
---
kind: place
pillars: [geography-routes, ecology-resources, daily-life]
status: proposed
added: 2026-10-13
revised: 2026-10-13
---
# Sloose

## Canon
- proposed: Sloose is one city cut by the Neth, a tidal canal that reverses twice a day and changes which bank is wrong.
- proposed: Four bridges cross the Neth; Wetbridge is the only one with a legal floor, and the Tollhouse owns that floor.
- proposed: The water-table is published every eleven days and is wrong by about four minutes at each turn.
- proposed: Nobody swims the Neth. A swimmer caught at the turn loses every name in their mouth at once and is fished out polite.
- proposed: Lowbank breakfast is eel broth and black bread, drunk standing; sitting down is where the writ-clerks wait and it costs.
- proposed: Paper comes from the Neth's reeds, cut at the last autumn tide, which is why the Counterbook runs short by spring.

## Open questions
- T-001 which bank is the wrong one at what minute of the turn
- T-002 who maintains the four bridges, and how badly
- T-003 what the ferry takes from someone with no names left
- T-004 what Sloose eats when the reed cut fails

## Links
- [[counterbook-artifact]]
- [[tollhouse-institution]]
- [[mouth-rent-custom]]
- [[ebb-side-conflict]]

--- ./world/encyclopedia/tollhouse-institution.md
---
kind: institution
pillars: [power-systems, governance-law, secrets]
status: proposed
added: 2026-10-13
revised: 2026-10-13
---
# The Tollhouse

## Canon
- proposed: The Tollhouse forbids nothing and records everything; the loss happens in the mouth before the ink dries.
- proposed: Recorders read the ledger aloud from the Well Room, a shaft open to the canal, which is neither bank and so is free.
- proposed: No recorder has ever had a name entered against them; the blank column is the seal of office and the reason for the riots.
- proposed: You may buy an extract about yourself at four copper a line, which is the only way anyone in Sloose learns what they have lost.
- proposed: The Tollhouse keeps no guard. It publishes the water-table, and every argument in the city is about four minutes of that paper.
- proposed: Its ledgers are bound in reed paper from the autumn cut, so the book runs short in spring and spendings go uncounted until June.

## Open questions
- T-009 what the law cannot do at any price, with a full ledger
- T-010 who enforces a spending when the recorder has been bought
- T-011 what happens in the uncounted weeks between the paper running out and the new cut
- T-012 which recorder's name is actually in the book, and who put it there

## Links
- [[counterbook-artifact]]
- [[sloose-place]]
- [[ebb-side-conflict]]
- [[ovidge-sarn-person]]

--- ./world/index.md
---
world: sloose
sessions: 1
last_date: 2026-10-13
tunables:
  words_per_turn: 170
  texture_cadence: 4
  reads_per_turn: 3   # a tripwire, not a ration: needing more means you are scoring from files
  beat_budget: 45     # words per labelled beat, so one bloated beat cannot eat the whole turn
  option_words: 18    # per candidate option, counting the option, not the '- steady -' markup
  memo_item_words: 45
  sarcasm: on
  weight_gap: 1.0
  weight_hook: 1.0
  weight_contradiction: 1.5
  lopsidedness_floor: 0.6
  turns_per_session: 12
---
# Sloose — encyclopedia index

Derived from `encyclopedia/*.md`. If counts disagree with the entity files, rebuild from them —
the entity files are authoritative, never this table.

Seeded 2026-10-13 from the writer's premise: a canal city where a name spoken on the wrong side of the
water is spent for good, anywhere, ever, and a tollhouse that keeps the ledger of who spent what. Every
canon line is `proposed:` — a hypothesis, not canon. `established:` appears only after the writer answers.

## Pillar coverage
| pillar | entries | established | proposed | status |
|---|---|---|---|---|
| geography-routes | 1 | 0 | 6 | all-proposed |
| ecology-resources | 1 | 0 | 6 | all-proposed |
| history-periodisation | 1 | 0 | 6 | all-proposed |
| social-structure | 1 | 0 | 6 | all-proposed |
| power-systems | 1 | 0 | 6 | all-proposed |
| governance-law | 2 | 0 | 12 | all-proposed |
| economy-trade | 1 | 0 | 6 | all-proposed |
| faith-myth | 1 | 0 | 6 | all-proposed |
| language-names | 2 | 0 | 12 | all-proposed |
| daily-life | 2 | 0 | 12 | all-proposed |
| conflicts-tensions | 1 | 0 | 6 | all-proposed |
| want-vs-need | 1 | 0 | 7 | all-proposed |
| formative-past | 1 | 0 | 7 | all-proposed |
| relationships | 1 | 0 | 7 | all-proposed |
| contradictions | 1 | 0 | 7 | all-proposed |
| secrets | 1 | 0 | 6 | all-proposed |
| competence-failure | 1 | 0 | 7 | all-proposed |
| voice-attention | 1 | 0 | 7 | all-proposed |

Every pillar is empty of canon, so every `gap_weight` is 3 and scoring cannot separate them yet. Until
the first answer lands, the texture window and `threads.md` choose the question.

## Entities
| slug | kind | pillars | status | hooks |
|---|---|---|---|---|
| counterbook-artifact | artifact | language-names, governance-law, history-periodisation | proposed | 3 |
| ebb-side-conflict | conflict | conflicts-tensions, social-structure, faith-myth | proposed | 4 |
| mouth-rent-custom | custom | economy-trade, daily-
--- ./world/log.md
# Sloose — session log

## 2026-10-13 (session 1)
- turn: 1 · provoked: consequence · targeted: daily-life
- seeded: 6 entities, 24 threads, 0 established lines. Premise from the writer (canal city, names spent by the wrong bank, a tollhouse ledger); mechanics, names and consequences from the skill, all of it `proposed:` and veto-able.

--- ./world/threads.md
# Sloose — open threads

One row per thread. `status: open` feeds the scoreboard; `parked` stays visible; `resolved` points at the entity that absorbed it.

| id | the question, answerable in one sentence | asked-by | pillars | hook | status | spawned |
|---|---|---|---|---|---|---|
| T-001 | which bank is the wrong one at what minute of the turn | skill | geography-routes, governance-law | the water-table decides a sentence | open | [[sloose-place]] |
| T-002 | who maintains the four bridges, and how badly | skill | geography-routes, economy-trade | Wetbridge's floor is the city's argument | open | [[sloose-place]] |
| T-003 | what the ferry takes from someone with no names left | skill | economy-trade, daily-life | the ferryman cannot be called | open | [[sloose-place]] |
| T-004 | what Sloose eats when the reed cut fails | skill | ecology-resources, daily-life | paper and porridge come from the same marsh | open | [[sloose-place]] |
| T-005 | whether a written name and a spoken name are the same name | skill | language-names, power-systems | every fortune in the city leans on it | open | [[counterbook-artifact]] |
| T-006 | what the book does with two people spending one name at one tide | skill | language-names, governance-law | one column, two mouths | open | [[counterbook-artifact]] |
| T-007 | who took the first page, and why both banks blame the other | skill | history-periodisation, governance-law | the era starts at a torn leaf | open | [[counterbook-artifact]] |
| T-008 | what a return costs, given only three have ever been bought | skill | power-systems, economy-trade | three paid horizontal strokes, no receipts | open | [[counterbook-artifact]] |
| T-009 | what the law cannot do at any price | skill | governance-law, power-systems | the ledger is a witness, not a weapon | open | [[tollhouse-institution]] |
| T-010 | who enforces a spending when the recorder has been bought | skill | governance-law, social-structure | both banks claim the office | open | [[tollhouse-institution]] |
| T-011 | what happens in the uncounted weeks before the new paper | skill | ecology-resources, conflicts-tensions | names go spending that no book will hold | open | [[tollhouse-institution]] |
| T-012 | which recorder's name is actually in the book, and who wrote it | skill | secrets, governance-law | the blank column is not blank | open | [[tollhouse-institution]] |
| T-013 | what leaves Sloose that was never meant to | skill | economy-trade, geography-routes | 
