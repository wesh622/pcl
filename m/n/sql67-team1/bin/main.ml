(* Harnais de test du front-end (rôle A).

   Usage : main.exe <fichier.sql> <dossier>
   Le dossier ne sert pas encore : à terme, le vrai SQL67 y écrit le C et le
   Makefile (rôle C). Ici, on vérifie seulement que la requête parse. *)

open Sql67

let show_position (p : Lexing.position) =
  Printf.sprintf "%s:%d:%d" p.pos_fname p.pos_lnum (p.pos_cnum - p.pos_bol + 1)

let () =
  if Array.length Sys.argv <> 3 then begin
    Printf.eprintf "usage: %s <fichier.sql> <dossier>\n" Sys.argv.(0);
    exit 2
  end;
  match Parse.parse_file Sys.argv.(1) with
  | Ok _ -> print_endline "parse OK"
  | Error { message; position; exit_code } ->
      (match position with
       | Some p -> Printf.eprintf "%s: %s\n" (show_position p) message
       | None -> Printf.eprintf "%s\n" message);
      exit exit_code
