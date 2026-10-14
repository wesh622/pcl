Le tri s'applique avant LIMIT.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT produit, prix FROM ventes ORDER BY prix DESC LIMIT 3;`

  $ "$TESTDIR/order_puis_limit/order_puis_limit.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  produit,prix
  "tarte, mirabelles",18.5
  "le ""spécial"" du chef",4.9
  macaron de Nancy,2.3
