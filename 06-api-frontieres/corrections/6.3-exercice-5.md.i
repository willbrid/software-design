# Correction 6.3 — Exercice 5 : la purge de minuit

> Rappel de l'énoncé : des membres payés deux fois malgré une API
> idempotente ; des téléphones qui renvoient des heures plus tard ; une
> purge des clés de plus de 24 heures chaque nuit.

L'audit, la correction et leurs tests sont dans `ex5` du module de
correction, verts sous `go vet ./...` et `go test -race -count=1 ./...`.

## En bref

- **34 versements en double, 3 225 000 FCFA**, tous dus à des requêtes
  revenues après la purge de leur clé, la plus tardive au bout de 203 h.
- **Garder les clés 7 jours ne suffit pas** : il reste 2 doubles
  versements, de téléphones revenus après plus de 7 jours.
- **La correction** : garder les clés 7 jours, **et** refuser une action
  inconnue envoyée pour la première fois il y a plus de 6 jours. Le
  serveur ne peut plus savoir si elle a été faite : une personne
  vérifie.

## 1. L'audit

```go
@@P:en/c63/ex5/audit.go|// Audit reads@@
```

```text
--- PASS: TestAudit (0.00s)
--- PASS: TestAnOldActionIsRefusedNotPaid (0.00s)
ok      example/idem63/ex5      1.014s
```

## 2. Les chiffres

`cmd/week` rejoue la semaine avec trois réglages : la purge de
l'incident, une purge à 7 jours, et une purge à 7 jours avec le refus des
actions de plus de 6 jours :

```text
keys kept 24h0m0s  refuse after 0s       3000 actions, 3035 payouts, paid twice 34 (3225000 FCFA), back after 24h 67, refused 0, shortest 31h4m0s, longest 203h15m0s
keys kept 168h0m0s refuse after 0s       3000 actions, 3002 payouts, paid twice  2 ( 350000 FCFA), back after 24h 67, refused 0, shortest 182h52m0s, longest 203h15m0s
keys kept 168h0m0s refuse after 144h0m0s 3000 actions, 3000 payouts, paid twice  0 (      0 FCFA), back after 24h 66, refused 2, shortest 0s, longest 0s
```

- **34 membres payés deux fois**, 3 225 000 FCFA de trop ;
- **67 requêtes** sont revenues plus de 24 heures après le premier envoi.
  Les doubles versements commencent à **31 heures** : avec une purge à
  minuit des clés de plus de 24 heures, une clé vit entre 24 et
  48 heures, selon l'heure de la journée où elle a été créée ;
- la plus tardive est revenue au bout de **203 heures**, plus de huit
  jours : un téléphone resté sans réseau, ou éteint, toute la semaine.

## 3. La cause

L'idempotence ne tient **que tant que la clé est gardée**. La purge à
24 heures avait été choisie en pensant au client de la leçon, qui
renvoie en quelques secondes. L'application des trésorières, elle, garde
une file de versements en attente sans limite de durée. Les deux règles
n'avaient jamais été comparées : la durée de vie des clés est une
promesse faite aux clients, et personne ne l'avait écrite dans le
contrat de l'API.

## 4. La correction

Garder plus longtemps réduit le problème sans le supprimer (deuxième
ligne : 2 doubles versements). Il n'existe pas de durée qui couvre
**tous** les téléphones : il faut une règle pour ce qui arrive après.

```go
@@P:en/c63/ex5/server.go|// PayIfFresh is Pay@@
```

L'application envoie, avec la clé, la date de création de l'action.
Une action inconnue de plus de 6 jours (un jour de marge sur les 7 de
rétention) est refusée : `422`, type `too-old`. L'application l'affiche
à la trésorière : « ce versement est trop ancien ; vérifiez la liste des
versements avant de le refaire ».

```go
@@P:en/c63/ex5/audit_test.go|func TestAnOldActionIsRefusedNotPaid@@
```

Troisième ligne de la mesure : **aucun double versement**, 2 refus à
vérifier à la main. Les refusées ne sont plus renvoyées, d'où 66
requêtes revenues après 24 heures au lieu de 67.

La date de création vient du téléphone, dont l'horloge peut mentir. Un
téléphone qui retarde ferait passer une vieille action pour récente.
Deux défenses : le serveur compare aussi la date à celle de la session
de l'application, et la contrainte métier (un versement par tour, leçon
5.1) reste le dernier garde-fou.

## 5. Le compte rendu

1. **Quoi** : du 2 au 8 novembre 2026, 34 versements ont été faits deux
   fois, pour 3 225 000 FCFA.
2. **Cause** : l'application renvoie les versements en attente quand le
   téléphone retrouve du réseau, parfois après plusieurs jours ; le
   serveur purgeait les clés d'idempotence après 24 heures, et traitait
   ces renvois comme de nouvelles actions.
3. **Détection** : par les trésorières, une semaine plus tard. Rien ne
   comptait les requêtes arrivées longtemps après leur création.
4. **Correction** : clés gardées 7 jours ; refus (`422 too-old`) d'une
   action inconnue de plus de 6 jours, que la trésorière vérifie ; les
   34 doubles versements sont repris auprès des membres, avec leur
   accord.
5. **Prévention** : la durée de vie des clés est écrite dans le contrat
   de l'API ; l'application ne renvoie pas une action plus vieille que
   cette durée sans demander ; une contrainte « un versement par tour »
   en base ; une mesure de l'âge des requêtes à leur arrivée, avec une
   alerte au-delà de 3 jours.

## Ce qu'il faut retenir

- Une clé protège tant qu'elle est gardée : sa durée de vie fait partie
  du contrat.
- Aucune durée ne couvre tous les clients ; au-delà, on refuse et une
  personne vérifie.
- La contrainte métier protège même quand la clé a disparu.
