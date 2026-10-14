(* Grammaire SQL67 — fragment F0.
   Chaque clause construit les champs de la requête.
   Les erreurs sont récupérées dans lib/parse.ml.
   --strict est configuré dans lib/dune. *)

%{
open Ast
%}

%token SELECT FROM AS ORDER BY ASC DESC LIMIT OFFSET DISTINCT ALL
%token <string> IDENT
%token <int> INT
%token STAR COMMA SEMI EOF MINUS

%start <Ast.query> query
%%

query:
  | SELECT distinct select_list FROM from_clause order_by_clause limit_offset SEMI? EOF
      { { distinct = $2;
          select   = List.rev $3;
          from     = $5;
          order_by = $6;
          limit    = fst $7;
          offset   = snd $7 } }

distinct:
  |                               { false }
  | ALL                           { false }
  | DISTINCT                      { true }

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
  | order_key                     { ($1, Asc) }   (* ASC par défaut *)
  | order_key ASC                 { ($1, Asc) }
  | order_key DESC                { ($1, Desc) }

order_key:
  | expr                          { By_expr $1 }
  | INT                           { By_position $1 }   (* ORDER BY 2 *)

(* (limit, offset). Acceptés : LIMIT n [OFFSET m], OFFSET m [LIMIT n],
   et la forme SQLite/MySQL LIMIT m, n (m = offset). *)
limit_offset:
  |                                         { (None, None) }
  | LIMIT signed_int                        { (Some $2, None) }
  | LIMIT signed_int OFFSET signed_int      { (Some $2, Some $4) }
  | LIMIT signed_int COMMA signed_int       { (Some $4, Some $2) }
  | OFFSET signed_int                       { (None, Some $2) }
  | OFFSET signed_int LIMIT signed_int      { (Some $4, Some $2) }

(* Le signe est accepté au niveau syntaxique ; B tranche la sémantique
   (« LIMIT -1 » diffère entre SQLite et PostgreSQL). *)
signed_int:
  | INT                           { $1 }
  | MINUS INT                     { - $2 }
