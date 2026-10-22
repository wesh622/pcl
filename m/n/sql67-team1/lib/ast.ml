(* AST SQL67 — fragment F0. Types à reprendre/valider par B. *)

type dir = Asc | Desc

(* Une colonne. *)
type expr =
  | Column of string

type select_item =
  | Star                            (* SELECT * *)
  | Item of expr * string option    (* alias optionnel, avec ou sans AS *)

type query = {
  distinct : bool;
  select   : select_item list;
  from     : string;                (* Nom de la table. *)
  from_sql : string;                (* Nom tel qu'écrit dans la requête (messages d'erreur). *)
  order_by : (expr * dir) list;
  limit    : int option;
  offset   : int option;
}
