type schema = (string * string list) list

let ( let* ) = Result.bind

let erreur msg = Error (Error.semantic_error msg)

(* Les identifiants SQL sont insensibles à la casse. *)
let egal a b = String.lowercase_ascii a = String.lowercase_ascii b

let index_de nom colonnes =
  let rec aux i = function
    | [] -> None
    | c :: reste -> if egal c nom then Some i else aux (i + 1) reste
  in
  aux 0 colonnes

(* Comme List.map, mais s'arrête à la première erreur. *)
let rec map_result f = function
  | [] -> Ok []
  | x :: reste ->
      let* y = f x in
      let* ys = map_result f reste in
      Ok (y :: ys)

let resoudre_select colonnes items =
  let un_item = function
    | Ast.Star ->
        Ok (List.mapi (fun i nom -> { Resolu.nom; col = i }) colonnes)
    | Ast.Item (Ast.Column c, alias) -> (
        match index_de c colonnes with
        | None -> erreur (Printf.sprintf "colonne inconnue : %s" c)
        | Some i ->
            let nom =
              match alias with Some a -> a | None -> List.nth colonnes i
            in
            Ok [ { Resolu.nom; col = i } ])
  in
  let* groupes = map_result un_item items in
  Ok (List.concat groupes)

(* ORDER BY : on cherche d'abord parmi les alias du SELECT, puis dans la table. *)
let resoudre_tri colonnes sorties order_by =
  let un_tri (Ast.Column c, dir) =
    match List.find_opt (fun s -> egal s.Resolu.nom c) sorties with
    | Some s -> Ok (s.Resolu.col, dir)
    | None -> (
        match index_de c colonnes with
        | Some i -> Ok (i, dir)
        | None -> erreur (Printf.sprintf "colonne inconnue dans ORDER BY : %s" c))
  in
  map_result un_tri order_by

(* Choix à confirmer avec SQLite : LIMIT négatif = pas de limite, OFFSET négatif = 0. *)
let normaliser_limit = function Some n when n >= 0 -> Some n | _ -> None
let normaliser_offset = function Some n when n > 0 -> n | _ -> 0

let analyse (schema : schema) (q : Ast.query) : (Resolu.query, Error.t) result =
  let* nom_table, colonnes =
    match List.find_opt (fun (t, _) -> egal t q.Ast.from) schema with
    | Some (t, cols) -> Ok (t, cols)
    | None -> erreur (Printf.sprintf "table inconnue : %s" q.Ast.from)
  in
  let* sorties = resoudre_select colonnes q.Ast.select in
  let* tri = resoudre_tri colonnes sorties q.Ast.order_by in
  Ok
    {
      Resolu.table = nom_table;
      colonnes;
      sorties;
      tri;
      limit = normaliser_limit q.Ast.limit;
      offset = normaliser_offset q.Ast.offset;
    }