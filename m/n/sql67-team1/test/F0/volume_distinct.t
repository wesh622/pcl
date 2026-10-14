DISTINCT sur 1 000 000 de lignes et 1 000 valeurs : une recherche linéaire des
doublons (n × valeurs) reste possible, mais n² ne l'est pas.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT DISTINCT v FROM gros ORDER BY v DESC LIMIT 2;`

  $ seq 1 1000000 | awk 'BEGIN { print "v" } { print $1 % 1000 }' > gros.csv
  $ "$TESTDIR/volume_distinct/volume_distinct.out" gros.csv
  v
  999
  998
