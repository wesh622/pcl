2 000 colonnes : on projette la dernière et la première.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT c2000, c1 FROM t;`

  $ awk 'BEGIN { for (r = 0; r < 3; r++) { l = ""; for (i = 1; i <= 2000; i++) l = l (i > 1 ? "," : "") (r ? r * i : "c" i); print l } }' > t.csv
  $ "$TESTDIR/csv_mille_colonnes/csv_mille_colonnes.out" t.csv
  c2000,c1
  2000,1
  4000,2
