Aucune espace autour des virgules et du point-virgule.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT id,produit,prix FROM ventes ORDER BY prix,id LIMIT 3;`

  $ "$TESTDIR/requete_colle/requete_colle.out" "$TESTDIR/data/ventes.csv"
  id,produit,prix
  2,croissant,1.1
  6,croissant,1.1
  10,croissant,1.1
