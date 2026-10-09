(* Traduit l'AST en un programme C qui s'appuie sur runtime.c *)

let c_string s = Printf.sprintf "%S" s (* suffisant pour des identifiants SQL *)

let query (q : Ast.query) =
  let b = Buffer.create 1024 in
  let p fmt = Printf.bprintf b fmt in
  p "#include \"runtime.h\"\n\n";
  p "int main(int argc, char **argv) {\n";
  p "  if (argc < 2) sql_error(\"missing table argument\");\n";
  p "  table_t *t = table_load(argv[1]); /* table %s */\n" q.from;
  (match q.select with
   | Ast.Star -> p "  table_print(t);\n"
   | Ast.Columns cols ->
       p "  const char *cols[] = { %s };\n"
         (String.concat ", " (List.map c_string cols));
       p "  table_print_columns(t, cols, %d);\n" (List.length cols));
  p "  return 0;\n}\n";
  Buffer.contents b

(* Requête invalide : le C compile mais échoue à l'exécution *)
let error msg =
  Printf.sprintf
    "#include \"runtime.h\"\n\nint main(void) {\n  sql_error(%s);\n}\n"
    (c_string msg)
