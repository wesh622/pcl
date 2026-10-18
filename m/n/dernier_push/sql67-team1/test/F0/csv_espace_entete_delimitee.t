Requête : `SELECT " prenom" AS p, nom FROM contacts ORDER BY p;`

  $ "$TESTDIR/csv_espace_entete_delimitee/csv_espace_entete_delimitee.out" "$TESTDIR/data/contacts.csv"
  p,nom
   Julie,Moreau
   Sarah,Petit
   Tom,Garcia
