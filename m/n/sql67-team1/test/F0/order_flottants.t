Colonne flottante : 18.5 > 4.9 > 2.3 (en texte, "18.5" < "2.3" < "4.9").

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT produit, prix FROM ventes ORDER BY prix DESC, id;`

  $ "$TESTDIR/order_flottants/order_flottants.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  produit,prix
  "tarte, mirabelles",18.5
  "le ""spécial"" du chef",4.9
  macaron de Nancy,2.3
  pain aux raisins,1.45
  baguette tradition,1.2
  baguette tradition,1.2
  baguette tradition,1.2
  croissant,1.1
  croissant,1.1
  croissant,1.1
