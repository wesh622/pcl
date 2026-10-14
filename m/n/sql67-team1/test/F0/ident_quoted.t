SELECT "name" AS "the ""best""" FROM "employees" LIMIT 1;

  $ "$TESTDIR/ident_quoted/ident_quoted.out" "$TESTDIR/data/employees.csv"
  "the ""best"""
  Alice
