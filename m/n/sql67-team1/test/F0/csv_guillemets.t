Champs quotés : virgule, guillemets doublés, saut de ligne, et en-tête quoté.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT * FROM t;`

  $ printf 'nom,"note, finale"\n"Le ""grand"" Duc",12\n"sur deux\nlignes",8\n"simple",9\n' > t.csv
  $ "$TESTDIR/csv_guillemets/csv_guillemets.out" t.csv
  nom,"note, finale"
  "Le ""grand"" Duc",12
  "sur deux
  lignes",8
  simple,9
