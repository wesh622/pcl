RFC 4180 stricte : un CSV invalide est une erreur, avant toute sortie, avec le
nom du fichier seul (eltravail.md, CSV Parsing).

Guillemet jamais refermé :

  $ printf 'a,b\n1,"abc\n' > t.csv
  $ "$TESTDIR/csv_select/csv_select.out" t.csv
  Error: invalid CSV file t.csv
  [1]

Texte après le guillemet fermant :

  $ printf 'a,b,c\n1,"x"y,3\n' > t.csv
  $ "$TESTDIR/csv_select/csv_select.out" t.csv
  Error: invalid CSV file t.csv
  [1]

Guillemet dans un champ non quoté (l'espace empêche le champ d'être quoté) :

  $ printf 'a, b, "c"\n1,2,3\n' > t.csv
  $ "$TESTDIR/csv_select/csv_select.out" t.csv
  Error: invalid CSV file t.csv
  [1]

Nombre de champs différent de l'en-tête :

  $ printf 'a,b\n1,2,3\n' > t.csv
  $ "$TESTDIR/csv_select/csv_select.out" t.csv
  Error: invalid CSV file t.csv
  [1]

Fichier vide :

  $ : > t.csv
  $ "$TESTDIR/csv_select/csv_select.out" t.csv
  Error: invalid CSV file t.csv
  [1]

Le chemin n'apparaît pas, seulement le nom :

  $ mkdir dir && printf 'a\n"x\n' > dir/t.csv
  $ "$TESTDIR/csv_select/csv_select.out" dir/t.csv
  Error: invalid CSV file t.csv
  [1]
