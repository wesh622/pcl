Moyennes entières et décimales mélangées (colonne flottante), 15.5 = 15.50 (ordre du
fichier), NULL en dernier en DESC. Les moyennes ne sont pas affichées.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT prenom, nom FROM etudiants ORDER BY moyenne DESC;`

  $ "$TESTDIR/order_entiers_et_flottants/order_entiers_et_flottants.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  prenom,nom
  Inês,Ferreira
  Awa,N'Diaye
  Yanis,Benali
  Lucas,Martin
  Hugo,dubois
  Erwan,Le Gall
  Chloé,Martin
  léa,Dubois
