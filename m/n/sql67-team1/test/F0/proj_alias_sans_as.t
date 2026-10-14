Renommage sans AS (standard SQL, accepté par SQLite, PostgreSQL et MariaDB).

Fiabilité : probable (proposition en attente ou comportement commun aux 3 SGBD).

Requête : `SELECT produit article, qte quantite FROM ventes;`

  $ "$TESTDIR/proj_alias_sans_as/proj_alias_sans_as.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  article,quantite
  baguette tradition,3
  croissant,6
  pain aux raisins,2
  baguette tradition,1
  "tarte, mirabelles",1
  croissant,12
  macaron de Nancy,4
  baguette tradition,2
  "le ""spécial"" du chef",1
  croissant,
