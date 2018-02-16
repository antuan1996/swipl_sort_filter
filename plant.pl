:- [plant_db].

group(DISEASE, GROUP) :- illnesses_group(GROUP, ILLNESSES), member(DISEASE, ILLNESSES).

groups_set([], []).
groups_set([DISEASE | TAIL], GROUPS) :- group(DISEASE, CURRENT_GROUP), groups_set(TAIL, INTERIM), list_to_set([CURRENT_GROUP | INTERIM], GROUPS).
groups_intersection(DISEASES, GROUPS) :- groups_set(DISEASES, DISEASES_GROUPS), intersection(DISEASES_GROUPS, GROUPS, [_ | _]).

filter_object(QUERY_ILLNESS, QUERY_CONTRAS, [_, ILLNESSES_GROUPS, CONTRA_GROUPS, _]) :- group(QUERY_ILLNESS, ILLNESSES_GROUP), member(ILLNESSES_GROUP, ILLNESSES_GROUPS), \+(groups_intersection(QUERY_CONTRAS, CONTRA_GROUPS)).

compare_object([NAME1, ILLNESSES1, CONTRAS1, PROBABILITY1], [_, _, PROBABILITY2], [NAME1, ILLNESSES1, CONTRAS1, PROBABILITY1]) :- PROBABILITY1 > PROBABILITY2, !.
compare_object([NAME1, ILLNESSES1, CONTRAS1, PROBABILITY1], [NAME2, _, PROBABILITY2], [NAME1, ILLNESSES1, CONTRAS1, PROBABILITY1]) :- PROBABILITY1 = PROBABILITY2, NAME1 @=< NAME2, !.
compare_object([_, _, _, _], [NAME2, ILLNESSES2, CONTRAS2, PROBABILITY2], [NAME2, ILLNESSES2, CONTRAS2, PROBABILITY2]).

merge_lists([], [], _, []).
merge_lists([X | TAILX], [], _, [X | TAILX]).
merge_lists([], [Y | TAILY], _, [Y | TAILY]).
merge_lists([X | TAILX], [Y | TAILY], COMP, [X | RECURS]) :-  call(COMP, X, Y, X), !, merge_lists(TAILX, [Y | TAILY], COMP, RECURS).
merge_lists([X | TAILX], [Y | TAILY], COMP, [Y | RECURS]) :-  call(COMP, X, Y, Y), merge_lists([X | TAILX], TAILY, COMP, RECURS).

split_list([], _, [], []) :- !.
split_list(LIST, 0, [], LIST) :- !.
split_list([FIRST | TAIL], N, LEFT, RIGHT) :- N1 is N-1, split_list(TAIL, N1, LEFT_INTERNAL, RIGHT), LEFT = [FIRST | LEFT_INTERNAL].

sort_objects([], _, []).
sort_objects([A], _, [A]) :- !.
sort_objects(OBJECTS_LIST, COMP, RESULT) :- length(OBJECTS_LIST, N), MIDDLE is div(N, 2), split_list(OBJECTS_LIST, MIDDLE, LEFT, RIGHT), sort_objects(LEFT, COMP, SORTED_LEFT), sort_objects(RIGHT, COMP, SORTED_RIGHT), merge_lists(SORTED_LEFT, SORTED_RIGHT, COMP, RESULT).

find(QUERY_ILLNESS, QUERY_CONTRAS, X) :- findall([NAME, ILLNESSES, CONTRAS, PROBABILITY], plant(NAME, ILLNESSES, CONTRAS, PROBABILITY), OBJECTS1), include(filter_object(QUERY_ILLNESS, QUERY_CONTRAS), OBJECTS1, OBJECTS), sort_objects(OBJECTS, compare_object, X).

print_plant([NAME, ILLNESSES, CONTRAS, PROBABILITY]) :-
	write("Название: "),
	writeln(NAME),
	write("Лечит заболевания: "),
	writeln(ILLNESSES),
	write("Противопоказания: "),
	writeln(CONTRAS),
	write("Вероятность найти: "),
	writeln(PROBABILITY).

print_plants([]) :- writeln("-----------------").
print_plants([HEAD|TAIL]) :- writeln("-----------------"), print_plant(HEAD), print_plants(TAIL).

find_plants_interactive() :- writeln("Введите название болезни"), read(QUERY_ILLNESS), writeln("Введите противопоказания"), read(QUERY_CONTRAS), find(QUERY_ILLNESS, QUERY_CONTRAS, X), print_plants(X).
