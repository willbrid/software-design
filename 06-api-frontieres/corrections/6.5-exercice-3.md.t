# Correction 6.5 — Exercice 3 : l'échéancier en double

> Rappel de l'énoncé : v1 a son propre calcul d'échéancier ; le réécrire
> en traduction de v2, sans changer sa forme.

La solution est dans `ex3` du module de correction, verte sous
`go vet ./...` et `go test -race -count=1 ./...`.

## En bref

- **Un seul calcul, `Plan`**, mis en forme v2 par `toV2`, puis traduit
  en v1 par `ToV1`.
- **La forme de v1 ne change pas** : `due_date` en `02/01/2006`,
  `amount_fcfa`.
- **Ses chiffres changent**, pour 75 prêts sur 200 : ce sont les bons,
  et il faut le dire aux membres.

## 1. La solution

@@P:en/c65/ex3/schedule.go|// ToV1 writes one@@

@@P:en/c65/ex3/schedule.go|// toV2 writes@@

@@P:en/c65/ex3/schedule.go|// V1 serves@@

```text
--- PASS: TestV1IsAFormOfV2 (0.12s)
ok      example/version65/ex3   1.137s
```

## 2. Les membres qui voyaient 283 733 FCFA

L'ancien calcul divisait le total sans arrondir à 5 FCFA, et ne
corrigeait pas la dernière échéance : la somme des échéances différait
du total dû de quelques francs, et chaque échéance demandait une somme
qu'on ne peut pas payer en pièces. Après la correction, l'ancienne
application affiche 283 730 FCFA, comme la nouvelle.

Ce qu'on dit aux membres, dans les notes de version et par la
trésorière : « les échéances des prêts sont désormais arrondies à 5 FCFA,
et la dernière ajuste le total ; les montants affichés peuvent changer de
quelques francs, sans changer ce que vous devez au total ». Ce message
est dû même si le changement est une correction : un écran qui change
sans explication fait douter de tout le reste.

## Ce qu'il faut retenir

- Une ancienne version se réécrit en traduction : sa forme reste, son
  calcul disparaît.
- Un test qui compare les deux versions sur des données variées trouve
  les écarts qu'aucun exemple choisi ne montre.
- Corriger une version, c'est changer ce que des membres voient : on le
  leur dit.
