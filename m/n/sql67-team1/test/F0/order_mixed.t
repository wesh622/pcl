Une seule valeur non numérique suffit : toute la colonne est comparée en texte,
octet par octet (casse incluse, majuscules avant minuscules). NULL en premier.

  $ cat > mixed.csv << EOF
  > v
  > 10
  > 9
  > b
  > 
  > B
  > 100
  > EOF
  $ "$TESTDIR/order_mixed/order_mixed.out" mixed.csv
  v
  
  10
  100
  9
  B
  b
