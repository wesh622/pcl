(* Harnais de test du front-end (rôle A).

   Usage : main.exe <fichier.sql> <dossier>
   Le dossier ne sert pas encore : à terme, le vrai SQL67 y écrit le C et le
   Makefile (rôle C). Ici, on vérifie seulement que la requête parse. *)

open Sql67

let show_position (p : Lexing.position) =
  Printf.sprintf "%s:%d:%d" p.pos_fname p.pos_lnum (p.pos_cnum - p.pos_bol + 1)

let print_resolu (r : Resolu.query) =
  Printf.printf "table=%s\n" r.Resolu.table;
  Printf.printf "  distinct=%b\n" r.Resolu.distinct;
  List.iter
    (fun (s : Resolu.sortie) ->
      Printf.printf "  sortie %s (col %d)\n" s.Resolu.nom s.Resolu.col)
    r.Resolu.sorties;
  List.iter
    (fun (i, d) ->
      Printf.printf "  tri col %d %s\n" i
        (match d with Ast.Asc -> "ASC" | Ast.Desc -> "DESC"))
    r.Resolu.tri;
  Printf.printf "  limit=%s offset=%d\n"
    (match r.Resolu.limit with Some n -> string_of_int n | None -> "aucune")
    r.Resolu.offset

let debug_semantique ast =
  let schema = [ ("personnes", [ "nom"; "age" ]) ] in
  match Semantique.analyse schema ast with
  | Ok r -> print_resolu r
  | Error { message; _ } -> prerr_endline message

(* [Rôle C] Analyse du rôle A, inchangée dans son déroulement, mais qui
   renvoie le résultat au lieu de faire exit. Les messages sur stderr sont
   conservés. *)
let analyse fichier : (Ast.query, Error.t) result =
  match Parse.parse_file fichier with
  | Ok ast ->
      if Sys.getenv_opt "SQL67_DEBUG" <> None then debug_semantique ast;
      Ok ast
  | Error ({ message; position; _ } as e) ->
      (match position with
       | Some p -> Printf.eprintf "%s: %s\n" (show_position p) message
       | None -> Printf.eprintf "%s\n" message);
      Error e

let () =
  if Array.length Sys.argv <> 3 then begin
    Printf.eprintf "usage: %s <fichier.sql> <dossier>\n" Sys.argv.(0);
    exit 2
  end;
  let dossier = Sys.argv.(2) in
  (* [Rôle C] Aucune exception ne doit faire planter le compilateur. *)
  let resultat =
    try analyse Sys.argv.(1) with
    | Error.Syntax_error e -> Error e
    | Sys_error m -> Error (Error.semantic_error m)
    | exn -> Error (Error.semantic_error (Printexc.to_string exn))
  in
  match Codegen.generer resultat dossier with
  | Ok () -> ()
  | Error m ->
      (* Seul cas de sortie non nulle : impossible d'écrire dans <dossier>. *)
      Printf.eprintf "erreur: écriture dans '%s' impossible: %s\n" dossier m;
      exit 1
