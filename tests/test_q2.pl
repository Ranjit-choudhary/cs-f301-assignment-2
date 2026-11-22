% test_q2.pl - tests for code/82_q2.pl (P2)
%
% Run from the repository root:
%   swipl -q -g run_tests -t halt tests/test_q2.pl

:- use_module(library(plunit)).
:- use_module(library(lists)).
:- ensure_loaded('../code/82_q2').

% ---------------------------------------------------------------------
% Examples from the assignment
% ---------------------------------------------------------------------

:- begin_tests(p2_spec_examples).

test(all_4253) :-
    all_equations([4,2,5,3], Es),
    Es == ["4*2-5=3", "4*2=5+3", "4-2=5-3", "4/2=5-3",
           "4=2*(5-3)", "4=2+(5-3)", "4=2+5-3"].

test(generate_4253_gives_one_of_the_seven) :-
    once(generate_equation([4,2,5,3], E)),
    all_equations([4,2,5,3], Es),
    memberchk(E, Es).

test(generate_234_fails, [fail]) :-
    generate_equation([2,3,4], _).

test(all_234_empty) :-
    all_equations([2,3,4], Es),
    Es == [].

test(all_248) :-
    all_equations([2,4,8], Es),
    Es == ["2*4=8"].

test(count_4253) :-
    count_equations([4,2,5,3], N),
    N =:= 7.

test(count_234) :-
    count_equations([2,3,4], N),
    N =:= 0.

test(count_248) :-
    count_equations([2,4,8], N),
    N =:= 1.

:- end_tests(p2_spec_examples).

% ---------------------------------------------------------------------
% Canonical form of expressions (spec examples of the parenthesis rule)
% ---------------------------------------------------------------------

:- begin_tests(p2_canonical_form).

canonical(op(*, op(+, num(4), num(2)), num(3)), "(4+2)*3").
canonical(op(+, num(4), op(*, num(2), num(3))), "4+2*3").
canonical(op(*, op(/, num(8), num(4)), num(2)), "8/4*2").
canonical(op(/, num(8), op(*, num(4), num(2))), "8/(4*2)").
canonical(op(-, op(-, num(1), num(2)), num(3)), "1-2-3").
canonical(op(-, num(1), op(-, num(2), num(3))), "1-(2-3)").
canonical(op(+, num(1), op(+, num(2), num(3))), "1+(2+3)").
canonical(op(+, op(+, num(1), num(2)), num(3)), "1+2+3").
canonical(num(10), "10").

test(spec_rule_examples, [forall(canonical(Tree, Want))]) :-
    findall(S, expr_to_string(Tree, S), [Str]),
    string(Str),
    Str == Want.

test(different_trees_give_different_strings) :-
    findall(S, (build_expr([1,2,3,4], T, _), expr_to_string(T, S)), Ss),
    length(Ss, N),
    sort(Ss, Unique),
    length(Unique, N).

:- end_tests(p2_canonical_form).

% ---------------------------------------------------------------------
% Edge cases
% ---------------------------------------------------------------------

:- begin_tests(p2_edge_cases).

test(empty_list_generate_fails, [fail]) :-
    generate_equation([], _).

test(empty_list_all) :-
    all_equations([], Es),
    Es == [].

test(single_zero_generate_fails, [fail]) :-
    generate_equation([0], _).

test(single_zero_all) :-
    all_equations([0], Es),
    Es == [].

test(single_number_count) :-
    count_equations([5], N),
    N =:= 0.

test(two_zeros) :-
    all_equations([0,0], Es),
    Es == ["0=0"].

% 0/0 is never allowed, so only +, - and * appear.
test(three_zeros_no_division_by_zero) :-
    all_equations([0,0,0], Es),
    Es == ["0*0=0", "0+0=0", "0-0=0", "0=0*0", "0=0+0", "0=0-0"].

% 6/0 is rejected; 0/3 = 0 is a valid (exact) division but gives no equation.
test(division_by_zero_in_middle) :-
    all_equations([6,0,3], Es),
    Es == [].

test(zero_divisor_never_in_output) :-
    all_equations([0,0,0], Es),
    \+ ( member(E, Es), sub_string(E, _, _, _, "/0") ).

% Both sides negative: 1-3 = -2 = 2-4.
test(negative_intermediates) :-
    all_equations([1,3,2,4], Es),
    Es == ["1-3=2-4", "1=3+(2-4)", "1=3+2-4"].

% (1-4)/3 = -1 = 0-1: exact division of a negative value.
test(negative_exact_division, [nondet]) :-
    generate_equation([1,4,3,0,1], "(1-4)/3=0-1").

% (1-4)/2 is not exact; truncating -3//2 to -1 would wrongly accept it.
test(negative_non_exact_division_rejected, [fail]) :-
    generate_equation([1,4,2,0,1], "(1-4)/2=0-1").

% 3/2 is not exact; truncating it to 1 would wrongly give "3/2=1".
test(non_exact_division_rejected) :-
    all_equations([3,2,1], Es),
    Es == ["3-2=1", "3=2+1"].

test(non_exact_division_ground_fails, [fail]) :-
    generate_equation([3,2,1], "3/2=1").

test(exact_division_inside_expression) :-
    all_equations([1,2,3,6], Es),
    memberchk("1=2*3/6", Es).

% 1+2+3 and 1+(2+3) are different trees, so both are listed.
test(associativity_gives_distinct_equations) :-
    all_equations([1,2,3,6], Es),
    memberchk("1+2+3=6", Es),
    memberchk("1+(2+3)=6", Es),
    memberchk("1*2*3=6", Es),
    memberchk("1*(2*3)=6", Es).

test(all_123_6) :-
    all_equations([1,2,3,6], Es),
    Es == ["1*(2*3)=6", "1*2*3=6", "1+(2+3)=6", "1+2+3=6", "1=2*3/6"].

:- end_tests(p2_edge_cases).

% ---------------------------------------------------------------------
% Types, ordering and determinism
% ---------------------------------------------------------------------

:- begin_tests(p2_types).

test(generate_returns_string) :-
    once(generate_equation([4,2,5,3], E)),
    string(E).

test(all_returns_strings, [forall(member(L, [[4,2,5,3],[2,4,8],[0,0,0],[1,2,3,6]]))]) :-
    all_equations(L, Es),
    forall(member(E, Es), string(E)).

test(no_spaces_in_output) :-
    all_equations([4,2,5,3], Es),
    forall(member(E, Es), \+ sub_string(E, _, _, _, " ")).

test(atom_is_not_accepted, [fail]) :-
    generate_equation([2,4,8], '2*4=8').

test(ground_string_accepted, [nondet]) :-
    generate_equation([4,2,5,3], "4*2=5+3").

test(ground_wrong_string_fails, [fail]) :-
    generate_equation([4,2,5,3], "4+2=5+3").

test(all_is_sorted_and_duplicate_free, [forall(member(L, [[4,2,5,3],[1,2,3,6],[1,2,3,4,5]]))]) :-
    all_equations(L, Es),
    sort(Es, Sorted),
    Es == Sorted.

test(generate_enumerates_each_equation_once) :-
    findall(E, generate_equation([1,2,3,4,5], E), All),
    length(All, N),
    sort(All, Unique),
    length(Unique, N).

test(count_matches_all, [forall(member(L, [[],[7],[4,2,5,3],[2,3,4],[1,2,3,4,5]]))]) :-
    all_equations(L, Es),
    length(Es, Len),
    count_equations(L, N),
    N =:= Len.

test(all_is_deterministic) :-
    findall(Es, all_equations([4,2,5,3], Es), Answers),
    length(Answers, 1).

test(count_is_deterministic) :-
    findall(N, count_equations([4,2,5,3], N), Answers),
    Answers == [7].

:- end_tests(p2_types).
