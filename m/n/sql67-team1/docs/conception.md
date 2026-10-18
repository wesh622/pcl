# Conception — F0

État de main au 12 octobre 2026. Moran y a intégré le front-end F0.

Le programme suit actuellement ce chemin : **SQL → lexer → parseur → AST**.
`bin/` contient la commande et `lib/` les modules d'analyse.

## Sources

| Fichier | Rôle |
|---|---|
| `bin/main.ml` | Lit les arguments, lance l'analyse et affiche `parse OK` ou une erreur. |
| `lib/lexer.mll` | Règles pour reconnaître les tokens et ignorer les espaces et commentaires. |
| `lib/parser.mly` | Grammaire F0, tokens et actions OCaml qui construisent l'AST. |
| `lib/ast.ml` | Types représentant la requête : colonnes, alias, table, tri et bornes. Appartient à B. |
| `lib/parse.ml` | Relie la lecture du fichier au lexer/parseur et renvoie un AST ou une erreur. |
| `lib/error.ml` | Type partagé des erreurs : message, position et code de sortie. |

Les actions `{ ... }` du parseur construisent les valeurs des types définis dans
`ast.ml`. La construction est à A ; les types et la sémantique sont à Moran.

## Fichiers générés

| Fichier | Généré par | Rôle |
|---|---|---|
| `lexer.ml` | ocamllex, depuis `lexer.mll` | Lit les caractères et produit les tokens. |
| `parser.ml` | Menhir, depuis `parser.mly` | Reconnaît la syntaxe et construit l'AST. |
| `parser.mli` | Menhir | Interface de `Parser` : tokens, entrée `query` et exception `Error`. |

Un `.ml` contient le code ; un `.mli` décrit ce que les autres modules peuvent
utiliser. Ces fichiers générés vont dans `_build/`. On modifie les sources `.mll`
et `.mly`, puis on reconstruit. `parse.ml` est écrit à la main.

## Outils et bibliothèques

| Élément | Utilité |
|---|---|
| OCaml | Langage du compilateur et compilation en exécutable natif. |
| ocamllex | Générateur du lexer, fourni avec OCaml. |
| Menhir | Générateur du parseur et contrôle de la grammaire avec `--strict`. |
| Dune | Lance les générateurs, compile les modules et assemble le programme. |
| opam | Installe les dépendances déclarées dans `sql67.opam`. |
| `Sql67` | Bibliothèque interne des modules de `lib/`, utilisée par `main.ml`. |

La bibliothèque standard sert à lire les fichiers, manipuler les listes et
afficher les messages. Aucune bibliothèque OCaml externe n'est liée ; le mode
Menhir utilisé ne nécessite pas `menhirLib`.

`dune-project` déclare le projet. `lib/dune` décrit la bibliothèque et les
générateurs ; `bin/dune` décrit l'exécutable. La CI copie le résultat de Dune sous
le nom `SQL67`.

## Autres fichiers

- `docs/` : cette présentation et la [grammaire](grammaire.md).
- `test/F0/` : emplacement des tests F0, encore vide.
- `test/expl/` : exemples de tests fournis, avec des échecs volontaires.
- `.gitlab-ci.yml` : build, vérification, traduction, tests et livraison.
- `sql67.yml` : image Docker où tourne `SQL67`.
- `.gitignore` : exclusion des fichiers générés.
- Les README fournis expliquent le sujet et le contrat de livraison.

## État actuel et correctif

`Parse.parse_file` rattrape les erreurs d'ouverture ou de lecture du SQL et
renvoie un message avec le chemin et la cause : code 1, sans position.
Les erreurs de syntaxe gardent leur position et le code 2.

Build Dune local et 71 tests privés réussis. La nouvelle pipeline CI n'a pas été
vérifiée. Les messages syntaxiques restent génériques et `min_int` reste refusé.

Sur main, le dossier de sortie n'est pas encore utilisé. La sémantique, la
génération C/Makefile et le runtime restent à intégrer. Le sujet demande de produire
du C même pour une requête invalide, afin de signaler l'erreur dans le programme généré.
