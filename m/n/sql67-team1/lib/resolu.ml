type sortie = { nom : string; col : int }  (* nom affiché, indice de la colonne source *)

type query = {
  table    : string;
  colonnes : string list;          (* toutes les colonnes de la table, dans l'ordre *)
  sorties  : sortie list;          (* '*' développé, alias appliqués *)
  tri      : (int * Ast.dir) list; (* indices de colonnes DE LA TABLE *)
  limit    : int option;           (* None = pas de limite *)
  offset   : int;                  (* déjà normalisé : >= 0 *)
}