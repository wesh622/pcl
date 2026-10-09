Test F0 : requête invalide (SELECT sans colonnes).
Contrat du sujet : SQL67 et make réussissent quand même ; c'est le programme
qui signale l'erreur à l'exécution, avec un code de retour non nul.

  $ "$TESTDIR/syntax_error/syntax_error.out" "$TESTDIR/data/t.csv"
  Error: syntax error at line 1, column 11
  [2]
