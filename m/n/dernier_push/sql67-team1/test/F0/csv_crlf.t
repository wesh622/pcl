Requête : `SELECT * FROM t;`

  $ printf 'a,b\r\n1,"x\r\ny"\r\n2,z\r\n' > t.csv
  $ "$TESTDIR/csv_crlf/csv_crlf.out" t.csv
  a,b
  1,"x\r (esc)
  y"
  2,z
