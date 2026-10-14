SELECT salary FROM employees;

  $ "$TESTDIR/proj_unknown/proj_unknown.out" "$TESTDIR/data/employees.csv"
  Error: no such column: salary
  [1]
