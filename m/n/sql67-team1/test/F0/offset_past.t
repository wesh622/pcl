SELECT id FROM employees LIMIT 5 OFFSET 10;

  $ "$TESTDIR/offset_past/offset_past.out" "$TESTDIR/data/employees.csv"
  id
