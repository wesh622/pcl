SELECT id FROM employees LIMIT 3, 2;

  $ "$TESTDIR/limit_comma/limit_comma.out" "$TESTDIR/data/employees.csv"
  id
  4
  5
