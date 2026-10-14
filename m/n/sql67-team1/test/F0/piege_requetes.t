Requêtes à la forme inhabituelle mais valides.

Casse mélangée, tabulations, commentaires -- et /* */ (même collés aux mots-clés) :

Requête :

| -- requête du tableau de bord
| sElEcT  /* colonnes
|    utiles */ produit  -- le nom
|   ,prix AS "Prix" FROM
| 
|   ventes /**/ OrDeR/* collé */bY prix DeSc, id
| LiMiT 3 -- top 3
| ;

  $ "$TESTDIR/piege_commentaires/piege_commentaires.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv"
  produit,Prix
  "tarte, mirabelles",18.50
  "le ""spécial"" du chef",4.90
  macaron de Nancy,2.3

Fichier .sql en fins de ligne Windows (CRLF) :

  $ "$TESTDIR/piege_crlf/piege_crlf.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv"
  client
  M. Hoang
  Mme Lefèvre

LIMIT au maximum d'un entier 64 bits, et OFFSET au-delà : pas d'erreur.

Requête : `SELECT id FROM ventes LIMIT 9223372036854775807 OFFSET 8;`

  $ "$TESTDIR/piege_limit_enorme/piege_limit_enorme.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv"
  id
  9
  10

Requête : `SELECT id FROM ventes LIMIT 5 OFFSET 99999999999999999999;`

  $ "$TESTDIR/piege_offset_enorme/piege_offset_enorme.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv"
  id

Colonne inconnue dans la 2e clé d'ORDER BY : erreur, et rien sur stdout (pas d'en-tête).

Requête : `SELECT produit FROM ventes ORDER BY produit, prix_ttc;`

  $ "$TESTDIR/piege_order_inconnue/piege_order_inconnue.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv"
  Error: no such column: prix_ttc
  [1]
