SELECT * FROM nope;

  $ "$TESTDIR/table_unknown/table_unknown.out" "$TESTDIR/data/employees.csv"
  Error: no such table: nope
  [1]
