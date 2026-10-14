(* SQL67 : compilateur SQL → C.

   Usage : SQL67 <fichier.sql> <dossier>
   Écrit dans <dossier> du C et un Makefile ; [make -C <dossier>] produit
   <dossier>/<dossier>.out. Même pour une requête invalide : le programme
   produit signale alors l'erreur à l'exécution (code 2). *)

open Sql67

let show_position (p : Lexing.position) =
  Printf.sprintf "line %d, column %d" p.pos_lnum (p.pos_cnum - p.pos_bol + 1)

let () =
  if Array.length Sys.argv <> 3 then begin
    Printf.eprintf "usage: %s <fichier.sql> <dossier>\n" Sys.argv.(0);
    exit 2
  end;
  let sql = Sys.argv.(1) and dir = Sys.argv.(2) in
  let result =
    match Parse.parse_file sql with
    | Ok q -> Ok q
    | Error { Error.message; position = Some p; _ } ->
        Error (Printf.sprintf "%s (%s)" message (show_position p))
    | Error { Error.message; position = None; _ } -> Error message
    | exception Sys_error m -> Error m
  in
  Codegen.emit ~dir result
