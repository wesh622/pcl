La même colonne deux fois.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT produit, prix, produit FROM ventes;`

  $ "$TESTDIR/proj_doublee/proj_doublee.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  produit,prix,produit
  baguette tradition,1.2,baguette tradition
  croissant,1.1,croissant
  pain aux raisins,1.45,pain aux raisins
  baguette tradition,1.2,baguette tradition
  "tarte, mirabelles",18.5,"tarte, mirabelles"
  croissant,1.1,croissant
  macaron de Nancy,2.3,macaron de Nancy
  baguette tradition,1.2,baguette tradition
  "le ""spécial"" du chef",4.9,"le ""spécial"" du chef"
  croissant,1.1,croissant
