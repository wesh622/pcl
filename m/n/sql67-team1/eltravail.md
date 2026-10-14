# Éléments de travail Gibson : décisions et précisions

Ce fichier résume ce qui a été tranché ou proposé dans les éléments de travail (epics)
du sujet sur Gibson. Le sujet ne donne ni syntaxe ni sémantique précises : **ce sont ces
échanges qui font foi** pour la correction.

**Pour l'équipe et pour Claude :**
- Mettez à jour ce fichier dès qu'un epic change (vote clos, label « proposition(s)
  acceptée(s) », nouveau message d'erreur…). Indiquez la date.
- Avant de toucher au compilateur, lisez la section [Écarts avec notre implémentation](#écarts-avec-notre-implémentation).
- Statuts utilisés :
  - ✅ **acceptée** : label « proposition(s) acceptée(s) », ou bien le délai « si personne n'a rien à redire » est passé ;
  - 🟡 **proposée** : en attente, le délai court encore ;
  - 🗳️ **vote en cours** ;
  - ❓ **ouverte** : pas encore de réponse.

Dernière mise à jour : 2026-10-14 (décisions appliquées dans le code).

---

## Calendrier

| Quoi | Date |
|---|---|
| Échéance de livraison F0 (README) | **2026-10-21T00:00:00Z** |
| Échéance des epics F0 sur Gibson | 20 oct. 2026 |
| Clôture du vote LIMIT/OFFSET (#2) | **16 oct. 2026, 18h** |
| Clôture du vote sur la validation des CSV (#11) | 16 oct. 2026 |

## Contenu de F0

- `SELECT` simple, **une seule table** par requête.
- Projection de colonnes, avec renommage `AS` (alias de colonne). ✅
- `ORDER BY`, `LIMIT`, `OFFSET`.
- **Pas de renommage de table** en F0 (`FROM users u` / `FROM users AS u`) : la ligne
  « Renommage AS » du README désigne la projection. ✅
- **Pas d'identifiants qualifiés** `<table>.<colonne>` (`ORDER BY t.age`) en F0 : on se limite à `<colonne>`. 🟡 (délai de 3 jours à partir du 13/10)
- `SELECT *, *` est accepté, comme dans SQLite : toutes les colonnes apparaissent deux fois. 🟡

## Sortie (#9 format output CSV) ✅

- La sortie est un CSV sur **stdout**, **avec un en-tête** sur la première ligne. En cas d'erreur : un message sur **stderr**, à la place.
- CSV **normalisé et idempotent** : relire sa propre sortie doit redonner la même sortie.
- On **retire les guillemets** quand ils ne sont pas nécessaires (`"Ana"` → `Ana`). On les garde quand ils sont obligatoires (`"A""na"`, virgule, saut de ligne).
- Les **espaces font partie de la valeur**, on les conserve (`a, b` : la 2ᵉ colonne s'appelle ` b`).
- Séparateur : `,` sans espace.
- **NULL = champ vide**, en entrée comme en sortie (pas de mot-clé `null`).

## Lecture des CSV

### Grammaire (#6 CSV Parsing) ✅
- On applique **strictement la grammaire RFC 4180**. Les lignes que la RFC rejette sont des erreurs, par exemple :
  - un guillemet jamais refermé : `1,"abc` puis fin du fichier ;
  - du texte après le guillemet fermant : `1,"x"y,3` ;
  - un guillemet au milieu d'un champ non quoté : `a, b, "c"`. Ici, ` "c"` commence par une espace, donc ce n'est pas un champ quoté.
- Message proposé : **`Error: invalid CSV file t.csv`**, avec le **nom du fichier seul**, sans le chemin (sinon `$TESTDIR` apparaîtrait dans les tests). Code de retour **1**. L'erreur arrive avant toute sortie. 🟡

### Validation (#11) 🗳️ vote en cours
Trois options :
- 🪺 *total eager* : on valide tous les CSV passés en argument, dès le départ ;
- 🥚 *partial eager* : on valide au départ seulement les CSV utilisés ;
- 🦥 *lazy* : on valide au moment de l'utilisation.

En F0 (une seule requête, une seule table), 🥚 et 🦥 donnent le même résultat. La vraie question est : **un CSV invalide mais non utilisé provoque-t-il une erreur ?**

### Association table ↔ fichier (#10)
- `FROM users` désigne l'argument dont le nom est **`users.csv`**. ✅
- Sensibilité à la casse : ❓ « faites votre proposition ». PostgreSQL distingue la casse pour les identifiants entre guillemets et la replie pour les autres. SQLite ne distingue jamais.
- Plusieurs fichiers avec le même nom de table : on produit une erreur. 🟡
- Table absente : erreur à l'exécution. 🟡
- Fichier passé en argument mais inexistant (ou qui n'est pas un fichier) : ❓ question ouverte (Titouan Rose, Clément Di Gallo). Rien n'est tranché.

Messages proposés (#11, code de retour **1**) : 🟡
```
Error: no such table: T
Error: duplicate table: T
Error: invalid CSV file T.csv
```

## Identifiants SQL (#10)

- Les identifiants entre **guillemets doubles** sont acceptés : `"123table"`, `"User Data"`, `"select"`. ✅
- Les guillemets **doublés** s'échappent : `"my""table"` donne `my"table`. ✅
- Casse : ❓ à proposer (voir plus haut).

## Types (#8 champ texte?) ✅ vote clos

- **3 types en F0 : entier, flottant, texte.**
- Chaque colonne prend le **plus petit type viable** : entier si toutes ses valeurs non NULL sont des entiers, sinon flottant si c'est possible, sinon texte.
- Comparaison **numérique** si toutes les valeurs non NULL de la colonne sont des nombres. Sinon, **comparaison textuelle sensible à la casse** (`strcmp`).

## ORDER BY (#3)

- Une ou plusieurs colonnes, `ASC` / `DESC`, **`ASC` par défaut**. ✅
- Le tri s'applique **avant** `OFFSET`/`LIMIT`. ✅
- **NULL est la plus petite valeur** : en premier en `ASC`, en dernier en `DESC` (comme SQLite et MariaDB). 🟡
- Le **tri est stable** : à clés égales, on garde l'ordre du fichier. Les tests comparent donc la sortie telle quelle, sans `sort`. 🟡
- Colonne inexistante : erreur **avant toute écriture sur stdout**, message **`Error: no such column: age`**, code de retour **1**. 🟡

## LIMIT et OFFSET (#2) 🗳️ vote jusqu'au 16 oct. 18h : PostgreSQL 🐘 ou SQLite 🪶

| Forme | Proposition PostgreSQL (Gustavo) | Camp SQLite (plusieurs groupes) |
|---|---|---|
| `LIMIT 10` | oui | oui |
| `LIMIT 10 OFFSET 5` | oui | oui |
| `OFFSET 5` (sans LIMIT) | oui | **non** |
| `OFFSET 5 LIMIT 10` | **non** | non |
| `LIMIT 5, 10` (offset 5, limite 10) | **non** | oui |
| `LIMIT ALL` | non (pas en F0) | — |

Points communs :
- Valeurs : **entiers littéraux décimaux non négatifs** uniquement.
- `LIMIT -5` : **erreur de syntaxe** (`Error: syntax error`). Accepté par l'enseignant (« ok pour le négatif où Postgres se plaint »).
- Valeur trop grande : **pas d'erreur**, puisqu'aucune implémentation ne se plaint.

---

## Écarts avec notre implémentation

État du code au commit « Applique les décisions Gibson ». Tous les écarts connus ont été
corrigés, sauf ceux qui attendent un vote. Les tests correspondants sont dans `test/F0/`.

### Corrigés
| Sujet | Où | Test |
|---|---|---|
| Code de retour **1** pour toutes les erreurs | `EXIT_ERROR` dans `lib/c/runtime.c`, `lib/error.ml` | `proj_unknown.t`, `table_unknown.t`… |
| Type **par colonne** (int, puis float, puis texte), texte comparé avec `strcmp` (casse incluse) | `column_type`, `cmp_key` | `order_mixed.t`, `order_ints.t`, `order_name.t` |
| CSV strict RFC 4180 : `Error: invalid CSV file <nom>` | `parse_csv` | `csv_invalid.t` |
| Table en double : `Error: duplicate table: T` | `main` | `tables_args.t` |
| Identifiants `"..."` avec `""` échappé | `quoted_ident` dans `lib/lexer.mll` | `ident_quoted.t` |
| LIMIT/OFFSET négatif : erreur de syntaxe | `lib/parser.mly` (plus de `MINUS`) | `limit_negative.t` |
| Message `Error: syntax error`, sans position | `bin/main.ml` | `syntax_error.t` |
| Champ quoté vide `""` traité comme NULL | `parse_csv` | `csv_format.t` |

### En attente d'un vote
| Sujet | Aujourd'hui | Quand le vote sera clos |
|---|---|---|
| Formes de LIMIT/OFFSET (#2, 16/10 18h) | toutes acceptées : `LIMIT n`, `LIMIT n OFFSET m`, `OFFSET m`, `OFFSET m LIMIT n`, `LIMIT m, n` | supprimer les formes rejetées dans `limit_offset` (`lib/parser.mly`), et les tests `limit_comma` ou `offset_*` |
| Validation des CSV (#11, 16/10) | 🥚 seul le CSV utilisé est validé | si 🪺 l'emporte : passer `#define VALIDATE_ALL 1` dans `lib/c/runtime.c` (déjà implémenté et testé à la main) |

### Nos choix sur les points ouverts (à proposer sur Gibson si besoin)
- **Casse** : on ne distingue pas la casse des identifiants, quotés ou non (comme SQLite). Cela vaut pour les colonnes, les alias, les tables et les noms de fichiers. La casse du nom affiché est celle écrite dans la requête, ou celle de l'en-tête pour `*`.
- **Fichier inexistant ou illisible** passé en argument : `Error: invalid CSV file <nom>`. Logique : l'argument est fourni mais inutilisable. `no such table` est réservé au cas où aucun argument ne nomme la table. Avec 🥚, un fichier inexistant qui ne sert pas est ignoré.
- **Nombre de champs différent de l'en-tête** : CSV invalide. La RFC dit seulement « should ».
- **Nombres** : `[+-]?` chiffres, partie décimale et exposant facultatifs (`.5`, `1e2`, `+7`). Les espaces font partie de la valeur, donc `" 12"` est un texte. Un entier qui dépasse 64 bits est traité comme un flottant. En sortie, on réécrit le texte d'origine tel quel.
- **Syntaxe** : code de retour 1, comme les autres erreurs. L'exemple `[2]` de README_ARTEFACT n'est qu'une illustration.
- **Extras sans danger** : `SELECT DISTINCT`, `ORDER BY 2` (position), identifiants entre backticks.

Les tests de `test/F0/` suivent ces décisions : mettez-les à jour en même temps que le code.
