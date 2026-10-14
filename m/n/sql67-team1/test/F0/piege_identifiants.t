Identifiants délimités (eltravail.md, identifiants SQL) : mots-clés, espaces,
guillemets doublés. Toutes les tables sont passées, la requête choisit la sienne.

Une table nommée par un mot-clé (order.csv) et des colonnes "desc", "limit" :

Requête : `SELECT "desc", total AS "limit" FROM "order" ORDER BY "limit" DESC;`

  $ "$TESTDIR/piege_mots_cles/piege_mots_cles.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv"
  desc,limit
  lot de 50 boîtes,89
  farine T65 25kg,42.90
  levure fraîche x10,15.80
  "moule à tarte, 28cm",12.5
  ,7.00

Une table dont le nom contient une espace ("notes 2A.csv"), égalité départagée par nom :

Requête : `SELECT nom, "note finale" FROM "notes 2A" ORDER BY "note finale", nom;`

  $ "$TESTDIR/piege_table_espace/piege_table_espace.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv"
  nom,note finale
  Klein,9.5
  Weber,9.5
  Rossi,14
  Haddad,16

SELECT *, ..., * : toutes les colonnes deux fois, comme SQLite :

Requête : `SELECT *, nom AS encore, * FROM "notes 2A";`

  $ "$TESTDIR/piege_etoile_double/piege_etoile_double.out" "$TESTDIR/data/notes 2A.csv"
  nom,note finale,commentaire,encore,nom,note finale,commentaire
  Rossi,14,"bon travail, attention aux tests",Rossi,Rossi,14,"bon travail, attention aux tests"
  Weber,9.5,,Weber,Weber,9.5,
  Haddad,16,RAS,Haddad,Haddad,16,RAS
  Klein,9.5,"rendu en retard (""oublié"" le tag)",Klein,Klein,9.5,"rendu en retard (""oublié"" le tag)"

Alias croisés : dans ORDER BY, l'alias du SELECT passe avant la colonne de la table.
ORDER BY nom trie donc sur la commune, et ORDER BY commune sur le nom de station :

Requête : `SELECT nom AS commune, commune AS nom FROM stations ORDER BY nom, commune DESC;`

  $ "$TESTDIR/piege_alias_croises/piege_alias_croises.out" "$TESTDIR/data/stations.csv" "$TESTDIR/data/ventes.csv"
  commune,nom
  Laxou Champ-le-Bœuf,Laxou
  Place Stanislas,Nancy
  Gare - Thiers,Nancy
  Artem,Nancy
  Saint-Max Mairie,Saint-Max
  "Brabois, Hôpitaux",Vandœuvre-lès-Nancy
