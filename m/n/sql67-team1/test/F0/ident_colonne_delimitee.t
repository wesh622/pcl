Identifiants ordinaires écrits délimités.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT "produit", "prix" FROM "ventes" LIMIT 2;`

  $ "$TESTDIR/ident_colonne_delimitee/ident_colonne_delimitee.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  produit,prix
  baguette tradition,1.2
  croissant,1.1
