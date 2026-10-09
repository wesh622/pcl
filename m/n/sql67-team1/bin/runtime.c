/* =============================================================================
   runtime.c : la bibliothèque C copiée dans CHAQUE programme généré.

   Écrite à la main (le sujet le conseille) : lecture des CSV, stockage des
   tables en mémoire, affichage, gestion des erreurs. Le code généré par
   codegen.ml (main.c) ne fait qu'appeler ces fonctions.

   Ce fichier contient DEUX parties, séparées par le marqueur plus bas :
     1. l'en-tête   -> écrit tel quel dans <dossier>/runtime.h
     2. le code     -> écrit dans <dossier>/runtime.c
   (découpage fait par split_runtime dans main.ml). Un seul fichier source,
   embarqué dans SQL67 par la règle de bin/dune.

   ATTENTION : ce fichier est inclus dans une chaîne OCaml brute délimitée par
   {runtime| et son symétrique (barre verticale, « runtime », accolade fermante) :
   cette séquence de fermeture ne doit donc JAMAIS apparaître ici, sinon le
   build échoue avec une erreur de syntaxe dans runtime_c.ml.
   ============================================================================= */
#ifndef RUNTIME_H
#define RUNTIME_H
#include <stddef.h>

/* Une table en mémoire. Représentation volontairement simple pour F0 :
   tout est stocké en texte (char *), lignes dans un tableau dynamique.
   Le sujet évoque les B-arbres : à envisager quand les requêtes demanderont
   des recherches rapides (WHERE, jointures). Le typage des valeurs (nombres,
   NULL) devra aussi arriver, au plus tard pour ORDER BY numérique. */
typedef struct {
  size_t ncols, nrows;
  char **header;  /* noms des colonnes : ncols chaînes (1re ligne du CSV) */
  char ***rows;   /* données : nrows lignes de ncols chaînes */
} table_t;

/* Affiche « Error: msg » sur stderr et quitte avec le code 2. _Noreturn
   (C11, accepté par clang en C99) indique au compilateur que la fonction ne
   revient jamais : pas d'avertissement « fin de main sans return ». */
_Noreturn void sql_error(const char *msg);
/* Charge entièrement un fichier CSV en mémoire (le sujet impose de travailler
   en mémoire et de ne JAMAIS modifier les CSV reçus : ouverture en lecture seule). */
table_t *table_load(const char *path);
/* SELECT * : affiche l'en-tête puis toutes les lignes. */
void table_print(const table_t *t);
/* SELECT c1, c2... : affiche seulement les colonnes demandées, dans cet ordre. */
void table_print_columns(const table_t *t, const char **cols, size_t n);
#endif
/*--- runtime.c ---*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Le format exact des messages d'erreur et le code de retour seront fixés par
   le sujet / les échanges sur Gibson : c'est le SEUL endroit à modifier. */
void sql_error(const char *msg) {
  fprintf(stderr, "Error: %s\n", msg);
  exit(2);
}

/* realloc qui ne renvoie jamais NULL : en cas de manque de mémoire on quitte
   proprement au lieu de planter plus loin. realloc(NULL, n) = malloc(n). */
static void *xrealloc(void *p, size_t n) {
  p = realloc(p, n);
  if (!p) sql_error("out of memory");
  return p;
}

/* Lit UN champ CSV et le stocke (alloué) dans *out.
   Gère la syntaxe RFC 4180 :
     - champ entre guillemets : "a,b" contient une virgule, pas deux champs ;
     - "" à l'intérieur des guillemets représente un seul " ;
     - les \r (fins de ligne Windows \r\n) sont ignorés.
   Renvoie le caractère qui a terminé le champ : ',' (un autre champ suit),
   '\n' (fin de ligne) ou EOF (fin de fichier). */
static int read_field(FILE *f, char **out) {
  size_t len = 0, cap = 16;          /* tampon dynamique, doublé si plein */
  char *buf = xrealloc(NULL, cap);
  int c = fgetc(f), quoted = 0;
  if (c == '"') { quoted = 1; c = fgetc(f); }
  for (;; c = fgetc(f)) {
    if (c == EOF) break;
    if (quoted) {
      if (c == '"') {
        int d = fgetc(f);
        if (d == '"') { /* "" -> on garde un seul " (ajouté plus bas) */ }
        else { quoted = 0; ungetc(d, f); continue; } /* guillemet fermant */
      }
    } else if (c == ',' || c == '\n') break;
    else if (c == '\r') continue;
    if (len + 1 >= cap) buf = xrealloc(buf, cap *= 2);
    buf[len++] = (char)c;
  }
  buf[len] = '\0';
  *out = buf;
  return c;
}

/* Lit UNE ligne CSV : un tableau de champs, alloué dans *out.
   Renvoie le nombre de champs, ou 0 en fin de fichier. */
static size_t read_row(FILE *f, char ***out) {
  int c = fgetc(f);
  if (c == EOF) return 0;
  ungetc(c, f);                      /* on a juste regardé, on remet le caractère */
  size_t n = 0, cap = 8;
  char **row = xrealloc(NULL, cap * sizeof *row);
  int sep;
  do {
    if (n == cap) row = xrealloc(row, (cap *= 2) * sizeof *row);
    sep = read_field(f, &row[n++]);
  } while (sep == ',');              /* tant qu'une virgule annonce un autre champ */
  *out = row;
  return n;
}

table_t *table_load(const char *path) {
  FILE *f = fopen(path, "r");        /* lecture seule : on ne modifie jamais le CSV */
  if (!f) sql_error("cannot open table");
  table_t *t = xrealloc(NULL, sizeof *t);
  t->ncols = read_row(f, &t->header); /* 1re ligne = noms des colonnes */
  t->nrows = 0;
  t->rows = NULL;
  size_t cap = 0;
  char **row;
  size_t n;
  while ((n = read_row(f, &row)) > 0) {
    /* Ligne trop courte : on la complète par des champs vides, pour pouvoir
       toujours accéder à rows[i][j] sans vérifier. Ce qu'il faut afficher
       (vide ? NULL ?) est une question ouverte à trancher avec le sujet. */
    if (n < t->ncols) {
      row = xrealloc(row, t->ncols * sizeof *row);
      while (n < t->ncols) row[n++] = "";
    }
    /* Tableau dynamique de lignes : capacité doublée quand il est plein
       (coût amorti O(1) par ligne). */
    if (t->nrows == cap) t->rows = xrealloc(t->rows, (cap = cap ? cap * 2 : 64) * sizeof *t->rows);
    t->rows[t->nrows++] = row;
  }
  fclose(f);
  return t;
}

/* Affiche une ligne : les champs row[idx[0]], row[idx[1]]... séparés par
   des virgules. idx permet de choisir et réordonner les colonnes. */
static void print_row(char **row, const size_t *idx, size_t n) {
  for (size_t j = 0; j < n; j++) {
    if (j) putchar(',');
    fputs(row[idx[j]], stdout);
  }
  putchar('\n');
}

void table_print_columns(const table_t *t, const char **cols, size_t n) {
  /* 1. Résoudre chaque nom de colonne en indice (recherche linéaire dans
        l'en-tête : peu de colonnes, fait une seule fois). */
  size_t *idx = xrealloc(NULL, (n ? n : 1) * sizeof *idx);
  for (size_t j = 0; j < n; j++) {
    size_t k = 0;
    while (k < t->ncols && strcmp(t->header[k], cols[j]) != 0) k++;
    if (k == t->ncols) sql_error("unknown column");
    idx[j] = k;
  }
  /* 2. En-tête de la sortie : les noms demandés (plus tard : les alias AS). */
  for (size_t j = 0; j < n; j++) { if (j) putchar(','); fputs(cols[j], stdout); }
  putchar('\n');
  /* 3. Les données. */
  for (size_t i = 0; i < t->nrows; i++) print_row(t->rows[i], idx, n);
  free(idx);
}

void table_print(const table_t *t) {
  /* SELECT * = projection sur toutes les colonnes, dans l'ordre : idx = 0,1,2... */
  size_t *idx = xrealloc(NULL, (t->ncols ? t->ncols : 1) * sizeof *idx);
  for (size_t j = 0; j < t->ncols; j++) idx[j] = j;
  print_row(t->header, idx, t->ncols);
  for (size_t i = 0; i < t->nrows; i++) print_row(t->rows[i], idx, t->ncols);
  free(idx);
}
