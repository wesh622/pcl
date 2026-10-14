Une ligne n'a pas autant de champs que l'en-tête : CSV invalide.

Fiabilité : à confirmer (choix de notre groupe, point non tranché sur Gibson).

Requête : `SELECT * FROM t;`

  $ printf 'a,b\n1,2,3\n' > t.csv
  $ "$TESTDIR/csv_invalide_nb_champs/csv_invalide_nb_champs.out" t.csv
  Error: invalid CSV file t.csv
  [1]
