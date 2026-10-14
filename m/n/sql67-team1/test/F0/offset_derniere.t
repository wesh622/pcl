OFFSET laisse exactement la dernière ligne.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT id, produit FROM ventes LIMIT 5 OFFSET 9;`

  $ "$TESTDIR/offset_derniere/offset_derniere.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  id,produit
  10,croissant
