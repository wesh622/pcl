Beaucoup d'égalités : à clé égale, l'ordre du fichier est conservé.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT produit, vendeuse FROM ventes ORDER BY produit;`

  $ "$TESTDIR/order_stable/order_stable.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  produit,vendeuse
  baguette tradition,Sandrine
  baguette tradition,
  baguette tradition,Sandrine
  croissant,Sandrine
  croissant,Kevin
  croissant,Kevin
  "le ""spécial"" du chef",Mélanie
  macaron de Nancy,Kevin
  pain aux raisins,Mélanie
  "tarte, mirabelles",Mélanie
