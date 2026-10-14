Requêtes hors F0 ou mal formées : le programme compile, mais échoue à l'exécution.

Requête : `SELECT * FROM (SELECT * FROM ventes);`

  $ "$TESTDIR/piege_err_sous_requete/piege_err_sous_requete.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv"
  Error: syntax error
  [1]

Requête : `SELECT id FROM ventes ORDER BY id ORDER BY prix;`

  $ "$TESTDIR/piege_err_double_order/piege_err_double_order.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv"
  Error: syntax error
  [1]

Requête : `SELECT id FROM ventes LIMIT 1 ORDER BY id;`

  $ "$TESTDIR/piege_err_ordre_clauses/piege_err_ordre_clauses.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv"
  Error: syntax error
  [1]

Requête : `SELECT id FROM ventes LIMIT 1 LIMIT 2;`

  $ "$TESTDIR/piege_err_double_limit/piege_err_double_limit.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv"
  Error: syntax error
  [1]

Requête : `SELECT id FROM ventes FROM etudiants;`

  $ "$TESTDIR/piege_err_double_from/piege_err_double_from.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv"
  Error: syntax error
  [1]

Requête : `SELECT id, FROM ventes;`

  $ "$TESTDIR/piege_err_virgule/piege_err_virgule.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv"
  Error: syntax error
  [1]

Requête : `SELECT from FROM ventes;`

  $ "$TESTDIR/piege_err_mot_cle/piege_err_mot_cle.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv"
  Error: syntax error
  [1]

Requête : `SELECT id FROM ventes LIMIT 1.5;`

  $ "$TESTDIR/piege_err_limit_float/piege_err_limit_float.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv"
  Error: syntax error
  [1]

Requête : `SELECT * AS tout FROM ventes;`

  $ "$TESTDIR/piege_err_etoile_alias/piege_err_etoile_alias.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv"
  Error: syntax error
  [1]

Requête : `SELECT "produit FROM ventes;`

  $ "$TESTDIR/piege_err_guillemet/piege_err_guillemet.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv"
  Error: syntax error
  [1]

Requête : `SELECT id FROM ventes /* oublié de fermer`

  $ "$TESTDIR/piege_err_commentaire/piege_err_commentaire.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv"
  Error: syntax error
  [1]

Requête : `SELECT id FROM ventes ORDER BY;`

  $ "$TESTDIR/piege_err_order_vide/piege_err_order_vide.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv"
  Error: syntax error
  [1]

Requête : `SELECT;`

  $ "$TESTDIR/piege_err_select_seul/piege_err_select_seul.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv"
  Error: syntax error
  [1]
