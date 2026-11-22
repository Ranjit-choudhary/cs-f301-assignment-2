---
name: prolog-dev
description: Conventions, run commands, hard rules and a self-review checklist for writing and testing the Group 82 Prolog solutions (code/82_q1.pl, code/82_q2.pl) in SWI-Prolog 9.x.
---

# prolog-dev

Use this skill for any work on the Prolog problems (P1, P2) and their tests
(`tests/test_q1.pl`, `tests/test_q2.pl`).

## 1. Environment

- SWI-Prolog 9.x.
- Solution files: `code/82_q1.pl`, `code/82_q2.pl`.
- Test files: `tests/test_q1.pl`, `tests/test_q2.pl`.

## 2. How to run

Run `main/0`:

```sh
swipl -q -f code/82_q1.pl -g main -t halt
```

Run any other goal:

```sh
swipl -q -f code/82_q1.pl -g "<goal>" -t halt
```

Examples:

```sh
swipl -q -f code/82_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8], N), print(N), nl" -t halt
swipl -q -f code/82_q2.pl -g "all_equations([4,2,5,3], Es), print(Es), nl" -t halt
```

Load the file and look for warnings (singletons, discontiguous clauses) before running any test:

```sh
swipl -q -f code/82_q2.pl -t halt
```

A clean load prints nothing.

## 3. Hard rules (never break these)

- **No `halt/0`** anywhere in a solution file. The grader passes `-t halt` itself.
- **No `:- initialization(...)` directive** of any kind.
- **No global state:** no `assert/1`, `asserta/1`, `assertz/1`, `retract/1`,
  `retractall/1`, `b_setval/2`, `nb_setval/2`, and no `b_getval/2` or `nb_getval/2` either.
- **Allowed libraries only:** `lists`, `apply`, `yall`, `aggregate`.
  Write any `use_module` as `:- use_module(library(lists)).` and so on. Load nothing else.
- **No stray stdout output.** Only print what the problem specifies (e.g. `main/0`
  in P1). Every other predicate prints nothing. Remove all debug `format/2`,
  `print/1` and `writeln/1` calls before committing.
- Solution files contain **only definitions** (plus allowed `use_module` directives).
- P2: **never build a string and parse it back** (`term_string/2`, `term_to_atom/2`,
  `read_term/2` on a string) to evaluate an expression. Evaluate the expression tree directly.

## 4. Coding conventions

- Predicate and variable-role names are `snake_case`: `count_solutions/2`,
  `split_list/3`, `canonical_string/2`.
- Every predicate has a header comment with a mode declaration and a declarative reading:

  ```prolog
  % count_solutions(+Active, -N):
  %   N is the number of complete assignments that satisfy every clue in Active
  %   and ignore all other clues.
  count_solutions(Active, N) :-
      ...
  ```

  Mode markers: `+` input (bound), `-` output (unbound), `?` either.
- Read each clause as a logical statement ("Head holds if Body holds"). The comment
  says *what* is true, not *how* the search runs.
- One clause per line group. Keep all clauses of a predicate together (no
  discontiguous definitions).
- Use `_` or `_Name` for variables that are deliberately unused.
- Prefer `findall/3` or `aggregate_all/3` for counting and collecting, and `msort/2` or
  `sort/2` when the order must be fixed.
- Put helper predicates directly below the predicate that uses them.

## 5. Self-review checklist (apply before every answer)

1. **Loads cleanly:** `swipl -q -f <file> -t halt` prints no warnings or errors.
2. **Singleton variables:** no singleton warnings. Every named variable is used at
   least twice or is renamed to `_`/`_Name`.
3. **Choicepoints:** deterministic predicates leave no unwanted choicepoints. Check
   with the goal followed by `; true` in the toplevel, or by counting solutions with
   `findall`. Predicates that must yield exactly one answer do not yield duplicates
   on backtracking.
4. **Atom vs string types:** values are of the exact type the spec asks for:
   - P1 uses **atoms** (`'Alex'`, `'c++'`, `'AI'`, `research`).
   - P2 returns **SWI-Prolog strings** (`"4*2=5+3"`), not atoms and not code lists.
     Check with `string(E)`.
5. **Arithmetic:** `is/2` for evaluation, `=:=` / `=\=` for numeric comparison,
   `=`/`==` only for structural or term comparison.
6. **Failure behaviour:** predicates that should fail do fail. They do not loop, throw or
   print. Test the empty list and one-element inputs.
7. **Hard rules:** grep the file for `halt`, `initialization`, `assert`, `retract`,
   `setval` and any `use_module` outside the allowed set.
8. **Output format:** byte-exact against the examples in the spec (spacing, commas,
   brackets, trailing newline).
9. **Tests pass:** run the matching `tests/test_qN.pl` and check that every spec example passes.

## 6. Known AI failure modes in Prolog

- **Left recursion loops:** writing `expr(E) :- expr(L), ...` or recursing on an
  unbounded or growing structure before consuming input. This loops forever. Always
  recurse on a strictly smaller piece (e.g. split the number list first, then recurse
  on each non-empty part).
- **Atom vs SWI-Prolog string confusion:** in SWI-Prolog 7+ double quotes make a
  **string**, not a code list or an atom. Results can come out as atoms
  (`atom_concat/3`) when a string was required, `"abc" == abc` is false, and code lists
  get mixed in. Use `string_concat/3`, `format(string(S), ...)`, `number_string/2` or
  `atomics_to_string/2` when a string is required.
- **Missing exact integer division checks:** using `/` freely, which gives floats or
  rationals, or dividing by zero. Before any division require
  `B =\= 0, 0 =:= A mod B` and then compute `V is A // B`. Watch the sign: with
  negative operands, check exactness with `mod`/`rem` and keep the result consistent
  with true integer division.
- **Using `=` instead of `=:=`:** `X = 2+3` unifies `X` with the term `2+3` and does not
  compute 5. `2+3 = 5` fails. Use `is/2` to compute and `=:=` to compare values.
- **`is/2` on unbound variables:** calling `X is A + B` before `A` or `B` are bound
  raises an instantiation error. Generate first, then evaluate.
- **Negation on non-ground terms:** `\+` and `\=` used before the variables are bound
  give wrong answers. Apply them only after the relevant values are fixed (e.g. check
  clues on a fully filled-in solution).
- **Duplicates from multiple derivations:** the same answer reached by different
  paths. Use `sort/2` (removes duplicates) when a duplicate-free sorted list is required.
- **Forgotten `use_module` or banned libraries:** relying on autoloaded predicates from
  libraries outside the allowed set (e.g. `clpfd`, `strings`, `dcg/basics`).
- **Hard-coding answers:** writing out the puzzle solution instead of deriving it from
  the clue clauses.
- **Debug output left in:** leftover `writeln/1` or `format/2` calls that break exact-output
  grading.
