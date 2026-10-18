Requête : `SELECT * FROM t;`

  $ printf 'a,b\n1,2\n3,4\n5,"6"7\n' > t.csv
  $ "$TESTDIR/csv_invalide_derniere_ligne/csv_invalide_derniere_ligne.out" t.csv
  Error: invalid CSV file t.csv
  [1]
