(* =============================================================================
   main.ml : point d'entrée du compilateur SQL67.

   Contrat imposé par le sujet (README_ARTEFACT.md) :
       SQL67 <fichier.sql> <dossier>
   doit écrire dans <dossier> des fichiers C et un Makefile tels que
       make -C <dossier>
   produise <dossier>/<dossier>.out.

   Enchaînement :
       texte SQL --lexer.mll--> tokens --parser.mly--> AST (ast.ml)
                 --codegen.ml--> main.c  (+ runtime.c/.h + Makefile)
   ============================================================================= *)

(* Écrit une chaîne dans un fichier (mode binaire : pas de conversion de fins
   de ligne, on écrit exactement ce qu'on a). *)
let write_file path contents =
  let oc = open_out_bin path in
  output_string oc contents;
  close_out oc

(* Le Makefile généré. Contraintes du sujet : seuls clang (aussi accessible
   via cc et $(CC)), make, la libc et la libm sont disponibles ; gcc n'existe pas.
   - CC ?= clang : utilise $(CC) s'il est défini, clang sinon.
   - -O2 : la performance du .out est notée (20 %) ; on pourra tester -O3,
     -march=native est déconseillé (la machine de correction peut différer).
   - -lm : la libm, utile dès qu'on fera des calculs flottants.
   La cible porte le nom imposé : <dossier>.out. *)
let makefile name =
  Printf.sprintf
    "CC ?= clang\nCFLAGS = -O2 -std=c99 -Wall\n\n%s.out: main.c runtime.c runtime.h\n\t$(CC) $(CFLAGS) -o $@ main.c runtime.c -lm\n"
    name

(* Analyse le texte SQL. Renvoie Ok ast, ou Error message en cas d'erreur
   lexicale ou syntaxique. On utilise un type result plutôt que de laisser
   l'exception remonter : une requête invalide n'est PAS un échec du compilateur,
   elle doit donner un programme C qui signale l'erreur à l'exécution. *)
let compile_sql src =
  let lexbuf = Lexing.from_string src in
  try Ok (Parser.query Lexer.token lexbuf) with
  | Lexer.Error msg -> Error msg
  | Parser.Error ->
      (* lex_curr_p : position juste après le dernier token lu, c'est-à-dire
         le token qui a provoqué l'erreur. Colonne = offset - début de ligne. *)
      let pos = lexbuf.Lexing.lex_curr_p in
      Error
        (Printf.sprintf "syntax error at line %d, column %d" pos.pos_lnum
           (pos.pos_cnum - pos.pos_bol))

(* runtime.c contient à la fois l'en-tête (.h) et l'implémentation (.c),
   séparés par un marqueur. Un seul fichier source = une seule chaîne embarquée
   (voir la règle dans bin/dune) ; on le recoupe ici en deux fichiers. *)
let split_runtime () =
  let src = Runtime_c.source in
  let marker = "/*--- runtime.c ---*/" in
  let i = Str_util.find src marker in
  (String.sub src 0 i, String.sub src i (String.length src - i))

let () =
  match Sys.argv with
  | [| _; sql_file; out_dir |] ->
      let src = In_channel.with_open_bin sql_file In_channel.input_all in
      (* Le sujet dit que SQL67 crée le dossier « au besoin ». *)
      if not (Sys.file_exists out_dir) then Sys.mkdir out_dir 0o755;
      (* Requête valide ou non, on produit TOUJOURS un main.c compilable. *)
      let main_c =
        match compile_sql src with
        | Ok q -> Codegen.query q
        | Error msg -> Codegen.error msg
      in
      let h, c = split_runtime () in
      (* Le .out doit s'appeler comme le dossier (sans le chemin éventuel). *)
      let name = Filename.basename out_dir in
      write_file (Filename.concat out_dir "runtime.h") h;
      write_file (Filename.concat out_dir "runtime.c") ("#include \"runtime.h\"\n" ^ c);
      write_file (Filename.concat out_dir "main.c") main_c;
      write_file (Filename.concat out_dir "Makefile") (makefile name)
  | _ ->
      (* Mauvais arguments. Le job sql67:check lance SQL67 sans argument : le
         code de retour 1 est accepté (seuls 126/127 signalent un problème). *)
      prerr_endline "usage: SQL67 <fichier.sql> <dossier>";
      exit 1
