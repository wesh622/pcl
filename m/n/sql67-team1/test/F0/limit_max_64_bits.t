Valeur très grande (max d'un entier 64 bits) : pas d'erreur.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT id FROM ventes LIMIT 9223372036854775807 OFFSET 8;`

  $ "$TESTDIR/limit_max_64_bits/limit_max_64_bits.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  id
  9
  10
