1 000 000 de lignes, clé à 3 valeurs : tri stable obligatoire, et un tri quadratique
dépasse largement la limite de 2 minutes.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT k, n FROM gros ORDER BY k DESC;`

  $ seq 1 1000000 | awk 'BEGIN { print "k,n" } { print $1 % 3 "," $1 }' > gros.csv
  $ "$TESTDIR/volume_egalites/volume_egalites.out" gros.csv > res.csv
  $ wc -l < res.csv
  1000001
  $ head -4 res.csv
  k,n
  2,2
  2,5
  2,8
  $ tail -2 res.csv
  0,999996
  0,999999
