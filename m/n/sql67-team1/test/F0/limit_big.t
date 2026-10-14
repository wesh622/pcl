SELECT id FROM employees LIMIT 1000000;

  $ "$TESTDIR/limit_big/limit_big.out" "$TESTDIR/data/employees.csv"
  id
  1
  2
  3
  4
  5
  6
