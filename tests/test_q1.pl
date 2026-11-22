% test_q1.pl - tests for code/82_q1.pl (P1)
%
% Run from the repository root:
%   swipl -q -g run_tests -t halt tests/test_q1.pl

:- use_module(library(plunit)).
:- use_module(library(lists)).
:- ensure_loaded('../code/82_q1').

% kept_solution(-S): the single solution of clues 1 to 9.
kept_solution([p('Alex',  design,      java,       embedded),
               p('Ben',   development, javascript, web),
               p('Carla', testing,     python,     'AI'),
               p('Dana',  research,    'c++',      data)]).

% violates(+N, -S): S is a complete, distinct assignment in which clue N
% is false. Each one is the kept solution with one pair of values swapped
% (clue 9 uses another solution of clues 1 to 8).
violates(1, [p('Alex',design,java,embedded), p('Ben',development,javascript,web),
             p('Carla',testing,python,data), p('Dana',research,'c++','AI')]).
violates(2, [p('Alex',development,java,embedded), p('Ben',design,javascript,web),
             p('Carla',testing,python,'AI'), p('Dana',research,'c++',data)]).
violates(3, [p('Alex',design,java,embedded), p('Ben',development,javascript,web),
             p('Carla',testing,'c++','AI'), p('Dana',research,python,data)]).
violates(4, [p('Alex',design,java,embedded), p('Ben',testing,javascript,web),
             p('Carla',development,python,'AI'), p('Dana',research,'c++',data)]).
violates(5, [p('Alex',design,javascript,embedded), p('Ben',development,java,web),
             p('Carla',testing,python,'AI'), p('Dana',research,'c++',data)]).
violates(6, [p('Alex',design,java,'AI'), p('Ben',development,javascript,web),
             p('Carla',testing,python,embedded), p('Dana',research,'c++',data)]).
violates(7, [p('Alex',design,'c++',embedded), p('Ben',development,javascript,web),
             p('Carla',testing,python,'AI'), p('Dana',research,java,data)]).
violates(8, [p('Alex',design,java,embedded), p('Ben',development,javascript,web),
             p('Carla',research,python,'AI'), p('Dana',testing,'c++',data)]).
violates(9, [p('Alex',design,java,'AI'), p('Ben',development,javascript,web),
             p('Carla',research,'c++',data), p('Dana',testing,python,embedded)]).

% single_clue_count(?N, ?Count): the number of complete assignments (out of
% 24^3 = 13824) that satisfy clue N alone, worked out by hand.
%   1: AI holder is one of 3 non-Dana friends (18 project perms) and not in
%      research (18 dept perms): 18*18*24
%   2: Alex not development (18) and not c++ (18): 18*18*24
%   3: whoever is in testing has python (6 language perms per dept perm)
%   4: Ben has web (6) and is not in testing (18): 18*24*6
%   5: whoever has java is in design: 24*6*24
%   6: Carla not embedded (18) and not development (18): 18*24*18
%   7: Dana in research or testing (12) and not java (18): 12*18*24
%   8: data holder in research (24*6 dept/project pairs), not javascript (18)
%   9: whoever is in testing has AI: 24*24*6
single_clue_count(1, 7776).
single_clue_count(2, 7776).
single_clue_count(3, 3456).
single_clue_count(4, 2592).
single_clue_count(5, 3456).
single_clue_count(6, 7776).
single_clue_count(7, 5184).
single_clue_count(8, 2592).
single_clue_count(9, 3456).

:- begin_tests(p1_main).

test(main_output) :-
    with_output_to(string(Out), main),
    Out == "Alex = [design, java, AI]\nBen = [development, javascript, web]\nCarla = [research, c++, data]\nDana = [testing, python, embedded]\n".

test(main_solution_satisfies_clues_1_to_8) :-
    once(solve([1,2,3,4,5,6,7,8], S)),
    forall(between(1, 8, N), clue(N, S)).

test(main_is_deterministic, [nondet]) :-
    findall(x, main_quiet, Xs),
    Xs == [x].

main_quiet :- with_output_to(string(_), main).

:- end_tests(p1_main).

:- begin_tests(p1_count).

test(clues_1_to_8) :-
    count_solutions([1,2,3,4,5,6,7,8], N),
    N =:= 3.

test(clues_1_to_9) :-
    count_solutions([1,2,3,4,5,6,7,8,9], N),
    N =:= 1.

test(no_clues_counts_every_assignment) :-
    count_solutions([], N),
    N =:= 13824.

test(duplicate_clue_numbers_do_not_overcount) :-
    count_solutions([1,1,2,3,4,5,6,7,8,8,8], N),
    N =:= 3.

test(order_of_active_does_not_matter) :-
    count_solutions([8,7,6,5,4,3,2,1], N),
    N =:= 3.

test(single_clue, [forall(single_clue_count(C, Expected))]) :-
    count_solutions([C], N),
    N =:= Expected.

test(count_is_deterministic) :-
    findall(N, count_solutions([1,2,3,4,5,6,7,8], N), Ns),
    Ns == [3].

test(unique_solution_of_clues_1_to_9) :-
    findall(S, solve([1,2,3,4,5,6,7,8,9], S), Ss),
    kept_solution(K),
    Ss == [K].

:- end_tests(p1_count).

:- begin_tests(p1_clues).

test(holds_once_in_kept_solution, [forall(between(1, 9, N))]) :-
    kept_solution(K),
    findall(x, clue(N, K), Xs),
    Xs == [x].

test(fails_when_violated, [forall(between(1, 9, N)), fail]) :-
    violates(N, S),
    clue(N, S).

test(clue_9_false_in_other_solutions_of_1_to_8) :-
    findall(S, (solve([1,2,3,4,5,6,7,8], S), \+ clue(9, S)), Others),
    length(Others, 2).

:- end_tests(p1_clues).
