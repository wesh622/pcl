ASC explicite.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT nom, capacite FROM stations ORDER BY capacite ASC;`

  $ "$TESTDIR/order_asc_explicite/order_asc_explicite.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  nom,capacite
  Saint-Max Mairie,12
  Laxou Champ-le-Bœuf,14
  "Brabois, Hôpitaux",16
  Artem,18
  Place Stanislas,20
  Gare - Thiers,30
