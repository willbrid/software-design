# Correction 6.4 — Exercice 3 : faire évoluer la réponse sans casser

> Rappel de l'énoncé : ajouter `id_str`, `share` et `members_page` sans
> qu'aucune application installée ne perde son contrat.

La solution est dans `ex3` du module de correction, verte sous
`go vet ./...` et `go test -race -count=1 ./...`.

## En bref

- **Rien de l'existant ne change** : les nouveaux champs s'ajoutent à
  côté des anciens, jamais à leur place.
- **L'application stricte reçoit la réponse d'aujourd'hui**, reconnue
  par son `User-Agent`, puisqu'elle refuse tout ajout.
- **Les anciens champs restent tant qu'une version les lit** : `members`
  entier coexiste avec `members_page`.

## 1. La solution

@@P:en/c64/ex3/encode.go|// Encode writes@@

@@P:en/c64/ex3/encode.go|// answer is the answer@@

```text
--- PASS: TestEveryInstalledApplicationKeepsItsContract (0.00s)
--- PASS: TestTheOthersGetTheNewFields (0.01s)
--- PASS: TestTheLastPageHasNoNext (0.00s)
ok      example/contract64/ex3  1.025s
```

La structure `answer` est **embarquée** dans la réponse étendue : Go
écrit ses champs au même niveau que les nouveaux. L'ancienne réponse et
la nouvelle partagent ainsi une seule définition de l'existant, qu'on ne
peut pas modifier par mégarde d'un côté seulement.

## 2. Ce que reçoit l'application stricte, et combien de temps

Elle reçoit **la réponse d'aujourd'hui, octet pour octet**, et le
serveur doit continuer à la produire tant que cette application est
installée. C'est un coût : une branche dans l'encodeur, et un test de
plus, pour chaque évolution. Deux façons d'en sortir :

- publier une version stricte qui tolère l'inconnu, puis mesurer
  (`User-Agent`) le nombre de téléphones qui gardent l'ancienne, et
  annoncer une date d'arrêt (leçon 6.5) ;
- si l'application est celle d'un partenaire, lui montrer son contrat
  (`Closed: true`) et lui demander de l'ouvrir.

## 3. Le prix de `members` en double

La réponse contient désormais tous les membres **et** la première page.
Pour une tontine de 120 membres, 170 membres sont écrits dans chaque
réponse (les 120, puis les 50 de la première page), à toutes les
applications. Le jour où plus aucune version
installée ne lit `members`, on le retire ; tant qu'une version le lit,
c'est le prix de ne pas la casser.

## Ce qu'il faut retenir

- Évoluer, c'est ajouter à côté, jamais remplacer.
- Un client qui refuse l'inconnu fige la réponse qu'on lui envoie.
- L'ancien champ se retire quand plus personne ne le lit, et pas avant.
