ORDER BY sans clé. Erreur de syntaxe à l'exécution.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT id FROM ventes ORDER BY;`

  $ "$TESTDIR/syntaxe_order_vide/syntaxe_order_vide.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv"
  Error: syntax error
  [1]
