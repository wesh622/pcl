DISTINCT sur deux colonnes (avec une vendeuse NULL).

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT DISTINCT vendeuse, date FROM ventes ORDER BY date, vendeuse;`

  $ "$TESTDIR/distinct_deux_colonnes/distinct_deux_colonnes.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  vendeuse,date
  Mélanie,2026-09-01
  Sandrine,2026-09-01
  ,2026-09-02
  Kevin,2026-09-02
  Mélanie,2026-09-02
  Kevin,2026-09-03
  Mélanie,2026-09-03
  Sandrine,2026-09-03
  Kevin,2026-09-04
