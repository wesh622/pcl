{
(* Lexer SQL67 — F0.

   Ajouter un mot-clé : une ligne dans [keyword].
   Ajouter un opérateur : une règle ci-dessous.
   Les positions sont entretenues (Lexing.new_line) pour que les erreurs
   pointent la bonne ligne. *)

open Parser

let syntax_error lexbuf message =
  raise (Error.Syntax_error (Error.syntax_error message (Lexing.lexeme_start_p lexbuf)))

let keyword = function
  | "select" -> Some SELECT
  | "distinct" -> Some DISTINCT
  | "from"   -> Some FROM
  | "as"     -> Some AS
  | "order"  -> Some ORDER
  | "by"     -> Some BY
  | "asc"    -> Some ASC
  | "desc"   -> Some DESC
  | "limit"  -> Some LIMIT
  | "offset" -> Some OFFSET
  | _        -> None
}

let space = [' ' '\t' '\r']
let digit = ['0'-'9']
let ident = ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_']*

rule token = parse
  | '\n'                  { Lexing.new_line lexbuf; token lexbuf }
  | space+                { token lexbuf }
  | "--" [^ '\n' '\r']*   { token lexbuf }        (* commentaire de ligne *)
  | '*'                   { STAR }
  | ','                   { COMMA }
  | ';'                   { SEMI }
  | '-'                   { MINUS }
  | digit+ as s           {
      match int_of_string_opt s with
      | Some n -> INT n
      | None -> syntax_error lexbuf "integer literal out of range" }
  | '"'                   { quoted_ident (Buffer.create 16) lexbuf }
  | ident as s            {
      match keyword (String.lowercase_ascii s) with
      | Some tok -> tok
      | None -> IDENT s }
  | eof                   { EOF }
  | _ as c                { syntax_error lexbuf (Printf.sprintf "unexpected character %C" c) }

(* Identifiant délimité : "..." ; "" vaut un guillemet. Jamais un mot-clé. *)
and quoted_ident buf = parse
  | "\"\""                { Buffer.add_char buf '"'; quoted_ident buf lexbuf }
  | '"'                   { IDENT (Buffer.contents buf) }
  | '\n'                  { Lexing.new_line lexbuf; Buffer.add_char buf '\n';
                            quoted_ident buf lexbuf }
  | eof                   { syntax_error lexbuf "unterminated quoted identifier" }
  | _ as c                { Buffer.add_char buf c; quoted_ident buf lexbuf }
