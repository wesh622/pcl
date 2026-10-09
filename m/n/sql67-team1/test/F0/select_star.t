Test F0 : SELECT * renvoie toute la table, en-tête compris, sans modification.
Le .out a été produit par le pipeline (SQL67 select_star.sql select_star, puis make).

  $ "$TESTDIR/select_star/select_star.out" "$TESTDIR/data/t.csv"
  a,b,c
  1,2,3
  4,5,6
