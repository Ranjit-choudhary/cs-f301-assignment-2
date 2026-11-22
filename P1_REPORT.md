# P1 Report: Department Assignment Puzzle

## Value of N

```sh
swipl -q -f code/82_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8], N), print(N), nl" -t halt
```

```
3
```

**N = 3** for clues 1 to 8.

`count_solutions/2` counts with `aggregate_all(count, solve(Active, _), N)`. `solve/2` first builds a
complete assignment from three permutations (departments, languages, projects) and only then checks the
active clues. With no clues active it counts `count_solutions([], N)`, which gives N = 13824 = 24 × 24 × 24,
so every assignment is generated exactly once and none is counted twice.

## What N tells us about the puzzle

The puzzle is **under-constrained**: clues 1 to 8 do not have a unique solution. Three different
assignments satisfy all eight clues, so the clues cannot tell us who does what. `main/0` prints the first
of the three, but nothing in the clues makes that one "the" answer.

Every clue still does some work. Dropping any single clue gives more than 3 solutions, so none of the
eight is redundant. They are just not enough together:

| Clues used             | N  |
|------------------------|----|
| all of 1-8             | 3  |
| 1-8 without clue 1     | 4  |
| 1-8 without clue 2     | 6  |
| 1-8 without clue 3     | 13 |
| 1-8 without clue 4     | 12 |
| 1-8 without clue 5     | 9  |
| 1-8 without clue 6     | 7  |
| 1-8 without clue 7     | 5  |
| 1-8 without clue 8     | 16 |
| none                   | 13824 |

## The three solutions

| # | Alex | Ben | Carla | Dana |
|---|------|-----|-------|------|
| 1 | design, java, AI | development, javascript, web | research, c++, data | testing, python, embedded |
| 2 | design, java, embedded | development, javascript, web | testing, python, AI | research, c++, data |
| 3 | testing, python, embedded | development, javascript, web | design, java, AI | research, c++, data |

## How the solutions differ

What all three share:

- **Ben is fixed:** development, javascript, web in every solution.
- **The department-language pairs are fixed:** testing–python (clue 3), design–java (clue 5),
  development–javascript and research–c++. Each department always comes with the same language.
- **data always goes with research** (clue 8), and Ben's web project is fixed by clue 4.

What changes:

- **Who gets which department "bundle".** Alex, Carla and Dana share the design/java, testing/python
  and research/c++ bundles in three different ways:
  - Solution 1: Alex design, Carla research, Dana testing.
  - Solution 2: Alex design, Carla testing, Dana research.
  - Solution 3: Alex testing, Carla design, Dana research.
- **Who prefers AI and embedded.** AI goes to Alex in solution 1 and to Carla in solutions 2 and 3.
  Embedded goes to Dana (testing) in solution 1 and to Alex in solutions 2 and 3.

So the clues pin down the pairing of departments with languages and Ben's whole row. What they leave
open is how the remaining three bundles, and the AI/embedded projects, are spread over Alex, Carla and
Dana. A ninth clue has to break exactly this ambiguity to make the puzzle have a single solution.
