Deux clés, sens opposés, NULL dans les deux (NULL = plus petite valeur) :

Requête : `SELECT vendeuse, qte, id FROM ventes ORDER BY vendeuse DESC, qte;`

  $ "$TESTDIR/piege_null_multicle/piege_null_multicle.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv"
  vendeuse,qte,id
  Sandrine,2,8
  Sandrine,3,1
  Sandrine,6,2
  Mélanie,1,5
  Mélanie,1,9
  Mélanie,2,3
  Kevin,,10
  Kevin,4,7
  Kevin,12,6
  ,1,4

DISTINCT s'applique avant OFFSET/LIMIT, et NULL compte comme une valeur :

Requête : `SELECT DISTINCT vendeuse FROM ventes ORDER BY vendeuse LIMIT 2 OFFSET 1;`

  $ "$TESTDIR/piege_distinct_limit/piege_distinct_limit.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv"
  vendeuse
  Kevin
  Mélanie

DISTINCT sur deux colonnes, avec un NULL et des doublons partiels :

Requête : `SELECT DISTINCT vendeuse, produit FROM ventes ORDER BY produit, vendeuse;`

  $ "$TESTDIR/piege_distinct_null/piege_distinct_null.out" "$TESTDIR/data/ventes.csv" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv"
  vendeuse,produit
  ,baguette tradition
  Sandrine,baguette tradition
  Kevin,croissant
  Sandrine,croissant
  Mélanie,"le ""spécial"" du chef"
  Kevin,macaron de Nancy
  Mélanie,pain aux raisins
  Mélanie,"tarte, mirabelles"
