---
world: <kebab-name>
sessions: 0
last_date: <YYYY-MM-DD>
tunables:
  words_per_turn: 170
  texture_cadence: 4
  reads_per_turn: 3   # a tripwire, not a ration: needing more means you are scoring from files
  beat_budget: 60     # words per labelled beat; measured, the fat lives in reflect and write back
  option_words: 18    # per candidate option, counting the option, not the '- steady -' markup
  memo_item_words: 45 # per memo bullet, not the memo's total: one item turning into a paragraph is the
  turns_per_session: 12   # the close trigger; counted from the machine lines in log.md
  sarcasm: on
  weight_gap: 1.0
  weight_hook: 1.0
  weight_contradiction: 1.5
  lopsidedness_floor: 0.6
---
# <World title> — encyclopedia index

Derived from `encyclopedia/*.md`. If counts disagree with the entity files, rebuild from them —
the entity files are authoritative, never this table.

Counting rule: `entries` = files whose `pillars[]` name the pillar; `established` = `- established:`
bullets in those files, excluding any carrying `supersedes`; `proposed` = `- proposed:` bullets;
`status` = empty | all-proposed | thin (<3 established) | substantial. Per entity, `hooks` = inbound
`[[slug]]` links from other files.

## Pillar coverage
| pillar | entries | established | proposed | status |
|---|---|---|---|---|
| geography-routes | 0 | 0 | 0 | empty |
| ecology-resources | 0 | 0 | 0 | empty |
| history-periodisation | 0 | 0 | 0 | empty |
| social-structure | 0 | 0 | 0 | empty |
| power-systems | 0 | 0 | 0 | empty |
| governance-law | 0 | 0 | 0 | empty |
| economy-trade | 0 | 0 | 0 | empty |
| faith-myth | 0 | 0 | 0 | empty |
| language-names | 0 | 0 | 0 | empty |
| daily-life | 0 | 0 | 0 | empty |
| conflicts-tensions | 0 | 0 | 0 | empty |
| want-vs-need | 0 | 0 | 0 | empty |
| formative-past | 0 | 0 | 0 | empty |
| relationships | 0 | 0 | 0 | empty |
| contradictions | 0 | 0 | 0 | empty |
| secrets | 0 | 0 | 0 | empty |
| competence-failure | 0 | 0 | 0 | empty |
| voice-attention | 0 | 0 | 0 | empty |

## Entities
| slug | kind | pillars | status | hooks |
|---|---|---|---|---|
| example-river-place | place | geography-routes, ecology-resources | established | 0 |

## Texture digest
- (banal details, newest first: food, mending, swearing, queueing, what stinks)

## Hottest threads
- T-001 <the open question with the best score>

## Log line shape (per turn, appended)

- turn: <n> · provoked: <one or more of the five engagement types, plus review on a memo turn> · targeted: <pillar>
- decided: <what the writer settled>

Exactly one machine line per turn that happened, in order - including the close turn, whose line goes down before
its recap bullets. Prose lines are for the writer; the machine line is for
the next turn, which cannot remember otherwise.

`targeted:` is not decoration. The rule "never the same pillar in consecutive turns when another
candidate reaches `lopsidedness_floor`" cannot be evaluated without it, and by turn five the previous
turn's target is no longer in the transcript. Write it every turn.
