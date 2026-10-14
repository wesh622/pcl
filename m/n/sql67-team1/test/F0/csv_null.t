Champs vides = NULL, n'importe où dans la ligne, sortis comme champs vides.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT c, a, b FROM t ORDER BY a DESC;`

  $ printf 'a,b,c\n,,\n1,,x\n,2,\n' > t.csv
  $ "$TESTDIR/csv_null/csv_null.out" t.csv
  c,a,b
  x,1,
  ,,
  ,,2
