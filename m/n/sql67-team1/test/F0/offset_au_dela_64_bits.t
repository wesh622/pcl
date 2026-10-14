OFFSET au-delà de 64 bits : traité comme « tout sauter », sans erreur.

Fiabilité : à confirmer (choix de notre groupe, point non tranché sur Gibson).

Requête : `SELECT id FROM ventes LIMIT 5 OFFSET 99999999999999999999;`

  $ "$TESTDIR/offset_au_dela_64_bits/offset_au_dela_64_bits.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  id
