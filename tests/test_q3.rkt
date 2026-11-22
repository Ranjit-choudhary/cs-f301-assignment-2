#lang racket
;; test_q3.rkt - tests for code/82_q3.rkt (S1)
;;
;; Run from anywhere:
;;   racket tests/test_q3.rkt
;;
;; The solution file has no provide, so it is tested the way the grader runs
;; it: for every test case the solution source is copied to a temporary
;; file, the test calls are appended to the end, the copy is run with
;; racket, and its standard output is compared with the expected text.
;; The solution file itself is never modified.
;;
;; The file also audits the solution source: every symbol must be on the
;; S1 allowlist or be a name the solution defines itself, and none of the
;; commonly misused built-ins may appear anywhere.

(require racket/runtime-path)

(define-runtime-path solution-path "../code/82_q3.rkt")

(define racket-exe
  (let ([self (find-system-path 'exec-file)])
    (or (find-executable-path self) self)))

(define solution-source (file->string solution-path))

;; ---------------------------------------------------------------------
;; Running the solution like the grader
;; ---------------------------------------------------------------------

;; (run-with-calls calls) -> (values exit-code stdout stderr)
;; Runs a copy of the solution with the text `calls` appended.
(define (run-with-calls calls)
  (define tmp (make-temporary-file "q3-test-~a.rkt"))
  (call-with-output-file tmp #:exists 'truncate
    (lambda (out)
      (write-string solution-source out)
      (write-string "\n" out)
      (write-string calls out)
      (write-string "\n" out)))
  (define out (open-output-string))
  (define err (open-output-string))
  (define code
    (parameterize ([current-output-port out]
                   [current-error-port err])
      (system*/exit-code racket-exe tmp)))
  (delete-file tmp)
  (values code
          (string-replace (get-output-string out) "\r\n" "\n")
          (get-output-string err)))

(define tree-defs #<<END
(define t1 '(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ()))))
(define t2 '(1 () (2 () (3 () ()))))
(define t3 '(a (b () ()) (c () ())))
(define single '(9 () ()))
(define left-skewed '(4 (3 (2 (1 () ()) ()) ()) ()))
(define right-skewed '(1 () (2 () (3 () (4 () ())))))
(define (build-left n acc) (if (= n 0) acc (build-left (- n 1) (list n acc '()))))
(define (build-right n acc) (if (= n 0) acc (build-right (- n 1) (list n '() acc))))
(define deep-left (build-left 10000 '()))
(define deep-right (build-right 10000 '()))
END
  )

;; Each case: name, calls appended after the tree definitions, expected stdout.
(define cases
  (list
   ;; --- examples from the assignment ---
   (list "t1 print-inorder" "(print-inorder t1)" "(1 2 3 4 5 6 7)\n")
   (list "t1 print-all-traversals" "(print-all-traversals t1)"
         "(1 2 3 4 5 6 7)\n(4 2 1 3 6 5 7)\n(1 3 2 5 7 6 4)\n")
   (list "t1 print-height-and-leaves" "(print-height-and-leaves t1)" "(3 4)\n")
   (list "t2 print-all-traversals" "(print-all-traversals t2)"
         "(1 2 3)\n(1 2 3)\n(3 2 1)\n")
   (list "t2 print-height-and-leaves" "(print-height-and-leaves t2)" "(3 1)\n")
   (list "t3 print-inorder" "(print-inorder t3)" "(b a c)\n")
   (list "t3 print-all-traversals" "(print-all-traversals t3)"
         "(b a c)\n(a b c)\n(b c a)\n")
   (list "t3 print-height-and-leaves" "(print-height-and-leaves t3)" "(2 2)\n")
   (list "empty print-inorder" "(print-inorder '())" "()\n")
   (list "empty print-all-traversals" "(print-all-traversals '())" "()\n()\n()\n")
   (list "empty print-height-and-leaves" "(print-height-and-leaves '())" "(0 0)\n")
   ;; --- single node ---
   (list "single print-inorder" "(print-inorder single)" "(9)\n")
   (list "single print-all-traversals" "(print-all-traversals single)"
         "(9)\n(9)\n(9)\n")
   (list "single print-height-and-leaves" "(print-height-and-leaves single)" "(1 1)\n")
   ;; --- left-skewed: every node has only a left child ---
   (list "left-skewed print-inorder" "(print-inorder left-skewed)" "(1 2 3 4)\n")
   (list "left-skewed print-all-traversals" "(print-all-traversals left-skewed)"
         "(1 2 3 4)\n(4 3 2 1)\n(1 2 3 4)\n")
   (list "left-skewed print-height-and-leaves" "(print-height-and-leaves left-skewed)"
         "(4 1)\n")
   ;; --- right-skewed: every node has only a right child ---
   (list "right-skewed print-inorder" "(print-inorder right-skewed)" "(1 2 3 4)\n")
   (list "right-skewed print-all-traversals" "(print-all-traversals right-skewed)"
         "(1 2 3 4)\n(1 2 3 4)\n(4 3 2 1)\n")
   (list "right-skewed print-height-and-leaves" "(print-height-and-leaves right-skewed)"
         "(4 1)\n")
   ;; --- uneven tree: one leaf deep on the left, one shallow on the right ---
   (list "uneven print-all-traversals"
         "(print-all-traversals '(1 (2 (3 () ()) ()) (4 () ())))"
         "(3 2 1 4)\n(1 2 3 4)\n(3 2 4 1)\n")
   (list "uneven print-height-and-leaves"
         "(print-height-and-leaves '(1 (2 (3 () ()) ()) (4 () ())))" "(3 2)\n")
   ;; --- deep skewed trees (10,000 levels) ---
   (list "deep-left print-height-and-leaves" "(print-height-and-leaves deep-left)"
         "(10000 1)\n")
   (list "deep-right print-height-and-leaves" "(print-height-and-leaves deep-right)"
         "(10000 1)\n")
   ;; --- several calls in a row: each ends with exactly one newline ---
   (list "consecutive calls"
         "(print-inorder t3) (print-height-and-leaves t3) (print-inorder '())"
         "(b a c)\n(2 2)\n()\n")))

;; ---------------------------------------------------------------------
;; Source audit
;; ---------------------------------------------------------------------

;; Exact Scheme allowlist for S1 (read is S2 only).
(define allowlist
  '(define lambda let let* letrec if cond else and or not begin quote
     cons car cdr list
     caar cadr cdar cddr
     caaar caadr cadar caddr cdaar cdadr cddar cdddr
     caaaar caaadr caadar caaddr cadaar cadadr caddar cadddr
     cdaaar cdaadr cdadar cdaddr cddaar cddadr cdddar cddddr
     null? pair? eq? assq assoc
     + - * < > <= >= = max display newline))

;; Built-ins that must not appear anywhere in the solution.
(define forbidden
  '(first second third rest empty empty? zero? add1 sub1 when unless
     displayln printf equal? list? values let-values match provide
     append reverse map
     set! length filter member memq list-ref list-tail require read
     vector hash string do for for-each foldl foldr apply))

;; All datums of the solution after the #lang line.
(define solution-datums
  (with-input-from-file solution-path
    (lambda ()
      (read-line)
      (let loop ([acc '()])
        (define d (read))
        (if (eof-object? d) (reverse acc) (loop (cons d acc)))))))

;; Every symbol occurring anywhere in a datum.
(define (symbols-in d)
  (cond [(symbol? d) (list d)]
        [(pair? d) (append (symbols-in (car d)) (symbols-in (cdr d)))]
        [else '()]))

;; Names the solution defines itself: function names and their parameters.
(define (defined-names d)
  (match d
    [(list 'define (cons name params) _ ...) (cons name params)]
    [(list 'define (? symbol? name) _ ...) (list name)]
    [_ '()]))

(define used-symbols (remove-duplicates (append-map symbols-in solution-datums)))
(define own-names (remove-duplicates (append-map defined-names solution-datums)))

(define not-allowed
  (filter (lambda (s) (not (or (memq s allowlist) (memq s own-names)))) used-symbols))

(define forbidden-found
  (filter (lambda (s) (memq s used-symbols)) forbidden))

;; Top-level forms other than define (these would run, and possibly print,
;; when the file is loaded). Comments are not datums, so they are ignored.
(define top-level-non-definitions
  (filter (lambda (d) (not (and (pair? d) (eq? (car d) 'define)))) solution-datums))

;; ---------------------------------------------------------------------
;; Run everything
;; ---------------------------------------------------------------------

(define failures 0)
(define passed 0)

(define (check! name ok? detail)
  (if ok?
      (begin (set! passed (add1 passed)) (printf "PASS  ~a\n" name))
      (begin (set! failures (add1 failures)) (printf "FAIL  ~a\n      ~a\n" name detail))))

;; Loading the solution alone: exit 0, no output at all.
(let-values ([(code out err) (run-with-calls "")])
  (check! "load alone: exit 0 and no output"
          (and (= code 0) (string=? out "") (string=? err ""))
          (format "exit ~a, stdout ~s, stderr ~s" code out err)))

(check! "first line is #lang racket/base"
        (string-prefix? solution-source "#lang racket/base\n")
        (format "starts with ~s" (substring solution-source 0 (min 20 (string-length solution-source)))))

(check! "only define forms at top level"
        (null? top-level-non-definitions)
        (format "found ~s" top-level-non-definitions))

(check! "every symbol is allowed or defined by the solution"
        (null? not-allowed)
        (format "not allowed: ~s" not-allowed))

(check! "no forbidden built-ins"
        (null? forbidden-found)
        (format "found: ~s" forbidden-found))

(for ([c cases])
  (define-values (name calls expected) (apply values c))
  (define-values (code out err) (run-with-calls (string-append tree-defs "\n" calls)))
  (check! name
          (and (= code 0) (string=? out expected) (string=? err ""))
          (format "exit ~a\n      expected ~s\n      got      ~s\n      stderr   ~s"
                  code expected out err)))

(printf "\n~a passed, ~a failed\n" passed failures)
(exit (if (= failures 0) 0 1))
