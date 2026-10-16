# ft_ality

Entraîneur de combos façon *training mode* de jeu de combat : un automate fini
est construit à partir d'une grammaire, puis reconnaît les coups en temps réel
au clavier (pas besoin d'appuyer sur Entrée).

```
make
./ft_ality grammars/mk9.gmr          # mode normal
./ft_ality -d grammars/mk9.gmr       # mode debug (transitions de l'automate)
```
Quitter : `Ctrl-D` ou `Ctrl-C`.

## Format des grammaires

```
# commentaire
touche1, touche2, ..., toucheN = Nom du coup
```
Les symboles `up` / `down` / `left` / `right` (casse indifférente) sont mappés
sur les flèches ; les autres reçoivent `q w e a s d z x ...` dans l'ordre
alphabétique des symboles. Le mapping est donc entièrement calculé depuis la
grammaire.

## Architecture

| Module      | Rôle |
|-------------|------|
| `Types`     | types partagés (`rule`, `key`) |
| `Parser`    | lecture ligne par ligne, erreurs typées (`result`) avec numéro de ligne |
| `Automaton` | A = ⟨Q, Σ, Q0, F, δ⟩ : trie des préfixes + δ totale (plus long suffixe, Aho-Corasick) |
| `Keymap`    | calcul du mapping touches → symboles |
| `Terminal`  | lecture touche par touche (`stty` via `Sys.command`), décodage des flèches |
| `Main`      | arguments, boucle principale récursive terminale |

Aucun `open`, aucun `;;`, aucune `ref` / tableau / champ mutable ; modules
utilisés : `Stdlib` (Pervasives), `List`, `String`, `Sys`.

## Grammaires de test (pour la correction)

| Fichier | Test de la feuille |
|---------|--------------------|
| `grammars/mk9.gmr` | comportement de base (même mapping que le sujet) |
| `grammars/small.gmr` | petite grammaire (4 coups) |
| `grammars/homonymous.gmr` | règles homonymes (même combinaison) |
| `grammars/prefix.gmr` | préfixes communs (`a` / `a,b` / `a,b,a`) |
| `grammars/street_fighter.gmr` | combos longs qui se chevauchent |
| `grammars/invalid/*.gmr` | gestion d'erreurs (vide, sans `=`, clé vide, nom vide) |
