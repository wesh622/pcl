Dernière ligne sans saut de ligne, et dernier champ quoté.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT * FROM t;`

  $ printf 'a,b\n1,2\n3,"4"' > t.csv
  $ "$TESTDIR/csv_sans_saut_final/csv_sans_saut_final.out" t.csv
  a,b
  1,2
  3,4
