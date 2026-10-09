{
open Parser
exception Error of string

let keywords = [ "select", SELECT; "from", FROM ]
}

let ident = ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_']*

rule token = parse
  | [' ' '\t' '\r' '\n'] { token lexbuf }
  | "--" [^ '\n']*       { token lexbuf }
  | ident as id          { match List.assoc_opt (String.lowercase_ascii id) keywords with
                           | Some kw -> kw
                           | None -> IDENT id }
  | '*'                  { STAR }
  | ','                  { COMMA }
  | ';'                  { SEMI }
  | eof                  { EOF }
  | _ as c               { raise (Error (Printf.sprintf "unexpected character '%c'" c)) }
