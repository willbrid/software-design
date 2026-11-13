# Correction 6.3 — Exercice 3 : le client qui renvoie trop vite

> Rappel de l'énoncé : une clé par action, pas de renvoi des refus, une
> attente exponentielle avec une part aléatoire, `Retry-After`, et
> l'arrêt avec le contexte.

La solution est dans `ex3` du module de correction, verte sous
`go vet ./...` et `go test -race -count=1 ./...`.

## En bref

- **La clé est tirée avant la boucle**, comme dans le client de la
  leçon.
- **L'attente double**, plafonnée, et le client n'en prend qu'une part
  aléatoire : les clients qui ont échoué ensemble ne reviennent pas
  ensemble.
- **`Retry-After` passe avant** : le serveur sait mieux que le client
  quand revenir.

## 1. La solution

```go
@@P:en/c63/ex3/retry.go|// Send sends with one key@@
```

```text
--- PASS: TestOneKeyForEveryAttempt (0.00s)
--- PASS: TestTheWaitDoublesUpToMaxWithJitter (0.00s)
--- PASS: TestRetryAfterIsObeyed (0.00s)
--- PASS: TestARefusalIsNotSentAgain (0.00s)
--- PASS: TestTheLastAnswerIsReturned (0.00s)
--- PASS: TestItStopsWhenTheContextEnds (0.00s)
ok      example/idem63/ex3      1.015s
```

L'attente `p.Rand() * min(p.Max, p.Base<<attempt)` : avec `Base` à
10 ms et `Max` à 50 ms, les plafonds sont 10, 20, 40, 50, 50 ms, et le
test fixe le hasard à 0,5 pour vérifier 5, 10, 20, 25 ms. Les fonctions
`Rand` et `Sleep` sont injectées : le test ne dort jamais, et il vérifie
les attentes exactes.

## 2. Pourquoi une part aléatoire

Quand le serveur tombe, **tous** les clients échouent au même instant.
Avec une attente exponentielle sans hasard, ils reviennent tous après
10 ms, puis tous après 20 ms : la charge arrive en pics, chaque pic
retombe sur un serveur qui redémarre. Le hasard étale les retours sur
toute la fenêtre. Marc Brooker, sur le blog d'architecture d'AWS, le
mesure en simulation et résume : la solution n'est pas de retirer
l'attente exponentielle, mais d'y ajouter du hasard. La variante écrite
ici est celle qu'il appelle *Full Jitter*.

## 3. Ce qui reste sous-entendu

- **`Retry-After` a lui aussi besoin d'un plafond** : un serveur qui
  répond `Retry-After: 86400` ne doit pas bloquer l'application un jour.
  Le contexte de l'appelant (un délai de deux minutes pour l'écran)
  borne tout.
- **Le nombre d'essais n'est pas la seule borne** : six essais avec une
  attente plafonnée à 50 ms tiennent en moins d'une seconde. Pour un
  versement qui peut attendre, une file d'attente sur le téléphone, qui
  renvoie au retour du réseau, vaut mieux qu'une boucle. C'est elle qui
  cause l'exercice 5.

## Ce qu'il faut retenir

- Une clé par action, tirée avant le premier essai.
- Attente exponentielle, plafonnée, avec du hasard ; `Retry-After` avant
  tout.
- Le temps se borne par le contexte, pas seulement par le nombre
  d'essais.
