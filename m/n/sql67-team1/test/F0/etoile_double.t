SELECT *, * : toutes les colonnes deux fois (comme SQLite).

Fiabilité : probable (proposition en attente ou comportement commun aux 3 SGBD).

Requête : `SELECT *, * FROM "notes 2A";`

  $ "$TESTDIR/etoile_double/etoile_double.out" "$TESTDIR/data/notes 2A.csv"
  nom,note finale,commentaire,nom,note finale,commentaire
  Rossi,14.5,"bon travail, attention aux tests",Rossi,14.5,"bon travail, attention aux tests"
  Weber,9.5,,Weber,9.5,
  Haddad,16.25,RAS,Haddad,16.25,RAS
  Klein,9.5,"rendu en retard (""oublié"" le tag)",Klein,9.5,"rendu en retard (""oublié"" le tag)"
