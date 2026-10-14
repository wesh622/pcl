200 000 lignes, générées sur place. Le tri doit être stable et rester rapide : un tri
quadratique, ou un quicksort naïf sur une entrée déjà triée, dépasse la limite de temps.

Clé à 3 valeurs (n mod 3) : beaucoup d'égalités, l'ordre du fichier doit être conservé.

  $ seq 1 200000 | awk 'BEGIN { print "k,n" } { print $1 % 3 "," $1 }' > gros.csv
  $ "$TESTDIR/piege_tri_massif/piege_tri_massif.out" gros.csv > res.csv
  $ wc -l < res.csv
  200001
  $ head -4 res.csv
  k,n
  2,2
  2,5
  2,8
  $ tail -2 res.csv
  0,199995
  0,199998

Entrée déjà triée dans le sens demandé (pire cas d'un quicksort naïf) :

  $ seq 200000 -1 1 | awk 'BEGIN { print "k,n" } { print $1 "," $1 }' > gros.csv
  $ "$TESTDIR/piege_tri_massif/piege_tri_massif.out" gros.csv > res.csv
  $ head -3 res.csv
  k,n
  200000,200000
  199999,199999
  $ tail -1 res.csv
  1,1
