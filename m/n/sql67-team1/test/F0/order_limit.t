SELECT name FROM employees ORDER BY points DESC LIMIT 2;

  $ "$TESTDIR/order_limit/order_limit.out" "$TESTDIR/data/employees.csv"
  name
  Farid
  Alice
