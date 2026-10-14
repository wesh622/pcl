L'erreur peut venir de l'en-tête.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT * FROM t;`

  $ printf '"a,b\n1,2\n' > t.csv
  $ "$TESTDIR/csv_invalide_entete/csv_invalide_entete.out" t.csv
  Error: invalid CSV file t.csv
  [1]
