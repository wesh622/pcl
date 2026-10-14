Prix égaux : le tri stable garde l'ordre du fichier.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT id, produit FROM ventes ORDER BY prix;`

  $ "$TESTDIR/order_egalite_numerique/order_egalite_numerique.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  id,produit
  2,croissant
  6,croissant
  10,croissant
  1,baguette tradition
  4,baguette tradition
  8,baguette tradition
  3,pain aux raisins
  7,macaron de Nancy
  9,"le ""spécial"" du chef"
  5,"tarte, mirabelles"
