SELECT name, points FROM employees ORDER BY points;

  $ "$TESTDIR/order_points/order_points.out" "$TESTDIR/data/employees.csv"
  name,points
  Eve,
  Dana,10
  Bob,95
  Alice,120
  "Chen, Li",120
  Farid,300
