%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Jose Santos <jcas81@gmail.com>
% Date: 2009-01-30
%
% This file contains the Top Theory definition. The Top Theory defines the hypotheses
% search space
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- module(top_theory,
           [
             theory/3,

            % theory(Number, Head, Body)
            %
            %  Number is the top theory clause id.
            %  Body is a list of literals to be executed in order for Head to succeed

             addLiteral2Body/1
           ]
         ).

/*

  The top theory has three types of predicates:
       terminal symbols (with bk_call) around
       non-terminal:
           non-deterministic - yield several solutions: body, atom and member
           deterministic - have only one solution, all the others

  Our top theory interpreter (file hypothesis_generator.pl) supports at most one cut (!)
  per predicate definition. Allowing cuts simplifies and speeds the top theory significantly.
*/
:- dynamic theory/3.

% Some parts of the Top Theory will be filled in by the Top Theory compiler and depend
% on the particular mode declarations for the problem to solve

/*
The start clause of the top theory looks like below.
The Head, InTermsHead and OutTermsHead depend on the particular modeh declaration

theory(1, call_modeh(Signature, Target),
           [
             mergeTerms(InTermsHead, [], OutTermsHead, NInTerms, NOutTerms), %InTermsHead and OutTermsHead need to be compiled from modeh
             body(NInTerms, NOutTerms)
           ]
      ).
*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% addLiteral2Body(+Clause)
%
%  Given:
%    Clause: a clause
%  Succeeds:
%    If clause is responsible for adding a new literal to the body of an hypothesis
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addLiteral2Body(atom(_,_,_,_)).

% body(+InTerms, +OutTerms)


theory(11, body(_, []), []).
theory(12, body(InTerms, OutTerms),
           [atom(InTerms, OutTerms, NInTerms, NOutTerms),
            body(NInTerms, NOutTerms)]).


% Utility functions

% member/2

theory(20, member(H, [H|_]), []).
theory(21, member(H, [_|T]), [member(H, T)]).

% minus(+InList, +Elem, -OutList)
%
%
% OutList has InList-Value (InList if Value does not occur in InList)
%

theory(22, minus([], _, []), []).
theory(23, minus([H|T], H, T), [!]).
theory(24, minus([V|T], H, [V|R]), [minus(T, H, R)]).


% the atom declarations are missing. They will be 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% mergeTerms(+Terms, +CurInTerms, +CurOutTerms, -NewInTerms, -NewOutTerms)
%
% All arguments are lists of terms. A term is of the form: value/type, with both value and type ground
%
% This predicate merges terms (1st arg) with the current I/O terms.
%
% Terms may have repeated elements, but neither CurInTerms nor CurOutTerms has repeated elements.
% Furthermore, the intersection of CurInTerms with CurOutTerms is empty
%
% NewInterms will be bound with new elements of terms are prepended with InTerms
%
% If an element of Terms matchs a CurOutTerm that term goes to NewInTerms
%
% NewOutTerms will be bound with elements of CurOutTerms that do not exist in Terms
%
% We make the assumption that two terms that are identical should be renamed to the same variable
%
% e.g. mergeTerms([a/char,b/char], [a/char], [b/char], A, B). (A=[a/char,b/char], B=[])
%
% mergeTerms is a deterministic predicate (i.e. there is always one unique solution)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

theory(30, mergeTerms([], InTerms, OutTerms, InTerms, OutTerms), []).
theory(31, mergeTerms([V|OutVars], CurInTerms, CurOutTerms, NewInTerms, NewOutTerms),
            [
              member(V, CurInTerms),!,
              mergeTerms(OutVars, CurInTerms, CurOutTerms, NewInTerms, NewOutTerms)
            ]).
theory(32, mergeTerms([V|OutVars], CurInTerms, CurOutTerms, NewInTerms, NewOutTerms),
            [  minus(CurOutTerms, V, TempOutTerms),
               mergeTerms(OutVars, [V|CurInTerms], TempOutTerms, NewInTerms, NewOutTerms)
            ]).


% atom/4 will be generated by the compiler from the mode declarations
%
% they start at number 100 amd look like this:
%
% theory(100, atom(InTerms, OutTerms, NInTerms, NOutTerms),
%              [  //for each input variable of modeb declaration: call_randomMember(Var/Type, InTerms),
%               call_modeb(Recall, Signature, PredCall),
%               mergeTerms(OutputVariablesOfModeB, InTerms, OutTerms, NInTerms, NOutTerms),
%               body(NInTerms, NOutTerms)]).
