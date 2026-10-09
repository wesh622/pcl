(* =============================================================================
   codegen.ml : génération de code (le « back-end »).

   Rôle : transformer un AST (ast.ml) en texte C99 : le fichier main.c du
   programme produit.

   Choix de conception : le C généré est COURT. Tout le travail générique
   (lire un CSV, afficher une table, chercher une colonne...) est écrit une fois
   pour toutes, à la main, dans runtime.c. Le code généré se contente d'appeler
   ces fonctions dans le bon ordre, avec les bons arguments.
   -> plus facile à déboguer (on peut tester runtime.c seul),
   -> le compilateur OCaml reste simple.
   Pour la performance (20 % de la note), on pourra plus tard générer du code
   plus spécialisé là où ça compte.
   ============================================================================= *)

(* Transforme une chaîne OCaml en littéral de chaîne C, guillemets compris.
   %S produit la syntaxe OCaml ("a\"b"), compatible avec C pour les caractères
   simples : suffisant pour des identifiants SQL ([a-zA-Z0-9_]). À revoir si
   on accepte un jour des identifiants entre guillemets avec des accents. *)
let c_string s = Printf.sprintf "%S" s

(* Génère le main.c d'une requête valide.
   Le programme produit reçoit les tables en arguments (contrat du sujet :
   <nom>.out t1.csv t2.csv ...) ; en F0 il n'y a qu'une table : argv[1]. *)
let query (q : Ast.query) =
  (* On accumule le texte dans un Buffer (plus efficace que des ^ successifs). *)
  let b = Buffer.create 1024 in
  (* p "..." : comme printf, mais écrit dans le buffer. *)
  let p fmt = Printf.bprintf b fmt in
  p "#include \"runtime.h\"\n\n";
  p "int main(int argc, char **argv) {\n";
  p "  if (argc < 2) sql_error(\"missing table argument\");\n";
  (* Le nom de la table SQL n'est pas utilisé pour trouver le fichier : c'est
     l'ordre des arguments qui compte. On le garde en commentaire dans le C
     pour faciliter la lecture du code généré. *)
  p "  table_t *t = table_load(argv[1]); /* table %s */\n" q.from;
  (match q.select with
   | Ast.Star -> p "  table_print(t);\n"
   | Ast.Columns cols ->
       (* On passe les NOMS des colonnes : la correspondance nom -> indice se
          fait à l'exécution, car le compilateur ne voit jamais les CSV
          (il ne connaît pas l'en-tête des tables). *)
       p "  const char *cols[] = { %s };\n"
         (String.concat ", " (List.map c_string cols));
       p "  table_print_columns(t, cols, %d);\n" (List.length cols));
  p "  return 0;\n}\n";
  Buffer.contents b

(* Génère le main.c d'une requête INVALIDE.
   Contrat du sujet : SQL67 ne doit jamais échouer, même sur une requête fausse.
   Il produit un programme qui compile normalement et qui, à l'exécution,
   affiche l'erreur et renvoie un code non nul (via sql_error). *)
let error msg =
  Printf.sprintf
    "#include \"runtime.h\"\n\nint main(void) {\n  sql_error(%s);\n}\n"
    (c_string msg)
