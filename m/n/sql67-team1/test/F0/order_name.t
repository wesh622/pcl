SELECT name FROM employees ORDER BY name;

  $ "$TESTDIR/order_name/order_name.out" "$TESTDIR/data/employees.csv"
  name
  Alice
  Bob
  "Chen, Li"
  Dana
  Eve
  Farid
