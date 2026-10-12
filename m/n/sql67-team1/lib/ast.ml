(* AST SQL67 — fragment F0. Types à reprendre/valider par B. *)

type dir = Asc | Desc

(* Une colonne. *)
type expr =
  | Column of string

type select_item =
  | Star                            (* SELECT * *)
  | Item of expr * string option    (* alias optionnel, avec ou sans AS *)

type query = {
  select   : select_item list;
  from     : string;                (* Nom de la table. *)
  order_by : (expr * dir) list;
  limit    : int option;
  offset   : int option;
}
