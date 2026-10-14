Un CSV tapé à la main, avec une espace après chaque virgule. Les espaces font
partie des valeurs (eltravail.md, format output CSV) : les colonnes s'appellent
"nom", " prenom" et " tel", et Garcia a un téléphone " " (une espace), pas NULL.

Requête : `SELECT * FROM contacts;`

  $ "$TESTDIR/piege_contacts_star/piege_contacts_star.out" "$TESTDIR/data/contacts.csv" "$TESTDIR/data/ventes.csv"
  nom, prenom, tel
  Moreau, Julie, 06 12 34 56 78
  Garcia, Tom, 
  Petit, Sarah, 07 98 76 54 32

Donc la colonne prenom (sans espace) n'existe pas :

Requête : `SELECT prenom FROM contacts;`

  $ "$TESTDIR/piege_contacts_prenom/piege_contacts_prenom.out" "$TESTDIR/data/contacts.csv"
  Error: no such column: prenom
  [1]

Mais " prenom" existe, et les valeurs commencent toutes par une espace :

Requête : `SELECT " prenom" AS p, " tel" FROM contacts ORDER BY p;`

  $ "$TESTDIR/piege_contacts_espace/piege_contacts_espace.out" "$TESTDIR/data/etudiants.csv" "$TESTDIR/data/contacts.csv"
  p, tel
   Julie, 06 12 34 56 78
   Sarah, 07 98 76 54 32
   Tom, 
