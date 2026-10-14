Texte sensible à la casse : "dubois" après "N'Diaye" (majuscules d'abord).

Fiabilité : probable (proposition en attente ou comportement commun aux 3 SGBD).

Requête : `SELECT nom, prenom FROM etudiants ORDER BY nom, prenom;`

  $ "$TESTDIR/order_texte_casse/order_texte_casse.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/stations.csv" "$TESTDIR/data/order.csv" "$TESTDIR/data/notes 2A.csv" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/transactions.csv" "$TESTDIR/data/ventes.csv"
  nom,prenom
  Benali,Yanis
  Dubois,léa
  Ferreira,Inês
  Le Gall,Erwan
  Martin,Chloé
  Martin,Lucas
  N'Diaye,Awa
  dubois,Hugo
