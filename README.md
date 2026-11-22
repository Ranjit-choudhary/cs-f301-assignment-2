# CS F301 Principles of Programming Languages — Assignment 2 (Group 82)

Logic and Functional Programming: two Prolog problems solved in SWI-Prolog 9.x
and two Scheme problems solved in Racket 8.x (`#lang racket/base`).

## Group 82 Members

| Name | ID | GitHub | Contribution |
|---|---|---|---|
| Ranjit Choudhary | `2023B1A71226H` | `Ranjit-choudhary` | Setup, `prolog-dev`, P1 (`82_q1.pl`, `P1_REPORT.md`) |
| Rishabh Singh | `2023B4A70721H` | `Rishabh-18117` | `scheme-dev`, P2 (`82_q2.pl`) |
| Ritwik Sethi | `2023B1A71385H` | `omnomnomm` | S1 (`82_q3.rkt`) |
| Arihant Rakhecha | `2023B1A70998H` | `Aru-150905` | S2 (`82_q4.rkt`) |

## Repository Structure

```
.
├── code/
│   ├── 82_q1.pl            P1: department assignment puzzle (Prolog)
│   ├── 82_q2.pl            P2: valid arithmetic equations (Prolog)
│   ├── 82_q3.rkt           S1: binary tree traversals (Racket)
│   └── 82_q4.rkt           S2: conditional insert into a nested list (Racket)
├── tests/
│   ├── test_q1.pl          plunit tests for P1
│   ├── test_q2.pl          plunit tests for P2
│   ├── test_q3.rkt         grader-style output tests and built-in audit for S1
│   └── test_q4.rkt         grader-style stdin/stdout tests and built-in audit for S2
├── skills/
│   ├── prolog-dev/SKILL.md conventions, rules and review checklist for the Prolog work
│   └── scheme-dev/SKILL.md allowed built-ins, conventions and checklist for the Scheme work
├── prompts/
│   ├── P1.md               prompts used for P1, word for word
│   ├── P2.md               prompts used for P2
│   ├── S1.md               prompts used for S1
│   └── S2.md               prompts used for S2
├── P1_REPORT.md            value of N for clues 1-8 and what it says about the puzzle
└── README.md
```

## Problems Overview

- **P1 — Department Assignment Puzzle** (`82_q1.pl`): each clue is a `clue(N, Solution)` clause;
  `solve/2` generates all distinct assignments and checks the active clues. `main/0` prints one
  solution of clues 1-8, `count_solutions/2` counts them (N = 3), and clue 9 makes the solution unique.
- **P2 — Valid Arithmetic Equation** (`82_q2.pl`): builds and evaluates expression trees over the
  numbers in order, with exact integer division only, and prints them in canonical form.
  Provides `generate_equation/2`, `all_equations/2` and `count_equations/2`.
- **S1 — Binary Tree Traversals** (`82_q3.rkt`): accumulator-based inorder, preorder and postorder
  traversals, plus `print-inorder`, `print-all-traversals` and `print-height-and-leaves`.
- **S2 — Conditional Insert** (`82_q4.rkt`): tail-recursive `my-length`, `my-reverse` and `my-map`;
  the higher-order `make-inserter`, `insert-if-short` (defined with `make-inserter`) and
  `print-insert-result`, which reads `x`, `lst` and `n` from standard input.

## How to Run & Test

All commands are run from the repository root.

### P1 (SWI-Prolog)

```sh
swipl -q -f code/82_q1.pl -g main -t halt
swipl -q -f code/82_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8], N), writeln(N)" -t halt
swipl -q -f code/82_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8,9], N), writeln(N)" -t halt
```

### P2 (SWI-Prolog)

```sh
swipl -q -f code/82_q2.pl -g "generate_equation([4,2,5,3], E), writeln(E)" -t halt
swipl -q -f code/82_q2.pl -g "all_equations([4,2,5,3], Es), writeln(Es)" -t halt
swipl -q -f code/82_q2.pl -g "count_equations([4,2,5,3], N), writeln(N)" -t halt
```

### S1 and S2 (Racket)

The Racket files contain only definitions, so running them directly prints nothing:

```sh
racket code/82_q3.rkt
racket code/82_q4.rkt
```

To try a function, append a call to a copy of the file (as the grader does):

```sh
cp code/82_q3.rkt /tmp/run_q3.rkt
echo "(print-all-traversals '(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ()))))" >> /tmp/run_q3.rkt
racket /tmp/run_q3.rkt

cp code/82_q4.rkt /tmp/run_q4.rkt
echo "(print-insert-result)" >> /tmp/run_q4.rkt
echo "42 ((1 2) (3 4 5) (6) ()) 3" | racket /tmp/run_q4.rkt
```

### Tests

```sh
swipl -q -g run_tests -t halt tests/test_q1.pl
swipl -q -g run_tests -t halt tests/test_q2.pl
racket tests/test_q3.rkt
racket tests/test_q4.rkt
```

Each command exits with status 0 when every test passes.
