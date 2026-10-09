(* =============================================================================
   lexer.mll : analyse lexicale (ocamllex).

   Rôle : découper le texte SQL en une suite de « tokens » (mots).
     "SELECT a, b FROM t;"  ->  SELECT  IDENT "a"  COMMA  IDENT "b"  FROM  IDENT "t"  SEMI  EOF

   Le parser (parser.mly) ne voit jamais les caractères, seulement ces tokens.
   Les tokens eux-mêmes (SELECT, IDENT, ...) sont DÉCLARÉS dans parser.mly
   (lignes %token) : menhir génère le type Parser.token, qu'on ouvre ici.
   ============================================================================= *)

(* --- En-tête : code OCaml copié tel quel en haut de lexer.ml --- *)
{
open Parser   (* pour accéder aux constructeurs SELECT, FROM, IDENT, ... *)

(* Levée sur un caractère inconnu ; rattrapée dans main.ml, qui la transforme
   en erreur à l'exécution du programme C (cf. contrat du sujet). *)
exception Error of string

(* Table des mots-clés. Plutôt que d'écrire une règle par mot-clé, on reconnaît
   n'importe quel identifiant puis on regarde s'il est dans cette table :
   l'automate reste petit et ajouter un mot-clé = ajouter une ligne ici
   (et un %token dans parser.mly). *)
let keywords = [ "select", SELECT; "from", FROM ]
}

(* --- Définitions d'expressions régulières réutilisables --- *)

(* Identifiant SQL : une lettre ou _, puis lettres, chiffres ou _. *)
let ident = ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_']*

(* --- Règle principale : appelée par le parser à chaque fois qu'il veut un token.
   ocamllex prend la correspondance la PLUS LONGUE ; à longueur égale, la
   PREMIÈRE règle écrite gagne. --- *)
rule token = parse
  (* Blancs : ignorés, on relance la règle pour lire le token suivant. *)
  | [' ' '\t' '\r' '\n'] { token lexbuf }
  (* Commentaire SQL « -- ... » jusqu'à la fin de ligne : ignoré aussi. *)
  | "--" [^ '\n']*       { token lexbuf }
  (* Identifiant ou mot-clé. SQL est insensible à la casse pour les mots-clés
     (SELECT = select = SeLeCt), d'où le lowercase avant la recherche.
     Les noms de colonnes/tables gardent, eux, leur casse d'origine. *)
  | ident as id          { match List.assoc_opt (String.lowercase_ascii id) keywords with
                           | Some kw -> kw
                           | None -> IDENT id }
  (* Symboles. *)
  | '*'                  { STAR }
  | ','                  { COMMA }
  | ';'                  { SEMI }
  (* Fin du fichier : le parser en a besoin pour savoir que la requête est finie. *)
  | eof                  { EOF }
  (* Tout le reste est une erreur lexicale. *)
  | _ as c               { raise (Error (Printf.sprintf "unexpected character '%c'" c)) }
