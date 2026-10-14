Deux LIMIT. Erreur de syntaxe à l'exécution.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT id FROM ventes LIMIT 1 LIMIT 2;`

  $ "$TESTDIR/syntaxe_double_limit/syntaxe_double_limit.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv"
  Error: syntax error
  [1]
