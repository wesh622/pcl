(* AST SQL67 — fragment F0. *)

type dir = Asc | Desc

(* Une colonne. *)
type expr =
  | Column of string

type select_item =
  | Star                            (* SELECT * *)
  | Item of expr * string option    (* alias optionnel, avec ou sans AS *)

(* Clé de tri : une colonne (ou un alias), ou une position (ORDER BY 2). *)
type order_key =
  | By_expr of expr
  | By_position of int

type query = {
  distinct : bool;                  (* SELECT DISTINCT *)
  select   : select_item list;
  from     : string;                (* Nom de la table. *)
  order_by : (order_key * dir) list;
  limit    : int option;
  offset   : int option;
}
