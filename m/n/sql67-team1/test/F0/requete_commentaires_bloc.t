Commentaires /* */ sur plusieurs lignes et collés aux mots-clés.

Fiabilité : probable (proposition en attente ou comportement commun aux 3 SGBD).

Requête :

| /* rapport
|    hebdomadaire */SELECT/**/produit,prix/* TTC */FROM ventes ORDER/* x */BY prix DESC LIMIT 2;

  $ "$TESTDIR/requete_commentaires_bloc/requete_commentaires_bloc.out" "$TESTDIR/data/ventes.csv"
  produit,prix
  "tarte, mirabelles",18.5
  "le ""spécial"" du chef",4.9
