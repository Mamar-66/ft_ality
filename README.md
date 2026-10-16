# ft_ality

Bienvenue dans **ft_ality**, un outil conçu pour vous mettre dans l'ambiance d'un _training mode_ de jeu de combat !

Le principe ? L'application lit une grammaire de coups, construit un automate fini, et reconnaît vos enchaînements en temps réel directement au clavier — **pas besoin d'appuyer sur Entrée**.

## Lancer le projet

```
make
./ft_ality grammars/mk9.gmr          # Mode normal
./ft_ality -d grammars/mk9.gmr       # Mode debug (affiche les transitions de l'automate)

```

Pour quitter à tout moment : `Ctrl-D` ou `Ctrl-C`.

## Format des grammaires

Définissez vos coups de manière intuitive dans un fichier texte :

```
# Un commentaire commence par un dièse
touche1, touche2, ..., toucheN = Nom du coup

```

- **Touches spéciales :** `up`, `down`, `left` et `right` (la casse n'importe pas) sont automatiquement reliées aux flèches directionnelles.

- **Touches classiques :** Les autres symboles reçoivent les touches `q`, `w`, `e`, `a`, `s`, `d`, `z`, `x`... dans l'ordre alphabétique. Le mapping est calculé entièrement de manière dynamique.

## Architecture technique

Le code est découpé en plusieurs modules aux rôles bien définis :

| Module      | Rôle                                                                                                                                 |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `Types`     | Partage les types fondamentaux (`rule`, `key`)                                                                                       |
| `Parser`    | Analyse ligne par ligne et gère les erreurs typées (`result`) avec le numéro de ligne                                                |
| `Automaton` | Automate $A = \langle Q, \Sigma, Q_0, F, \delta \rangle$ : tri des préfixes + $\delta$ totale (plus long suffixe, type Aho-Corasick) |
| `Keymap`    | Calcule proprement le mapping entre touches et symboles                                                                              |
| `Terminal`  | Gère la lecture touche par touche via `stty` (`Sys.command`) et décode les flèches                                                   |
| `Main`      | Orchestre les arguments et gère la boucle principale en récursion terminale                                                          |

> **Note d'implémentation :** Par choix de conception rigoureux, le projet respecte des contraintes strictes : aucun `open`, aucun `;;`, aucune `ref`, aucun tableau ni champ mutable. Les modules autorisés se limitent à `Stdlib`, `List`, `String` et `Sys`.

## Grammaires de test

Plusieurs fichiers sont fournis pour tester les différents cas de figure :

| Fichier                       | Description                                                     |
| ----------------------------- | --------------------------------------------------------------- |
| `grammars/mk9.gmr`            | Comportement de base (même mapping que le sujet)                |
| `grammars/small.gmr`          | Petite grammaire simple (4 coups)                               |
| `grammars/homonymous.gmr`     | Règles homonymes (même combinaison de touches)                  |
| `grammars/prefix.gmr`         | Préfixes communs (`a` / `a,b` / `a,b,a`)                        |
| `grammars/street_fighter.gmr` | Combos longs qui se chevauchent                                 |
| `grammars/invalid/*.gmr`      | Gestion des erreurs (fichiers vides, sans `=`, clé ou nom vide) |
