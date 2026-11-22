% 82_q2.pl - P2: Form a Valid Arithmetic Equation
%
% Expression trees:
%   num(N)                 a single number N from the input list
%   op(Op, Left, Right)    Left Op Right, with Op one of +, -, *, /
%
% Trees are built and evaluated in one pass, so a division that is not
% exact (or divides by zero) is rejected as soon as it is built, and the
% search never extends a tree that is already invalid. All values are
% integers: division uses // only after checking that it is exact.

:- use_module(library(lists)).

% split_list(+Nums, -Left, -Right):
%   Left and Right are both non-empty and Left followed by Right is Nums,
%   so every number is used once and the order is kept.
split_list(Nums, Left, Right) :-
    append(Left, Right, Nums),
    Left = [_|_],
    Right = [_|_].

% build_expr(+Nums, -Tree, -Val):
%   Tree is an expression over the numbers of the non-empty list Nums, used
%   once each and in order, and Val is its exact integer value.
%   A single number is a leaf. A longer list is split into a non-empty left
%   and right part; each part becomes a subtree and the two subtrees are
%   joined by an operator whose result is defined.
build_expr([N], num(N), N).
build_expr(Nums, op(Op, LeftTree, RightTree), Val) :-
    split_list(Nums, LeftNums, RightNums),
    build_expr(LeftNums, LeftTree, LeftVal),
    build_expr(RightNums, RightTree, RightVal),
    apply_op(Op, LeftVal, RightVal, Val).

% apply_op(?Op, +LeftVal, +RightVal, -Val):
%   Val is LeftVal Op RightVal. Division holds only when RightVal is not
%   zero and divides LeftVal exactly; the quotient is then an integer.
apply_op(+, L, R, V) :- V is L + R.
apply_op(-, L, R, V) :- V is L - R.
apply_op(*, L, R, V) :- V is L * R.
apply_op(/, L, R, V) :-
    R =\= 0,
    0 =:= L rem R,
    V is L // R.
