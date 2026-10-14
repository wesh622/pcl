Projection de deux colonnes.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT produit, prix FROM ventes;`

  $ "$TESTDIR/proj_colonnes/proj_colonnes.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  produit,prix
  baguette tradition,1.2
  croissant,1.1
  pain aux raisins,1.45
  baguette tradition,1.2
  "tarte, mirabelles",18.5
  croissant,1.1
  macaron de Nancy,2.3
  baguette tradition,1.2
  "le ""spécial"" du chef",4.9
  croissant,1.1
