LIMIT négatif : erreur de syntaxe.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT id FROM ventes LIMIT -1;`

  $ "$TESTDIR/limit_negative/limit_negative.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  Error: syntax error
  [1]
