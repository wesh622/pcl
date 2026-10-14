SELECT name, points FROM employees ORDER BY points DESC;

  $ "$TESTDIR/order_points_desc/order_points_desc.out" "$TESTDIR/data/employees.csv"
  name,points
  Farid,300
  Alice,120
  "Chen, Li",120
  Bob,95
  Dana,10
  Eve,
