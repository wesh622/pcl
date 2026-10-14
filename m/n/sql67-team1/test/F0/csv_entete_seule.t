Table vide (en-tête seul) : la sortie est l'en-tête.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT b, a FROM t ORDER BY a;`

  $ printf 'a,b\n' > t.csv
  $ "$TESTDIR/csv_entete_seule/csv_entete_seule.out" t.csv
  b,a
