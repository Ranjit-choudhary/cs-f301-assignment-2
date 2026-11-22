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
;; Traversals
;;
;; Each traversal walks the tree once and conses every value exactly once
;; onto an accumulator, so it is O(n) with no append and no reverse.
;; The accumulator holds the values that come AFTER the current subtree,
;; so each subtree is processed right to left: the part that comes last is
;; consed first, and the finished list is already in forward order.
;; ---------------------------------------------------------------------

;; (inorder-list tree) -> list of the values of tree in inorder
;; (left subtree, node, right subtree).
(define (inorder-list tree)
  (inorder-acc tree '()))

;; (inorder-acc tree acc) -> inorder values of tree followed by acc
;; Empty tree: nothing to add, so the result is acc.
;; Node: first put the right subtree in front of acc, then the node value,
;; then the left subtree in front of all of that.
(define (inorder-acc tree acc)
  (if (empty-tree? tree)
      acc
      (inorder-acc (node-left tree)
                   (cons (node-value tree)
                         (inorder-acc (node-right tree) acc)))))

;; (preorder-list tree) -> list of the values of tree in preorder
;; (node, left subtree, right subtree).
(define (preorder-list tree)
  (preorder-acc tree '()))

;; (preorder-acc tree acc) -> preorder values of tree followed by acc
;; Empty tree: the result is acc.
;; Node: the right subtree goes in front of acc, the left subtree in front
;; of that, and the node value in front of everything.
(define (preorder-acc tree acc)
  (if (empty-tree? tree)
      acc
      (cons (node-value tree)
            (preorder-acc (node-left tree)
                          (preorder-acc (node-right tree) acc)))))

;; (postorder-list tree) -> list of the values of tree in postorder
;; (left subtree, right subtree, node).
(define (postorder-list tree)
  (postorder-acc tree '()))

;; (postorder-acc tree acc) -> postorder values of tree followed by acc
;; Empty tree: the result is acc.
;; Node: the node value goes in front of acc, the right subtree in front
;; of that, and the left subtree in front of everything.
(define (postorder-acc tree acc)
  (if (empty-tree? tree)
      acc
      (postorder-acc (node-left tree)
                     (postorder-acc (node-right tree)
                                    (cons (node-value tree) acc)))))

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
