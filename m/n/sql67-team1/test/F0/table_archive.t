Le dossier ne compte pas : archive/ventes.csv est la table ventes.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT * FROM ventes;`

  $ "$TESTDIR/table_archive/table_archive.out" "$TESTDIR/data/archive/ventes.csv" "$TESTDIR/data/order.csv"
  id,date,produit,qte,prix,vendeuse
  1,2026-08-30,baguette tradition,5,1.15,Sandrine
