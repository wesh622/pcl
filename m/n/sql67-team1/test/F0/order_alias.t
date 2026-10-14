ORDER BY sur un alias.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT produit AS article, prix FROM ventes ORDER BY article DESC, prix;`

  $ "$TESTDIR/order_alias/order_alias.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  article,prix
  "tarte, mirabelles",18.5
  pain aux raisins,1.45
  macaron de Nancy,2.3
  "le ""spécial"" du chef",4.9
  croissant,1.1
  croissant,1.1
  croissant,1.1
  baguette tradition,1.2
  baguette tradition,1.2
  baguette tradition,1.2
