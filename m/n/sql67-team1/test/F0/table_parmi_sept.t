La table est le 7e argument : il faut chercher ventes.csv parmi tous les arguments.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT id, produit FROM ventes LIMIT 2;`

  $ "$TESTDIR/table_parmi_sept/table_parmi_sept.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  id,produit
  1,baguette tradition
  2,croissant
