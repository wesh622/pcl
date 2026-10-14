DISTINCT puis tri décroissant.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT DISTINCT commune FROM stations ORDER BY commune DESC;`

  $ "$TESTDIR/distinct_colonne_triee/distinct_colonne_triee.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  commune
  Vandœuvre-lès-Nancy
  Saint-Max
  Nancy
  Laxou
