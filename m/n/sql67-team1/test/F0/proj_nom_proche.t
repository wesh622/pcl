Le nom de colonne doit correspondre exactement : prix n'est ni prix_ht ni prix_ttc.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT produit, prix FROM tarifs;`

  $ printf 'produit,prix_ht,prix,prix_ttc\nbaguette,1,2,3\ncroissant,4,5,6\n' > tarifs.csv
  $ "$TESTDIR/proj_nom_proche/proj_nom_proche.out" tarifs.csv
  produit,prix
  baguette,2
  croissant,5
