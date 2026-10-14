SELECT name AS who, points pts FROM employees;

  $ "$TESTDIR/proj_alias/proj_alias.out" "$TESTDIR/data/employees.csv"
  who,pts
  Alice,120
  Bob,95
  "Chen, Li",120
  Dana,10
  Eve,
  Farid,300
