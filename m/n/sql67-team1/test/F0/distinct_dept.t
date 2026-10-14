SELECT DISTINCT dept_id FROM employees;

  $ "$TESTDIR/distinct_dept/distinct_dept.out" "$TESTDIR/data/employees.csv"
  dept_id
  2
  1
  3
