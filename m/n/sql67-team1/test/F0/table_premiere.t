La table est le 1er argument, les autres ne servent pas.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT nom, ville FROM etudiants LIMIT 2;`

  $ "$TESTDIR/table_premiere/table_premiere.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv"
  nom,ville
  Martin,Nancy
  N'Diaye,Metz
