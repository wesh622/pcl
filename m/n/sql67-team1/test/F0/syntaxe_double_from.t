Deux FROM. Erreur de syntaxe à l'exécution.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT id FROM ventes FROM etudiants;`

  $ "$TESTDIR/syntaxe_double_from/syntaxe_double_from.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv"
  Error: syntax error
  [1]
