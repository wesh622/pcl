(* Génération de code (rôle C) : produit [main.c] et [Makefile] dans le
   dossier de sortie.

   Les CSV ne sont connus qu'à l'exécution du .out (ils sont passés en
   arguments) : le schéma n'existe donc pas à la compilation. Codegen part de
   l'AST ; le C généré lit l'en-tête du CSV et résout lui-même la table, les
   colonnes, les alias et l'ORDER BY (cf. Semantique, dont on réutilise la
   normalisation de LIMIT / OFFSET).

   Contrat :
   - [Ok q]    : main.c reçoit les CSV en arguments (./x.out t1.csv ...), choisit
                 celui dont le nom (sans .csv) est la table, et affiche un CSV
                 (en-tête + lignes) après DISTINCT / ORDER BY / OFFSET / LIMIT.
                 Erreurs d'exécution sur stderr : "Error: ..." puis exit(1)
                 (no such table, duplicate table, no such column, invalid
                 CSV file). Tous les CSV passés sont validés avant toute
                 écriture (« total eager validation », &11).
                 [./x.out --check-valid] : exit(0).
   - [Error e] : main.c n'écrit rien sur stdout, affiche "Error: <message>"
                 sur stderr puis exit(10) (&12) ; avec --check-valid, exit(1)
                 sans rien écrire. Un Makefile est généré dans les deux cas. *)

(* ------------------------------------------------------------------ *)
(* Utilitaires                                                         *)
(* ------------------------------------------------------------------ *)

(* Littéral de chaîne C (avec guillemets). Tout octet hors ASCII imprimable,
   ainsi que '?' (trigraphes), est émis en échappement octal à 3 chiffres. *)
let c_string s =
  let b = Buffer.create (String.length s + 2) in
  Buffer.add_char b '"';
  String.iter
    (fun c ->
      match c with
      | '"' -> Buffer.add_string b "\\\""
      | '\\' -> Buffer.add_string b "\\\\"
      | '\n' -> Buffer.add_string b "\\n"
      | '\r' -> Buffer.add_string b "\\r"
      | '\t' -> Buffer.add_string b "\\t"
      | c when Char.code c >= 32 && Char.code c < 127 && c <> '?' ->
          Buffer.add_char b c
      | c -> Printf.bprintf b "\\%03o" (Char.code c))
    s;
  Buffer.add_char b '"';
  Buffer.contents b

(* Tableau C constant. Un tableau vide est interdit en C99 : on émet alors
   un élément factice (le compteur associé, lui, vaut 0). *)
let c_array ty name items =
  match items with
  | [] -> Printf.sprintf "static const %s %s[1] = { 0 };" ty name
  | _ ->
      Printf.sprintf "static const %s %s[%d] = { %s };" ty name
        (List.length items) (String.concat ", " items)

(* ------------------------------------------------------------------ *)
(* main.c — cas d'erreur (analyse lexicale / syntaxique échouée)       *)
(* ------------------------------------------------------------------ *)

let c_of_error (e : Error.t) =
  String.concat "\n"
    [ "/* Genere par SQL67 : la requete est invalide. */";
      "#include <stdio.h>";
      "#include <stdlib.h>";
      "";
      "#include <string.h>";
      "";
      "int main(int argc, char **argv) {";
      "  if (argc > 1 && strcmp(argv[1], \"--check-valid\") == 0) return 1;";
      Printf.sprintf "  fprintf(stderr, \"Error: %%s\\n\", %s);" (c_string e.message);
      "  return 10;";
      "}";
      "" ]

(* ------------------------------------------------------------------ *)
(* main.c — cas nominal                                                *)
(* ------------------------------------------------------------------ *)

(* Partie fixe du programme C. Les constantes de la requête (TABLE_NAME,
   ITEM_COL, ORDER_NAME, ...) sont émises avant. *)
let c_runtime =
  {c|
typedef struct {
  size_t base;  /* position de la ligne dans g_cells (g_hn cellules) */
  size_t idx;   /* rang dans le fichier : rend les tris stables */
} row_t;

typedef struct {
  char **v;     /* champs de l'enregistrement courant (NULL : valeur null) */
  size_t n, cap;
} line_t;

typedef struct {
  int cls;        /* 0 null, 1 entier, 2 reel, 3 texte */
  long long i;
  double d;
  const char *s;
} sortkey_t;

static char **g_cells; /* cellules de toutes les lignes, g_hn par ligne ;
                          NULL represente la valeur null */
static size_t g_hn;    /* nombre de colonnes de l'en-tete */
static int *g_ocol;    /* colonne source de chaque sortie */
static size_t g_nout;  /* nombre de sorties */
static int g_scol[NORDER > 0 ? NORDER : 1]; /* colonne source de chaque tri */
static sortkey_t *g_keys; /* NORDER cles par ligne (indexees par idx) */

static void *xrealloc(void *p, size_t n) {
  void *q = realloc(p, n ? n : 1);
  if (!q) {
    fprintf(stderr, "Error: out of memory\n");
    exit(1);
  }
  return q;
}

static void fail(const char *fmt, const char *arg) {
  fprintf(stderr, "Error: ");
  fprintf(stderr, fmt, arg);
  fputc('\n', stderr);
  exit(1);
}

static const char *base_name(const char *p) {
  const char *s = strrchr(p, '/');
  return s ? s + 1 : p;
}

static int is_blank(char c) { return c == ' ' || c == '\t'; }

/* Vrai si s[0..n) est un nombre : signe optionnel, chiffres, '.' et
   exposant optionnels, au moins un chiffre dans la mantisse. *isint dit s'il
   s'agit d'un entier (pas de '.' ni d'exposant). */
static int is_number(const char *s, size_t n, int *isint) {
  size_t k = 0, digits = 0;
  *isint = 1;
  if (k < n && (s[k] == '+' || s[k] == '-')) k++;
  while (k < n && s[k] >= '0' && s[k] <= '9') k++, digits++;
  if (k < n && s[k] == '.') {
    *isint = 0;
    k++;
    while (k < n && s[k] >= '0' && s[k] <= '9') k++, digits++;
  }
  if (!digits) return 0;
  if (k < n && (s[k] == 'e' || s[k] == 'E')) {
    size_t e = 0;
    *isint = 0;
    k++;
    if (k < n && (s[k] == '+' || s[k] == '-')) k++;
    while (k < n && s[k] >= '0' && s[k] <= '9') k++, e++;
    if (!e) return 0;
  }
  return k == n;
}

/* Typage d'un champ de donnees [start, w) :
   - non delimite et vide (ou seulement des espaces) : null ;
   - nombre borde d'espaces : les espaces sont retires ;
   - sinon : texte, conserve tel quel (espaces compris). */
static char *norm_field(char *start, char *w, int quoted) {
  char *a = start, *b = w;
  int isint;
  while (a < b && is_blank(*a)) a++;
  while (b > a && is_blank(b[-1])) b--;
  if (a == b && !quoted) return NULL;
  if (a != b && (a != start || b != w) && is_number(a, (size_t)(b - a), &isint)) {
    *b = '\0';
    return a;
  }
  return start;
}

static char *read_all(const char *path, size_t *len) {
  FILE *fp = fopen(path, "rb");
  size_t cap = 4096, n = 0, r;
  char *buf;
  if (!fp) fail("cannot open file %s", base_name(path));
  buf = (char *)xrealloc(NULL, cap);
  while ((r = fread(buf + n, 1, cap - n, fp)) > 0) {
    n += r;
    if (n == cap) {
      cap *= 2;
      buf = (char *)xrealloc(buf, cap);
    }
  }
  fclose(fp);
  buf = (char *)xrealloc(buf, n + 1);
  buf[n] = '\0';
  *len = n;
  return buf;
}

/* Fin de champ : ',', fin de ligne (\n, \r ou \r\n) ou fin de fichier. */
static int is_sep(char c) { return c == ',' || c == '\n' || c == '\r'; }

/* Lit l'enregistrement suivant (RFC 4180, strict). Les champs sont ecrits
   en place dans [buf] ; si [data], ils sont types (cf. norm_field), sinon
   (en-tete) conserves tels quels. Retourne 1 si un enregistrement a ete lu,
   0 en fin de fichier, -1 si le CSV est invalide (guillemet non ferme, texte
   apres un guillemet fermant, guillemet dans un champ non delimite). */
static int next_record(char *buf, size_t len, size_t *ppos, line_t *ln,
                       int data) {
  size_t pos = *ppos;
  int eol = 0;

  if (pos >= len) return 0;
  ln->n = 0;
  while (!eol) {
    char *start = buf + pos, *w = start;
    int d, quoted = 0; /* d : ',', '\n', '\r' ou -1 (fin de fichier) */

    if (pos < len && buf[pos] == '"') {
      quoted = 1;
      pos++;
      for (;;) {
        if (pos >= len) return -1; /* guillemet non ferme */
        if (buf[pos] == '"') {
          if (pos + 1 < len && buf[pos + 1] == '"') {
            *w++ = '"';
            pos += 2;
          } else {
            pos++;
            break;
          }
        } else {
          *w++ = buf[pos++];
        }
      }
      if (pos < len && !is_sep(buf[pos])) return -1;
    } else {
      while (pos < len && !is_sep(buf[pos])) {
        if (buf[pos] == '"') return -1;
        *w++ = buf[pos++];
      }
    }

    d = pos < len ? (unsigned char)buf[pos] : -1;
    *w = '\0'; /* w <= buf + pos : le terminateur est deja memorise */
    if (ln->n == ln->cap) {
      ln->cap = ln->cap ? ln->cap * 2 : 16;
      ln->v = (char **)xrealloc(ln->v, ln->cap * sizeof(char *));
    }
    ln->v[ln->n++] = data ? norm_field(start, w, quoted) : start;

    if (d == ',') {
      pos++;
    } else {
      eol = 1;
      if (d == '\r') {
        pos++;
        if (pos < len && buf[pos] == '\n') pos++;
      } else if (d == '\n') {
        pos++;
      }
    }
  }
  *ppos = pos;
  return 1;
}

/* Classe une valeur pour le tri : null < nombre < texte. Les entiers sont
   compares exactement (int64, ecretes s'ils debordent), les autres nombres
   en double. Les nombres sont deja debarrasses de leurs espaces. */
static void make_key(const char *s, sortkey_t *k) {
  int isint;
  k->s = s;
  k->i = 0;
  k->d = 0;
  if (!s) {
    k->cls = 0;
    return;
  }
  if (!is_number(s, strlen(s), &isint)) {
    k->cls = 3;
    return;
  }
  if (isint) {
    k->i = strtoll(s, NULL, 10); /* LLONG_MAX / LLONG_MIN si debordement */
    k->d = (double)k->i;
    k->cls = 1;
  } else {
    k->d = strtod(s, NULL);
    k->cls = 2;
  }
}

static int cmp_key(const sortkey_t *a, const sortkey_t *b) {
  int ga = a->cls == 0 ? 0 : (a->cls == 3 ? 2 : 1);
  int gb = b->cls == 0 ? 0 : (b->cls == 3 ? 2 : 1);
  if (ga != gb) return ga < gb ? -1 : 1;
  if (ga == 0) return 0;
  if (ga == 2) return strcmp(a->s, b->s);
  if (a->cls == 1 && b->cls == 1) return (a->i > b->i) - (a->i < b->i);
  return (a->d > b->d) - (a->d < b->d);
}

static int cmp_sort(const void *pa, const void *pb) {
  const row_t *a = (const row_t *)pa, *b = (const row_t *)pb;
  int k;
  for (k = 0; k < NORDER; k++) {
    int c = cmp_key(&g_keys[a->idx * NORDER + k], &g_keys[b->idx * NORDER + k]);
    if (c) return ORDER_DIR[k] * c;
  }
  return (a->idx > b->idx) - (a->idx < b->idx);
}

/* Comparaison de cellules ; null est egal a null et inferieur au reste. */
static int cmp_cell(const char *a, const char *b) {
  if (!a || !b) return (a != NULL) - (b != NULL);
  return strcmp(a, b);
}

static int cmp_out(const row_t *a, const row_t *b) {
  size_t j;
  for (j = 0; j < g_nout; j++) {
    int c = cmp_cell(g_cells[a->base + g_ocol[j]], g_cells[b->base + g_ocol[j]]);
    if (c) return c;
  }
  return 0;
}

static int cmp_distinct(const void *pa, const void *pb) {
  const row_t *a = (const row_t *)pa, *b = (const row_t *)pb;
  int c = cmp_out(a, b);
  if (c) return c;
  return (a->idx > b->idx) - (a->idx < b->idx);
}

static int cmp_idx(const void *pa, const void *pb) {
  const row_t *a = (const row_t *)pa, *b = (const row_t *)pb;
  return (a->idx > b->idx) - (a->idx < b->idx);
}

static void put_quoted(const char *s) {
  putchar('"');
  for (; *s; s++) {
    if (*s == '"') putchar('"');
    putchar(*s);
  }
  putchar('"');
}

/* Champ de donnees : null n'imprime rien ; la chaine vide et le texte fait
   uniquement d'espaces sont delimites pour ne pas etre relus comme null ;
   le reste n'est delimite que si c'est obligatoire. */
static void put_field(const char *s) {
  const char *p;
  if (!s) return;
  for (p = s; is_blank(*p); p++)
    ;
  if (!*p || strpbrk(s, ",\"\n\r")) put_quoted(s);
  else fputs(s, stdout);
}

/* Nom de colonne : delimite seulement si c'est obligatoire. */
static void put_name(const char *s) {
  if (strpbrk(s, ",\"\n\r")) put_quoted(s);
  else fputs(s, stdout);
}

/* "dir/t1.csv" -> nom de la table ("t1"), alloue. */
static char *table_of_arg(const char *arg) {
  const char *base = base_name(arg);
  size_t n = strlen(base);
  char *t;
  if (n > 4 && strcmp(base + n - 4, ".csv") == 0) n -= 4;
  t = (char *)xrealloc(NULL, n + 1);
  memcpy(t, base, n);
  t[n] = '\0';
  return t;
}

static int find_col(char **hdr, const char *name) {
  size_t j;
  for (j = 0; j < g_hn; j++)
    if (strcmp(hdr[j], name) == 0) return (int)j;
  return -1;
}

int main(int argc, char **argv) {
  static char obuf[1 << 16];
  const char *path = NULL;
  char *buf = NULL, **hdr, **oname, **names;
  size_t len = 0, pos = 0, nrows = 0, caprows = 0, capcells = 0, i, j, start, end;
  int r, k, m;
  line_t ln = { NULL, 0, 0 };
  row_t *rows = NULL;

  if (argc > 1 && strcmp(argv[1], "--check-valid") == 0) return 0;

  /* Validation de tous les CSV recus (&11), avant toute ecriture. Seule la
     table interrogee est conservee en memoire. */
  names = (char **)xrealloc(NULL, (size_t)(argc > 1 ? argc : 1) * sizeof(char *));
  for (m = 1; m < argc; m++) {
    size_t flen, fpos = 0;
    char *fbuf = read_all(argv[m], &flen);
    int keep;
    names[m] = table_of_arg(argv[m]);
    for (k = 1; k < m; k++)
      if (strcmp(names[k], names[m]) == 0) fail("duplicate table: %s", names[m]);
    keep = strcmp(names[m], TABLE_NAME) == 0;
    if (flen >= 3 && (unsigned char)fbuf[0] == 0xEF &&
        (unsigned char)fbuf[1] == 0xBB && (unsigned char)fbuf[2] == 0xBF)
      fpos = 3; /* BOM UTF-8 */
    if (!keep) {
      while ((r = next_record(fbuf, flen, &fpos, &ln, 0)) > 0)
        ;
      if (r < 0) fail("invalid CSV file %s", base_name(argv[m]));
      free(fbuf);
      continue;
    }
    path = argv[m];
    buf = fbuf;
    len = flen;
    pos = fpos;
  }
  if (!path) fail("no such table: %s", TABLE_SQL);

  /* En-tete : noms de colonnes, conserves tels quels (espaces compris). */
  r = next_record(buf, len, &pos, &ln, 0);
  if (r < 0) fail("invalid CSV file %s", base_name(path));
  g_hn = r > 0 ? ln.n : 0;
  hdr = (char **)xrealloc(NULL, (g_hn ? g_hn : 1) * sizeof(char *));
  for (j = 0; j < g_hn; j++) hdr[j] = ln.v[j];

  /* Donnees : lignes completees par des null, ou tronquees. */
  while (r > 0 && (r = next_record(buf, len, &pos, &ln, 1)) > 0) {
    if (nrows == caprows) {
      caprows = caprows ? caprows * 2 : 64;
      rows = (row_t *)xrealloc(rows, caprows * sizeof(row_t));
    }
    if ((nrows + 1) * g_hn > capcells) {
      capcells = capcells ? capcells * 2 : 256;
      while ((nrows + 1) * g_hn > capcells) capcells *= 2;
      g_cells = (char **)xrealloc(g_cells, capcells * sizeof(char *));
    }
    for (j = 0; j < g_hn; j++)
      g_cells[nrows * g_hn + j] = j < ln.n ? ln.v[j] : NULL;
    rows[nrows].base = nrows * g_hn;
    rows[nrows].idx = nrows;
    nrows++;
  }
  if (r < 0) fail("invalid CSV file %s", base_name(path));

  /* Resolution du SELECT : '*' -> toutes les colonnes, dans l'ordre du CSV. */
  {
    size_t maxout = 0;
    for (k = 0; k < NITEMS; k++) maxout += ITEM_COL[k] ? 1 : g_hn;
    g_ocol = (int *)xrealloc(NULL, (maxout ? maxout : 1) * sizeof(int));
    oname = (char **)xrealloc(NULL, (maxout ? maxout : 1) * sizeof(char *));
  }
  for (k = 0; k < NITEMS; k++) {
    if (!ITEM_COL[k]) {
      for (j = 0; j < g_hn; j++) {
        g_ocol[g_nout] = (int)j;
        oname[g_nout++] = hdr[j];
      }
    } else {
      int c = find_col(hdr, ITEM_COL[k]);
      if (c < 0) fail("no such column: %s", ITEM_COL[k]);
      g_ocol[g_nout] = c;
      oname[g_nout++] = ITEM_ALIAS[k] ? (char *)ITEM_ALIAS[k] : hdr[c];
    }
  }

  /* Resolution de l'ORDER BY : d'abord les noms des sorties (alias compris),
     puis les colonnes de la table. */
  for (k = 0; k < NORDER; k++) {
    int c = -1;
    for (j = 0; j < g_nout && c < 0; j++)
      if (strcmp(oname[j], ORDER_NAME[k]) == 0) c = g_ocol[j];
    if (c < 0) c = find_col(hdr, ORDER_NAME[k]);
    if (c < 0) fail("no such column: %s", ORDER_NAME[k]);
    g_scol[k] = c;
  }

  /* DISTINCT : doublons sur les colonnes projetees ; on garde la premiere
     occurrence, puis on remet les lignes dans l'ordre du fichier. */
  if (DISTINCT && nrows > 1) {
    size_t kept = 0;
    qsort(rows, nrows, sizeof(row_t), cmp_distinct);
    for (i = 0; i < nrows; i++) {
      if (kept > 0 && cmp_out(&rows[kept - 1], &rows[i]) == 0) continue;
      rows[kept++] = rows[i];
    }
    nrows = kept;
    qsort(rows, nrows, sizeof(row_t), cmp_idx);
  }

  /* ORDER BY (stable). */
  if (NORDER > 0 && nrows > 1) {
    g_keys = (sortkey_t *)xrealloc(NULL, (caprows ? caprows : 1) * NORDER *
                                             sizeof(sortkey_t));
    for (i = 0; i < nrows; i++)
      for (k = 0; k < NORDER; k++)
        make_key(g_cells[rows[i].base + g_scol[k]],
                 &g_keys[rows[i].idx * NORDER + k]);
    qsort(rows, nrows, sizeof(row_t), cmp_sort);
  }

  /* OFFSET puis LIMIT. */
  start = (size_t)OFFSET_VAL;
  if (start > nrows) start = nrows;
  end = nrows;
  if (HAS_LIMIT && (size_t)LIMIT_VAL < nrows - start)
    end = start + (size_t)LIMIT_VAL;

  /* Sortie CSV : en-tete (noms/alias des sorties) puis les lignes. */
  setvbuf(stdout, obuf, _IOFBF, sizeof obuf);
  if (g_nout > 0) {
    for (j = 0; j < g_nout; j++) {
      if (j) putchar(',');
      put_name(oname[j]);
    }
    putchar('\n');
    for (i = start; i < end; i++) {
      for (j = 0; j < g_nout; j++) {
        if (j) putchar(',');
        put_field(g_cells[rows[i].base + g_ocol[j]]);
      }
      putchar('\n');
    }
  }
  return 0;
}
|c}

let c_of_query (q : Ast.query) =
  let items =
    List.map
      (function
        | Ast.Star -> ("NULL", "NULL")
        | Ast.Item (Ast.Column c, alias) ->
            let a = match alias with Some a -> c_string a | None -> "NULL" in
            (c_string c, a))
      q.Ast.select
  in
  let item_cols = List.map fst items in
  let item_aliases = List.map snd items in
  let order_names =
    List.map (fun (Ast.Column c, _) -> c_string c) q.Ast.order_by
  in
  let order_dirs =
    List.map
      (fun (_, d) -> match d with Ast.Asc -> "1" | Ast.Desc -> "-1")
      q.Ast.order_by
  in
  (* Choix de Semantique : LIMIT négatif = pas de limite, OFFSET négatif = 0. *)
  let limit_defs =
    match Semantique.normaliser_limit q.Ast.limit with
    | Some n -> Printf.sprintf "#define HAS_LIMIT 1\n#define LIMIT_VAL %dULL" n
    | None -> "#define HAS_LIMIT 0\n#define LIMIT_VAL 0ULL"
  in
  String.concat "\n"
    [ "/* Genere par SQL67. Ne pas modifier a la main. */";
      "#include <errno.h>";
      "#include <stdio.h>";
      "#include <stdlib.h>";
      "#include <string.h>";
      "";
      "/* Les CSV sont passes en arguments a l'execution. La table est celle";
      "   dont le nom de fichier (sans .csv) vaut exactement TABLE_NAME ; la premiere";
      "   ligne du CSV est l'en-tete. Colonnes et alias sont resolus a";
      "   l'execution. */";
      Printf.sprintf "#define TABLE_NAME %s" (c_string q.Ast.from);
      Printf.sprintf "#define TABLE_SQL %s" (c_string q.Ast.from_sql);
      Printf.sprintf "#define NITEMS %d" (List.length items);
      Printf.sprintf "#define NORDER %d" (List.length order_names);
      Printf.sprintf "#define DISTINCT %d" (if q.Ast.distinct then 1 else 0);
      limit_defs;
      Printf.sprintf "#define OFFSET_VAL %dULL"
        (Semantique.normaliser_offset q.Ast.offset);
      "";
      "/* ITEM_COL[k] = NULL : '*' ; ITEM_ALIAS[k] = NULL : pas d'alias. */";
      c_array "char *" "ITEM_COL" item_cols;
      c_array "char *" "ITEM_ALIAS" item_aliases;
      c_array "char *" "ORDER_NAME" order_names;
      c_array "int" "ORDER_DIR" order_dirs;
      c_runtime ]

(* ------------------------------------------------------------------ *)
(* Makefile                                                            *)
(* ------------------------------------------------------------------ *)

(* Le Makefile marche aussi bien lance depuis le dossier (make -C dossier)
   que depuis ailleurs (make -f dossier/Makefile) : les chemins sont
   relatifs a l'emplacement du Makefile. Seuls clang, make, libc et libm
   sont utilises. *)
let makefile_content nom_dossier =
  let exe = Filename.basename nom_dossier ^ ".out" in
  String.concat "\n"
    [ "HERE := $(dir $(lastword $(MAKEFILE_LIST)))";
      "CC := clang";
      "CFLAGS := -std=c99 -O2 -Wall";
      "TARGET := $(HERE)" ^ exe;
      "";
      "all: $(TARGET)";
      "";
      "$(TARGET): $(HERE)main.c";
      "\t$(CC) $(CFLAGS) -o $@ $< -lm";
      "";
      "clean:";
      "\trm -f $(TARGET)";
      "";
      ".PHONY: all clean";
      "" ]

(* ------------------------------------------------------------------ *)
(* Écriture sur disque                                                 *)
(* ------------------------------------------------------------------ *)

let rec mkdir_p d =
  if d <> "" && d <> "." && d <> Filename.dir_sep && not (Sys.file_exists d)
  then begin
    mkdir_p (Filename.dirname d);
    try Sys.mkdir d 0o755 with Sys_error _ when Sys.file_exists d -> ()
  end

let write_file path contents =
  let oc = open_out_bin path in
  Fun.protect
    ~finally:(fun () -> close_out_noerr oc)
    (fun () -> output_string oc contents)

(* Génère main.c et Makefile dans [nom_dossier]. Ne lève jamais d'exception :
   un échec d'écriture est renvoyé sous forme [Error message]. *)
let generer (resultat : (Ast.query, Error.t) result) (nom_dossier : string)
    : (unit, string) result =
  let c_code =
    match resultat with
    | Ok q -> c_of_query q
    | Error e -> c_of_error e
  in
  try
    mkdir_p nom_dossier;
    write_file (Filename.concat nom_dossier "main.c") c_code;
    write_file (Filename.concat nom_dossier "Makefile")
      (makefile_content nom_dossier);
    Ok ()
  with
  | Sys_error m -> Error m
  | exn -> Error (Printexc.to_string exn)
