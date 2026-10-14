LIMIT puis OFFSET.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT id, produit FROM ventes LIMIT 3 OFFSET 2;`

  $ "$TESTDIR/limit_offset/limit_offset.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  id,produit
  3,pain aux raisins
  4,baguette tradition
  5,"tarte, mirabelles"
