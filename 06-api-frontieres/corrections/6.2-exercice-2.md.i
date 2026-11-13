# Correction 6.2 — Exercice 2 : la demande de prêt

> Rappel de l'énoncé : transformer une demande de prêt en type sûr,
> toutes les erreurs d'un coup.

La solution est dans `ex2` du module de correction, verte sous
`go vet ./...` et `go test -race -count=1 ./...`.

## En bref

- **Un champ à la fois, dans l'ordre**, chaque erreur ajoutée à la
  liste : la personne corrige tout en une fois.
- **Le texte libre a ses règles** : retirer les espaces des bords,
  compter les caractères et non les octets, refuser les caractères de
  contrôle.
- **Le téléphone réutilise `border.ParsePhone`** : une règle, un endroit.

## 1. La solution

```go
@@P:en/c62/ex2/loan.go|func ParseLoan@@
```

```go
@@P:en/c62/ex2/loan.go|// parseReason returns@@
```

```text
--- PASS: TestARightLoan (0.00s)
--- PASS: TestEveryFieldIsRequired (0.00s)
--- PASS: TestEveryWrongFieldAtOnce (0.00s)
--- PASS: TestBounds (0.00s)
ok      example/border62/ex2    1.018s
```

## 2. Caractères, pas octets

`len` compte les **octets**. `"é"` en fait deux en UTF-8 : 200 « é »
font 400 octets, et `len(reason) <= 200` refuserait un motif de 101
lettres accentuées. Le test `200 letters with accents` le vérifie.
`utf8.RuneCountInString` compte les caractères Unicode (les *runes*).

C'est encore une approximation : un emoji composé (une famille, un
drapeau) compte plusieurs runes pour un seul symbole affiché. Pour une
limite de stockage, les runes suffisent ; pour une limite d'affichage
exacte, il faudrait compter les graphèmes, ce que la bibliothèque
standard ne fait pas.

## 3. Les caractères de contrôle

Un saut de ligne dans un motif casse les exports CSV et les journaux
ligne à ligne ; un `NUL` coupe le texte dans certains programmes en C,
et PostgreSQL refuse `\x00` dans un `text`. `unicode.IsControl` les
attrape tous. `utf8.ValidString` est une seconde ceinture : le
décodeur de la version 2 refuse déjà l'UTF-8 invalide, mais `ParseLoan`
peut être appelé avec une valeur venue d'ailleurs, un import CSV par
exemple.

## Ce qu'il faut retenir

- Toutes les erreurs, dans un ordre stable.
- `utf8.RuneCountInString` pour une longueur de texte, jamais `len`.
- Un texte libre se nettoie et se borne comme un nombre.
