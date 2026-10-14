Colonnes dans un autre ordre que le fichier.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT vendeuse, date, id FROM ventes;`

  $ "$TESTDIR/proj_reordonnee/proj_reordonnee.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  vendeuse,date,id
  Sandrine,2026-09-01,1
  Sandrine,2026-09-01,2
  Mélanie,2026-09-01,3
  ,2026-09-02,4
  Mélanie,2026-09-02,5
  Kevin,2026-09-02,6
  Kevin,2026-09-03,7
  Sandrine,2026-09-03,8
  Mélanie,2026-09-03,9
  Kevin,2026-09-04,10
