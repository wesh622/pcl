Tabulations, sauts de ligne et espaces partout, mots-clés en casse mélangée.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête :

| sElEcT
|     produit ,prix
|   fRoM  ventes
| 
|   OrDeR  bY  prix  DeSc
|   LiMiT  2
|   ;

  $ "$TESTDIR/requete_blancs/requete_blancs.out" "$TESTDIR/data/ventes.csv"
  produit,prix
  "tarte, mirabelles",18.5
  "le ""spécial"" du chef",4.9
