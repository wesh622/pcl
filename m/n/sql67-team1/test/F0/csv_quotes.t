Champs quotés (RFC 4180) : virgules, guillemets doublés, retours à la ligne, CRLF.

  $ printf 'id,name,dept_id,points,rate,year\r\n1,"say ""hi""",1,2,3,4\r\n2,"two\r\nlines",1,2,3,4\r\n' > employees.csv
  $ "$TESTDIR/proj_cols/proj_cols.out" employees.csv
  name,points
  "say ""hi""",2
  "two\r (esc)
  lines",2
