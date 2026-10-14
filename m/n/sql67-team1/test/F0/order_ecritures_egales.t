1.20, 1.2 et 1.200 sont le même nombre : à valeur égale, l'ordre du fichier est gardé.
On n'affiche que les références, pour ne pas dépendre de l'écriture des nombres.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT ref FROM tarifs ORDER BY prix;`

  $ printf 'ref,prix\nB12,1.20\nA07,0.95\nC33,1.2\nD01,1.200\nE18,10\n' > tarifs.csv
  $ "$TESTDIR/order_ecritures_egales/order_ecritures_egales.out" tarifs.csv
  ref
  A07
  B12
  C33
  D01
  E18
