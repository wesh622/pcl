(* Façade du front-end : SQL source → AST, ou Error.t.
   Les erreurs de syntaxe et de lecture sont renvoyées à l'appelant. *)

let parse_string ?(filename = "<string>") (src : string) :
    (Ast.query, Error.t) result =
  let lexbuf = Lexing.from_string src in
  Lexing.set_filename lexbuf filename;
  try Ok (Parser.query Lexer.token lexbuf) with
  | Parser.Error ->
      Error (Error.syntax_error "syntax error" (Lexing.lexeme_start_p lexbuf))
  | Error.Syntax_error e -> Error e

let parse_file (path : string) : (Ast.query, Error.t) result =
  try
    let ch = open_in_bin path in
    let src =
      Fun.protect
        ~finally:(fun () -> close_in_noerr ch)
        (fun () -> really_input_string ch (in_channel_length ch))
    in
    parse_string ~filename:path src
  with Sys_error message ->
    Error {
      message = Printf.sprintf "cannot read SQL file %S: %s" path message;
      position = None;
      exit_code = 1;
    }
