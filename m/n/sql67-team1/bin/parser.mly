(* =============================================================================
   parser.mly : analyse syntaxique (menhir).

   Rôle : vérifier que la suite de tokens produite par lexer.mll respecte la
   grammaire de SQL67, et construire l'AST (ast.ml) correspondant.

   Menhir génère un automate LR(1) (analyse ascendante). En cas d'ambiguïté
   dans la grammaire, il le signale à la compilation (conflits shift/reduce) :
   c'est un garde-fou précieux quand la grammaire va grossir à chaque fragment.

   Lecture d'une règle :
       nom: | motif { action OCaml qui construit la valeur }
   « x = truc » donne le nom x à la valeur reconnue par truc.
   ============================================================================= *)

(* --- Déclaration des tokens (utilisés par lexer.mll) --- *)
%token SELECT FROM     (* mots-clés *)
%token STAR COMMA SEMI (* *  ,  ; *)
%token EOF             (* fin de fichier *)
%token <string> IDENT  (* identifiant : porte son nom (chaîne) *)

(* Point d'entrée : menhir génère la fonction Parser.query, de type
   (Lexing.lexbuf -> token) -> Lexing.lexbuf -> Ast.query
   appelée dans main.ml avec Lexer.token. *)
%start <Ast.query> query
%%

(* Une requête : SELECT <liste> FROM <table> avec un ; final facultatif (SEMI?),
   puis obligatoirement la fin du fichier (EOF) : on refuse ainsi tout texte
   qui traînerait après la requête. *)
query:
  | SELECT s = select_list FROM t = IDENT SEMI? EOF { { Ast.select = s; from = t } }

(* La liste après SELECT : soit *, soit une ou plusieurs colonnes séparées par
   des virgules. separated_nonempty_list est une macro de la bibliothèque
   standard de menhir : elle renvoie directement une string list. *)
select_list:
  | STAR                                         { Ast.Star }
  | cols = separated_nonempty_list(COMMA, IDENT) { Ast.Columns cols }
