Sortie normalisée (eltravail.md, format output CSV) : guillemets retirés quand
inutiles, gardés quand nécessaires, espaces conservés, NULL = champ vide.

  $ printf 'a, b\n"Ana", x \n"A""na",""\n,"1,2"\n' > t.csv
  $ "$TESTDIR/csv_select/csv_select.out" t.csv
  a, b
  Ana, x 
  "A""na",
  ,"1,2"

Idempotence : relire sa propre sortie redonne la même sortie.

  $ "$TESTDIR/csv_select/csv_select.out" t.csv > t1.csv
  $ mkdir r && cp t1.csv r/t.csv
  $ "$TESTDIR/csv_select/csv_select.out" r/t.csv > t2.csv
  $ cmp t1.csv t2.csv

Saut de ligne final facultatif, fins de ligne CRLF acceptées :

  $ printf 'a,b\r\n1,2' > t.csv
  $ "$TESTDIR/csv_select/csv_select.out" t.csv
  a,b
  1,2

En-tête seul : on affiche l'en-tête.

  $ printf 'a,b\n' > t.csv
  $ "$TESTDIR/csv_select/csv_select.out" t.csv
  a,b
