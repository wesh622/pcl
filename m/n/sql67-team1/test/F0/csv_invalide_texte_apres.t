Texte après le guillemet fermant : CSV invalide.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT * FROM t;`

  $ printf 'a,b,c\n1,"x"y,3\n' > t.csv
  $ "$TESTDIR/csv_invalide_texte_apres/csv_invalide_texte_apres.out" t.csv
  Error: invalid CSV file t.csv
  [1]
