# Correction 6.1 — Exercice 3 : l'API des actions

> Rappel de l'énoncé : réécrire une API dont chaque action est un `GET`
> sur `/api`, sans casser les applications installées.

La solution est dans `ex3` du module de correction, verte sous
`go vet ./...` et `go test -race -count=1 ./...`.

## En bref

- **Une ressource par chose, une méthode par action** : `POST` paie,
  `GET` lit, `DELETE` fait quitter.
- **L'ancienne route reste pour la lecture**, à l'identique, et refuse
  tout ce qui change quelque chose.
- **Un lien ouvert ne fait plus quitter personne.**

## 1. La solution

```go
@@P:en/c61/ex3/api.go|// New serves@@
```

```text
--- PASS: TestPayIsAPost (0.00s)
--- PASS: TestContributionsAreRead (0.00s)
--- PASS: TestLeavingIsADelete (0.00s)
--- PASS: TestOpeningLinksChangesNothing (0.00s)
--- PASS: TestInstalledAppsStillRead (0.00s)
ok      example/api61/ex3       1.014s
```

## 2. Pourquoi ne pas supprimer `/api`

Les applications déjà installées sur les téléphones appellent `/api`.
Une partie des membres ne mettra pas l'application à jour avant des
semaines. Supprimer la route les priverait de leur historique
(`action=list`) du jour au lendemain. La solution garde la lecture,
**octet pour octet** (le test `TestInstalledAppsStillRead` compare les
deux réponses), et coupe les écritures par `GET`, qui sont le danger.

Les anciennes applications qui paient par `GET` reçoivent un `405`.
C'est une rupture assumée : elles affichent une erreur au lieu de
payer, et le membre doit mettre à jour. La leçon 6.5 montre comment
annoncer et mesurer une telle rupture avant de la faire.

## 3. Ce qui reste à faire

- Le `type` des problèmes de l'ancienne route (`use-post`) dit
  exactement quoi faire : une application récente peut l'afficher.
- `DELETE /members/{member}` doit être réservé à une trésorière : c'est
  une question d'autorisation, que le niveau 10 traite. En attendant, un
  `DELETE` n'est envoyé par aucun robot.

## Ce qu'il faut retenir

- Le chemin nomme une chose ; la méthode dit ce qu'on en fait.
- On garde l'ancienne route tant qu'elle sert, mais seulement pour ce
  qui est sûr.
- Un test compare l'ancienne et la nouvelle réponse quand on promet de
  ne rien changer.
