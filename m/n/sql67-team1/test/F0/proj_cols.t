SELECT name, points FROM employees;

  $ "$TESTDIR/proj_cols/proj_cols.out" "$TESTDIR/data/employees.csv"
  name,points
  Alice,120
  Bob,95
  "Chen, Li",120
  Dana,10
  Eve,
  Farid,300
