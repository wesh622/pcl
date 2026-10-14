LIMIT avant ORDER BY. Erreur de syntaxe à l'exécution.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT id FROM ventes LIMIT 1 ORDER BY id;`

  $ "$TESTDIR/syntaxe_clauses_inversees/syntaxe_clauses_inversees.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv"
  Error: syntax error
  [1]
