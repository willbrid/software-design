# Correction 6.3 — Exercice 2 : une clé par membre

> Rappel de l'énoncé : rendre les cotisations idempotentes avec une clé
> unique pour un membre.

La solution est dans `ex2` du module de correction, verte sous
`go vet ./...` et `go test -race -count=1 ./...`.

## En bref

- **La clé primaire est `(member, key)`** : deux membres peuvent tirer la
  même clé sans se gêner.
- **Le reste est le serveur de la leçon** : la clé prise d'abord, la
  cotisation, la réponse rangée, dans une transaction.
- **Le membre vient de l'authentification**, jamais du corps.

## 1. La solution

@@P:en/c63/ex2/contribution.go|// Handler serves@@

```text
--- PASS: TestTheSameMemberAndKeyRecordOnce (0.07s)
--- PASS: TestTwoMembersMayDrawTheSameKey (0.07s)
--- PASS: TestTenAtOnceRecordOnce (0.12s)
--- PASS: TestAKeyIsForOneBodyAndRequired (0.06s)
ok      example/idem63/ex2      1.342s
```

## 2. Pourquoi le membre vient de l'authentification

Si le membre venait du corps, un client pourrait envoyer la clé d'un
autre membre avec le nom de cet autre membre, et recevoir **sa**
réponse gardée : l'identifiant, le montant, et ce que contient la
réponse. La portée de la clé n'a de sens que si celui qui la présente ne
peut pas choisir à qui elle appartient. En production, `X-Member` est
remplacé par l'identité tirée du jeton d'authentification (niveau 10).

## 3. Ce qui change pour la purge

La purge garde son critère, `created_at`, et la clé primaire composée ne
la ralentit pas. Pour un membre très actif, un index sur
`(created_at)` permet de purger par tranche sans lire toute la table
(leçon 5.5).

## Ce qu'il faut retenir

- Une clé est unique pour celui qui la tire : `(client, key)`.
- Le client de la clé est celui qui est authentifié.
- Le mécanisme ne change pas : prendre, faire, ranger, dans une
  transaction.
