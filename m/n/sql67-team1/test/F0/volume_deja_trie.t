1 000 000 de lignes déjà triées dans le sens demandé : pire cas d'un quicksort naïf
(temps quadratique ou débordement de pile).

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT n FROM gros ORDER BY n DESC LIMIT 3;`

  $ seq 1000000 -1 1 | awk 'BEGIN { print "n" } { print }' > gros.csv
  $ "$TESTDIR/volume_deja_trie/volume_deja_trie.out" gros.csv
  n
  1000000
  999999
  999998
