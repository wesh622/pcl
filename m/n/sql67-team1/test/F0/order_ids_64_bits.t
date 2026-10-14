Entiers au-delà de 2^53 : un tri via double les confond.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT id, libelle FROM transactions ORDER BY id DESC;`

  $ "$TESTDIR/order_ids_64_bits/order_ids_64_bits.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  id,libelle
  1146893754324553731,CB BOULANGERIE PAUL
  1146893754324553730,PRLV FREE MOBILE
  1146893754324553729,CB CARREFOUR NANCY
  1146893754324553728,VIR SALAIRE SEPT
