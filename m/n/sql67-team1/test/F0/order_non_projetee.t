Tri sur une colonne absente du SELECT.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT produit FROM ventes ORDER BY prix DESC, id;`

  $ "$TESTDIR/order_non_projetee/order_non_projetee.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  produit
  "tarte, mirabelles"
  "le ""spécial"" du chef"
  macaron de Nancy
  pain aux raisins
  baguette tradition
  baguette tradition
  baguette tradition
  croissant
  croissant
  croissant
