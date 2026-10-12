(* Façade du front-end : SQL source → AST, ou Error.t.
   C'est le livrable du rôle A : aucune exception ne sort d'ici. *)

let parse_string ?(filename = "<string>") (src : string) :
    (Ast.query, Error.t) result =
  let lexbuf = Lexing.from_string src in
  Lexing.set_filename lexbuf filename;
  try Ok (Parser.query Lexer.token lexbuf) with
  | Parser.Error ->
      Error (Error.syntax_error "syntax error" (Lexing.lexeme_start_p lexbuf))
  | Error.Syntax_error e -> Error e

let parse_file (path : string) : (Ast.query, Error.t) result =
  In_channel.with_open_bin path (fun ch ->
      parse_string ~filename:path (In_channel.input_all ch))
