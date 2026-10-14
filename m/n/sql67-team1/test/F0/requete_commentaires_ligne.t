Commentaires -- en début, en fin de ligne et à la fin.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête :

| -- top des ventes
| SELECT produit, -- le nom
|   prix
| FROM ventes -- la table
| ORDER BY prix DESC LIMIT 2; -- fin

  $ "$TESTDIR/requete_commentaires_ligne/requete_commentaires_ligne.out" "$TESTDIR/data/ventes.csv"
  produit,prix
  "tarte, mirabelles",18.5
  "le ""spécial"" du chef",4.9
