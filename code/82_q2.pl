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

% precedence(?Op, ?Prec):
%   Prec is the binding strength of Op; * and / bind tighter than + and -.
precedence(+, 1).
precedence(-, 1).
precedence(*, 2).
precedence(/, 2).

% expr_to_string(+Expr, -Str):
%   Str is the canonical SWI-Prolog string of Expr, with no spaces.
%   A number is written in decimal. An op(Op, L, R) is written as L, Op, R,
%   where each operand is put in parentheses by needs_parens/3, so every
%   different tree gets a different string.
expr_to_string(num(N), Str) :-
    number_string(N, Str).
expr_to_string(op(Op, L, R), Str) :-
    precedence(Op, P),
    operand_string(left, P, L, LStr),
    operand_string(right, P, R, RStr),
    format(string(Str), "~w~w~w", [LStr, Op, RStr]).

% operand_string(+Side, +ParentPrec, +Expr, -Str):
%   Str is Expr written as the Side operand of an operator of precedence
%   ParentPrec: in parentheses when needs_parens/3 says so, plain otherwise.
operand_string(Side, ParentPrec, Expr, Str) :-
    expr_to_string(Expr, Inner),
    (   needs_parens(Side, ParentPrec, Expr)
    ->  format(string(Str), "(~w)", [Inner])
    ;   Str = Inner
    ).

% needs_parens(+Side, +ParentPrec, +Expr):
%   Expr must be in parentheses as the Side operand of a parent of
%   precedence ParentPrec. A number never needs them. A left operand needs
%   them only if its operator binds strictly weaker than the parent (the
%   operators are left-associative); a right operand needs them if its
%   operator binds the same or weaker.
needs_parens(left, ParentPrec, op(Op, _, _)) :-
    precedence(Op, P),
    P < ParentPrec.
needs_parens(right, ParentPrec, op(Op, _, _)) :-
    precedence(Op, P),
    P =< ParentPrec.

% generate_equation(+List, ?Equation):
%   Equation is the canonical string "L=R" of a valid equation over List:
%   List is split into a non-empty left and right part (in order), L is an
%   expression over the left part, R is an expression over the right part,
%   and both have the same exact integer value. Backtracking gives every
%   valid equation once. Fails for [], for one-element lists and for lists
%   with no valid equation.
generate_equation(List, Equation) :-
    split_list(List, LeftNums, RightNums),
    build_expr(LeftNums, LeftTree, Val),
    build_expr(RightNums, RightTree, RightVal),
    RightVal =:= Val,
    expr_to_string(LeftTree, LStr),
    expr_to_string(RightTree, RStr),
    format(string(Str), '~s=~s', [LStr, RStr]),
    Equation = Str.
