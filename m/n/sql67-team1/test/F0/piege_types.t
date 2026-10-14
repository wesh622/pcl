Typage par colonne (eltravail.md, Types) : entier, sinon flottant, sinon texte.

Identifiants 64 bits (au-delà de 2^53) : un tri via double les confond tous.

Requête : `SELECT id, libelle FROM transactions ORDER BY id;`

  $ "$TESTDIR/piege_grands_ids/piege_grands_ids.out" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/order.csv"
  id,libelle
  1146893754324553728,VIR SALAIRE SEPT
  1146893754324553729,CB CARREFOUR NANCY
  1146893754324553730,PRLV FREE MOBILE
  1146893754324553731,CB BOULANGERIE PAUL

1.20, 1.2 et 1.10 sont des nombres : 1.20 = 1.2, et le tri stable garde l'ordre du
fichier (1, 4, puis 8). La sortie garde le texte d'origine.

Requête : `SELECT id, produit, prix FROM ventes ORDER BY prix DESC;`

  $ "$TESTDIR/piege_prix_egaux/piege_prix_egaux.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv"
  id,produit,prix
  5,"tarte, mirabelles",18.50
  9,"le ""spécial"" du chef",4.90
  7,macaron de Nancy,2.3
  3,pain aux raisins,1.45
  1,baguette tradition,1.20
  4,baguette tradition,1.20
  8,baguette tradition,1.2
  2,croissant,1.10
  6,croissant,1.10
  10,croissant,1.10

Moyennes entières et décimales mélangées (colonne flottante), 15.5 = 15.50,
NULL en dernier en DESC :

Requête : `SELECT prenom, moyenne FROM etudiants ORDER BY moyenne DESC;`

  $ "$TESTDIR/piege_moyennes/piege_moyennes.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv"
  prenom,moyenne
  Inês,17
  Awa,15.5
  Yanis,15.50
  Lucas,12.75
  Hugo,11
  Erwan,9.25
  Chloé,8.5
  léa,

Un seul "NC" dans velos_dispo : toute la colonne devient texte ("12" < "3").

Requête : `SELECT nom, velos_dispo FROM stations ORDER BY velos_dispo;`

  $ "$TESTDIR/piege_nc/piege_nc.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv"
  nom,velos_dispo
  Saint-Max Mairie,
  Gare - Thiers,0
  "Brabois, Hôpitaux",12
  Laxou Champ-le-Bœuf,3
  Place Stanislas,7
  Artem,NC

Texte comparé octet par octet, casse comprise : "dubois" après "N'Diaye".

Requête : `SELECT nom, prenom FROM etudiants ORDER BY nom, prenom;`

  $ "$TESTDIR/piege_casse/piege_casse.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv"
  nom,prenom
  Benali,Yanis
  Dubois,léa
  Ferreira,Inês
  Le Gall,Erwan
  Martin,Chloé
  Martin,Lucas
  N'Diaye,Awa
  dubois,Hugo
