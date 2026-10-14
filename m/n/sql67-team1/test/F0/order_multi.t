SELECT name, dept_id, points FROM employees ORDER BY dept_id ASC, points DESC;

  $ "$TESTDIR/order_multi/order_multi.out" "$TESTDIR/data/employees.csv"
  name,dept_id,points
  Bob,1,95
  Eve,1,
  Alice,2,120
  "Chen, Li",2,120
  Farid,3,300
  Dana,3,10
