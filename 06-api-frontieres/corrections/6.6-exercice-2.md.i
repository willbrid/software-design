# Correction 6.6 — Exercice 2 : changer un seul champ

> Rappel de l'énoncé : un `PATCH /rules` conditionnel, qui ne change que
> les champs envoyés.

La solution est dans `ex2` du module de correction, verte sous
`go vet ./...` et `go test -race -count=1 ./...`.

## En bref

- **Des pointeurs disent quels champs le corps contient** : `nil`, le
  champ ne change pas.
- **La version se vérifie deux fois** : à la lecture (pour répondre `412`
  tôt) et à l'écriture, par `Store.Put`, qui seul est sûr.
- **Un champ inconnu est refusé** : une faute de frappe dans un `PATCH`
  serait un changement silencieusement ignoré (leçon 6.2).

## 1. La solution

```go
@@P:en/c66/ex2/patch.go|func Handler@@
```

```go
@@P:en/c66/ex2/patch.go|// apply copies@@
```

```text
--- PASS: TestAPatchChangesOnlyItsFields (0.00s)
--- PASS: TestAPatchIsConditional (0.00s)
ok      example/screen66/ex2    1.022s
```

Entre `s.Get()` et `s.Put()`, une autre requête peut écrire. Le premier
contrôle (`v != read`) ne suffit donc pas ; c'est `Put(current, read)`,
qui compare la version sous le verrou du stockage, qui garantit que rien
ne s'est glissé entre les deux.

## 2. `If-Match` avec un `PATCH`

Pour deux changements qui ne se touchent pas (la part, la pénalité), un
`PATCH` sans condition **suffirait** : chacun ne réécrit que son champ.
`If-Match` y fait refuser l'un des deux pour rien, et l'écran doit
relire.

Mais `If-Match` reste utile dès que le changement dépend de ce qu'on a
lu : « déplacer Bintou après Awa dans l'ordre de passage » se fait sur la
liste lue ; si une autre trésorière a ajouté Chantal entre-temps, la
liste envoyée l'efface. Deux règles pratiques :

- `PATCH` sans condition pour les champs indépendants, qui se remplacent
  en entier par une valeur choisie (la part, le jour) ;
- `If-Match` pour ce qui se calcule à partir de la valeur lue (une liste
  réordonnée, un compteur).

Le serveur de l'exercice l'exige partout : c'est le choix le plus sûr,
au prix de quelques `412`.

## Ce qu'il faut retenir

- Un `PATCH` envoie ce qui change ; des pointeurs le disent.
- La seule vérification qui compte est celle faite au moment d'écrire.
- Une valeur calculée à partir de la valeur lue a besoin de `If-Match`.
