% 82_q1.pl - P1: Department Assignment Puzzle, Reloaded
%
% A Solution is a list of four terms p(Name, Dept, Lang, Project) in the
% order Alex, Ben, Carla, Dana:
%   [p('Alex',D1,L1,P1), p('Ben',D2,L2,P2), p('Carla',D3,L3,P3), p('Dana',D4,L4,P4)]
%
% Every clue(N, Solution) assumes Solution is fully instantiated, so it only
% checks values. It uses memberchk/2 (deterministic) instead of member/2, so a
% clue succeeds at most once and leaves no choicepoints that would make
% findall/3 count one solution several times.

:- use_module(library(lists)).
:- use_module(library(aggregate)).

% clue(+N, +Solution):
%   Clue number N holds in the fully filled-in Solution.

% Clue 1: the friend who prefers the AI project does not work in research
% and is not Dana.
clue(1, S) :-
    memberchk(p(Name, Dept, _, 'AI'), S),
    Dept \== research,
    Name \== 'Dana'.

% Clue 2: Alex does not work in development and does not prefer C++.
clue(2, S) :-
    memberchk(p('Alex', Dept, Lang, _), S),
    Dept \== development,
    Lang \== 'c++'.

% Clue 3: the friend working in the testing department likes Python.
clue(3, S) :-
    memberchk(p(_, testing, Lang, _), S),
    Lang == python.

% Clue 4: Ben prefers web projects and does not work in testing.
clue(4, S) :-
    memberchk(p('Ben', Dept, _, Project), S),
    Project == web,
    Dept \== testing.

% Clue 5: the friend whose favorite language is Java works in design.
clue(5, S) :-
    memberchk(p(_, Dept, java, _), S),
    Dept == design.

% Clue 6: Carla's project is not embedded, and her department is not
% development.
clue(6, S) :-
    memberchk(p('Carla', Dept, _, Project), S),
    Project \== embedded,
    Dept \== development.

% Clue 7: Dana's favorite language is not Java, and she works in research
% or testing.
clue(7, S) :-
    memberchk(p('Dana', Dept, Lang, _), S),
    Lang \== java,
    memberchk(Dept, [research, testing]).

% Clue 8: the friend who prefers data projects works in research and does
% not use JavaScript.
clue(8, S) :-
    memberchk(p(_, Dept, Lang, data), S),
    Dept == research,
    Lang \== javascript.

% solve(+Active, -Solution):
%   Solution is a complete assignment in which every friend has a different
%   department, language and project, and every clue whose number is in
%   Active holds. The assignment is generated first, so clue/2 only ever
%   sees a fully instantiated Solution. Each clue is checked once inside
%   forall/2, so the check adds no choicepoints and repeated clue numbers
%   in Active cannot produce the same Solution twice.
solve(Active, Solution) :-
    Solution = [p('Alex',  D1, L1, P1),
                p('Ben',   D2, L2, P2),
                p('Carla', D3, L3, P3),
                p('Dana',  D4, L4, P4)],
    permutation([research, development, design, testing], [D1, D2, D3, D4]),
    permutation([python, java, 'c++', javascript],        [L1, L2, L3, L4]),
    permutation(['AI', web, embedded, data],              [P1, P2, P3, P4]),
    forall(member(C, Active), once(clue(C, Solution))).

% count_solutions(+Active, -N):
%   N is the number of complete assignments that satisfy every clue in
%   Active and ignore all the other clues.
count_solutions(Active, N) :-
    aggregate_all(count, solve(Active, _), N).

% main:
%   Prints one solution of clues 1 to 8, one friend per line in the order
%   Alex, Ben, Carla, Dana, as  Name = [Dept, Lang, Project].
main :-
    once(solve([1, 2, 3, 4, 5, 6, 7, 8], Solution)),
    print_solution(Solution).

% print_solution(+Solution):
%   Prints each p(Name, Dept, Lang, Project) of Solution on its own line.
print_solution(Solution) :-
    forall(member(p(Name, Dept, Lang, Project), Solution),
           format('~w = [~w, ~w, ~w]~n', [Name, Dept, Lang, Project])).
