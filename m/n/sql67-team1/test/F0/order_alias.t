SELECT name AS n FROM employees ORDER BY n DESC;

  $ "$TESTDIR/order_alias/order_alias.out" "$TESTDIR/data/employees.csv"
  n
  Farid
  Eve
  Dana
  "Chen, Li"
  Bob
  Alice
