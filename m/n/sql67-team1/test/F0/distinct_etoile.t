DISTINCT * sans doublon : la table entière.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT DISTINCT * FROM "notes 2A";`

  $ "$TESTDIR/distinct_etoile/distinct_etoile.out" "$TESTDIR/data/notes 2A.csv"
  nom,note finale,commentaire
  Rossi,14.5,"bon travail, attention aux tests"
  Weber,9.5,
  Haddad,16.25,RAS
  Klein,9.5,"rendu en retard (""oublié"" le tag)"
