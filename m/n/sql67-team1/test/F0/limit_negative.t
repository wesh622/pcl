SELECT id FROM employees LIMIT -1;

  $ "$TESTDIR/limit_negative/limit_negative.out" "$TESTDIR/data/employees.csv"
  Error: syntax error
  [1]
