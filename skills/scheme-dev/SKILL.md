---
name: scheme-dev
description: Allowed built-ins, conventions, run commands and a self-review checklist for writing and testing the Group 82 Scheme solutions (code/82_q3.rkt, code/82_q4.rkt) in Racket 8.x with #lang racket/base.
---

# scheme-dev

Use this skill for any work on the Scheme problems (S1, S2) and their tests
(`tests/test_q3.rkt`, `tests/test_q4.rkt`).

## 1. Environment

- Racket 8.x.
- Every solution file starts with exactly `#lang racket/base` on line 1. No other
  `#lang`, and no `require`.
- Solution files: `code/82_q3.rkt` (S1), `code/82_q4.rkt` (S2).
- Test files: `tests/test_q3.rkt`, `tests/test_q4.rkt`.

## 2. How to run

```sh
racket code/82_q3.rkt
racket code/82_q4.rkt
```

- Solution files contain **only definitions**. Running a file on its own must print
  **nothing**.
- The grader appends its own calls to the end of the file. In a Racket module **every
  top-level expression that is not a definition gets its value printed**, so a stray
  `(foo t1)` or even `'x` at top level breaks grading.
- A solution file has no `provide`, so a test cannot `require` it. Test the way the
  grader does: append the calls to a **temporary copy** of the solution and run that copy.
  Never edit the solution file to add calls.

  ```sh
  cp code/82_q3.rkt /tmp/run_q3.rkt
  echo "(print-inorder '(4 (2 () ()) (6 () ())))" >> /tmp/run_q3.rkt
  racket /tmp/run_q3.rkt                 # expected: (2 4 6)

  cp code/82_q4.rkt /tmp/run_q4.rkt
  echo "(print-insert-result)" >> /tmp/run_q4.rkt
  echo "42 ((1 2) (3 4 5) (6) ()) 3" | racket /tmp/run_q4.rkt
  ```

## 3. Allowed built-ins (exact allowlist)

Only these may appear in a solution file:

| Group | Allowed |
|---|---|
| Binding / definition | `define`, `lambda`, `let`, `let*`, `letrec`, named `let` |
| Control | `if`, `cond` (with `else`), `and`, `or`, `not`, `begin` |
| Quoting | `quote` (written `'`) |
| Pairs / lists | `cons`, `car`, `cdr`, `list`, every `c[ad]{2,4}r` (`cadr`, `cddr`, `caddr`, `cdddr`, `cadddr`, `cddddr`, `caar`, `cdar`, ...) |
| Predicates | `null?`, `pair?`, `eq?` |
| Lookup | `assq`, `assoc` |
| Arithmetic / comparison | `+`, `-`, `*`, `<`, `>`, `<=`, `>=`, `=`, `max` |
| Output | `display`, `newline` |
| Input (**S2 only**) | `read` |

Anything not in this table is forbidden, even if `racket/base` provides it.

## 4. Forbidden (common traps)

- Mutation: `set!`, `set-car!`, `set-cdr!`, `set-box!`, and any `!` procedure.
- Data types: vectors, hash tables, **strings** (no `"..."` literals, no `string-append`,
  no `format`, no `printf`), boxes, structs.
- Loops: `do`, `for`, `for/list`, `for-each`, and the rest of the `for` family.
- List library: `length`, `append`, `reverse`, `map`, `filter`, `foldl`, `foldr`,
  `member`, `memq`, `list-ref`, `list-tail`, `apply`, `last`, `remove`.
- Predicates and others not listed: `equal?`, `eqv?`, `list?`, `number?`, `symbol?`,
  `zero?`, `add1`, `sub1`, `when`, `unless`, `case`, `else` outside `cond`, `void`,
  `error`, `writeln`, `print`, `write`, `printf`.
- Any `require`, `provide` or `module` form.

When one of these is needed, write a helper from the allowed built-ins, e.g.
`my-length`, `my-reverse`, `my-append`, `my-map`. Use the `my-` prefix so a stray
library name is easy to grep for.

## 5. Coding conventions

- Names are `kebab-case`: `print-inorder`, `count-leaves`, `my-reverse`.
  Predicates end in `?` (`leaf?`, `len-ok?`). Accumulators are named `acc`.
- Every function has a header comment with its contract and a **recursive reading**:

  ```racket
  ;; (my-length lst) -> number
  ;; The length of () is 0; the length of (x . rest) is 1 + the length of rest.
  ;; Tail recursive: walks lst once, carrying the count in acc.
  (define (my-length lst)
    (let loop ((lst lst) (acc 0))
      (if (null? lst)
          acc
          (loop (cdr lst) (+ acc 1)))))
  ```

- One `define` per function. Put helpers above the functions that use them.
- Pass all state through arguments. No mutation and no global accumulators.
- **Tail recursion with accumulators** for anything that walks a list's top level
  (lengths, copies, maps over 10,000-element lists): use a named `let` with an `acc`,
  build the result in reverse, then `my-reverse` it once at the end, or build it
  backwards on purpose.
- Recursion **into** sublists (nesting depth) may stay non-tail. A depth of 100 is
  shallow. Recurse into `car` normally and walk `cdr` with the tail-recursive loop.
- Tree functions (S1): recurse on `cadr` (left) and `caddr` (right) and visit the left
  subtree first. An accumulator traversal (pass the result list so far) avoids an
  append helper.
- Name the parts of a tree node with small helpers (`node-value`, `node-left`,
  `node-right`, `empty-tree?`) defined only with `car`, `cadr`, `caddr` and `null?`.

## 6. Self-review checklist (apply before every answer)

1. Line 1 is `#lang racket/base`, and there is nothing at top level except `define` forms
   and comments.
2. `racket code/82_qN.rkt` prints **nothing**.
3. **Allowlist scan:** every identifier in the file is a parameter, a local variable,
   one of our own `define`d names, or in the table in Section 3. Grep in particular for
   `length`, `append`, `reverse`, `map`, `filter`, `member`, `memq`, `list-ref`,
   `list-tail`, `equal?`, `set!`, `string`, `vector`, `hash`, `for`, `do`, `when`,
   `unless`, `null`, `empty`, `first`, `rest`, `add1`, `sub1`, `zero?`, `else` (only inside `cond`).
4. `read` appears only in S2.
5. Output uses only `display` and `newline`. Every printing function ends with exactly one
   `newline`. Printed lists look exactly like the spec, e.g. `(1 2 3)` and `()`.
6. Empty inputs are handled: the empty tree `()`, the empty list `()`, and `n = 0`.
7. Every recursion over a list's top level is tail recursive, and there is no quadratic
   repeated `my-append` or `my-length` inside a loop.
8. Numbers are compared with `=` and symbols with `eq?`. `eq?` is never used on numbers
   or lists.
9. The spec examples and our edge cases in `tests/test_qN.rkt` all pass, including a
   10,000-element list and depth-100 nesting for S2.

## 7. Known AI failure modes in Scheme

- **Reaching for forbidden built-ins:** `length`, `append`, `reverse`, `map`, `filter`,
  `equal?`, `list?`, `when`, `unless`, `add1` and `for-each` show up out of habit even
  when asked not to use them. Scan for them every time.
- **Top-level test calls left in the file:** example calls such as `(print-inorder t1)`
  or `(define t1 ...)` with prints at module level. Racket prints the value of every
  top-level expression, so loading the file produces output.
- **`#lang racket` instead of `#lang racket/base`**, or adding `require` lines.
- **Using strings for output:** `(display "(")`, `printf` or `format` to hand-build list
  syntax. Build a real list and `display` it once.
- **Non-tail recursion on long lists:** `(+ 1 (my-length (cdr lst)))` or a
  `(cons (f (car lst)) (my-map f (cdr lst)))` that grows the stack. Use an
  accumulator plus `my-reverse` for 10,000-element lists.
- **Quadratic append:** building a traversal with `(my-append left (cons v right))` at
  every node, or appending to the end of an accumulator inside a loop.
- **Measuring the length after insertion:** in S2 the length must come from the
  **original** list, before `x` is consed on.
- **Forgetting the top-level list or empty lists:** treating the outer list or `()`
  as a special case when the spec says they behave like any other list.
- **`eq?` on numbers or lists:** works on small integers by accident but is wrong in
  general. Use `=` for numbers.
- **Mixing up tree accessors:** `cadr` is the left subtree and `caddr` the right; `cddr`
  is a list holding the right subtree, not the subtree itself.
- **Missing the final `newline`**, or printing an extra blank line.
- **Symbols vs quoted data in tests:** writing `(a (b () ()) ...)` without a quote, which
  Racket tries to evaluate as a call.
