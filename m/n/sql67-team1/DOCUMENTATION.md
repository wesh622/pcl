# SQL67 — Documentation technique (état actuel, fragment F0)

Ce document décrit le code OCaml du compilateur SQL67 tel qu'il est aujourd'hui dans
`lib/` et `bin/`. Il ne remplace pas le sujet (`README.md`) ni le contrat de livraison
(`README_ARTEFACT.md`).

> **À retenir d'abord.** Le projet est aujourd'hui un **front-end** : il sait lire une
> requête F0 et la vérifier sémantiquement *si on lui fournit un schéma*. Il ne génère
> **encore aucun code C** et l'exécutable n'appelle que l'analyse syntaxique.
> Voir la partie 4.

---

## 1. Architecture générale

### 1.1 Ce que doit faire SQL67 (rappel du contrat)

```sh
SQL67 <nom>.sql <nom>        # écrit des fichiers C + un Makefile dans <nom>/
make -C <nom>                # produit <nom>/<nom>.out
<nom>/<nom>.out t1.csv …     # exécute la requête sur les tables CSV
```

SQL67 est donc un **compilateur SQL → C99**. Les tables CSV ne sont connues qu'à
l'**exécution** du `.out`, pas à la compilation.

### 1.2 Organisation des fichiers

```
sql67-team1/
├── dune-project          projet dune (dune 3.11, extension menhir 2.1)
├── sql67.opam            dépendances : ocaml ≥ 5.0, dune ≥ 3.11, menhir
├── bin/
│   ├── dune              exécutable `main` (public_name sql67), dépend de la lib sql67
│   └── main.ml           point d'entrée en ligne de commande
├── lib/                  bibliothèque `sql67` (tous les modules sont exposés en Sql67.X)
│   ├── dune              ocamllex lexer + menhir parser (--strict)
│   ├── error.ml          type d'erreur partagé
│   ├── ast.ml            AST produit par le parser
│   ├── lexer.mll         analyse lexicale (ocamllex)
│   ├── parser.mly        grammaire (Menhir)
│   ├── parse.ml          façade : texte → AST ou erreur
│   ├── resolu.ml         représentation « résolue » (après sémantique)
│   └── semantique.ml     analyse sémantique : AST + schéma → requête résolue
├── test/
│   ├── F0 … F5/          vides (.gitkeep) — aucun test du projet pour l'instant
│   └── expl/             exemples de tests cram fournis par le sujet
├── .gitlab-ci.yml        pipeline : build (dune) → check → translate → …
└── sql67.yml             image Docker d'exécution de SQL67
```

### 1.3 Découpage par rôles

Les commentaires du code parlent de trois rôles :

| Rôle | Responsabilité                                   | Fichiers                                   |
|------|--------------------------------------------------|--------------------------------------------|
| A    | Front-end : texte SQL → AST, sans exception      | `lexer.mll`, `parser.mly`, `parse.ml`      |
| B    | Sémantique : AST → requête résolue               | `ast.ml` (à valider), `resolu.ml`, `semantique.ml` |
| C    | Back-end : génération du C et du Makefile        | **pas encore écrit**                       |

`error.ml` est commun aux trois.

### 1.4 Principe de conception

Chaque étape est une **fonction pure** qui renvoie un `result` :

```
string ──Parse──▶ (Ast.query, Error.t) result ──Semantique──▶ (Resolu.query, Error.t) result ──(C)──▶ fichiers C
```

Les exceptions restent internes (`Parser.Error`, `Error.Syntax_error`) et sont
transformées en `Error.t` par `Parse`. Le chaînage se fait avec `Result.bind`
(l'opérateur `let*`).

---

## 2. Ordre logique de la chaîne de traitement

```
                 fichier .sql
                      │
                      ▼
 (0) error.ml   ─ type Error.t, utilisé partout ─────────────────────┐
                      │                                              │
 (1) lexer.mll  ─ caractères → tokens (SELECT, IDENT "a", INT 3…)    │
                      │                                              │
 (2) parser.mly ─ tokens → arbre de syntaxe                          │
                      │                                              │
 (3) ast.ml     ─ définit l'arbre produit par (2)                    │
                      │                                              │
     parse.ml   ─ assemble (1)+(2), attrape les erreurs ─▶ Error.t ◀─┤
                      │  Ast.query                                   │
                      ▼                                              │
 (4) resolu.ml  ─ définit la forme « résolue » de la requête         │
                      │                                              │
 (5) semantique.ml ─ Ast.query + schéma → Resolu.query ─▶ Error.t ◀──┘
                      │  Resolu.query
                      ▼
     [génération C — rôle C, absent]
                      │
                      ▼
 (6) bin/main.ml ─ lit argv, appelle la chaîne, affiche l'erreur, exit code
```

**Ordre de lecture conseillé** pour découvrir le code :
`error.ml` → `ast.ml` → `lexer.mll` → `parser.mly` → `parse.ml` → `resolu.ml` →
`semantique.ml` → `main.ml`.

> En pratique, `main.ml` ne va aujourd'hui que jusqu'à `parse.ml` : `Semantique`
> n'est appelé nulle part.

---

## 3. Détail fichier par fichier

### 3.0 `lib/error.ml` — erreurs partagées

**Rôle :** un type d'erreur commun à toutes les étapes.

```ocaml
type t = { message : string; position : Lexing.position option; exit_code : int }
exception Syntax_error of t
val syntax_error   : string -> Lexing.position -> t   (* position connue, exit 2 *)
val semantic_error : string -> t                      (* pas de position,  exit 2 *)
```

- **Entrée :** un message (et une position pour les erreurs de syntaxe).
- **Sortie :** une valeur `Error.t`. Le code de sortie vaut toujours 2 (« requête
  invalide »).
- L'exception `Syntax_error` ne sert qu'à faire sortir une erreur du lexer, qui est
  appelé depuis le parser généré et ne peut donc pas renvoyer un `result`.

### 3.1 `lib/lexer.mll` — analyse lexicale

**Rôle :** découper le texte en tokens.

- **Entrée :** un `Lexing.lexbuf` (le flux de caractères).
- **Sortie :** `Lexer.token : Lexing.lexbuf -> Parser.token`, appelé token par token
  par le parser. Les types de tokens viennent de `parser.mly` (`open Parser`).

**Ce qu'il fait :**

| Entrée lue                         | Résultat                                           |
|------------------------------------|----------------------------------------------------|
| `\n`                               | `Lexing.new_line` (numéros de ligne justes), ignoré |
| espaces, `\t`, `\r`                | ignorés                                            |
| `-- …` jusqu'à la fin de ligne     | commentaire, ignoré                                |
| `*` `,` `;` `-`                    | `STAR` `COMMA` `SEMI` `MINUS`                      |
| `[0-9]+`                           | `INT n` ; erreur si l'entier dépasse `max_int`     |
| `[A-Za-z_][A-Za-z0-9_]*`           | mot-clé si c'en est un (insensible à la casse), sinon `IDENT s` (casse conservée) |
| fin de fichier                     | `EOF`                                              |
| autre caractère                    | `raise (Error.Syntax_error …)` avec la position    |

Mots-clés reconnus (table `keyword`) : `select from as order by asc desc limit offset`.

### 3.2 `lib/parser.mly` — grammaire (Menhir)

**Rôle :** vérifier que la suite de tokens forme une requête F0 et construire l'AST.

- **Entrée :** une fonction de lexing (`Lexer.token`) et un `lexbuf`.
- **Sortie :** `Parser.query : (Lexing.lexbuf -> token) -> Lexing.lexbuf -> Ast.query`.
  En cas d'erreur : exception `Parser.Error`.

**Grammaire acceptée :**

```
query        ::= SELECT select_list FROM IDENT order_by? limit? offset? ';'? EOF
select_list  ::= select_item (',' select_item)*
select_item  ::= '*' | expr | expr AS IDENT | expr IDENT        -- alias implicite
expr         ::= IDENT
order_by     ::= ORDER BY order_item (',' order_item)*
order_item   ::= expr | expr ASC | expr DESC                    -- ASC par défaut
limit        ::= LIMIT signed_int
offset       ::= OFFSET signed_int
signed_int   ::= INT | '-' INT
```

Les listes sont construites en récursion gauche (`$3 :: $1`) puis renversées avec
`List.rev`, ce qui est l'idiome classique pour un parser LR.
Le signe négatif est accepté ici ; c'est la sémantique qui décide quoi en faire.

### 3.3 `lib/ast.ml` — arbre de syntaxe abstraite

**Rôle :** décrire la requête telle qu'elle a été écrite, sans aucune vérification.

```ocaml
type dir = Asc | Desc
type expr = Column of string
type select_item = Star | Item of expr * string option   (* alias éventuel *)
type query = {
  select   : select_item list;
  from     : string;
  order_by : (expr * dir) list;
  limit    : int option;     (* peut être négatif *)
  offset   : int option;     (* peut être négatif *)
}
```

Aucune fonction : uniquement des types, produits par `parser.mly`, consommés par
`semantique.ml`.

### 3.4 `lib/parse.ml` — façade du front-end

**Rôle :** cacher lexer et parser derrière une interface sans exception.

```ocaml
val parse_string : ?filename:string -> string -> (Ast.query, Error.t) result
val parse_file   : string -> (Ast.query, Error.t) result
```

- **Entrée :** le texte SQL (ou un chemin de fichier).
- **Traitement :** crée un `lexbuf`, lui donne le nom du fichier (pour les messages),
  lance `Parser.query Lexer.token`, et convertit :
  - `Parser.Error` → `Error.syntax_error "syntax error"` à la position du dernier token lu ;
  - `Error.Syntax_error e` (venant du lexer) → `Error e`.
- **Sortie :** `Ok ast` ou `Error e`.

### 3.5 `lib/resolu.ml` — requête résolue

**Rôle :** la forme de la requête *après* vérification, prête pour la génération de
code. Plus aucun nom à chercher : tout est en **indices de colonnes**.

```ocaml
type sortie = { nom : string; col : int }   (* nom affiché, indice dans la table *)
type query = {
  table    : string;                 (* nom canonique de la table *)
  colonnes : string list;            (* toutes les colonnes de la table *)
  sorties  : sortie list;            (* `*` développé, alias appliqués *)
  tri      : (int * Ast.dir) list;   (* indices de colonnes DE LA TABLE *)
  limit    : int option;             (* None = pas de limite ; jamais négatif *)
  offset   : int;                    (* toujours ≥ 0 *)
}
```

C'est la bonne interface pour le rôle C : un générateur de code n'aura qu'à lire ces
champs.

### 3.6 `lib/semantique.ml` — analyse sémantique

**Rôle :** vérifier que la requête a un sens par rapport au schéma, et la traduire en
`Resolu.query`.

```ocaml
type schema = (string * string list) list   (* (nom de table, colonnes) *)
val analyse : schema -> Ast.query -> (Resolu.query, Error.t) result
```

- **Entrée :** un schéma (liste de tables avec leurs colonnes) et un `Ast.query`.
- **Traitement (`analyse`) :**
  1. cherche la table du `FROM` dans le schéma (insensible à la casse) → sinon
     `table inconnue : …` ;
  2. `resoudre_select` : `*` devient toutes les colonnes ; chaque `Column c` devient
     `{ nom = alias ou nom de la colonne ; col = indice }` → sinon `colonne inconnue : …` ;
  3. `resoudre_tri` : chaque colonne du `ORDER BY` est cherchée **d'abord parmi les
     noms de sortie (alias)**, puis parmi les colonnes de la table → sinon
     `colonne inconnue dans ORDER BY : …` ;
  4. normalise `LIMIT` (négatif → `None`, pas de limite) et `OFFSET` (négatif ou
     absent → `0`), comme SQLite.
- **Sortie :** `Ok Resolu.query` ou la **première** erreur rencontrée.
- **Utilitaires :** `egal` (comparaison insensible à la casse), `index_de`,
  `map_result` (un `List.map` qui s'arrête à la première erreur).

### 3.7 `bin/main.ml` — point d'entrée

**Rôle :** programme en ligne de commande.

- **Entrée :** `Sys.argv` = `<fichier.sql> <dossier>`.
- **Traitement :** vérifie le nombre d'arguments, appelle `Parse.parse_file`.
- **Sortie :**
  - succès → affiche `parse OK`, code 0 ;
  - erreur → affiche `fichier:ligne:colonne: message` sur stderr, code 2 ;
  - mauvais nombre d'arguments → message d'usage, code 2.
- Le second argument (`<dossier>`) n'est **pas utilisé** pour l'instant.

---

## 4. Avis sur la qualité du code et améliorations

### 4.1 Ce qui est bien fait

- **Découpage net en étapes**, avec des types intermédiaires bien choisis
  (`Ast` = ce qui est écrit, `Resolu` = ce qui est compris). Ajouter un fragment
  revient à étendre chaque étape sans tout casser.
- **Gestion d'erreurs propre** : `result` partout, les exceptions sont confinées à
  `parse.ml`, les positions sont suivies (`Lexing.new_line`, `set_filename`).
- **Menhir en `--strict`** : un conflit de grammaire fait échouer la compilation, au
  lieu d'être résolu en silence.
- **`Resolu` en indices** : excellente préparation pour la génération de C (accès à
  `ligne[i]` direct, pas de recherche de nom à l'exécution).
- **Code court et lisible**, commentaires utiles (choix SQLite/PostgreSQL signalés,
  mode d'emploi pour ajouter un mot-clé).
- Insensibilité à la casse des mots-clés et des identifiants, alias implicite, `;`
  optionnel : bons réflexes SQL.

### 4.2 Problèmes importants (à traiter avant la livraison F0 du 21/10)

1. **Aucune génération de C.** C'est le cœur du projet et il manque entièrement
   (rôle C). Sans lui, aucun test F0 ne peut passer : `make -C <dossier>` échouera
   car rien n'est écrit dans `<dossier>`.

2. **`main.ml` viole le contrat sur les requêtes invalides.** Le contrat
   (`README_ARTEFACT.md`) exige que SQL67 écrive du C et un Makefile **même si la
   requête est invalide** : c'est le programme `.out` qui doit signaler l'erreur à
   l'exécution. Ici, `main` fait `exit 2` sans rien écrire → compté comme un défaut du
   compilateur. Il faut, en cas d'erreur, générer un petit `main.c` qui affiche le
   message et renvoie le bon code.

3. **Le schéma n'est pas connu à la compilation.** `Semantique.analyse` a besoin d'un
   `schema`, mais les CSV ne sont donnés qu'au `.out`, à l'exécution. Il faut trancher :
   - soit la résolution des noms de colonnes (et le développement de `*`) se fait
     **dans le C généré**, en lisant la ligne d'en-tête du CSV ;
   - soit on garde `Semantique` à la compilation pour ce qui ne dépend pas du schéma
     (LIMIT/OFFSET, cohérence des alias…) et on déplace la recherche de colonnes au
     runtime.

   Dans les deux cas, `Resolu` devra probablement garder des **noms** à résoudre et
   pas seulement des indices. C'est la décision d'architecture la plus urgente.

4. **Correspondance table SQL ↔ fichier CSV** : le `.out` reçoit les CSV par position
   (`t1.csv t2.csv …`). Il faut définir comment `FROM t` choisit son fichier (nom du
   fichier ? ordre des arguments ?) et le vérifier sur les tests du sujet.

5. **Pas de tests.** `test/F0` … `test/F5` sont vides ; `test/expl` ne contient que les
   exemples du sujet. Or les tests valent 20 % de la note. Ajouter au minimum des
   tests cram pour : chaque clause seule, alias avec/sans `AS`, `ORDER BY` sur alias,
   `LIMIT`/`OFFSET` négatifs, colonne/table inconnue, erreurs de syntaxe.

### 4.3 Problèmes plus mineurs

- **`parse_file` peut lever une exception** (`Sys_error` si le fichier n'existe pas),
  alors que le commentaire de `parse.ml` promet « aucune exception ne sort d'ici ».
  Rattraper `Sys_error` et renvoyer un `Error.t`.
- **Les erreurs sémantiques n'ont pas de position** : l'AST ne stocke aucune
  `Lexing.position`. Ajouter des positions (au moins sur `Column` et sur le `FROM`)
  donnera des messages comme `a.sql:1:8: colonne inconnue : x`.
- **Message de syntaxe pauvre** : toujours `"syntax error"`. Menhir permet des messages
  par état (`--compile-errors` / fichier `.messages`), ou au minimum afficher le token
  fautif (`Lexing.lexeme lexbuf`).
- **`Error.exit_code` est redondant** : il vaut toujours 2. Soit le supprimer, soit
  s'en servir vraiment (codes différents selon le type d'erreur si le sujet le demande).
- **Ambiguïté alias / colonne dans `ORDER BY`** : avec `SELECT a AS b, b FROM t ORDER BY b`,
  le code prend le premier nom de sortie trouvé (`a`). Vérifier le comportement exact
  de SQLite sur ce cas et l'écrire dans un test.
- **Lexer incomplet pour la suite** : pas d'identifiants entre guillemets (`"ma col"`),
  pas de chaînes `'…'`, pas de commentaires `/* … */`, pas de nombres décimaux.
  `12abc` est lu comme `INT 12` puis `IDENT abc` (le parser échouera, mais le message
  sera trompeur).
- **Entiers OCaml sur 63 bits** : `LIMIT 9223372036854775807` est refusé alors que
  SQLite l'accepte (entiers 64 bits). Cas limite, mais facile à tester par les
  correcteurs. `Int64` ou un plafonnement résoudrait le problème.
- **`ORDER BY 1`** (numéro de colonne) n'est pas géré ; SQLite le permet.
- **Nommage mélangé français/anglais** (`Resolu.sortie`, `analyse` vs `Parse`,
  `parse_string`, `Error`). Choisir une langue et s'y tenir aide la lecture collective.
- **Pas de fichiers `.mli`** : ajouter `parse.mli` et `semantique.mli` fixerait les
  interfaces entre rôles et cacherait les utilitaires (`egal`, `map_result`…).
- `dune-project` ne déclare pas de `(package …)` alors qu'un `sql67.opam` est écrit à
  la main ; on peut laisser dune générer l'opam (`(generate_opam_files true)`).

### 4.4 Plan d'action conseillé (par priorité)

1. Décider où se fait la résolution des colonnes (compilation ou exécution) — point 4.2.3.
2. Écrire un module `codegen.ml` : `Resolu.query -> unit` qui écrit `main.c`, une
   petite bibliothèque CSV en C, et le `Makefile` produisant `<dossier>/<dossier>.out`.
3. Brancher toute la chaîne dans `main.ml` : `Parse` → `Semantique` → `Codegen`, et en
   cas d'erreur générer un C qui affiche l'erreur (jamais d'`exit` non nul côté SQL67).
4. Écrire les tests F0 (cram) en comparant avec SQLite.
5. Ensuite seulement : positions dans l'AST, messages d'erreur Menhir, `.mli`.

### 4.5 Verdict

Ce qui existe est **propre, idiomatique et bien pensé** : la séparation
AST / résolu / erreurs est celle d'un vrai compilateur et elle tiendra pour les
fragments suivants. Mais c'est environ **un tiers du travail F0** : le back-end C
manque, le point d'entrée ne respecte pas encore le contrat, et la question
« schéma connu à la compilation ou à l'exécution ? » doit être tranchée vite parce
qu'elle change la forme de `Resolu`.
