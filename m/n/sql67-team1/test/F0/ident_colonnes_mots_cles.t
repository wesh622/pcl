Colonne "desc" et alias "limit" : mots-clés délimités, utilisés jusque dans ORDER BY.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT "desc", client AS "limit" FROM "order" ORDER BY "limit" DESC, id;`

  $ "$TESTDIR/ident_colonnes_mots_cles/ident_colonnes_mots_cles.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  desc,limit
  lot de 50 boîtes,SARL Krauss
  "moule à tarte, 28cm",Mme Lefèvre
  ,M. Hoang
  farine T65 25kg,Boulangerie Paul
  levure fraîche x10,Boulangerie Paul
