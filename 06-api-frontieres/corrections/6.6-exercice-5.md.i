# Correction 6.6 — Exercice 5 : le BFF qui attendait

> Rappel de l'énoncé : le service des soldes ralentit ; le BFF attend
> chaque réponse ; mesurer, corriger avec un budget, rédiger le compte
> rendu.

La mesure, la correction et leurs tests sont dans `ex5` du module de
correction, verts sous `go vet ./...` et `go test -race -count=1 ./...`.

## En bref

- **Sans budget, l'accueil prend 1,6 s en médiane**, et 125 écrans sur
  200 dépassent la seconde, côté serveur, avant même le réseau mobile.
- **Avec un budget de 300 ms**, aucun ne dépasse la seconde, et le 99ᵉ
  centile est à 416 ms. 131 écrans sur 200 arrivent **partiels** : le
  solde affiche « — ».
- **Le membre perd une information secondaire**, et garde un accueil qui
  s'ouvre.

## 1. La mesure

```go
@@P:en/c66/ex5/audit.go|func Summarize@@
```

## 2. La correction

```go
@@P:en/c66/ex5/budget.go|func BudgetBFF@@
```

```go
@@P:en/c66/ex5/budget.go|// build asks@@
```

```text
--- PASS: TestSummarize (0.00s)
--- PASS: TestTheBudgetIsKept (2.01s)
--- PASS: TestAFastAPIGivesTheWholeScreen (0.02s)
ok      example/screen66/ex5    3.053s
```

Un seul contexte borne **tous** les appels du BFF : `api.Get` le passe à
la requête, et la requête s'arrête quand il expire. Le BFF n'a pas à
compter le temps de chaque appel.

## 3. Les chiffres

`cmd/evening` rejoue la soirée deux fois :

```text
no budget     200 home screens  p50 1.603s  p95 1.646s  p99 1.666s  over 1 s: 125  failed: 0  partial: 0
budget 300 ms 200 home screens  p50 309ms   p95 402ms   p99 416ms   over 1 s:   0  failed: 0  partial: 131
```

- **Sans budget** : la médiane, 1,6 s, est la durée d'un appel lent
  (1,5 s) plus le reste. Un écran est lent dès qu'**un** de ses trois
  soldes l'est ; avec un appel lent sur quatre, c'est le cas de
  1 − 0,75³ ≈ 58 % des écrans. Les 125 écrans de plus d'une seconde le
  confirment.
- **Avec le budget** : 131 écrans partiels, ce même ordre de grandeur ;
  le 95ᵉ centile à 402 ms dépasse un peu le budget, le temps de répondre
  après l'expiration, sous la charge de 200 écrans à la fois.

## 4. Ce que perd et gagne le membre

Il perd **le montant dû**, sur un écran sur deux pendant l'incident ; il
peut l'obtenir en ouvrant la tontine. Il gagne un accueil qui s'ouvre en
0,3 s au lieu de 1,6 s (plus le réseau), et des écrans qui ne restent
pas bloqués. Côté serveur, le gain est aussi pour le service lent : les
appels abandonnés libèrent leurs connexions au lieu de s'empiler.

L'écran doit savoir afficher « — » pour le solde : c'est le repli de la
leçon 6.4, appliqué à une réponse que le BFF a choisi de rendre
incomplète.

## 5. Le compte rendu

1. **Quoi** : le vendredi 13 novembre 2026 au soir, l'écran d'accueil a
   mis plus d'une seconde à se construire côté serveur pour environ
   60 % des membres, 1,6 s en médiane, plus la latence mobile.
2. **Cause** : la base du service des soldes a ralenti ; le BFF de
   l'accueil attendait chaque solde sans limite de temps, alors que le
   solde n'est pas indispensable à l'écran.
3. **Détection** : par les membres. Le BFF ne mesurait pas sa propre
   durée par centile.
4. **Correction** : un budget de 300 ms pour tout l'écran ; le solde
   devient facultatif, affiché « — » quand il n'arrive pas à temps, avec
   `X-Partial: balance`.
5. **Prévention** : chaque BFF déclare ce qui est indispensable et ce
   qui peut manquer, et son budget ; ses centiles et son taux de
   réponses partielles sont suivis, avec une alerte au-delà de 5 % de
   partiels ; le ralentissement d'une dépendance fait partie des tests
   (`SlowBalance`).

## Ce qu'il faut retenir

- Un appel sans limite de temps transmet la lenteur de chaque
  dépendance à tout l'écran.
- Un budget, un contexte, et la liste de ce qui peut manquer.
- Un écran partiel qui s'ouvre vaut mieux qu'un écran complet qui tourne.
