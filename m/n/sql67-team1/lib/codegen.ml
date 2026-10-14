(* Back-end SQL67 : écrit dans un dossier le C d'une requête et son Makefile.

   Le compilateur ne voit jamais les CSV : il décrit la requête dans query.c
   (une constante [QUERY]) et l'accompagne d'un moteur générique
   (runtime.c, sql67.h, copiés depuis lib/c/) qui résout les colonnes sur
   l'en-tête de la table à l'exécution.

   Une requête invalide produit quand même un programme qui compile : il
   affiche l'erreur et termine avec le code 2 (contrat SQL67). *)

(* Littéral C : les caractères non imprimables passent en octal. *)
let c_string s =
  let b = Buffer.create (String.length s + 2) in
  Buffer.add_char b '"';
  String.iter
    (fun c ->
      match c with
      | '"' -> Buffer.add_string b "\\\""
      | '\\' -> Buffer.add_string b "\\\\"
      | ' ' .. '~' -> Buffer.add_char b c
      | c -> Buffer.add_string b (Printf.sprintf "\\%03o" (Char.code c)))
    s;
  Buffer.add_char b '"';
  Buffer.contents b

let query_c (q : Ast.query) =
  let b = Buffer.create 1024 in
  let pr fmt = Printf.bprintf b fmt in
  pr "/* Généré par SQL67. */\n#include <stddef.h>\n#include \"sql67.h\"\n\n";
  pr "static const struct sel_item SEL[] = {\n";
  List.iter
    (function
      | Ast.Star -> pr "  { ITEM_STAR, NULL, NULL },\n"
      | Ast.Item (Ast.Column c, alias) ->
          let name = Option.value alias ~default:c in
          pr "  { ITEM_COLUMN, %s, %s },\n" (c_string c) (c_string name))
    q.select;
  pr "};\n\n";
  let norder = List.length q.order_by in
  if norder > 0 then begin
    pr "static const struct order_item ORDER[] = {\n";
    List.iter
      (fun (key, dir) ->
        let desc = if dir = Ast.Desc then 1 else 0 in
        match key with
        | Ast.By_expr (Ast.Column c) ->
            pr "  { ORDER_NAME, %s, 0, %d },\n" (c_string c) desc
        | Ast.By_position p -> pr "  { ORDER_POS, NULL, %dLL, %d },\n" p desc)
      q.order_by;
    pr "};\n\n"
  end;
  (* Comme SQLite : LIMIT négatif = pas de limite, OFFSET négatif = 0. *)
  let limit = match q.limit with Some n when n >= 0 -> n | _ -> -1 in
  let offset = match q.offset with Some n when n > 0 -> n | _ -> 0 in
  pr "const struct query QUERY = {\n";
  pr "  NULL, %s, %d,\n" (c_string q.from) (if q.distinct then 1 else 0);
  pr "  %d, SEL,\n" (List.length q.select);
  pr "  %d, %s,\n" norder (if norder > 0 then "ORDER" else "NULL");
  pr "  %dLL, %dLL\n};\n" limit offset;
  Buffer.contents b

let error_c message =
  Printf.sprintf
    "/* Généré par SQL67 : requête invalide. */\n\
     #include <stddef.h>\n\
     #include \"sql67.h\"\n\n\
     const struct query QUERY = { %s, \"\", 0, 0, NULL, 0, NULL, -1LL, 0LL };\n"
    (c_string message)

let makefile exe =
  Printf.sprintf
    "# Généré par SQL67.\n\
     CC ?= cc\n\
     CFLAGS ?= -O2 -std=c99 -D_DEFAULT_SOURCE\n\n\
     %s: query.c runtime.c sql67.h\n\
     \t$(CC) $(CFLAGS) -o $@ query.c runtime.c\n\n\
     clean:\n\
     \trm -f %s\n\n\
     .PHONY: clean\n"
    exe exe

let rec mkdir_p dir =
  if not (Sys.file_exists dir) then begin
    let parent = Filename.dirname dir in
    if parent <> dir then mkdir_p parent;
    Sys.mkdir dir 0o755
  end

let write_file path contents =
  Out_channel.with_open_bin path (fun ch -> Out_channel.output_string ch contents)

(* [result] : la requête analysée, ou le message d'erreur à afficher. *)
let emit ~dir (result : (Ast.query, string) result) =
  mkdir_p dir;
  let exe = Filename.basename dir ^ ".out" in
  let query = match result with Ok q -> query_c q | Error m -> error_c m in
  write_file (Filename.concat dir "sql67.h") C_sources.header;
  write_file (Filename.concat dir "runtime.c") C_sources.runtime;
  write_file (Filename.concat dir "query.c") query;
  write_file (Filename.concat dir "Makefile") (makefile exe)
