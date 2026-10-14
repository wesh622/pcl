Fichier .sql en fins de ligne Windows (CRLF).

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête :

| SELECT client
| FROM "order"
| ORDER BY total
| LIMIT 2;

  $ "$TESTDIR/requete_crlf/requete_crlf.out" "$TESTDIR/data/order.csv"
  client
  M. Hoang
  Mme Lefèvre
