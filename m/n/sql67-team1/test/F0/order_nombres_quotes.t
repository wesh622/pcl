Un nombre entre guillemets reste un nombre : les guillemets ne sont qu'un échappement CSV.

Fiabilité : probable (proposition en attente ou comportement commun aux 3 SGBD).

Requête : `SELECT ref FROM tarifs ORDER BY qte DESC;`

  $ printf 'ref,qte\nB12,"100"\nA07,9\nC33,"25"\n' > tarifs.csv
  $ "$TESTDIR/order_nombres_quotes/order_nombres_quotes.out" tarifs.csv
  ref
  B12
  C33
  A07
