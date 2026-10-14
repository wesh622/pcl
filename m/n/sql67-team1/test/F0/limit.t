SELECT id FROM employees LIMIT 3;

  $ "$TESTDIR/limit/limit.out" "$TESTDIR/data/employees.csv"
  id
  1
  2
  3
