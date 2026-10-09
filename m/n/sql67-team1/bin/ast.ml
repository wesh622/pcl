(* =============================================================================
   ast.ml : l'Arbre de Syntaxe Abstraite (AST).

   C'est la représentation d'une requête SQL une fois analysée, indépendante
   du texte d'origine (espaces, majuscules, commentaires ont disparu).

   Le parser (parser.mly) PRODUIT des valeurs de ces types ;
   le générateur de code (codegen.ml) les CONSOMME pour écrire du C.
   C'est donc le contrat entre le « front-end » et le « back-end » du compilateur.

   À FAIRE (F0 et suivants) : ajouter ici AS, ORDER BY, LIMIT, OFFSET, puis
   WHERE, jointures... Idéalement en se rapprochant de l'algèbre relationnelle
   (projection, sélection, tri...), comme le conseille le sujet.
   ============================================================================= *)

(* Ce qui suit le mot-clé SELECT. *)
type select_list =
  | Star                       (* SELECT *            : toutes les colonnes *)
  | Columns of string list     (* SELECT c, a         : colonnes nommées, dans l'ordre demandé *)

(* Une requête complète. Un enregistrement (record) plutôt qu'un tuple :
   on pourra ajouter des champs (order_by, limit...) sans casser le code existant
   qui utilise q.select et q.from. *)
type query = {
  select : select_list;   (* quoi afficher *)
  from : string;          (* nom de la table (FROM t) *)
}
