Guillemet jamais refermé : CSV invalide (RFC 4180 stricte).

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT * FROM t;`

  $ printf 'a,b\n1,"abc\n' > t.csv
  $ "$TESTDIR/csv_invalide_guillemet_ouvert/csv_invalide_guillemet_ouvert.out" t.csv
  Error: invalid CSV file t.csv
  [1]
