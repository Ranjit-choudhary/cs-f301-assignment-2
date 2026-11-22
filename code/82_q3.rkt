#lang racket/base

;; 82_q3.rkt - S1: Binary Tree Traversals
;;
;; A binary tree is either () or a three-element list (value left right),
;; where left and right are binary trees.

;; ---------------------------------------------------------------------
;; Tree accessors
;; ---------------------------------------------------------------------

;; (empty-tree? tree) -> boolean
;; A tree is empty exactly when it is ().
(define (empty-tree? tree)
  (null? tree))

;; (node-value tree) -> value of a non-empty tree
(define (node-value tree)
  (car tree))

;; (node-left tree) -> left subtree of a non-empty tree
(define (node-left tree)
  (cadr tree))

;; (node-right tree) -> right subtree of a non-empty tree
(define (node-right tree)
  (caddr tree))

;; ---------------------------------------------------------------------
;; List helper
;; ---------------------------------------------------------------------

;; (my-reverse lst) -> the elements of lst in reverse order
;; Tail recursive: walks lst once, consing each element onto acc, so the
;; first element ends up last. The loop is named after the function.
(define (my-reverse lst)
  (let my-reverse ((lst lst) (acc '()))
    (if (null? lst)
        acc
        (my-reverse (cdr lst) (cons (car lst) acc)))))

;; ---------------------------------------------------------------------
;; Traversals
;;
;; Each traversal walks the tree once, visiting the LEFT subtree before the
;; RIGHT subtree, and conses every value exactly once onto an accumulator.
;; The accumulator holds the values visited so far, newest first, so it is
;; the traversal in reverse; one my-reverse at the end puts it in forward
;; order. Every value is consed twice in total, so each traversal is O(n).
;; ---------------------------------------------------------------------

;; (inorder-list tree) -> list of the values of tree in inorder
;; (left subtree, node, right subtree).
(define (inorder-list tree)
  (my-reverse (inorder-acc tree '())))

;; (inorder-acc tree acc) -> the inorder values of tree, reversed, in
;; front of acc
;; Empty tree: nothing to add, so the result is acc.
;; Node: add the left subtree to acc first, then the node value, then the
;; right subtree on top of all of that.
(define (inorder-acc tree acc)
  (if (empty-tree? tree)
      acc
      (inorder-acc (node-right tree)
                   (cons (node-value tree)
                         (inorder-acc (node-left tree) acc)))))

;; (preorder-list tree) -> list of the values of tree in preorder
;; (node, left subtree, right subtree).
(define (preorder-list tree)
  (my-reverse (preorder-acc tree '())))

;; (preorder-acc tree acc) -> the preorder values of tree, reversed, in
;; front of acc
;; Empty tree: the result is acc.
;; Node: add the node value to acc first, then the left subtree, then the
;; right subtree on top of all of that.
(define (preorder-acc tree acc)
  (if (empty-tree? tree)
      acc
      (preorder-acc (node-right tree)
                    (preorder-acc (node-left tree)
                                  (cons (node-value tree) acc)))))

;; (postorder-list tree) -> list of the values of tree in postorder
;; (left subtree, right subtree, node).
(define (postorder-list tree)
  (my-reverse (postorder-acc tree '())))

;; (postorder-acc tree acc) -> the postorder values of tree, reversed, in
;; front of acc
;; Empty tree: the result is acc.
;; Node: add the left subtree to acc first, then the right subtree, then
;; the node value on top of all of that.
(define (postorder-acc tree acc)
  (if (empty-tree? tree)
      acc
      (cons (node-value tree)
            (postorder-acc (node-right tree)
                           (postorder-acc (node-left tree) acc)))))

;; ---------------------------------------------------------------------
;; Printing
;; ---------------------------------------------------------------------

;; (print-line x) -> prints x with display, then a newline
(define (print-line x)
  (display x)
  (newline))

;; (print-inorder tree) -> prints the inorder list of tree on one line
(define (print-inorder tree)
  (print-line (inorder-list tree)))

;; (print-all-traversals tree) -> prints three lines: the inorder,
;; preorder and postorder lists of tree, in that order
(define (print-all-traversals tree)
  (print-line (inorder-list tree))
  (print-line (preorder-list tree))
  (print-line (postorder-list tree)))

;; ---------------------------------------------------------------------
;; Height and leaves
;; ---------------------------------------------------------------------

;; (leaf? tree) -> boolean
;; A leaf is a non-empty node whose left and right subtrees are both ().
(define (leaf? tree)
  (and (not (empty-tree? tree))
       (empty-tree? (node-left tree))
       (empty-tree? (node-right tree))))

;; (tree-height tree) -> number
;; The height of () is 0; the height of a node is 1 plus the larger of the
;; heights of its two subtrees, so a single node has height 1.
(define (tree-height tree)
  (if (empty-tree? tree)
      0
      (+ 1 (max (tree-height (node-left tree))
                (tree-height (node-right tree))))))

;; (leaf-count tree) -> number
;; The number of leaves of tree. () has no leaves.
(define (leaf-count tree)
  (leaf-count-acc tree 0))

;; (leaf-count-acc tree acc) -> number of leaves of tree plus acc
;; Empty tree: adds nothing. Leaf: adds 1. Other node: count the left
;; subtree into acc, then the right subtree into that.
(define (leaf-count-acc tree acc)
  (cond ((empty-tree? tree) acc)
        ((leaf? tree) (+ acc 1))
        (else (leaf-count-acc (node-right tree)
                              (leaf-count-acc (node-left tree) acc)))))

;; (print-height-and-leaves tree) -> prints the list (height leaf-count)
;; of tree on one line
(define (print-height-and-leaves tree)
  (print-line (list (tree-height tree) (leaf-count tree))))
