Sandboxed, the test is in an empty space:

  $ ls

So you may set it up like so:

  $ cat > my_table.csv << EOF
  > Everything, go, wild
  > 1, 2, 3
  > 4,,         6
  > 14e3,    8,9.6, 10
  > EOF

Now you have your CSV:

  $ ls
  my_table.csv

  $ cat my_table.csv
  Everything, go, wild
  1, 2, 3
  4,,         6
  14e3,    8,9.6, 10

You may also retrieve the file test and its directory:

  $ echo $TESTFILE $TESTDIR
  setup.t .*/sql67/sujet/test/expl (re)

Let's examine a SQL file to compile:

  $ cat $TESTDIR/a.sql
  SELECT * FROM my_table;

When testing, your SQL67 already have compiled it into the dir `a` full of C files.
The next compiler, the C compiler `cc`, has also been called via `make`.

  $ ls $TESTDIR/a/ # fake output of `./SQL67 a.sql a` + `a.out`
  Makefile
  a.out
  chose.c
  machin.c
  truc.c

Let's fetch that exe in our sandbox and run it against `my_table.csv`:

  $ cp $TESTDIR/a/a.out .
  $ ./a.out my_table.csv
  Everything, go, wild
  1, 2, 3
  4, null, 6
  14e3, 8, 9.6

To be honest, `a.out` is a fraud and can work on any table:

  $ cp $TESTDIR/*.csv .
  $ ./a.out a.csv | diff -y a.csv -
  foo							      |	foo, null, null
  1							      |	1, null, null
  							      |	null, null, null
  2_0							      |	20, null, null
  3.1_4							      |	3.14, null, null
  [1]
  $ ./a.out b.csv | diff -y b.csv -
  foo, bar  , 	buzz					      |	foo, bar, buzz
  1,2,3							      |	1, 2, 3
  							      |	null, null, null
  2_0,,7							      |	20, null, 7
  3.1_4							      |	3.14, null, null
  1,2,3							      |	1, 2, 3
  [1]
  $ ./a.out d.csv | diff -y d.csv -
  foo							      |	foo, null, null
  1							      |	1, null, null
  							      |	null, null, null
  2_0							      |	20, null, null
  3.1_4							      |	3.14, null, null
  42
  \ No newline at end of file
  							      |	42, null, null
  [1]
  $ ./a.out d.csv | diff -y d.csv -
  foo							      |	foo, null, null
  1							      |	1, null, null
  							      |	null, null, null
  2_0							      |	20, null, null
  3.1_4							      |	3.14, null, null
  42
  \ No newline at end of file
  							      |	42, null, null
  [1]

That executable is not even a binary; what a scam!

  $ cat a.out
  awk -F'[ \t]*,[ \t]*' -v OFS=', ' '{gsub("_",""); print $1?$1:"null", $2?$2:"null", $3?$3:"null"}' $1

