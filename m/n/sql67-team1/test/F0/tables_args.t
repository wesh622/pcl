Association table / fichier (eltravail.md) : FROM t cherche l'argument t.csv.

  $ printf 'a\n1\n' > t.csv
  $ mkdir d && printf 'a\n2\n' > d/t.csv

Deux arguments pour la même table :

  $ "$TESTDIR/csv_select/csv_select.out" t.csv d/t.csv
  Error: duplicate table: t
  [1]

Aucun argument ne nomme la table :

  $ printf 'x\n1\n' > u.csv
  $ "$TESTDIR/csv_select/csv_select.out" u.csv
  Error: no such table: t
  [1]

  $ "$TESTDIR/csv_select/csv_select.out"
  Error: no such table: t
  [1]
