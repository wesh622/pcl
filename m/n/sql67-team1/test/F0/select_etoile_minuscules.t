Mots-clés en minuscules, sans point-virgule final.

Fiabilité : sûre (décision acceptée ou consensus sur Gibson, voir eltravail.md).

Requête : `select * from ventes`

  $ "$TESTDIR/select_etoile_minuscules/select_etoile_minuscules.out" "$TESTDIR/data/ventes.csv"
  id,date,produit,qte,prix,vendeuse
  1,2026-09-01,baguette tradition,3,1.2,Sandrine
  2,2026-09-01,croissant,6,1.1,Sandrine
  3,2026-09-01,pain aux raisins,2,1.45,Mélanie
  4,2026-09-02,baguette tradition,1,1.2,
  5,2026-09-02,"tarte, mirabelles",1,18.5,Mélanie
  6,2026-09-02,croissant,12,1.1,Kevin
  7,2026-09-03,macaron de Nancy,4,2.3,Kevin
  8,2026-09-03,baguette tradition,2,1.2,Sandrine
  9,2026-09-03,"le ""spécial"" du chef",1,4.9,Mélanie
  10,2026-09-04,croissant,,1.1,Kevin
