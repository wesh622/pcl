Alias sur l'étoile. Erreur de syntaxe à l'exécution.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT * AS tout FROM ventes;`

  $ "$TESTDIR/syntaxe_etoile_alias/syntaxe_etoile_alias.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv"
  Error: syntax error
  [1]
