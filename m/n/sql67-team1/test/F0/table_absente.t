Aucun argument ne s'appelle clients.csv.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT * FROM clients;`

  $ "$TESTDIR/table_absente/table_absente.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  Error: no such table: clients
  [1]
