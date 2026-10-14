/* SQL67 — moteur d'exécution d'une requête F0 sur des tables CSV.
   Ce fichier est copié tel quel dans chaque dossier produit par SQL67 ;
   la requête elle-même est décrite dans query.c (variable QUERY).

   Le compilateur ne voit jamais les CSV : la résolution des colonnes se fait
   donc ici, à partir de l'en-tête de la table. Toute erreur est détectée
   avant la première écriture sur stdout, affiche « Error: ... » sur stderr
   et termine avec le code 1. Décisions suivies : voir eltravail.md. */
#include <errno.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

#include "sql67.h"

#define EXIT_ERROR 1

/* Validation des CSV (vote &11 en cours) :
   0 = seulement le CSV utilisé par la requête (« partial eager ») ;
   1 = tous les CSV passés en argument, avant tout (« total eager »). */
#define VALIDATE_ALL 0

static void fail(const char *fmt, ...) {
  va_list ap;
  fflush(stdout);
  fputs("Error: ", stderr);
  va_start(ap, fmt);
  vfprintf(stderr, fmt, ap);
  va_end(ap);
  fputc('\n', stderr);
  exit(EXIT_ERROR);
}

static void *xmalloc(size_t n) {
  void *p = malloc(n ? n : 1);
  if (!p) fail("out of memory");
  return p;
}

static void *xrealloc(void *p, size_t n) {
  p = realloc(p, n ? n : 1);
  if (!p) fail("out of memory");
  return p;
}

static const char *base_name(const char *path) {
  const char *b = strrchr(path, '/');
  return b ? b + 1 : path;
}

/* ------------------------------------------------------------------ CSV */

/* Une cellule : texte (NULL SQL si champ vide, quoté ou non). */
struct cell {
  const char *s;
  size_t len;
};

enum col_type { TYPE_INT, TYPE_FLOAT, TYPE_TEXT };

struct table {
  int ncols;
  char **header;
  size_t nrows;
  struct cell *cells; /* nrows * ncols */
};

static char *read_file(const char *path, size_t *len) {
  FILE *f = fopen(path, "rb");
  size_t cap = 1 << 16, n = 0, r;
  char *buf;
  if (!f) return NULL;
  buf = xmalloc(cap + 1);
  while ((r = fread(buf + n, 1, cap - n, f)) > 0) {
    n += r;
    if (n == cap) {
      cap *= 2;
      buf = xrealloc(buf, cap + 1);
    }
  }
  if (ferror(f)) { fclose(f); free(buf); return NULL; }
  fclose(f);
  buf[n] = '\0';
  *len = n;
  return buf;
}

/* Analyse stricte selon la grammaire RFC 4180 (fins de ligne CRLF ou LF) :
     - un champ quoté doit être refermé, et suivi de ',' ou d'une fin de ligne ;
     - un champ non quoté ne contient ni '"' ni CR isolé ;
     - toutes les lignes ont autant de champs que l'en-tête ;
     - le fichier contient au moins l'en-tête.
   Découpe en place : les cellules pointent dans [buf]. Renvoie 0 si invalide. */
static int parse_csv(char *buf, size_t n, struct table *t) {
  struct cell *f = NULL;      /* tous les champs, en-tête compris */
  size_t nf = 0, cap = 0, i = 0, rec_start, k;
  int ncols = -1;

  if (n == 0) return 0;
  for (;;) {
    rec_start = nf;
    for (;;) { /* un champ */
      struct cell fl;
      if (nf == cap) {
        cap = cap ? cap * 2 : 1024;
        f = xrealloc(f, cap * sizeof *f);
      }
      if (i < n && buf[i] == '"') {
        size_t w = ++i;
        fl.s = buf + i;
        for (;;) {
          if (i >= n) { free(f); return 0; }          /* jamais refermé */
          if (buf[i] == '"') {
            if (i + 1 < n && buf[i + 1] == '"') { buf[w++] = '"'; i += 2; }
            else { i++; break; }
          } else buf[w++] = buf[i++];
        }
        fl.len = (size_t)(buf + w - fl.s);
        if (i < n && buf[i] != ',' && buf[i] != '\n' && buf[i] != '\r') {
          free(f); return 0;                           /* texte après le '"' */
        }
      } else {
        fl.s = buf + i;
        while (i < n && buf[i] != ',' && buf[i] != '\n' && buf[i] != '\r') {
          if (buf[i] == '"') { free(f); return 0; }
          i++;
        }
        fl.len = (size_t)(buf + i - fl.s);
      }
      f[nf++] = fl;
      if (i < n && buf[i] == ',') { i++; continue; }
      break;
    }
    if (i < n && buf[i] == '\r') {
      if (i + 1 >= n || buf[i + 1] != '\n') { free(f); return 0; }
      i++;
    }
    if (i < n) i++; /* '\n' */
    if (ncols < 0) ncols = (int)(nf - rec_start);
    else if (nf - rec_start != (size_t)ncols) { free(f); return 0; }
    if (i >= n) break; /* fin de fichier, saut de ligne final facultatif */
  }

  /* Tout est découpé : on peut terminer les chaînes (écrase les séparateurs). */
  for (k = 0; k < nf; k++) ((char *)f[k].s)[f[k].len] = '\0';
  t->ncols = ncols;
  t->header = xmalloc((size_t)ncols * sizeof *t->header);
  for (k = 0; k < (size_t)ncols; k++) t->header[k] = (char *)f[k].s;
  t->nrows = nf / (size_t)ncols - 1;
  t->cells = f + ncols;
  for (k = 0; k < t->nrows * (size_t)ncols; k++)
    if (t->cells[k].len == 0) t->cells[k].s = NULL; /* champ vide = NULL */
  return 1;
}

static void load_table(const char *path, struct table *t) {
  size_t n;
  char *buf = read_file(path, &n);
  if (!buf || !parse_csv(buf, n, t)) fail("invalid CSV file %s", base_name(path));
}

/* ---------------------------------------------------------------- types */

/* Entier : [+-]?[0-9]+ ; flottant : [+-]?([0-9]+(.[0-9]*)?|.[0-9]+)([eE][+-]?[0-9]+)?
   Les espaces font partie de la valeur : " 12" est un texte. */
static enum col_type type_of(const char *s) {
  const char *p = s;
  int digits = 0, is_int = 1;
  if (*p == '+' || *p == '-') p++;
  while (*p >= '0' && *p <= '9') { p++; digits = 1; }
  if (*p == '.') {
    is_int = 0;
    p++;
    while (*p >= '0' && *p <= '9') { p++; digits = 1; }
  }
  if (!digits) return TYPE_TEXT;
  if (*p == 'e' || *p == 'E') {
    is_int = 0;
    p++;
    if (*p == '+' || *p == '-') p++;
    if (!(*p >= '0' && *p <= '9')) return TYPE_TEXT;
    while (*p >= '0' && *p <= '9') p++;
  }
  if (*p) return TYPE_TEXT;
  if (is_int) { /* hors de long long : flottant */
    errno = 0;
    (void)strtoll(s, NULL, 10);
    if (errno == ERANGE) return TYPE_FLOAT;
  }
  return is_int ? TYPE_INT : TYPE_FLOAT;
}

/* Le plus petit type viable pour toute la colonne (valeurs NULL ignorées). */
static enum col_type column_type(const struct table *t, int c) {
  enum col_type ty = TYPE_INT;
  size_t r;
  for (r = 0; r < t->nrows && ty != TYPE_TEXT; r++) {
    const char *s = t->cells[r * t->ncols + c].s;
    if (s) {
      enum col_type v = type_of(s);
      if (v > ty) ty = v;
    }
  }
  return ty;
}

/* ------------------------------------------------------------ résolution */

static int find_column(const struct table *t, const char *name) {
  int c;
  for (c = 0; c < t->ncols; c++)
    if (strcasecmp(t->header[c], name) == 0) return c;
  return -1;
}

/* Nom de table d'un argument : nom du fichier sans « .csv ». */
static int names_table(const char *path, const char *table) {
  const char *base = base_name(path);
  size_t len = strlen(base);
  if (len > 4 && strcasecmp(base + len - 4, ".csv") == 0) len -= 4;
  return len == strlen(table) && strncasecmp(base, table, len) == 0;
}

static int same_table_name(const char *a, const char *b) {
  const char *ba = base_name(a), *bb = base_name(b);
  size_t la = strlen(ba), lb = strlen(bb);
  if (la > 4 && strcasecmp(ba + la - 4, ".csv") == 0) la -= 4;
  if (lb > 4 && strcasecmp(bb + lb - 4, ".csv") == 0) lb -= 4;
  return la == lb && strncasecmp(ba, bb, la) == 0;
}

/* ----------------------------------------------------------------- tri */

/* Clé de tri, précalculée par ligne selon le type de la colonne. */
union keyval { long long i; double d; };

struct key {
  int col;
  int desc;
  enum col_type type;
  union keyval *vals; /* une valeur par ligne (INT / FLOAT) */
};

static const struct table *T;
static const struct key *KEYS;
static int NKEYS;

/* NULL est la plus petite valeur ; texte comparé octet par octet (casse incluse). */
static int cmp_key(const struct key *k, size_t x, size_t y) {
  const char *a = T->cells[x * T->ncols + k->col].s;
  const char *b = T->cells[y * T->ncols + k->col].s;
  if (!a || !b) return (a != NULL) - (b != NULL);
  switch (k->type) {
  case TYPE_INT: return (k->vals[x].i > k->vals[y].i) - (k->vals[x].i < k->vals[y].i);
  case TYPE_FLOAT: return (k->vals[x].d > k->vals[y].d) - (k->vals[x].d < k->vals[y].d);
  default: return strcmp(a, b);
  }
}

static int cmp_rows(size_t x, size_t y) {
  int i;
  for (i = 0; i < NKEYS; i++) {
    int c = cmp_key(&KEYS[i], x, y);
    if (c) return KEYS[i].desc ? -c : c;
  }
  return 0;
}

/* Tri fusion : stable, l'ordre du fichier départage les égalités. */
static void merge_sort(size_t *a, size_t *tmp, size_t n) {
  size_t mid, i, j, k;
  if (n < 2) return;
  if (n <= 16) {
    for (i = 1; i < n; i++) {
      size_t v = a[i];
      for (j = i; j > 0 && cmp_rows(a[j - 1], v) > 0; j--) a[j] = a[j - 1];
      a[j] = v;
    }
    return;
  }
  mid = n / 2;
  merge_sort(a, tmp, mid);
  merge_sort(a + mid, tmp, n - mid);
  if (cmp_rows(a[mid - 1], a[mid]) <= 0) return;
  memcpy(tmp, a, mid * sizeof *a);
  i = 0; j = mid; k = 0;
  while (i < mid && j < n) a[k++] = cmp_rows(a[j], tmp[i]) < 0 ? a[j++] : tmp[i++];
  while (i < mid) a[k++] = tmp[i++];
}

/* ------------------------------------------------------------- DISTINCT */

static int *OUT_COLS;
static int NOUT;

static unsigned long hash_row(size_t r) {
  unsigned long h = 1469598103934665603UL;
  int o;
  for (o = 0; o < NOUT; o++) {
    const struct cell *ce = &T->cells[r * T->ncols + OUT_COLS[o]];
    size_t i;
    if (!ce->s) { h = (h ^ 0xff) * 1099511628211UL; continue; }
    for (i = 0; i < ce->len; i++) h = (h ^ (unsigned char)ce->s[i]) * 1099511628211UL;
    h = (h ^ 0x1f) * 1099511628211UL;
  }
  return h;
}

static int same_output(size_t x, size_t y) {
  int o;
  for (o = 0; o < NOUT; o++) {
    const struct cell *a = &T->cells[x * T->ncols + OUT_COLS[o]];
    const struct cell *b = &T->cells[y * T->ncols + OUT_COLS[o]];
    if (!a->s || !b->s) { if (a->s != b->s) return 0; continue; }
    if (a->len != b->len || memcmp(a->s, b->s, a->len) != 0) return 0;
  }
  return 1;
}

/* Garde la première occurrence de chaque ligne projetée. */
static size_t distinct(size_t *rows, size_t n) {
  size_t size = 16, kept = 0, i;
  size_t *slots;
  while (size < 2 * n) size *= 2;
  slots = xmalloc(size * sizeof *slots);
  for (i = 0; i < size; i++) slots[i] = (size_t)-1;
  for (i = 0; i < n; i++) {
    size_t h = (size_t)hash_row(rows[i]) & (size - 1);
    int dup = 0;
    while (slots[h] != (size_t)-1) {
      if (same_output(slots[h], rows[i])) { dup = 1; break; }
      h = (h + 1) & (size - 1);
    }
    if (!dup) { slots[h] = rows[i]; rows[kept++] = rows[i]; }
  }
  free(slots);
  return kept;
}

/* ------------------------------------------------------------- sortie */

/* CSV normalisé : guillemets seulement si nécessaires ; NULL = champ vide. */
static void put_field(const char *s) {
  const char *p;
  if (!s) return;
  for (p = s; *p; p++)
    if (*p == ',' || *p == '"' || *p == '\n' || *p == '\r') break;
  if (!*p) { fputs(s, stdout); return; }
  putchar('"');
  for (p = s; *p; p++) {
    if (*p == '"') putchar('"');
    putchar(*p);
  }
  putchar('"');
}

int main(int argc, char **argv) {
  const struct query *q = &QUERY;
  struct table t;
  const char **out_names;
  struct key *keys;
  size_t *rows, n, start, end, r;
  int i, j, o, found = -1;
  static char outbuf[1 << 16];

  setvbuf(stdout, outbuf, _IOFBF, sizeof outbuf);
  if (q->error) fail("%s", q->error);

#if VALIDATE_ALL
  for (i = 1; i < argc; i++) {
    for (j = 1; j < i; j++)
      if (same_table_name(argv[i], argv[j])) {
        char name[4096];
        const char *b = base_name(argv[i]);
        size_t len = strlen(b);
        if (len > 4 && strcasecmp(b + len - 4, ".csv") == 0) len -= 4;
        if (len >= sizeof name) len = sizeof name - 1;
        memcpy(name, b, len);
        name[len] = '\0';
        fail("duplicate table: %s", name);
      }
    {
      struct table tmp;
      load_table(argv[i], &tmp); /* tables gardées en mémoire, comme la principale */
    }
  }
#endif

  /* La table de la requête : exactement un argument doit la nommer. */
  for (i = 1; i < argc; i++)
    if (names_table(argv[i], q->table)) {
      if (found >= 0) fail("duplicate table: %s", q->table);
      found = i;
    }
  if (found < 0) fail("no such table: %s", q->table);
  (void)j;
  (void)same_table_name;
  load_table(argv[found], &t);
  T = &t;

  /* Projection : '*' développé, colonnes résolues sur l'en-tête. */
  NOUT = 0;
  for (i = 0; i < q->nsel; i++) NOUT += q->sel[i].kind == ITEM_STAR ? t.ncols : 1;
  OUT_COLS = xmalloc((size_t)NOUT * sizeof *OUT_COLS);
  out_names = xmalloc((size_t)NOUT * sizeof *out_names);
  o = 0;
  for (i = 0; i < q->nsel; i++) {
    if (q->sel[i].kind == ITEM_STAR) {
      int c;
      for (c = 0; c < t.ncols; c++) { OUT_COLS[o] = c; out_names[o++] = t.header[c]; }
    } else {
      int c = find_column(&t, q->sel[i].column);
      if (c < 0) fail("no such column: %s", q->sel[i].column);
      OUT_COLS[o] = c;
      out_names[o++] = q->sel[i].name;
    }
  }

  /* ORDER BY : alias du SELECT d'abord, puis colonnes de la table. */
  keys = xmalloc((size_t)q->norder * sizeof *keys);
  for (i = 0; i < q->norder; i++) {
    const struct order_item *it = &q->order[i];
    int c = -1;
    if (it->kind == ORDER_POS) {
      if (it->pos < 1 || it->pos > NOUT)
        fail("ORDER BY term out of range - should be between 1 and %d", NOUT);
      c = OUT_COLS[it->pos - 1];
    } else {
      for (o = 0; o < NOUT && c < 0; o++)
        if (strcasecmp(out_names[o], it->column) == 0) c = OUT_COLS[o];
      if (c < 0) c = find_column(&t, it->column);
      if (c < 0) fail("no such column: %s", it->column);
    }
    keys[i].col = c;
    keys[i].desc = it->desc;
    keys[i].type = column_type(&t, c);
    keys[i].vals = NULL;
    if (keys[i].type != TYPE_TEXT) {
      keys[i].vals = xmalloc(t.nrows * sizeof *keys[i].vals);
      for (r = 0; r < t.nrows; r++) {
        const char *s = t.cells[r * t.ncols + c].s;
        if (!s) continue;
        if (keys[i].type == TYPE_INT) keys[i].vals[r].i = strtoll(s, NULL, 10);
        else keys[i].vals[r].d = strtod(s, NULL);
      }
    }
  }
  KEYS = keys;
  NKEYS = q->norder;

  n = t.nrows;
  rows = xmalloc(n * sizeof *rows);
  for (r = 0; r < n; r++) rows[r] = r;
  if (NKEYS > 0) {
    size_t *tmp = xmalloc((n / 2 + 1) * sizeof *tmp);
    merge_sort(rows, tmp, n);
    free(tmp);
  }
  if (q->distinct) n = distinct(rows, n);

  start = (size_t)q->offset < n ? (size_t)q->offset : n;
  end = n;
  if (q->limit >= 0 && (size_t)q->limit < end - start) end = start + (size_t)q->limit;

  for (o = 0; o < NOUT; o++) {
    if (o) putchar(',');
    put_field(out_names[o]);
  }
  putchar('\n');
  for (r = start; r < end; r++) {
    const struct cell *row = &t.cells[rows[r] * t.ncols];
    for (o = 0; o < NOUT; o++) {
      if (o) putchar(',');
      put_field(row[OUT_COLS[o]].s);
    }
    putchar('\n');
  }
  return fflush(stdout) == 0 ? 0 : EXIT_ERROR;
}
