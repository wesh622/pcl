Fichier vide (pas même d'en-tête) : CSV invalide.

Fiabilité : à confirmer (choix de notre groupe, point non tranché sur Gibson).

Requête : `SELECT * FROM t;`

  $ printf '' > t.csv
  $ "$TESTDIR/csv_invalide_vide/csv_invalide_vide.out" t.csv
  Error: invalid CSV file t.csv
  [1]
