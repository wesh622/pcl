SELECT year, id FROM employees;

  $ "$TESTDIR/proj_reorder/proj_reorder.out" "$TESTDIR/data/employees.csv"
  year,id
  2019,1
  2021,2
  2018,3
  2021,4
  2020,5
  2019,6
