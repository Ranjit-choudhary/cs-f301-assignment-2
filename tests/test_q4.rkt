#lang racket
;; test_q4.rkt - tests for code/82_q4.rkt (S2)
;;
;; Run from anywhere:
;;   racket tests/test_q4.rkt
;;
;; The solution file has no provide, so it is tested the way the grader runs
;; it: for every test case the solution source is copied to a temporary
;; file, the test calls are appended to the end, and the copy is run with
;; racket, with the case's text fed to standard input. Its standard output
;; is compared with the expected text. The solution file is never modified.
;;
;; The file also audits the solution source: every symbol must be on the S2
;; allowlist or be a name the solution defines itself, none of the commonly
;; misused built-ins may appear, and insert-if-short is defined exactly once,
;; using make-inserter.

(require racket/runtime-path)

(define-runtime-path solution-path "../code/82_q4.rkt")

(define racket-exe
  (let ([self (find-system-path 'exec-file)])
    (or (find-executable-path self) self)))

(define solution-source (file->string solution-path))

;; ---------------------------------------------------------------------
;; Running the solution like the grader
;; ---------------------------------------------------------------------

;; (run-with-calls calls stdin) -> (values exit-code stdout stderr seconds)
;; Runs a copy of the solution with the text `calls` appended, feeding the
;; string `stdin` to its standard input.
(define (run-with-calls calls stdin)
  (define tmp (make-temporary-file "q4-test-~a.rkt"))
  (call-with-output-file tmp #:exists 'truncate
    (lambda (out)
      (write-string solution-source out)
      (write-string "\n" out)
      (write-string calls out)
      (write-string "\n" out)))
  (define out (open-output-string))
  (define err (open-output-string))
  (define start (current-inexact-milliseconds))
  (define code
    (parameterize ([current-output-port out]
                   [current-error-port err]
                   [current-input-port (open-input-string stdin)])
      (system*/exit-code racket-exe tmp)))
  (define seconds (/ (- (current-inexact-milliseconds) start) 1000.0))
  (delete-file tmp)
  (values code
          (string-replace (get-output-string out) "\r\n" "\n")
          (get-output-string err)
          seconds))

;; ---------------------------------------------------------------------
;; Large inputs and their expected outputs
;; ---------------------------------------------------------------------

(define (show v) (format "~a" v))

;; (nest d): d levels of nesting around (), e.g. (nest 2) = ((()))
(define (nest d) (if (= d 0) '() (list (nest (- d 1)))))
;; Every list in (nest d) has length 0 or 1, so with n = 2 each one gets x.
(define (nest-x d) (if (= d 0) '(x) (list 'x (nest-x (- d 1)))))

(define numbers (range 1 10001))                  ; (1 2 ... 10000)
(define singletons (map list numbers))            ; ((1) (2) ... (10000))

;; Each stdin case: name, stdin text, expected stdout.
(define stdin-cases
  (list
   ;; --- examples from the assignment ---
   (list "spec 1" "42 ((1 2) (3 4 5) (6) ()) 3" "((42 1 2) (3 4 5) (42 6) (42))\n")
   (list "spec 2" "0 (((1) 2) (3) ((4 5 6) ())) 3" "((0 (0 1) 2) (0 3) (0 (4 5 6) (0)))\n")
   (list "spec 3" "7 () 3" "(7)\n")
   (list "spec 4" "7 () 0" "()\n")
   ;; --- n = 0: no length is < 0, so nothing changes ---
   (list "n = 0 nested" "q ((1 2) () ((3))) 0" "((1 2) () ((3)))\n")
   (list "n = 0 flat" "q (a b c) 0" "(a b c)\n")
   ;; --- nested empty lists are lists, not atoms ---
   (list "nested empty lists n=2" "z (() (())) 2" "((z) (z (z)))\n")
   (list "nested empty lists n=3" "z (() (())) 3" "(z (z) (z (z)))\n")
   (list "only empty lists n=1" "e (() () ()) 1" "((e) (e) (e))\n")
   ;; --- length is measured on the original list, before inserting ---
   (list "boundary length = n" "z (a b c) 3" "(a b c)\n")
   (list "boundary length = n-1" "z (a b c) 4" "(z a b c)\n")
   (list "inserted x is not counted" "z ((a) (b c)) 2" "((z a) (b c))\n")
   ;; --- symbols and input layout ---
   (list "symbol atoms" "s (a (b (c d)) e) 3" "(a (s b (s c d)) e)\n")
   (list "input over several lines" "z\n(a (b c)\n ())\n2\n" "(a (b c) (z))\n")
   ;; --- large inputs ---
   (list "depth-100 nesting"
         (format "x ~a 2" (show (nest 100)))
         (string-append (show (nest-x 100)) "\n"))
   (list "10,000-element list, inserted at top"
         (format "x ~a 10001" (show numbers))
         (string-append (show (cons 'x numbers)) "\n"))
   (list "10,000-element list, unchanged"
         (format "x ~a 5" (show numbers))
         (string-append (show numbers) "\n"))
   (list "10,000 sublists, each gets x"
         (format "x ~a 2" (show singletons))
         (string-append (show (map (lambda (s) (cons 'x s)) singletons)) "\n"))))

;; Each direct case: name, calls appended to the solution, expected stdout.
(define direct-cases
  (list
   (list "insert-if-short called directly"
         "(display (insert-if-short 42 '((1 2) (3 4 5) (6) ()) 3)) (newline)"
         "((42 1 2) (3 4 5) (42 6) (42))\n")
   (list "make-inserter: only empty lists"
         "(display ((make-inserter 'e (lambda (len) (= len 0))) '(1 () (2 ()) (())))) (newline)"
         "(1 (e) (2 (e)) ((e)))\n")
   (list "make-inserter: length >= 3"
         "(display ((make-inserter 'big (lambda (len) (>= len 3))) '((1 2 3) (4) (5 6 7 8)))) (newline)"
         "(big (big 1 2 3) (4) (big 5 6 7 8))\n")
   (list "make-inserter: odd length, original length used"
         "(display ((make-inserter 'o (lambda (len) (or (= len 1) (= len 3)))) '((a) (b c) (d e f)))) (newline)"
         "(o (o a) (b c) (o d e f))\n")
   (list "make-inserter returns a reusable function"
         "(define f (make-inserter 'k (lambda (len) (< len 2)))) (display (f '(1))) (display (f '((2 3) ()))) (newline)"
         "(k 1)((2 3) (k))\n")
   (list "my-length / my-reverse / my-map"
         "(display (list (my-length '()) (my-length '(1 (2 3) () a)) (my-reverse '(1 (2 3) ())) (my-map (lambda (v) (* v v)) '(1 2 3)))) (newline)"
         "(0 4 (() (2 3) 1) (1 4 9))\n")
   (list "my-length / my-map on 1,000,000 elements"
         "(define (build k acc) (if (= k 0) acc (build (- k 1) (cons k acc)))) (define big (build 1000000 '())) (display (list (my-length big) (car (my-reverse big)) (car (my-reverse (my-map (lambda (v) (+ v 1)) big))))) (newline)"
         "(1000000 1000000 1000001)\n")))

;; ---------------------------------------------------------------------
;; Source audit
;; ---------------------------------------------------------------------

;; Exact Scheme allowlist for S2 (the S1 list plus read).
(define allowlist
  '(define lambda let let* letrec if cond else and or not begin quote
     cons car cdr list
     caar cadr cdar cddr
     caaar caadr cadar caddr cdaar cdadr cddar cdddr
     caaaar caaadr caadar caaddr cadaar cadadr caddar cadddr
     cdaaar cdaadr cdadar cdaddr cddaar cddadr cdddar cddddr
     null? pair? eq? assq assoc
     + - * < > <= >= = max display newline
     read))

;; Built-ins that must not appear anywhere in the solution.
(define forbidden
  '(first rest empty empty? zero? add1 sub1 when unless displayln printf
     equal? list? values let-values match provide length append reverse map
     second third set! filter member memq list-ref list-tail require
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

;; Names the solution binds itself: defined functions and their
;; parameters, lambda parameters, and names bound by let, let*, letrec and
;; named let.
(define (bound-names d)
  (match d
    [(list 'define (cons name params) body ...)
     (append (cons name params) (append-map bound-names body))]
    [(list 'lambda params body ...)
     (append params (append-map bound-names body))]
    [(list (or 'let 'let* 'letrec) (? symbol? name) (list (list vars inits) ...) body ...)
     (append (list name) vars (append-map bound-names (append inits body)))]
    [(list (or 'let 'let* 'letrec) (list (list vars inits) ...) body ...)
     (append vars (append-map bound-names (append inits body)))]
    [(? pair?) (append-map bound-names d)]
    [_ '()]))

(define used-symbols (remove-duplicates (append-map symbols-in solution-datums)))
(define own-names (remove-duplicates (append-map bound-names solution-datums)))

(define not-allowed
  (filter (lambda (s) (not (or (memq s allowlist) (memq s own-names)))) used-symbols))

(define forbidden-found
  (filter (lambda (s) (memq s used-symbols)) forbidden))

(define top-level-non-definitions
  (filter (lambda (d) (not (and (pair? d) (eq? (car d) 'define)))) solution-datums))

;; (definitions-of name) -> the top-level define forms that define name
(define (definitions-of name)
  (filter (lambda (d)
            (match d
              [(list 'define (cons (== name) _) _ ...) #t]
              [(list 'define (== name) _ ...) #t]
              [_ #f]))
          solution-datums))

;; ---------------------------------------------------------------------
;; Run everything
;; ---------------------------------------------------------------------

(define failures 0)
(define passed 0)
(define time-limit 10.0)   ; seconds per run, generous for start-up time

(define (check! name ok? detail)
  (if ok?
      (begin (set! passed (add1 passed)) (printf "PASS  ~a\n" name))
      (begin (set! failures (add1 failures)) (printf "FAIL  ~a\n      ~a\n" name detail))))

(define (shorten s) (if (> (string-length s) 120) (string-append (substring s 0 120) "...") s))

;; Loading the solution alone: exit 0, no output at all.
(let-values ([(code out err secs) (run-with-calls "" "")])
  (check! "load alone: exit 0 and no output"
          (and (= code 0) (string=? out "") (string=? err ""))
          (format "exit ~a, stdout ~s, stderr ~s" code out err)))

(check! "first line is #lang racket/base"
        (string-prefix? solution-source "#lang racket/base\n")
        (format "starts with ~s" (substring solution-source 0 (min 20 (string-length solution-source)))))

(check! "only define forms at top level"
        (null? top-level-non-definitions)
        (format "found ~s" top-level-non-definitions))

(check! "every symbol is allowed or bound by the solution"
        (null? not-allowed)
        (format "not allowed: ~s" not-allowed))

(check! "no forbidden built-ins"
        (null? forbidden-found)
        (format "found: ~s" forbidden-found))

(check! "exactly one definition of insert-if-short"
        (= 1 (length (definitions-of 'insert-if-short)))
        (format "found ~a" (length (definitions-of 'insert-if-short))))

(check! "insert-if-short is defined using make-inserter"
        (let ([defs (definitions-of 'insert-if-short)])
          (and (pair? defs) (memq 'make-inserter (symbols-in (car defs))) #t))
        "make-inserter does not appear in its body")

(check! "my-length, my-map, make-inserter, print-insert-result each defined once"
        (andmap (lambda (n) (= 1 (length (definitions-of n))))
                '(my-length my-map make-inserter print-insert-result))
        (format "counts: ~s"
                (map (lambda (n) (cons n (length (definitions-of n))))
                     '(my-length my-map make-inserter print-insert-result))))

(for ([c stdin-cases])
  (define-values (name stdin expected) (apply values c))
  (define-values (code out err secs) (run-with-calls "(print-insert-result)" stdin))
  (check! name
          (and (= code 0) (string=? out expected) (string=? err "") (< secs time-limit))
          (format "exit ~a, ~a s\n      expected ~s\n      got      ~s\n      stderr   ~s"
                  code secs (shorten expected) (shorten out) (shorten err))))

(for ([c direct-cases])
  (define-values (name calls expected) (apply values c))
  (define-values (code out err secs) (run-with-calls calls ""))
  (check! name
          (and (= code 0) (string=? out expected) (string=? err "") (< secs time-limit))
          (format "exit ~a, ~a s\n      expected ~s\n      got      ~s\n      stderr   ~s"
                  code secs (shorten expected) (shorten out) (shorten err))))

(printf "\n~a passed, ~a failed\n" passed failures)
(exit (if (= failures 0) 0 1))
