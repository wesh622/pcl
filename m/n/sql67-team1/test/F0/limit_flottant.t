LIMIT non entier : erreur de syntaxe.

Fiabilité : probable (proposition en attente ou comportement commun aux 3 SGBD).

Requête : `SELECT id FROM ventes LIMIT 1.5;`

  $ "$TESTDIR/limit_flottant/limit_flottant.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  Error: syntax error
  [1]
