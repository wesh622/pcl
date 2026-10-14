Colonne entière : comparaison numérique (négatifs, grands entiers). NULL en dernier en DESC.

  $ cat > nums.csv << EOF
  > v
  > -3
  > 
  > 9223372036854775807
  > 20
  > +7
  > EOF
  $ "$TESTDIR/order_ints/order_ints.out" nums.csv
  v
  9223372036854775807
  20
  +7
  -3
  

Colonne flottante : entiers et flottants mélangés, notation scientifique.

  $ cat > nums.csv << EOF
  > v
  > 1e2
  > 2.5
  > 3
  > .5
  > EOF
  $ "$TESTDIR/order_ints/order_ints.out" nums.csv
  v
  1e2
  3
  2.5
  .5
