Le programme ne modifie jamais les CSV reçus.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT * FROM ventes ORDER BY prix;`

  $ cp "$TESTDIR/data/ventes.csv" copie.csv
  $ "$TESTDIR/table_non_modifiee/table_non_modifiee.out" "$TESTDIR/data/ventes.csv" > /dev/null
  $ cmp copie.csv "$TESTDIR/data/ventes.csv"
