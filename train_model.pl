:- use_module('source/gilps').

%:- show_settings.

:- set(verbose, 1).

% reads problem definition and saves learned theory in a file (this is optional)
proteins:-
  read_problem('datasets/proteins/proteins'),
  set(output_theory_file, 'models/theory_proteins.pl').
  
  
:- proteins.
:- build_theory.
