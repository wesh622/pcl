-- top des ventes
SELECT produit, -- le nom
  prix
FROM ventes -- la table
ORDER BY prix DESC LIMIT 2; -- fin
