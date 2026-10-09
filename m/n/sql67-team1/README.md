[TOC]

# Project de CompiLation: SQL67

L'objectif de ce projet est d'écrire un compilateur d'un langage de haut niveau,
en developpant toutes les étapes qui le compose,
depuis l'analyse lexicale jusqu'à la production de code bas niveau.
Le language source est un fragment de SQL que nous ferons grandir au fur et à mesure.
Le langage cible est le C99.
Le processus est alors le suivant:

1. Vous poussez les sources de votre compilateur SQL67 sur Gibson.
2. Votre morceau de pipeline rend votre compilateur SQL67 executable (i.e. le compile) si besoin.
3. Un second morceau de pipeline présente des sources SQL à votre compilateur SQL67 pour en 
   extraire des sources C.
4. Ces sources C sont ensuite compilés (via le Makefile que votre compilateur SQL67 fournit aussi).
5. Les executables produits sont lancés, potentiellement sur des bases de données en
   [CSV](https://datatracker.ietf.org/doc/html/rfc4180).
6. Ces executions donnent lieu à des messages sur `stdout` et `stderr`, et des écritures 
   de bases de données en [CSV](https://datatracker.ietf.org/doc/html/rfc4180).

Ce processus implique donc 2 ou 3 compilateurs:
un compilateur C, comme `clang` ou `gcc`;
votre compilateur SQL67;
et si besoin, un compilateur pour compiler votre compilateur.

Le présent sujet décrit les modalités du projet.

## Cadre général

L'écriture du compilateur concerne les deux modules PCL1 et PCL2.
La partie PCL1 (octobre à mi-janvier) s'adresse à tous les élèves:
il s'agit de compiler un petit fragment de SQL.
La partie PCL2 (mi-janvier à mi-mai) s'étend à un fragment plus important.
Seuls les élèves des approfondissements IL et ISS présents au S8
à Telecom Nancy sont concernés par ce second module PCL2.
La suite de ce document se concentre sur PCL1
mais vous pouvez en deviner ce qu'il vous attend pour PCL2.

Pour ce projet, formez des groupes de 4. Les élèves d'un même groupe sont:
soit tous en IAMD, SLE ou SIE, ou bien en mobilité au semestre 8 (PCL1 uniquement);
soit tous en IL ou ISS, et aucun en mobilité au semestre 8 (PCL1 et PCL2).
Tous les membres des groupes de projet doivent travailler à part égale sur le projet.

Aucun langage ou outil n'est imposé pour le développement de votre compilateur,
c'est à vous de choisir.
Choisissez un langage pour lequel chacun des membres du groupe est suffisament compétent. 
Les analyses lexicale et syntaxique peuvent être "manuelles" ou outillés
(dans la lignée de `lex` et `yacc`).
Aussi, l'analyse syntaxique peut être descendante ou ascendante.

Vous utiliserez un dépôt Git sur Gibson, l'instance Gitlab de TELECOM Nancy,
pour développer votre projet.
On vous informera des modalités de création des dépôts.
Les dépots seront régulièrement consultés par les enseignants chargés de vous évaluer
lors des séances de TP.

En cas de litige sur la participation active de chacun des membres du groupe au projet,
le contenu de votre projet sur le dépôt sera examiné attentivement.
Les notes peuvent être individualisées.

## Rythme de Travail 

Toutes les 2 semaines de cours, vous découvrirez un nouveau fragment de SQL à gérer.
Les semaines de vacances ne sont pas concernées.
Ces fragments seront publiés sur Gibson via éléments de travail (*issues*).

Fragment | Deadline Livraison
-------- | --------
F0 | 2026-10-21T00:00:00Z
F1 | 2026-11-11T00:00:00Z
F2 | 2026-11-25T00:00:00Z
F3 | 2026-12-09T00:00:00Z
F4 | 2026-12-23T00:00:00Z
F5 | 2027-01-23T00:00:00Z

Les fragments ne sont expressément pas trop détaillés.
D'une part, vous bénéficiez déjà de connaissances et ressources
en SQL, en C et en compilation.
D'autre part, servez-vous de la publication sur Gibson
pour nous questionner sur le fragment concerné.

En particulier, nous ne donnons ni syntaxe ni sémantique précises.
Nous nous baserons sur des implémentations de référence (SQLite, PostgreSQL, MariaDB) et nos échanges pour statuer.
Vous avez donc intérêt à participer à ces échanges.

Une méthode efficace pour influencer nos verdicts:
proposer des tests;
montrer qu'ils sont en accord avec une ou plusieurs implémentations de référence.

En tout cas, ne restez pas assis sur vos mains.
Au mieux, les fragments vont s'enchaîner rapidement;
au pire, ils s'accumuleront encore plus vite.

## Livraisons et Notation

Cette section présente ce qui est attendu à chaque livraison.
Pour les aspects techniques des livraisons: [README_ARTEFACT.md](README_ARTEFACT.md)

### Livraison des Fragments (80%)

Commencez par livrer vos fragments en temps et en heure.
Vous êtes 4 et disposez de 2
semaines par fragment. Chaque fragment rapporte jusqu'à 3 points. À chaque itération, la
livraison des fragments publiés sera évaluée: un fragment donné rapportera 1,6 point à la
fin de sa première itération, puis 0,8 à la seconde, 0,4 à la troisième, et enfin 0,2 à la
quatrième.

| FEAT | S0 | S1 | S2 | S3 | S4 | S5 |  TOTAL
|------|----|----|----|----|----|----|-------:
|  F0  | 8% | 4% | 2% | 1% |    |    | **15%**
|  F1  |    | 8% | 4% | 2% | 1% |    | **15%**
|  F2  |    |    | 8% | 4% | 2% | 1% | **15%**
|  F3  |    |    |    | 8% | 4% | 2% | **14%**
|  F4  |    |    |    |    | 8% | 4% | **12%**
|  F5  |    |    |    |    |    | 9% |  **9%**

### Livraison de Tests Unitaires (20%)

Pour valider la livraison d'un fragment, quoi de mieux que des tests? Chaque fragment
donne lieu à plusieurs fonctionnalités. Charge à vous d'écrire une suite de tests pour
chacune de ses fonctionnalités. Non seulement, ça vous servira à développer votre
compilateur; mais ça peut vous rapportez des points à chaque fragment.

Pour ça, faites créer une suite de tests dans un dossier `test/F0`, `test/F1`, ..., `test/F5`
selon le fragment ciblé. Vos tests seront validés à partir d'une version de référence de SQL67.
Basez vous sur `test/expl`; il s'agit de *cram* tests que vous pouvez exercer
avec [`cram -v test/expl`](https://bitheap.org/cram/),
[`scrut -C test test/expl`](https://facebookincubator.github.io/scrut/):

```scrut
$ cram -v test/expl
test/expl/exit_code.t: failed
--- test/expl/exit_code.t
+++ test/expl/exit_code.t.err
@@ -1,6 +1,7 @@
 A command has an exit code. By default, the test expects 0.
 
   $ false
+  [1]
 
 When a command exits with a nonzero exit code,
 specify it between square brackets after its output:
test/expl/fail_test.t: failed
--- test/expl/fail_test.t
+++ test/expl/fail_test.t.err
@@ -14,3 +14,5 @@
 Try to remove it again:
 
   $ rm data.txt
+  rm: data.txt: No such file or directory
+  [1]
test/expl/setup.t: passed
test/expl/success_expl.t: passed
# Ran 4 tests, 0 skipped, 2 failed.
[1]
```

```scrut
$ scrut -C test test/expl
// =============================================================================
// @ test/expl/fail_test.t:16
// -----------------------------------------------------------------------------
// # Try to remove it again:
// -----------------------------------------------------------------------------
// $ rm data.txt
// =============================================================================

unexpected exit code
  expected: 0
  actual:   1

## STDOUT
#> rm: data.txt: No such file or directory
## STDERR


// =============================================================================
// @ test/expl/exit_code.t:3
// -----------------------------------------------------------------------------
// # A command has an exit code. By default, the test expects 0.
// -----------------------------------------------------------------------------
// $ false
// =============================================================================

unexpected exit code
  expected: 0
  actual:   1

## STDOUT
## STDERR


Result: 4 document(s) with 16 testcase(s): 14 succeeded, 2 failed and 0 skipped
[50]
```

Un bon test est un test qui expose un défaut. Ainsi, vous gagnez des points
avec votre suite de tests par compilateur SQL67 invalidé lors de l'évaluation
d'une itération proche. La quantité de points obtenu décroit au fur et à mesure
qu'on s'éloigne de la date de livraison du fragmemt; et il y a un maximum de
points de tests par fragments. Les valeurs sont données par le tableau suivant:

| TEST |  S0  |  S1  |  S2  |  S3  |  S4  |  S5  |   MAX
|------|------|------|------|------|------|------|--------:
|  F0  | 0.5% | 0.2% | 0.1% |      |      |      | **3.6%**
|  F1  |      | 0.5% | 0.2% | 0.1% | 0.0% |      | **3.6%**
|  F2  |      |      | 0.5% | 0.2% | 0.1% | 0.0% | **3.6%**
|  F3  |      |      |      | 0.5% | 0.2% | 0.1% | **3.6%**
|  F4  |      |      |      |      | 0.5% | 0.2% | **2.8%**
|  F5  |      |      |      |      |      | 0.4% | **2.8%**

Par exemple: sur le fragment F0, vos tests invalident 5 autres compilateurs à
la livraison S0, mais aussi à la livraison S1; à la livraison S2, ils ont enfin
résolu leurs problèmes et ces tests n'invalident plus rien; vous empochez donc
$5 \times 0.5% + 5 \times 0.2% = 3.5%$.
Invalider des compilateurs supplémentaires au S1
vous aurait amené à 3.6%, le maximum pour ce fragment.

### Performance (20%)

Ces tests serviront aussi des tests de performances.
Il s'agit donc de la performance du code C que vous générez;
pas de la vitesse de votre compilateur à transformer le SQL en C.
L'ensemble des tests pour un fragment donné prendra un temps différent par équipe;
ce qui donne lieu à un classement, par fragment.
À chaque livraison, il y a un pourcentage de points donné ci-dessous:

| PERF |  S0  |  S1  |  S2  |  S3  |  S4  |  S5  |  TOTAL
|------|------|------|------|------|------|------|--------:
|  F0  | 1.8% | 0.9% | 0.6% | 0.3% |      |      | **3.6%**
|  F1  |      | 1.8% | 0.9% | 0.6% | 0.3% |      | **3.6%**
|  F2  |      |      | 1.8% | 0.9% | 0.6% | 0.3% | **3.6%**
|  F3  |      |      |      | 1.9% | 1.0% | 0.7% | **3.6%**
|  F4  |      |      |      |      | 1.9% | 0.9% | **2.8%**
|  F5  |      |      |      |      |      | 2.8% | **2.8%**

Vous obtenez une part de points proportionnelle à votre classement.

Par exemple, pour le fragment F1:

1. vous êtes les plus rapides à la livraison S1, vous obtenez 1.8%, i.e. 0.36 point;
2. à la livraison S2, il y a $k=5$ équipes sur $n=32$ devant vous,
   alors vous obtenez $\left(1-\frac{k}{n-1}\right)0.9$%, i.e. ±0.75%, i.e. ±0.15 points;
3. à la livraison S3, il n'y plus que 1 équipe devant, vous obtenez $\left(1-\frac{1}{31}\right)0.6$%, i.e. ±0.58%, i.e. ±0.12 points;
4. à la livraison S4, vous êtes premier, vous obtenez 0.3%, i.e. 0.06 points;
5. à la livraison S5, vous conservez la couronne mais il n'y a plus de points à gagner;

Vos performances sur le fragment F1, vous rapporte ±3.44% (sur un total de 3.6%), i.e. 0.69 points (sur un total de 0.72).

## Conseils

Relisez vos cours de SQL, de C, de structures de données et de compilation.

### SQL

Manipulez les implémentations de référence: SQLite, PostgreSQL, MariaDB.
Consultez leurs documentations, vous y trouverez leurs syntaxes et sémantiques.

### C

Quelque soit le langage choisi pour écrire votre compilateur,
vous pouvez (devrez?) écrire à la main les morceaux de C
pour lire, et écrire, des tables depuis, et vers, des fichiers CSV.

Quelle structure de données pour une table? Cela peut être un simple tableau--dynamique,
pourquoi pas--mais les SGBDRs reposent sur les B-arbres--une généralisation des arbres
binaires de recherche.

### Analyse Syntaxique

Votre grammaire va subir au minimum une demi-douzaine d'évolutions. Le premier fragment
risque même d'être un simple langage rationnel. Mais sachez anticiper: le fragment finira
par être un langage algébrique. Surtout, ne baclez pas votre grammaire, au risque d'une
situation délicate dans le style suivant:
"pour ce nouveau fragment,
dois-je modifier les règles sur le non-terminal `A`, `A1` ou `A3`? ou encore `B12`?
ou plutôt repousser le terminal `truc`?"

### Appropriation collective du code

L'équipe est collectivement responsable du compilateur. Chaque développeur doit être en
capacité de faire des modifications dans toutes les portions du code, même celles qu'il
n'a pas écrites. Ce sera très probablement le cas, vu la demi-douzaine d'itérations. Les
tests diront si quelque chose ne fonctionne plus.

Il serait bon de limiter les fonctionnalités avec un unique auteur et surtout de bien
communiquer. Tout le monde n'a pas non plus besoin d'une compréhension exhaustive. Dans
votre équipe de 4, on peut envisager le process suivant:

1. Alice écrit la fonctionnalité puis ouvre une demande de fusion.
2. Bob fait une relecture minutieuse de la demande de fusion.
   Cela peut donner lieu à des échanges avec Alice.
3. ± Simultanement à la fusion, Charlie et David prennent connaissance
   d'un mémo de conception pour la fonctionnalité.

### Arbres de Syntaxe Abstraite

Le sujet n'impose même pas de passer par des AST, mais ça reste une bonne idée. Les termes
d'algèbre relationnelle sont de bons AST; termes que vous pourrez manipuler pour optimiser
les requêtes.

Vous pouvez aussi jeter un oeil au mot-clé `EXPLAIN` dans les différentes implémentations
de réferences. Il fait apparaitre une suite d'instructions dans un style davantage
impératif que le très déclaratif SQL. Ça tombe bien, votre compilateur SQL cible du C,
langage impératif s'il en est.

## F0

Cette section donne les contours du premier fragment au cas où:

- Simple `SELECT` sur 1 table
- `OFFSET` et `LIMIT`
- Renommage `AS`
- `ORDER BY`

