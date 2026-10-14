Deux NULL sont égaux pour DISTINCT : il n'en reste qu'un.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT DISTINCT ville, cp FROM inscrits ORDER BY ville;`

  $ printf 'nom,ville,cp\nAdam,Nancy,54000\nBrun,,\nCaron,Metz,57000\nDiallo,,\nEvrard,Nancy,54000\nFaure,Metz,\n' > inscrits.csv
  $ "$TESTDIR/distinct_null/distinct_null.out" inscrits.csv
  ville,cp
  ,
  Metz,57000
  Metz,
  Nancy,54000
