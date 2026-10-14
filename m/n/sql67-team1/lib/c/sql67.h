/* SQL67 — description d'une requête, remplie par le compilateur (query.c)
   et exécutée par runtime.c. Ce fichier est copié tel quel dans chaque
   dossier produit par SQL67. */
#ifndef SQL67_H
#define SQL67_H

enum item_kind { ITEM_STAR, ITEM_COLUMN };

struct sel_item {
  int kind;            /* ITEM_STAR ou ITEM_COLUMN */
  const char *column;  /* colonne source (ITEM_COLUMN) */
  const char *name;    /* nom affiché : alias, ou la colonne telle qu'écrite */
};

enum order_kind { ORDER_NAME, ORDER_POS };

struct order_item {
  int kind;            /* ORDER_NAME (colonne ou alias) ou ORDER_POS (ORDER BY 2) */
  const char *column;
  long long pos;       /* 1 = première colonne du SELECT */
  int desc;
};

struct query {
  const char *error;   /* non NULL : requête invalide, erreur signalée à l'exécution */
  const char *table;
  int distinct;
  int nsel;
  const struct sel_item *sel;
  int norder;
  const struct order_item *order;
  long long limit;     /* < 0 : pas de limite */
  long long offset;    /* >= 0 */
};

extern const struct query QUERY;

#endif
