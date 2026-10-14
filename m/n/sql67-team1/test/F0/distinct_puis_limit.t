DISTINCT s'applique avant OFFSET/LIMIT.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT DISTINCT produit FROM ventes ORDER BY produit LIMIT 3 OFFSET 1;`

  $ "$TESTDIR/distinct_puis_limit/distinct_puis_limit.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  produit
  croissant
  "le ""spécial"" du chef"
  macaron de Nancy
