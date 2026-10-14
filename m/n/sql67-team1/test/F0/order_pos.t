SELECT name, year FROM employees ORDER BY 2, 1;

  $ "$TESTDIR/order_pos/order_pos.out" "$TESTDIR/data/employees.csv"
  name,year
  "Chen, Li",2018
  Alice,2019
  Farid,2019
  Eve,2020
  Bob,2021
  Dana,2021
