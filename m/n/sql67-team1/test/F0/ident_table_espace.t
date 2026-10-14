Table et colonne avec une espace.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT nom, "note finale" FROM "notes 2A";`

  $ "$TESTDIR/ident_table_espace/ident_table_espace.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  nom,note finale
  Rossi,14.5
  Weber,9.5
  Haddad,16.25
  Klein,9.5
