# Correction 6.4 — Exercice 2 : le lecteur tolérant d'un prêt

> Rappel de l'énoncé : réécrire la lecture d'un prêt pour qu'elle
> affiche « — » ou « Autre » au lieu d'échouer ou de mentir.

La solution est dans `ex2` du module de correction, verte sous
`go vet ./...` et `go test -race -count=1 ./...`.

## En bref

- **Des pointeurs vers `json.Number`** : un champ absent, `null`, ou d'un
  autre type se lit comme « inconnu », sans faire échouer le reste.
- **Une valeur de repli par champ** : « — » pour un montant, « Autre »
  pour un statut.
- **Un calcul n'est fait que si toutes ses données sont connues** : le
  reste à payer a besoin du montant **et** du remboursé.

## 1. La solution

```go
@@P:en/c64/ex2/loan.go|// ReadLoan reads@@
```

```go
@@P:en/c64/ex2/loan.go|// number reads@@
```

```text
--- PASS: TestReadLoan (0.00s)
--- PASS: TestNotJSONIsAnError (0.00s)
ok      example/contract64/ex2  1.011s
```

## 2. Pourquoi « — » pour un `null`

Le lecteur ne sait pas ce que veut dire `null` : « rien remboursé », ou
« le serveur ne sait pas encore » (le paiement Mobile Money est en
attente de confirmation). Afficher le montant entier comme reste à
payer, c'est **choisir** la première lecture. Si c'est la seconde, le
membre croit devoir 150 000 FCFA alors qu'il en a remboursé 50 000, et
paie deux fois.

« — » est honnête : l'écran dit qu'il ne sait pas. C'est le contrat qui
doit dire ce que `null` veut dire ; tant qu'il ne le dit pas, le lecteur
ne devine pas.

## 3. Ce qui reste une erreur

Un corps qui n'est pas du JSON (la page HTML d'un proxy en panne) reste
une erreur : `TestNotJSONIsAnError`. Le lecteur tolérant tolère une
réponse **qui a changé**, pas une réponse **qui n'en est pas une**.

## Ce qu'il faut retenir

- Lire chaque champ pour lui-même, avec un pointeur pour « absent ».
- Un calcul a besoin de toutes ses données, sinon « — ».
- Le lecteur ne devine pas le sens d'un `null` : le contrat le dit.
