SELECT name, rate FROM employees ORDER BY rate;

  $ "$TESTDIR/order_rate/order_rate.out" "$TESTDIR/data/employees.csv"
  name,rate
  Farid,0.5
  "Chen, Li",2.75
  Alice,3.5
  Bob,4.25
  Eve,4.25
  Dana,10
