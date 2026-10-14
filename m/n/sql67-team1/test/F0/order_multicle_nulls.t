Deux clés de sens opposés, NULL dans les deux.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT vendeuse, qte, id FROM ventes ORDER BY vendeuse DESC, qte;`

  $ "$TESTDIR/order_multicle_nulls/order_multicle_nulls.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  vendeuse,qte,id
  Sandrine,2,8
  Sandrine,3,1
  Sandrine,6,2
  Mélanie,1,5
  Mélanie,1,9
  Mélanie,2,3
  Kevin,,10
  Kevin,4,7
  Kevin,12,6
  ,1,4
