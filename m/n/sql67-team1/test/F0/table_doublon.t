data/ventes.csv et data/archive/ventes.csv : deux tables ventes.

Fiabilité : probable (proposition en attente ou comportement commun aux 3 SGBD).

Requête : `SELECT * FROM ventes;`

  $ "$TESTDIR/table_doublon/table_doublon.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/archive/ventes.csv"
  Error: duplicate table: ventes
  [1]
