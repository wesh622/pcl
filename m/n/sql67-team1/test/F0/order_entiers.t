Colonne entière : 12 > 6 (un tri texte donnerait "12" < "6"). NULL en premier.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT produit, qte FROM ventes ORDER BY qte, id;`

  $ "$TESTDIR/order_entiers/order_entiers.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  produit,qte
  croissant,
  baguette tradition,1
  "tarte, mirabelles",1
  "le ""spécial"" du chef",1
  pain aux raisins,2
  baguette tradition,2
  baguette tradition,3
  macaron de Nancy,4
  croissant,6
  croissant,12
