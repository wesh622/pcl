LIMIT sans valeur. Erreur de syntaxe à l'exécution.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT id FROM ventes LIMIT;`

  $ "$TESTDIR/syntaxe_limit_vide/syntaxe_limit_vide.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv"
  Error: syntax error
  [1]
