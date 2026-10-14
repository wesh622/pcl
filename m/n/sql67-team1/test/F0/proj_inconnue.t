Colonne inexistante : erreur avant toute écriture sur stdout, code 1.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT produit, remise FROM ventes;`

  $ "$TESTDIR/proj_inconnue/proj_inconnue.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  Error: no such column: remise
  [1]
