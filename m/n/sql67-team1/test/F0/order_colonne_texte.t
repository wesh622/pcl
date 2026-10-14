Un seul "NC" : toute la colonne est du texte, "12" < "3" < "7" < "NC".

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT nom, velos_dispo FROM stations ORDER BY velos_dispo;`

  $ "$TESTDIR/order_colonne_texte/order_colonne_texte.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  nom,velos_dispo
  Saint-Max Mairie,
  Gare - Thiers,0
  "Brabois, Hôpitaux",12
  Laxou Champ-le-Bœuf,3
  Place Stanislas,7
  Artem,NC
