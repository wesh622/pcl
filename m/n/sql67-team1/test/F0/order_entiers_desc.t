Même chose en DESC : NULL en dernier.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT produit, qte FROM ventes ORDER BY qte DESC, id;`

  $ "$TESTDIR/order_entiers_desc/order_entiers_desc.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  produit,qte
  croissant,12
  croissant,6
  macaron de Nancy,4
  baguette tradition,3
  pain aux raisins,2
  baguette tradition,2
  baguette tradition,1
  "tarte, mirabelles",1
  "le ""spécial"" du chef",1
  croissant,
