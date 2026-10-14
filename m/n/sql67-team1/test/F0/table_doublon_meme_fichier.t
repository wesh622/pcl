Le même fichier passé deux fois.

Fiabilité : probable (proposition en attente ou comportement commun aux 3 SGBD).

Requête : `SELECT * FROM ventes;`

  $ "$TESTDIR/table_doublon_meme_fichier/table_doublon_meme_fichier.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/ventes.csv"
  Error: duplicate table: ventes
  [1]
