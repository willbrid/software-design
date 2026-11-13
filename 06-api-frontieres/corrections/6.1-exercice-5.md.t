# Correction 6.1 — Exercice 5 : le vendredi des 500

> Rappel de l'énoncé : un déploiement à 14 h, une alerte « plus de 5 %
> de 5xx » ; analyser le journal, trouver la cause, corriger, et
> rédiger le compte rendu.

L'analyse, la correction et le test sont dans `ex5` du module de
correction, verts sous `go vet ./...` et `go test -race -count=1 ./...`.

## En bref

- **La cause** : `%v` au lieu de `%w` dans la nouvelle couche. Le texte
  de l'erreur reste, son identité disparaît : `errors.Is` ne la trouve
  plus, et chaque refus devient un `500`.
- **2 771 refus répondus `500`, pour 943 membres**, et 8 313 requêtes en
  plus : le client a renvoyé chacun de ces refus trois fois.
- **Le test qui manquait** traverse la pile telle qu'elle est déployée,
  et pas seulement la traduction.

## 1. L'analyse

@@P:en/c61/ex5/analyze.go|// Analyze reads@@

@@P:en/c61/ex5/analyze.go|// isRefusal reports@@

Une fois l'identité perdue, il ne reste que le **texte** pour
reconnaître un refus : `isRefusal` compare la fin du message aux textes
des erreurs du stockage. C'est fragile, et c'est précisément pour cela
que le code de production ne doit jamais en dépendre ; pour un audit
d'une journée, c'est suffisant.

## 2. Les chiffres

```text
24000 requests, 33209 lines
08:00   2061 lines    61 5xx    3.0 %
09:00   2088 lines    88 5xx    4.2 %
10:00   2053 lines    53 5xx    2.6 %
11:00   2061 lines    61 5xx    3.0 %
12:00   2061 lines    61 5xx    3.0 %
13:00   2060 lines    60 5xx    2.9 %
14:00   3429 lines  1889 5xx   55.1 %
15:00   3541 lines  2040 5xx   57.6 %
16:00   3453 lines  1921 5xx   55.6 %
17:00   3423 lines  1886 5xx   55.1 %
18:00   3430 lines  1892 5xx   55.2 %
19:00   3549 lines  2049 5xx   57.7 %
first hour above 5 % of 5xx: 14:00
refusals answered 500: 2771 requests, 943 members, 8313 extra lines
```

- Avant 14 h, entre 2,6 et 4,2 % de `5xx` : ce sont les vraies pannes du
  stockage (3 % des appels), répondues `503`.
- **À 14 h, 55 %** : tous les refus deviennent des `500`. Le seuil de
  5 % est franchi dans l'heure du déploiement.
- Le nombre de lignes par heure passe d'environ 2 060 à 3 450 : chaque
  refus est envoyé quatre fois au lieu d'une. **8 313 requêtes en plus**
  pour 2 771 refus, soit exactement 3 par refus.
- **943 membres** ont reçu « erreur interne, réessayez » au lieu de
  « vous avez déjà payé ce tour » ou « le montant n'est pas la part ».

## 3. La cause

```go
        return c, fmt.Errorf("contribute %s round %d: %v", member, round, err)
```

`%v` écrit le **texte** de `err` dans une nouvelle erreur, sans la
garder. `errors.Is(err, tontine.ErrAlreadyPaid)` parcourt la chaîne des
erreurs enveloppées : avec `%v`, il n'y a pas de chaîne. La traduction
tombe dans son dernier cas, `500`. Les pannes passagères aussi : sans
`ErrUnavailable` reconnu, elles perdent leur `503` et leur
`Retry-After`.

Les tests de `httpapi` n'ont rien vu, parce qu'ils appellent le
gestionnaire **avec le stockage directement**. La couche ajoutée à 14 h
n'était dans aucun test : le code testé n'était pas le code déployé.

## 4. La correction et le test

@@P:en/c61/ex5/service.go|// Service is the layer@@

Le test monte la pile complète, gestionnaire, service, stockage, comme
en production :

@@P:en/c61/ex5/stack_test.go|func TestTheDeployedStackKeepsTheStatuses@@

Avec la couche de 14 h à la place de `Service`, il échoue :

```text
--- FAIL: TestTheDeployedStackKeepsTheStatuses (0.00s)
    stack_test.go:19: unexpected: contribute awa round 1: already paid for this round
    stack_test.go:40: {"member":"awa","round":1,"amount_fcfa":5000}: 500, want 409
    stack_test.go:19: unexpected: contribute awa round 2: amount is not the share of the tontine
    stack_test.go:40: {"member":"awa","round":2,"amount_fcfa":2500}: 500, want 422
    stack_test.go:19: unexpected: contribute bob round 2: not a member of this tontine
    stack_test.go:40: {"member":"bob","round":2,"amount_fcfa":5000}: 500, want 422
FAIL
FAIL    example/api61/ex5       0.003s
FAIL
```

Avec `%w`, il passe :

```text
--- PASS: TestAnalyze (0.00s)
--- PASS: TestTheDeployedStackKeepsTheStatuses (0.00s)
--- PASS: TestTheDayOfTheIncident (3.41s)
ok      example/api61/ex5       4.434s
```

`go vet` ne signale pas ce `%v` : écrire `%v` pour une erreur est
légal, et parfois voulu (quand on **veut** cacher l'erreur d'une
dépendance à l'appelant). Seul un test qui traverse la couche le voit.

## 5. Le compte rendu

1. **Quoi** : le vendredi 6 novembre 2026, de 14 h à 20 h, 2 771
   cotisations refusées (tour déjà payé, mauvais montant, mauvaise
   tontine) ont été répondues « erreur interne » à 943 membres, et
   renvoyées trois fois chacune par l'application : 8 313 requêtes en
   plus. Aucune cotisation n'a été perdue ni enregistrée deux fois.
2. **Cause** : la couche de service déployée à 14 h enveloppait les
   erreurs avec `%v`, qui perd leur identité ; la traduction en statuts
   ne les reconnaissait plus.
3. **Détection** : l'alerte sur le taux de `5xx`, 20 minutes après le
   déploiement. Le redémarrage ne pouvait rien : le défaut était dans le
   code.
4. **Correction** : `%w` dans la couche de service ; le déploiement de
   correction remplace l'annulation du soir.
5. **Prévention** : un test de bout en bout de la pile déployée, pour
   chaque refus ; une règle de revue (« une erreur enveloppée utilise
   `%w`, sauf décision écrite ») ; un tableau de bord des `5xx` par
   texte d'erreur journalisé, pour voir en une minute qu'un refus connu
   est devenu un `500`.

## Ce qu'il faut retenir

- `%w` garde l'erreur, `%v` ne garde que son texte.
- Le test doit traverser les couches qui seront déployées.
- Un refus devenu `500` coûte deux fois : un mauvais message au membre,
  et des requêtes renvoyées pour rien.
