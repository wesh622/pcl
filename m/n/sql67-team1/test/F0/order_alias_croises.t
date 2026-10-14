Alias croisés : dans ORDER BY, l'alias passe avant la colonne de la table
(comme SQLite, PostgreSQL et MariaDB).

Fiabilité : probable (proposition en attente ou comportement commun aux 3 SGBD).

Requête : `SELECT nom AS commune, commune AS nom FROM stations ORDER BY nom, commune DESC;`

  $ "$TESTDIR/order_alias_croises/order_alias_croises.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  commune,nom
  Laxou Champ-le-Bœuf,Laxou
  Place Stanislas,Nancy
  Gare - Thiers,Nancy
  Artem,Nancy
  Saint-Max Mairie,Saint-Max
  "Brabois, Hôpitaux",Vandœuvre-lès-Nancy
