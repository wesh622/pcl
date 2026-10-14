SELECT id FROM employees LIMIT 2 OFFSET 3;

  $ "$TESTDIR/limit_offset/limit_offset.out" "$TESTDIR/data/employees.csv"
  id
  4
  5
