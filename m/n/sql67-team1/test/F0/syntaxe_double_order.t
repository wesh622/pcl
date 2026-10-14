Deux ORDER BY. Erreur de syntaxe à l'exécution.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT id FROM ventes ORDER BY id ORDER BY prix;`

  $ "$TESTDIR/syntaxe_double_order/syntaxe_double_order.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv"
  Error: syntax error
  [1]
