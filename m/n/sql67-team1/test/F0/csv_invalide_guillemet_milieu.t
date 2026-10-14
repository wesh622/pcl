Guillemet dans un champ non quoté (après une espace) : CSV invalide.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT * FROM t;`

  $ printf 'a, b, "c"\n1,2,3\n' > t.csv
  $ "$TESTDIR/csv_invalide_guillemet_milieu/csv_invalide_guillemet_milieu.out" t.csv
  Error: invalid CSV file t.csv
  [1]
