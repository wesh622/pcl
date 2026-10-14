SELECT SELECT. Erreur de syntaxe à l'exécution.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT SELECT id FROM ventes;`

  $ "$TESTDIR/syntaxe_double_select/syntaxe_double_select.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv"
  Error: syntax error
  [1]
