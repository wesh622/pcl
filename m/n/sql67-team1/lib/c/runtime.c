/* SQL67 — moteur d'exécution d'une requête F0 sur des tables CSV.
   Ce fichier est copié tel quel dans chaque dossier produit par SQL67 ;
   la requête elle-même est décrite dans query.c (variable QUERY).

   Le compilateur ne voit jamais les CSV : la résolution des colonnes se fait
   donc ici, à partir de l'en-tête de la table. Toute erreur affiche
   « Error: ... » et termine avec le code 2. */
#include <ctype.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

#include "sql67.h"

#define EXIT_ERROR 2

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

/* ------------------------------------------------------------------ CSV */

/* Une cellule : texte (NULL si champ vide non quoté) + valeur numérique. */
struct cell {
  const char *s;
  size_t len;
  double num;
  int isnum;
};

struct table {
  int ncols;
  char **header;
  size_t nrows;
  struct cell *cells; /* nrows * ncols */
};

static int parse_number(const char *s, size_t len, double *out) {
  char buf[64];
  char *end;
  size_t i = 0, j = len;
  while (i < j && (s[i] == ' ' || s[i] == '\t')) i++;
  while (j > i && (s[j - 1] == ' ' || s[j - 1] == '\t')) j--;
  if (i == j || j - i >= sizeof buf) return 0;
  if (!(isdigit((unsigned char)s[i]) || s[i] == '-' || s[i] == '+' || s[i] == '.')) return 0;
  memcpy(buf, s + i, j - i);
  buf[j - i] = '\0';
  if (strpbrk(buf, "xXnNiI")) return 0; /* ni hexadécimal, ni nan/inf */
  *out = strtod(buf, &end);
  return end != buf && *end == '\0';
}

static char *read_file(const char *path, size_t *len) {
  FILE *f = fopen(path, "rb");
  size_t cap = 1 << 16, n = 0, r;
  char *buf;
  if (!f) fail("cannot open %s", path);
  buf = xmalloc(cap + 1);
  while ((r = fread(buf + n, 1, cap - n, f)) > 0) {
    n += r;
    if (n == cap) {
      cap *= 2;
      buf = xrealloc(buf, cap + 1);
    }
  }
  fclose(f);
  buf[n] = '\0';
  *len = n;
  return buf;
}

/* Découpe RFC 4180, en place : les champs pointent dans [buf]. */
struct field { char *s; size_t len; int quoted; };

static size_t next_record(char *buf, size_t n, size_t i, struct field **fields,
                          size_t *cap, size_t *count) {
  *count = 0;
  for (;;) {
    struct field fl;
    if (*count == *cap) {
      *cap = *cap ? *cap * 2 : 16;
      *fields = xrealloc(*fields, *cap * sizeof **fields);
    }
    fl.quoted = 0;
    if (i < n && buf[i] == '"') {
      size_t w;
      fl.quoted = 1;
      i++;
      fl.s = buf + i;
      w = i;
      while (i < n) {
        if (buf[i] == '"') {
          if (i + 1 < n && buf[i + 1] == '"') { buf[w++] = '"'; i += 2; }
          else { i++; break; }
        } else buf[w++] = buf[i++];
      }
      fl.len = (size_t)(buf + w - fl.s);
      while (i < n && buf[i] != ',' && buf[i] != '\n' && buf[i] != '\r') i++;
    } else {
      fl.s = buf + i;
      while (i < n && buf[i] != ',' && buf[i] != '\n' && buf[i] != '\r') i++;
      fl.len = (size_t)(buf + i - fl.s);
    }
    (*fields)[(*count)++] = fl;
    if (i < n && buf[i] == ',') { i++; continue; }
    if (i < n && buf[i] == '\r') i++;
    if (i < n && buf[i] == '\n') i++;
    return i;
  }
}

static void load_table(const char *path, struct table *t) {
  size_t n, i = 0, cap = 0, count, rowcap = 0;
  struct field *fields = NULL;
  char *buf = read_file(path, &n);
  int c;

  t->ncols = 0;
  t->header = NULL;
  t->nrows = 0;
  t->cells = NULL;
  if (n == 0) return;

  i = next_record(buf, n, i, &fields, &cap, &count);
  t->ncols = (int)count;
  t->header = xmalloc(count * sizeof *t->header);
  for (c = 0; c < t->ncols; c++) {
    t->header[c] = fields[c].s;
    fields[c].s[fields[c].len] = '\0';
  }

  while (i < n) {
    struct cell *row;
    if (buf[i] == '\n' || buf[i] == '\r') { /* ligne vide */
      if (buf[i] == '\r') i++;
      if (i < n && buf[i] == '\n') i++;
      continue;
    }
    i = next_record(buf, n, i, &fields, &cap, &count);
    if (t->nrows == rowcap) {
      rowcap = rowcap ? rowcap * 2 : 1024;
      t->cells = xrealloc(t->cells, rowcap * t->ncols * sizeof *t->cells);
    }
    row = t->cells + t->nrows * t->ncols;
    for (c = 0; c < t->ncols; c++) {
      struct cell *ce = &row[c];
      if ((size_t)c < count && (fields[c].len > 0 || fields[c].quoted)) {
        ce->s = fields[c].s;
        ce->len = fields[c].len;
        ce->isnum = parse_number(ce->s, ce->len, &ce->num);
      } else {
        ce->s = NULL; /* NULL SQL */
        ce->len = 0;
        ce->isnum = 0;
      }
    }
    t->nrows++;
  }
  /* Termine les chaînes une fois tout découpé (on écrase les séparateurs). */
  for (i = 0; i < t->nrows * (size_t)t->ncols; i++)
    if (t->cells[i].s) ((char *)t->cells[i].s)[t->cells[i].len] = '\0';
  free(fields);
}

/* ------------------------------------------------------------ résolution */

static int find_column(const struct table *t, const char *name) {
  int c;
  for (c = 0; c < t->ncols; c++)
    if (strcasecmp(t->header[c], name) == 0) return c;
  return -1;
}

static const char *table_name_of(const char *path, char *buf, size_t size) {
  const char *base = strrchr(path, '/');
  size_t len;
  base = base ? base + 1 : path;
  len = strlen(base);
  if (len > 4 && strcasecmp(base + len - 4, ".csv") == 0) len -= 4;
  if (len >= size) len = size - 1;
  memcpy(buf, base, len);
  buf[len] = '\0';
  return buf;
}

/* ----------------------------------------------------------------- tri */

struct key { int col; int desc; };

static const struct table *T;
static const struct key *KEYS;
static int NKEYS;

/* NULL < nombres < texte (comme SQLite) ; DESC inverse tout. */
static int cmp_cell(const struct cell *a, const struct cell *b) {
  if (!a->s || !b->s) return (a->s != NULL) - (b->s != NULL);
  if (a->isnum && b->isnum) return (a->num > b->num) - (a->num < b->num);
  if (a->isnum != b->isnum) return a->isnum ? -1 : 1;
  return strcmp(a->s, b->s);
}

static int cmp_rows(size_t x, size_t y) {
  int k;
  for (k = 0; k < NKEYS; k++) {
    int c = cmp_cell(&T->cells[x * T->ncols + KEYS[k].col],
                     &T->cells[y * T->ncols + KEYS[k].col]);
    if (c) return KEYS[k].desc ? -c : c;
  }
  return 0;
}

/* Tri fusion : stable, l'ordre de la table départage les égalités. */
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
  int i, o, found = -1;
  char name[4096];
  static char outbuf[1 << 16];

  setvbuf(stdout, outbuf, _IOFBF, sizeof outbuf);
  if (q->error) fail("%s", q->error);

  for (i = 1; i < argc; i++)
    if (strcasecmp(table_name_of(argv[i], name, sizeof name), q->table) == 0) {
      found = i;
      break;
    }
  if (found < 0) fail("no such table: %s", q->table);
  load_table(argv[found], &t);
  T = &t;

  /* Projection : '*' développé, colonnes résolues sur l'en-tête. */
  NOUT = 0;
  for (i = 0; i < q->nsel; i++) NOUT += q->sel[i].kind == ITEM_STAR ? t.ncols : 1;
  OUT_COLS = xmalloc(NOUT * sizeof *OUT_COLS);
  out_names = xmalloc(NOUT * sizeof *out_names);
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
  keys = xmalloc(q->norder * sizeof *keys);
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
