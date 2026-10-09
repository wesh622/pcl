# Conception du compilateur SQL67 (OCaml)

Ce document explique **pourquoi** chaque fichier existe et pourquoi il est écrit ainsi.
Le *comment* est dans les commentaires des fichiers eux-mêmes.

À lire en premier par chaque membre de l'équipe : le sujet exige que tout le monde
puisse modifier n'importe quelle partie du code.

---

## 1. Point de départ : ce que le sujet impose

Tout le reste découle de ces contraintes (README.md et README_ARTEFACT.md) :

| Contrainte du sujet | Conséquence sur la conception |
|---|---|
| `SQL67 <x.sql> <x>` écrit du C **et un Makefile** dans `<x>/` | `main.ml` écrit 4 fichiers : `main.c`, `runtime.c`, `runtime.h`, `Makefile` |
| `make -C <x>` doit produire `<x>/<x>.out` | La cible du Makefile est nommée d'après le dossier |
| Seuls `clang`, `make`, libc et libm sont disponibles | Makefile en `$(CC)`/clang, aucune bibliothèque externe en C |
| `SQL67` est **un seul fichier exécutable** | Le code C du runtime est **embarqué** dans l'exécutable OCaml |
| OCaml : exécutable **natif** (le bytecode ne marche pas) | `dune` construit `main.exe` en natif |
| Requête invalide : SQL67 et make **réussissent**, l'erreur apparaît **à l'exécution** | Le compilateur ne plante jamais : il génère un `main.c` qui affiche l'erreur |
| Le `.out` reçoit les CSV en arguments, travaille **en mémoire**, ne modifie **jamais** les CSV | Le runtime charge tout en mémoire, en ouvrant les fichiers en lecture seule |
| SQL67 ne voit **jamais** les CSV | Les noms de colonnes sont résolus **à l'exécution**, pas à la compilation |
| La grammaire va évoluer à chaque fragment (F0 à F5), jusqu'à une grammaire algébrique | Un générateur de parseur (menhir) plutôt qu'un parseur écrit à la main |
| La performance du `.out` compte pour 20 % de la note | C compilé en `-O2`, runtime en C simple et direct |

---

## 2. Architecture générale

Un compilateur classique en 3 étapes, une par fichier :

```
 select.sql                                                          select/
 ──────────                                                          ───────
 "SELECT c, a FROM t;"
        │
        ▼  lexer.mll    (analyse lexicale : caractères → tokens)
 SELECT IDENT"c" COMMA IDENT"a" FROM IDENT"t" SEMI EOF
        │
        ▼  parser.mly   (analyse syntaxique : tokens → AST)
 { select = Columns ["c";"a"]; from = "t" }        ← type défini dans ast.ml
        │
        ▼  codegen.ml   (génération de code : AST → C)
 main.c  ─────────────────────────────────────────────────────────▶  main.c
                                    runtime.c (embarqué) ──────────▶  runtime.c, runtime.h
                                    main.ml ───────────────────────▶  Makefile
                                                                         │
                                                              make ──────▼
                                                                      select.out
```

**Pourquoi cette séparation ?**
- Chaque étape peut être comprise, testée et modifiée seule.
- On peut se répartir le travail : ajouter `ORDER BY` touche le lexer (mot-clé),
  le parser (règle), l'AST (champ) et le codegen/runtime (tri). Ce sont 4 endroits
  bien identifiés, et non un seul gros fichier où tout est mélangé.
- C'est la structure vue en cours de compilation : le vocabulaire est commun à toute l'équipe.

---

## 3. Fichier par fichier

### `dune-project`
**Rôle :** marquer la racine du projet pour dune.

**Pourquoi dune ?** C'est l'outil de build standard d'OCaml, recommandé par le sujet
(« dune `executable`, `main.exe` »). Il gère tout seul l'ordre de compilation des
modules et sait appeler ocamllex et menhir.

**Pourquoi `(using menhir 2.1)` ?** Sans cette ligne, dune refuse de compiler `parser.mly`.

### `sql67.opam`
**Rôle :** lister les dépendances (ocaml ≥ 4.14, dune, menhir).

**Pourquoi ?** Pour que chacun installe son environnement en une commande
(`opam install . --deps-only`). La version 4.14 minimum vient de `In_channel`,
utilisé dans `main.ml`.

### `bin/dune`
**Rôle :** décrire comment construire l'exécutable.

Il y a 4 blocs :
1. `executable` : le programme, avec `main.ml` comme point d'entrée.
2. `ocamllex` : génère `lexer.ml` à partir de `lexer.mll`.
3. `menhir` : génère `parser.ml` à partir de `parser.mly`.
4. `rule` : **le point le plus subtil du projet.** Le sujet impose que `SQL67` soit
   *un seul fichier*. Or chaque programme généré a besoin du runtime C.

   Les solutions possibles étaient les suivantes :
   - (a) livrer `runtime.c` à côté de `SQL67` : interdit ;
   - (b) écrire le C du runtime directement dans des chaînes OCaml : illisible et pénible à modifier ;
   - (c) **garder `runtime.c` comme vrai fichier C et le transformer automatiquement en
     chaîne OCaml au moment du build.** C'est ce qu'on a choisi.

   La règle produit `runtime_c.ml` contenant `let source = {runtime|…|runtime}`.
   Les chaînes `{id|…|id}` d'OCaml n'interprètent aucun échappement : le C est
   copié tel quel.

### `bin/ast.ml`
**Rôle :** définir la forme d'une requête analysée.

**Pourquoi un AST ?** Le sujet ne l'impose pas mais le recommande. Il sépare
*comprendre la requête* (parser) de *produire le C* (codegen). Sans AST, le parser
devrait écrire du C directement : impossible à optimiser ou à faire évoluer.

**Pourquoi un record `{ select; from }` ?** On ajoutera des champs (`order_by`,
`limit`, `offset`…) sans casser le code qui utilise déjà `q.select` et `q.from`.

**À anticiper :** dès que la requête se complexifie (WHERE, jointures), il faudra
passer à des termes d'**algèbre relationnelle** (`Project`, `Select`, `Sort`, `Join`…).
Ils permettent d'optimiser les requêtes, et l'optimisation compte pour la note de performance.

### `bin/lexer.mll`
**Rôle :** découper le texte en tokens.

**Pourquoi ocamllex plutôt qu'un lexer écrit à la main ?** On décrit les tokens par
des expressions régulières et ocamllex construit l'automate. Le code est plus court
et plus sûr. Ajouter un mot-clé prend une ligne.

**Choix notables :**
- **Table de mots-clés** au lieu d'une règle par mot-clé : on reconnaît un identifiant,
  puis on regarde s'il s'agit d'un mot-clé. L'automate reste petit, et la règle
  « plus longue correspondance » évite qu'un nom comme `selection` soit lu comme `SELECT` + `ion`.
- **Insensibilité à la casse** des mots-clés (`select` = `SELECT`), comme dans tous les SGBD
  de référence. Les noms de colonnes gardent leur casse : la sensibilité des
  identifiants est une question à trancher avec le sujet.
- **Commentaires `--`** ignorés : c'est du SQL standard et les tests risquent d'en contenir.

### `bin/parser.mly`
**Rôle :** vérifier la grammaire et construire l'AST.

**Pourquoi menhir (analyse ascendante LR(1)) ?**
- Le sujet prévient que la grammaire va changer au moins six fois et finira algébrique
  (expressions imbriquées, sous-requêtes). Un générateur de parseur supporte bien ces changements.
- **Menhir signale les ambiguïtés** (conflits) à la compilation. Avec un parseur
  écrit à la main, une ambiguïté passe inaperçue jusqu'au jour où un test échoue.
- Menhir est plus moderne que ocamlyacc : meilleurs messages d'erreur, et macros
  comme `separated_nonempty_list`.

**Choix notables :**
- `SEMI?` : le `;` final est facultatif, comme dans SQLite.
- `EOF` obligatoire à la fin : on refuse `SELECT * FROM t truc`.

### `bin/codegen.ml`
**Rôle :** produire le `main.c` à partir de l'AST.

**Choix principal : générer peu de C.** Tout ce qui est générique (lire un CSV,
afficher, chercher une colonne) est écrit **une seule fois** dans `runtime.c`.
Le code généré se contente d'appeler ces fonctions. Les raisons :
- `runtime.c` est du C normal, qu'on peut tester et déboguer directement ;
- le compilateur OCaml reste petit ;
- un bug du runtime se corrige à un seul endroit.

Plus tard, pour la performance, on pourra générer du code **spécialisé** pour
chaque requête (boucles et comparaisons écrites en dur), là où les mesures montrent que ça compte.

**Pourquoi les noms de colonnes sont-ils passés en chaînes et non en indices ?**
SQL67 ne voit jamais les CSV : il ne sait pas que `c` est la 3ᵉ colonne. La
correspondance se fait donc à l'exécution, dans `table_print_columns`.

**`Codegen.error`** sert pour les requêtes invalides. Le sujet impose de produire
quand même un programme qui compile et affiche l'erreur à l'exécution.

### `bin/runtime.c`
**Rôle :** la bibliothèque C copiée dans chaque programme généré.

**Pourquoi l'en-tête et l'implémentation sont-ils dans un seul fichier ?** Il n'y a ainsi
qu'une chaîne à embarquer. `main.ml` la recoupe en `runtime.h` et `runtime.c` grâce au
marqueur `/*--- runtime.c ---*/`.

**Choix notables :**
- **Tout en texte (`char *`)** : c'est suffisant pour afficher en F0. Il faudra des types
  (entier, flottant, NULL) au plus tard pour un `ORDER BY` numérique (`10` doit venir après `9`).
- **Tableau dynamique de lignes** à capacité doublée : simple, rapide à parcourir
  (bonne localité mémoire), et ajout en O(1) amorti. Le sujet évoque les B-arbres ;
  ils deviendront utiles avec WHERE et les jointures.
- **Parseur CSV RFC 4180** : guillemets, `""` échappés, fins de ligne `\r\n`. Les
  CSV des tests sont « sales » (voir `test/expl/*.csv`), il faut être robuste.
- **Lignes trop courtes complétées par des champs vides**, pour ne jamais lire hors du
  tableau. Faut-il afficher vide ou `NULL` ? C'est une question ouverte (voir §5).
- **`sql_error`** : *un seul* endroit qui fixe le format des erreurs (`Error: …`, code 2).
  Quand le sujet précisera le format attendu, on ne changera que cette fonction.
- **`xrealloc`** : en cas de manque de mémoire, on arrête proprement au lieu de planter plus loin.

### `bin/str_util.ml`
**Rôle :** chercher une sous-chaîne, pour découper le runtime.

**Pourquoi ne pas utiliser la bibliothèque `str` ?** Ajouter une dépendance pour 8 lignes n'en vaut pas la peine.

### `bin/main.ml`
**Rôle :** le point d'entrée. Il lit les arguments, enchaîne lexer → parser →
codegen, puis écrit les fichiers.

**Choix notables :**
- Les erreurs de lexer et de parser sont transformées en **`result` (`Ok`/`Error`)**
  plutôt que de laisser remonter une exception. Une requête invalide **n'est pas** un
  échec du compilateur : elle produit un programme valide qui signale l'erreur.
- **Le Makefile** est en `-O2 -std=c99 -Wall`, avec `CC ?= clang` :
  - pas de `gcc`, car il n'est pas installé ;
  - pas de `-march=native`, car la machine de correction peut être différente ;
  - `-lm`, pour les futurs calculs flottants.
- **Sans argument**, le programme affiche son usage et renvoie 1. C'est ce que le job
  `sql67:check` exécute : seuls les codes 126 et 127 y signalent un problème.

### `.gitlab-ci.yml` (job `sql67:build` complété)
**Image `ocaml/opam:debian-13-ocaml-5.3`**, celle recommandée par le sujet. Elle
utilise Debian 13, comme `sql67-env` où `SQL67` s'exécute : même glibc, donc pas
d'erreur `GLIBC_2.xx not found`. `sql67.yml` reste donc sur `sql67-env`.

**`--build-dir /tmp/_build`** : l'image tourne sous l'utilisateur `opam`, qui n'a
pas forcément le droit d'écrire dans le dépôt cloné par GitLab.
⚠️ Cette ligne n'a **pas encore été vérifiée** sur Gibson : c'est la première chose à regarder si le job échoue.

### `.gitignore`
On ignore `_build/`, `SQL67` (le sujet demande de ne pas le commiter) et les dossiers
générés dans `test/F*/<nom>/`. On garde `test/F*/data/`, qui contient les CSV des tests.

### `test/F0/`
Il y a 3 tests au format cram/scrut, plus `data/t.csv` :

| Test | Ce qu'il vérifie |
|---|---|
| `select_star` | `SELECT *` : toute la table, en-tête compris |
| `select_cols` | projection **et réordonnancement** (`c, a` alors que le CSV est `a,b,c`) |
| `syntax_error` | le contrat « requête invalide » : erreur à l'exécution, code 2 |

Ils ont deux usages : vérifier notre propre compilateur, et rapporter des points
(20 % de la note) en faisant échouer les compilateurs des autres groupes.

---

## 4. Ce qui a été vérifié

- ✅ `dune build` compile sans erreur (OCaml 4.14 en local).
- ✅ Les 3 tests produisent la sortie et le code de retour attendus (vérifié à la main).
- ✅ `SQL67` sans argument renvoie 1.
- ❌ Les `.t` n'ont pas été lancés avec `scrut`, qui n'était pas installé.
- ❌ Le pipeline GitLab n'a jamais tourné.

## 5. Questions ouvertes (à trancher avec SQLite et l'issue F0 sur Gibson)

1. **Format de sortie** : séparateur `,` ou `, ` ? Faut-il des guillemets autour des
   champs qui contiennent une virgule ? Comment afficher `NULL` ? L'exemple de `test/expl`
   affiche `null` et `, ` mais c'est un « faux » programme.
2. **Message et code d'erreur** exacts (actuellement `Error: …` et le code 2).
3. **Lignes vides et lignes trop courtes ou trop longues** dans les CSV.
4. **Casse des noms de colonnes** : `SELECT A` doit-il trouver la colonne `a` ?
5. **Types** : comment `ORDER BY` compare-t-il `"10"` et `"9"` ?

## 6. Prochaines étapes (F0, échéance 21/10)

| Fonctionnalité | Fichiers à toucher |
|---|---|
| `AS` | lexer (mot-clé), parser, ast (`(string * string option) list`), runtime (nom affiché) |
| `ORDER BY [ASC/DESC]` | lexer, parser, ast, runtime (`qsort` + comparaison typée) |
| `LIMIT` / `OFFSET` | lexer (+ entiers), parser, ast, runtime (bornes de la boucle d'affichage) |
| Tests | `test/F0/` : cas limites (`LIMIT 0`, `OFFSET` trop grand, colonne inconnue…) |

Pour ajouter un mot-clé, la recette est toujours la même :
`%token` dans `parser.mly`, puis une entrée dans `keywords` de `lexer.mll`, puis
une règle de grammaire, puis un champ dans l'AST, et enfin le code dans `codegen.ml` ou `runtime.c`.
