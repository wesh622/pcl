(* Erreurs du compilateur — type partagé par A, B et C.
   [exit_code] : 0 = succès, 10 = requête invalide (contrat SQL67, &12). *)

type t = {
  message   : string;
  position  : Lexing.position option;
  exit_code : int;
}

(* Levée par le lexer sur un caractère ou un entier invalide ; le parser,
   lui, échoue avec [Parser.Error]. [Parse] rattrape les deux. *)
exception Syntax_error of t

let syntax_error message position =
  { message; position = Some position; exit_code = 10 }

let semantic_error message =
  { message; position = None; exit_code = 10 }
