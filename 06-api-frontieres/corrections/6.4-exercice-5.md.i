# Correction 6.4 — Exercice 5 : le statut `late`

> Rappel de l'énoncé : une valeur nouvelle d'un statut, des versions
> installées qui échouent dessus ; mesurer, expliquer, corriger côté
> serveur.

L'audit, la correction et leurs tests sont dans `ex5` du module de
correction, verts sous `go vet ./...` et `go test -race -count=1 ./...`.

## En bref

- **2 355 écrans de prêts en erreur, pour 500 membres** dans la
  semaine ; **190 le sont encore le dimanche**, cinq jours après la
  sortie de la version 3.4.
- **Ajouter une valeur était une rupture** pour les versions 3.1 à 3.3,
  qui n'avaient pas de repli. La politique « listes ouvertes » n'avait
  jamais été écrite.
- **La correction** : le serveur envoie à chaque version ce qu'elle sait
  lire. Avant 3.4, un prêt en retard part comme `open`, avec un champ
  `late` qu'elles ignorent.

## 1. L'audit

```go
@@P:en/c64/ex5/audit.go|// Audit reads@@
```

## 2. Les chiffres

`cmd/latewk` rejoue la semaine telle qu'elle a été déployée, puis avec
la correction :

```text
as deployed       25263 sessions, 2355 failed map[3.1:788 3.2:704 3.3:863], 500 members, 190 still failing on Sunday, first Mon 2 Nov 07:03
for each version  25263 sessions, 0 failed map[], 0 members, 0 still failing on Sunday
```

- **2 355 écrans** ont échoué sur 25 263, répartis sur les trois
  anciennes versions ;
- **500 membres**, ceux qui ont un prêt en retard et une ancienne
  version : pour eux, l'écran des prêts est **inutilisable**, jusqu'à ce
  qu'ils mettent à jour ;
- **190 membres** échouent encore à leur dernière ouverture de la
  semaine. Une mise à jour prend des jours, parfois des semaines : la
  sortie de la 3.4 ne répare pas les téléphones qui ne la reçoivent pas.

## 3. La cause

Pour le serveur, ajouter une valeur à `status` était un ajout, donc sans
danger. Pour les versions 3.1 à 3.3, qui échouent sur une valeur
inconnue, c'était une rupture. Les deux points de vue sont justes : il
manquait **la règle** qui dit lequel s'applique. Avec la politique de
l'exercice 4 (« toute liste est ouverte, un client affiche un repli »),
les versions 3.1 à 3.3 auraient été fautives dès leur sortie, et le
défaut aurait été trouvé en revue ; sans elle, le serveur a cassé des
clients qui respectaient la seule règle qu'ils connaissaient.

Le contrat des versions 3.1 à 3.3, s'il avait été écrit, aurait dit
`Values: ["open", "repaid"]`, et le test de contrat aurait échoué
**avant** le déploiement du lundi.

## 4. La correction

```go
@@P:en/c64/ex5/loans.go|// AnswerFor writes@@
```

```go
@@P:en/c64/ex5/audit_test.go|func TestEveryVersionReadsTheAnswerMadeForIt@@
```

```text
--- PASS: TestAudit (0.00s)
--- PASS: TestTheWeekAsDeployedFails (1.04s)
--- PASS: TestEveryVersionReadsTheAnswerMadeForIt (1.08s)
ok      example/contract64/ex5  3.143s
```

Les anciennes versions voient « En cours » au lieu de « En retard » :
c'est une information en moins, mais l'écran fonctionne, et le membre
voit son prêt. La version 3.4 voit `late`. Le champ `late: true` ne sert
à aucune version aujourd'hui ; il permet à une future 3.3.1 corrective,
plus petite qu'une 3.4, de l'afficher.

Cette branche dans le serveur a un coût : elle restera tant qu'une
version 3.3 ou plus ancienne appellera l'API. La leçon 6.5 montre comment
mesurer ce moment, et l'annoncer.

## 5. Le compte rendu

1. **Quoi** : du lundi 2 au dimanche 8 novembre 2026, l'écran des prêts
   a échoué 2 355 fois pour 500 membres ayant un prêt en retard et une
   version 3.1 à 3.3 de l'application ; 190 étaient encore bloqués le
   dimanche.
2. **Cause** : le serveur a ajouté la valeur `late` au statut d'un prêt ;
   ces versions échouaient sur toute valeur inconnue, et aucune règle ne
   disait qu'un statut pouvait gagner des valeurs.
3. **Détection** : par les avis des membres, puis par les erreurs
   remontées par l'application. Aucun test du serveur ne connaissait ce
   que les versions installées acceptaient.
4. **Correction** : le serveur adapte la réponse à la version déclarée
   dans `User-Agent` : `late` devient `open` avant 3.4.
5. **Prévention** : la politique de compatibilité publiée (listes
   ouvertes, repli obligatoire) ; un contrat par version de
   l'application, vérifié par le serveur avant chaque déploiement ; un
   suivi du nombre de sessions par version, pour savoir quand retirer la
   branche de compatibilité.

## Ce qu'il faut retenir

- Ajouter une valeur à une liste fermée est une rupture pour qui n'a pas
  de repli.
- Le serveur peut servir à chaque version ce qu'elle sait lire, le temps
  qu'elle disparaisse.
- La règle « listes ouvertes » s'écrit avant la première version, pas
  après le premier incident.
