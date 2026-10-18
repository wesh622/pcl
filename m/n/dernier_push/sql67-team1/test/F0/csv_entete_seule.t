Requête : `SELECT b, a FROM t ORDER BY a;`

  $ printf 'a,b\n' > t.csv
  $ "$TESTDIR/csv_entete_seule/csv_entete_seule.out" t.csv
  b,a
