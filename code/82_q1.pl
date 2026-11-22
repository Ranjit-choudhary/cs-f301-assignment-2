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
