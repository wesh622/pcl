Le message donne le nom du fichier seul, pas le chemin.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT * FROM t;`

  $ mkdir -p un/deux && printf 'a\n"x\n' > un/deux/t.csv
  $ "$TESTDIR/csv_invalide_chemin/csv_invalide_chemin.out" un/deux/t.csv
  Error: invalid CSV file t.csv
  [1]
