Champ de 100 000 caractères et nom de colonne de 5 000 : aucun buffer fixe ne tient.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT * FROM t;`

  $ awk 'BEGIN { h = ""; for (i = 0; i < 5000; i++) h = h "c"; v = ""; for (i = 0; i < 100000; i++) v = v "x"; print "id," h; print "1," v; print "2,ok" }' > t.csv
  $ "$TESTDIR/csv_long_champ/csv_long_champ.out" t.csv > res.csv
  $ cmp res.csv t.csv
  $ wc -c < res.csv
  105012
