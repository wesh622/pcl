let write_file path contents =
  let oc = open_out_bin path in
  output_string oc contents;
  close_out oc

let makefile name =
  Printf.sprintf
    "CC ?= clang\nCFLAGS = -O2 -std=c99 -Wall\n\n%s.out: main.c runtime.c runtime.h\n\t$(CC) $(CFLAGS) -o $@ main.c runtime.c -lm\n"
    name

let compile_sql src =
  let lexbuf = Lexing.from_string src in
  try Ok (Parser.query Lexer.token lexbuf) with
  | Lexer.Error msg -> Error msg
  | Parser.Error ->
      let pos = lexbuf.Lexing.lex_curr_p in
      Error
        (Printf.sprintf "syntax error at line %d, column %d" pos.pos_lnum
           (pos.pos_cnum - pos.pos_bol))

let split_runtime () =
  (* runtime.c contient le .h et le .c séparés par un marqueur *)
  let src = Runtime_c.source in
  let marker = "/*--- runtime.c ---*/" in
  let i = Str_util.find src marker in
  (String.sub src 0 i, String.sub src i (String.length src - i))

let () =
  match Sys.argv with
  | [| _; sql_file; out_dir |] ->
      let src = In_channel.with_open_bin sql_file In_channel.input_all in
      if not (Sys.file_exists out_dir) then Sys.mkdir out_dir 0o755;
      let main_c =
        match compile_sql src with
        | Ok q -> Codegen.query q
        | Error msg -> Codegen.error msg
      in
      let h, c = split_runtime () in
      let name = Filename.basename out_dir in
      write_file (Filename.concat out_dir "runtime.h") h;
      write_file (Filename.concat out_dir "runtime.c") ("#include \"runtime.h\"\n" ^ c);
      write_file (Filename.concat out_dir "main.c") main_c;
      write_file (Filename.concat out_dir "Makefile") (makefile name)
  | _ ->
      prerr_endline "usage: SQL67 <fichier.sql> <dossier>";
      exit 1
