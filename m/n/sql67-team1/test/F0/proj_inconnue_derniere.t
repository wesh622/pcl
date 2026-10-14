La colonne inexistante est la dernière : aucune ligne ne doit sortir avant l'erreur.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT id, produit, qte, prix, remise FROM ventes;`

  $ "$TESTDIR/proj_inconnue_derniere/proj_inconnue_derniere.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  Error: no such column: remise
  [1]
