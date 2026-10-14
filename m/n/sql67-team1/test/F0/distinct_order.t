SELECT DISTINCT year FROM employees ORDER BY year DESC;

  $ "$TESTDIR/distinct_order/distinct_order.out" "$TESTDIR/data/employees.csv"
  year
  2021
  2020
  2019
  2018
