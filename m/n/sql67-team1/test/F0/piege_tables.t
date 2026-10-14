Association table / fichier (eltravail.md) : FROM ventes désigne l'argument ventes.csv,
quel que soit son dossier ou sa position parmi les arguments.

En dernière position, après six autres tables :

  $ "$TESTDIR/piege_distinct_limit/piege_distinct_limit.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  vendeuse
  Kevin
  Mélanie

Le fichier de l'archive porte le même nom de table : ventes est en double.

  $ "$TESTDIR/piege_distinct_limit/piege_distinct_limit.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/archive/ventes.csv"
  Error: duplicate table: ventes
  [1]

Le même fichier passé deux fois est aussi un doublon :

  $ "$TESTDIR/piege_distinct_limit/piege_distinct_limit.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/ventes.csv"
  Error: duplicate table: ventes
  [1]

L'archive seule est une table ventes valide :

  $ "$TESTDIR/piege_distinct_limit/piege_distinct_limit.out" "$TESTDIR/data/archive/ventes.csv" "$TESTDIR/data/order.csv"
  vendeuse

Six tables, aucune ne s'appelle ventes :

  $ "$TESTDIR/piege_distinct_limit/piege_distinct_limit.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv"
  Error: no such table: ventes
  [1]

Un fichier ventes.csv créé à la volée, avec un en-tête seul : le résultat n'a que l'en-tête.

  $ printf 'id,date,produit,qte,prix,vendeuse\n' > ventes.csv
  $ "$TESTDIR/piege_distinct_limit/piege_distinct_limit.out" ventes.csv "$TESTDIR/data/etudiants.csv"
  vendeuse

Les CSV reçus ne sont jamais modifiés :

  $ cp "$TESTDIR/data/ventes.csv" copie.csv
  $ "$TESTDIR/piege_prix_egaux/piege_prix_egaux.out" "$TESTDIR/data/ventes.csv" > /dev/null
  $ cmp copie.csv "$TESTDIR/data/ventes.csv"
