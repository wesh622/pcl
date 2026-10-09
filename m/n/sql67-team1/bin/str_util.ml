(* =============================================================================
   str_util.ml : petites fonctions utilitaires sur les chaînes.

   La bibliothèque standard d'OCaml n'a pas de recherche de sous-chaîne
   (il y a la bibliothèque « str », mais une dépendance de plus pour 8 lignes
   ne vaut pas le coup).
   ============================================================================= *)

(* find s sub : position de la première occurrence de sub dans s.
   Lève Not_found si sub n'apparaît pas. Algorithme naïf en O(n*m) : il n'est
   appelé qu'une fois par compilation, sur runtime.c, donc aucun souci. *)
let find s sub =
  let n = String.length s and m = String.length sub in
  let rec go i =
    if i + m > n then raise Not_found
    else if String.sub s i m = sub then i
    else go (i + 1)
  in
  go 0
