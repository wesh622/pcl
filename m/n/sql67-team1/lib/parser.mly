(* Grammaire SQL67 — fragment F0.
   Chaque clause construit les champs de la requête.
   Les erreurs sont récupérées dans lib/parse.ml.
   --strict est configuré dans lib/dune. *)

%{
open Ast
%}

%token SELECT FROM AS ORDER BY ASC DESC LIMIT OFFSET
%token <string> IDENT
%token <int> INT
%token STAR COMMA SEMI EOF MINUS

%start <Ast.query> query
%%

query:
  | SELECT select_list FROM from_clause order_by_clause limit_clause offset_clause SEMI? EOF
      { { select   = List.rev $2;
          from     = $4;
          order_by = $5;
          limit    = $6;
          offset   = $7 } }

(* Liste de projections : récursion gauche, renversée à la fin. *)
select_list:
  | select_item                   { [$1] }
  | select_list COMMA select_item { $3 :: $1 }

select_item:
  | STAR                          { Star }
  | expr                          { Item ($1, None) }
  | expr AS IDENT                 { Item ($1, Some $3) }
  | expr IDENT                    { Item ($1, Some $2) }   (* alias implicite *)

(* Colonne utilisée dans SELECT ou ORDER BY. *)
expr:
  | IDENT                         { Column $1 }

(* Une seule table en F0. *)
from_clause:
  | IDENT                         { $1 }

(* ORDER BY optionnel ; liste renversée ici pour l'AST. *)
order_by_clause:
  |                               { [] }
  | ORDER BY order_list           { List.rev $3 }

order_list:
  | order_item                    { [$1] }
  | order_list COMMA order_item   { $3 :: $1 }

order_item:
  | expr                          { ($1, Asc) }   (* ASC par défaut *)
  | expr ASC                      { ($1, Asc) }
  | expr DESC                     { ($1, Desc) }

limit_clause:
  |                               { None }
  | LIMIT signed_int              { Some $2 }

offset_clause:
  |                               { None }
  | OFFSET signed_int             { Some $2 }

(* Le signe est accepté au niveau syntaxique ; B tranche la sémantique
   (« LIMIT -1 » diffère entre SQLite et PostgreSQL). *)
signed_int:
  | INT                           { $1 }
  | MINUS INT                     { - $2 }
