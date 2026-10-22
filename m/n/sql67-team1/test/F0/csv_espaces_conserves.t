Requête : `SELECT * FROM contacts;`

  $ "$TESTDIR/csv_espaces_conserves/csv_espaces_conserves.out" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/ventes.csv" | sed 's/$/|/'
  nom, prenom, tel|
  Moreau, Julie, 06 12 34 56 78|
  Garcia, Tom, |
  Petit, Sarah, 07 98 76 54 32|
