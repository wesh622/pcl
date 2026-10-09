#ifndef RUNTIME_H
#define RUNTIME_H
#include <stddef.h>

typedef struct {
  size_t ncols, nrows;
  char **header;  /* ncols */
  char ***rows;   /* nrows x ncols */
} table_t;

_Noreturn void sql_error(const char *msg);
table_t *table_load(const char *path);
void table_print(const table_t *t);
void table_print_columns(const table_t *t, const char **cols, size_t n);
#endif
/*--- runtime.c ---*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void sql_error(const char *msg) {
  fprintf(stderr, "Error: %s\n", msg);
  exit(2);
}

static void *xrealloc(void *p, size_t n) {
  p = realloc(p, n);
  if (!p) sql_error("out of memory");
  return p;
}

/* Lit un champ CSV (RFC 4180 : guillemets doublés) ; renvoie le séparateur rencontré */
static int read_field(FILE *f, char **out) {
  size_t len = 0, cap = 16;
  char *buf = xrealloc(NULL, cap);
  int c = fgetc(f), quoted = 0;
  if (c == '"') { quoted = 1; c = fgetc(f); }
  for (;; c = fgetc(f)) {
    if (c == EOF) break;
    if (quoted) {
      if (c == '"') {
        int d = fgetc(f);
        if (d == '"') { /* "" -> " */ }
        else { quoted = 0; ungetc(d, f); continue; }
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

/* Lit une ligne ; renvoie le nombre de champs (0 si fin de fichier) */
static size_t read_row(FILE *f, char ***out) {
  int c = fgetc(f);
  if (c == EOF) return 0;
  ungetc(c, f);
  size_t n = 0, cap = 8;
  char **row = xrealloc(NULL, cap * sizeof *row);
  int sep;
  do {
    if (n == cap) row = xrealloc(row, (cap *= 2) * sizeof *row);
    sep = read_field(f, &row[n++]);
  } while (sep == ',');
  *out = row;
  return n;
}

table_t *table_load(const char *path) {
  FILE *f = fopen(path, "r");
  if (!f) sql_error("cannot open table");
  table_t *t = xrealloc(NULL, sizeof *t);
  t->ncols = read_row(f, &t->header);
  t->nrows = 0;
  t->rows = NULL;
  size_t cap = 0;
  char **row;
  size_t n;
  while ((n = read_row(f, &row)) > 0) {
    if (n < t->ncols) { /* complète les lignes courtes par des champs vides */
      row = xrealloc(row, t->ncols * sizeof *row);
      while (n < t->ncols) row[n++] = "";
    }
    if (t->nrows == cap) t->rows = xrealloc(t->rows, (cap = cap ? cap * 2 : 64) * sizeof *t->rows);
    t->rows[t->nrows++] = row;
  }
  fclose(f);
  return t;
}

static void print_row(char **row, const size_t *idx, size_t n) {
  for (size_t j = 0; j < n; j++) {
    if (j) putchar(',');
    fputs(row[idx[j]], stdout);
  }
  putchar('\n');
}

void table_print_columns(const table_t *t, const char **cols, size_t n) {
  size_t *idx = xrealloc(NULL, (n ? n : 1) * sizeof *idx);
  for (size_t j = 0; j < n; j++) {
    size_t k = 0;
    while (k < t->ncols && strcmp(t->header[k], cols[j]) != 0) k++;
    if (k == t->ncols) sql_error("unknown column");
    idx[j] = k;
  }
  for (size_t j = 0; j < n; j++) { if (j) putchar(','); fputs(cols[j], stdout); }
  putchar('\n');
  for (size_t i = 0; i < t->nrows; i++) print_row(t->rows[i], idx, n);
  free(idx);
}

void table_print(const table_t *t) {
  size_t *idx = xrealloc(NULL, (t->ncols ? t->ncols : 1) * sizeof *idx);
  for (size_t j = 0; j < t->ncols; j++) idx[j] = j;
  print_row(t->header, idx, t->ncols);
  for (size_t i = 0; i < t->nrows; i++) print_row(t->rows[i], idx, t->ncols);
  free(idx);
}
