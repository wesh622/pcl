Le tri s'applique avant OFFSET.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT produit, prix FROM ventes ORDER BY prix LIMIT 2 OFFSET 7;`

  $ "$TESTDIR/order_puis_offset/order_puis_offset.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  produit,prix
  macaron de Nancy,2.3
  "le ""spécial"" du chef",4.9
