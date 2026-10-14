Le nom doit correspondre exactement : ventes_2025.csv, vente.csv et
ventes.csv.bak ne sont pas la table ventes.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `SELECT * FROM ventes;`

  $ cp "$TESTDIR/data/ventes.csv" ventes_2025.csv && cp "$TESTDIR/data/ventes.csv" vente.csv && cp "$TESTDIR/data/ventes.csv" ventes.csv.bak
  $ "$TESTDIR/table_nom_proche/table_nom_proche.out" ventes_2025.csv vente.csv ventes.csv.bak
  Error: no such table: ventes
  [1]
