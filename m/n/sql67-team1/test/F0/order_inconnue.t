Colonne inexistante dans la 2e clé : erreur, et pas même l'en-tête sur stdout.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT produit FROM ventes ORDER BY produit, prix_ttc;`

  $ "$TESTDIR/order_inconnue/order_inconnue.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  Error: no such column: prix_ttc
  [1]
