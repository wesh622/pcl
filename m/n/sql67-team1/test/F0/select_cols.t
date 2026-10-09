Test F0 : projection. Seules les colonnes demandées sont affichées,
dans l'ordre de la requête (c puis a), pas dans l'ordre du CSV.

  $ "$TESTDIR/select_cols/select_cols.out" "$TESTDIR/data/t.csv"
  c,a
  3,1
  6,4
