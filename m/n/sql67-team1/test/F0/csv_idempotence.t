Relire sa propre sortie redonne exactement la même sortie.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT * FROM ventes;`

  $ "$TESTDIR/csv_idempotence/csv_idempotence.out" "$TESTDIR/data/ventes.csv" > ventes.csv
  $ mkdir relu && cp ventes.csv relu/ventes.csv
  $ "$TESTDIR/csv_idempotence/csv_idempotence.out" relu/ventes.csv > encore.csv
  $ cmp ventes.csv encore.csv
