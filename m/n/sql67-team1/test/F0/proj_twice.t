SELECT name, name FROM employees;

  $ "$TESTDIR/proj_twice/proj_twice.out" "$TESTDIR/data/employees.csv"
  name,name
  Alice,Alice
  Bob,Bob
  "Chen, Li","Chen, Li"
  Dana,Dana
  Eve,Eve
  Farid,Farid
