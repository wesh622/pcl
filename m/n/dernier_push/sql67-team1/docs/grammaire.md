# Grammaire SQL67 — F0 — rôle Jérémie

> Mémo de conception, mis à jour le 12 octobre 2026.
> Ce document décrit le front-end F0 présent dans main.

## Périmètre

A transforme le texte SQL en AST, ou en erreur lexicale/syntaxique avec position.
B définit les types de cet AST, puis l’interprète et le valide. C génère le C et le Makefile. D gère le runtime,
les tests cram et la CI. Le dossier `sujet/` reste strictement intact.

## Grammaire lisible (EBNF)

Les crochets désignent une partie optionnelle, les accolades une répétition.
Les mots-clés sont insensibles à la casse. EOF impose une seule requête par fichier.

```ebnf
query         = SELECT, select_list, FROM, from_clause,
                [order_by], [limit_clause], [offset_clause], [";"], EOF ;
select_list   = select_item, {",", select_item} ;
select_item   = "*" | expr, [ [AS], IDENT ] ;
expr          = IDENT ;
from_clause   = IDENT ;
order_by      = ORDER, BY, order_list ;
order_list    = order_item, {",", order_item} ;
order_item    = expr, [ASC | DESC] ;
limit_clause  = LIMIT, signed_int ;
offset_clause = OFFSET, signed_int ;
signed_int    = ["-"], INT ;
```

`LIMIT` et `OFFSET` sont indépendamment optionnels dans le code actuel.
Si les deux sont présents, `LIMIT` précède `OFFSET`. Ce choix décrit notre parser ;
il ne prétend pas couvrir toutes les syntaxes des SGBD de référence.

## Contrat lexical

- Mots-clés : SELECT, FROM, AS, ORDER, BY, ASC, DESC, LIMIT, OFFSET.
- IDENT : `[A-Za-z_][A-Za-z0-9_]*`, sauf les mots-clés ci-dessus.
- INT : suite de chiffres, convertie en `int` OCaml ; dépassement → erreur lexicale.
- Le signe moins est un token MINUS séparé ; le signe plus est actuellement refusé.
- Ponctuation : STAR (`*`), COMMA (`,`), SEMI (`;`), EOF.
- Espaces, tabulations et retours chariot ignorés ; `\n` met à jour le numéro de ligne.
- Commentaires `--` jusqu'à la fin de ligne ; commentaires `/* ... */` non pris en charge.
- Identifiants quotés, noms qualifiés (`t.a`) et chaînes non pris en charge actuellement.

## Construction de l'AST

- `*` produit `Star` ; une colonne produit `Item (Column nom, alias)`.
- Alias avec ou sans AS ; aucun alias sur `*`.
- Les listes de projection et de tri sont remises dans l'ordre du texte avec `List.rev`.
- Direction de tri absente → `Asc`.
- LIMIT/OFFSET absents → `None` ; présents → `Some entier`.
- B définit et maintient les types dans `lib/ast.ml`.
- L’AST actuel ne porte pas de positions.

### Types actuels

```ocaml
(* AST SQL67 — fragment F0. Types à reprendre/valider par B. *)

type dir = Asc | Desc

(* Une colonne. *)
type expr =
  | Column of string

type select_item =
  | Star                            (* SELECT * *)
  | Item of expr * string option    (* alias optionnel, avec ou sans AS *)

type query = {
  select   : select_item list;
  from     : string;                (* Nom de la table. *)
  order_by : (expr * dir) list;
  limit    : int option;
  offset   : int option;
}
```

### Source Menhir actuelle

Copie de `lib/parser.mly` vérifiée le 12 octobre 2026. La génération est déclarée dans `lib/dune`, avec `--strict` pour traiter
les avertissements comme des erreurs. La directive `%expect 0` a été retirée.
Toute modification F0 du parser doit être reportée ici.

```menhir
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
```

## Exemples de vérification manuelle

Syntaxes attendues comme acceptées (leur sens appartient à B) :

```sql
SELECT * FROM t;
select a as x, b FROM t ORDER BY x DESC, b LIMIT 5 OFFSET 2;
SELECT a x FROM t OFFSET 2
SELECT *, a FROM t LIMIT -1;
```

Syntaxes attendues comme refusées :

```sql
SELECT FROM t;
SELECT a, FROM t;
SELECT * AS x FROM t;
SELECT a FROM t ORDER BY;
SELECT a FROM t OFFSET 2 LIMIT 5;
SELECT a FROM t; SELECT b FROM t;
```

Vérifier également : fichier vide, caractère inattendu, entier trop grand,
commentaire final sans saut de ligne et erreur après plusieurs lignes.
Une colonne inconnue ou une limite négative ne se rejette pas comme erreur de
syntaxe : B décide de sa validité sémantique.

## Erreurs F0

`Parse.parse_string` rattrape `Parser.Error` et `Error.Syntax_error` et retourne
`Error.t` avec une position. Le message du parser est actuellement générique
(`syntax error`) ; les messages contextualisés restent à réaliser.
`$startpos`/`$endpos` permettent de situer des nœuds reconnus, mais ne suffisent
pas seuls à expliquer une erreur de syntaxe.

`Parse.parse_file` rattrape maintenant `Sys_error` si le fichier SQL ne peut pas
être ouvert ou lu. Il renvoie une `Error.t` avec le chemin et la cause,
`position = None` et `exit_code = 1`. Les erreurs lexer/parser restent au code 2.
Le build Dune et 71 tests privés ont réussi. La grammaire n'a pas changé.

Dans `main`, le harnais affiche encore `parse OK` ; il ne génère aucun programme C.
Le transport des erreurs de requête vers le programme C relève de l'intégration
avec C.

La borne minimale d’un `int` OCaml est actuellement refusée : sa partie
positive dépasse `max_int` avant l’application du signe moins par le parser.
