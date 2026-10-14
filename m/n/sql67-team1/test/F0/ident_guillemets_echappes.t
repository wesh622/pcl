Alias avec guillemets doublés et virgule : l'en-tête produit doit être ré-échappé.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT produit AS "le ""best""", prix AS "prix, TTC" FROM ventes LIMIT 2;`

  $ "$TESTDIR/ident_guillemets_echappes/ident_guillemets_echappes.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  "le ""best""","prix, TTC"
  baguette tradition,1.2
  croissant,1.1
