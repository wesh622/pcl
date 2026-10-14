Une colonne puis l'étoile.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT nom, * FROM "notes 2A";`

  $ "$TESTDIR/etoile_et_colonne/etoile_et_colonne.out" "$TESTDIR/data/notes 2A.csv"
  nom,nom,note finale,commentaire
  Rossi,Rossi,14.5,"bon travail, attention aux tests"
  Weber,Weber,9.5,
  Haddad,Haddad,16.25,RAS
  Klein,Klein,9.5,"rendu en retard (""oublié"" le tag)"
