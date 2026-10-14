Le programme reçoit plusieurs tables ; la requête choisit la sienne par son nom :

  $ cat > other.csv << EOF
  > x
  > 1
  > EOF
  $ "$TESTDIR/select_star/select_star.out" other.csv "$TESTDIR/data/employees.csv"
  id,name,dept_id,points,rate,year
  1,Alice,2,120,3.5,2019
  2,Bob,1,95,4.25,2021
  3,"Chen, Li",2,120,2.75,2018
  4,Dana,3,10,10,2021
  5,Eve,1,,4.25,2020
  6,Farid,3,300,0.5,2019

Les CSV reçus ne sont pas modifiés :

  $ cat other.csv
  x
  1
