L'en-tête « nom, prenom, tel » n'a pas de colonne prenom, seulement " prenom".

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT prenom FROM contacts;`

  $ "$TESTDIR/csv_espace_entete/csv_espace_entete.out" "$TESTDIR/data/contacts.csv"
  Error: no such column: prenom
  [1]
