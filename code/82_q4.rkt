#lang racket/base

;; 82_q4.rkt - S2: Conditionally Insert into a Nested List
;;
;; List helpers written only with the allowed built-ins. Each one walks the
;; top level of its list once with a named let and an accumulator, so it is
;; tail recursive and O(n): long lists (10,000+ elements) use constant stack.

;; (my-length lst) -> number
;; The length of () is 0; the length of (x . rest) is 1 + the length of rest.
;; Tail recursive: the count so far is carried in acc.
(define (my-length lst)
  (let loop ((remaining lst) (acc 0))
    (if (null? remaining)
        acc
        (loop (cdr remaining) (+ acc 1)))))

;; (my-reverse lst) -> the top-level elements of lst in reverse order
;; Reversing () gives acc; reversing (x . rest) onto acc is reversing rest
;; onto (x . acc). Tail recursive: each element is consed once.
(define (my-reverse lst)
  (let loop ((remaining lst) (acc '()))
    (if (null? remaining)
        acc
        (loop (cdr remaining) (cons (car remaining) acc)))))

;; (my-map f lst) -> the list of (f x) for each top-level element x of lst,
;; in the original order
;; Mapping over () gives (); mapping over (x . rest) gives (f x) followed by
;; the map of rest. Tail recursive: the results are collected in reverse in
;; acc and put back in order with one my-reverse at the end.
(define (my-map f lst)
  (let loop ((remaining lst) (acc '()))
    (if (null? remaining)
        (my-reverse acc)
        (loop (cdr remaining) (cons (f (car remaining)) acc)))))

;; (sublist? elem) -> boolean
;; An element is a (sub)list when it is () or a pair. () counts as a list
;; too, so nested empty lists are transformed instead of kept as atoms.
(define (sublist? elem)
  (or (null? elem) (pair? elem)))

;; (insert-if-short x lst n) -> lst with x put at the front of every list,
;; at every level of nesting (lst itself included), whose original
;; top-level length is less than n
;; The length of lst is measured first, on the original list. Then every
;; element that is a list is transformed the same way (atoms are kept), and
;; x is consed on afterwards if the original length was < n, so the new x
;; is never measured or transformed itself.
(define (insert-if-short x lst n)
  (let ((len (my-length lst))
        (transformed (my-map (lambda (elem)
                               (if (sublist? elem)
                                   (insert-if-short x elem n)
                                   elem))
                             lst)))
    (if (< len n)
        (cons x transformed)
        transformed)))
