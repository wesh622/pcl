-- requête du tableau de bord
sElEcT	/* colonnes
   utiles */ produit  -- le nom
  ,prix AS "Prix" FROM

	ventes /**/ OrDeR/* collé */bY prix DeSc, id
LiMiT 3 -- top 3
;
