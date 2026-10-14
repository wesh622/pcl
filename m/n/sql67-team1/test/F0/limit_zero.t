SELECT id FROM employees LIMIT 0;

  $ "$TESTDIR/limit_zero/limit_zero.out" "$TESTDIR/data/employees.csv"
  id
