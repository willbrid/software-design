# Exercices 6.1 — Des méthodes et des statuts qui disent quoi faire

Cinq exercices, du plus simple au plus ouvert. Traite-les **dans l'ordre** et
écris tes réponses dans `mes-reponses/` avant d'ouvrir les corrections.

Les exercices s'appuient sur les paquets de la
[leçon 6.1](../cours/6.1-methodes-et-statuts.md) (`tontine`, `httpapi`,
`client`), recopiés tels quels dans le module des exercices. Ils n'ont
besoin que de la bibliothèque standard. Tout le code ci-dessous compile
et passe `go vet` ; les tontines, les membres et l'incident sont
**fictifs**.

---

## Exercice 1 — Compréhension : quel statut, et que fait le client ?

*Niveau 1. Aucune ligne de code à écrire.*

### 1.a — Huit situations

Pour chaque situation, donne le statut de la réponse, et dis si le
client de la leçon la renvoie.

1. Une cotisation est enregistrée.
2. Le membre paie 5 000 FCFA dans une tontine à 10 000 FCFA.
3. Le membre paie un tour qu'il a déjà payé.
4. La base ne répond pas.
5. Le corps de la requête est coupé au milieu du JSON.
6. L'application envoie `DELETE` sur `/tontines/1/contributions`.
7. Le code fait un `nil` déréférencé dans le gestionnaire.
8. Un membre demande la cotisation 42 d'une tontine dont il n'est pas
   membre, et l'existence même de cette cotisation ne le regarde pas.

### 1.b — Trois pourquoi

1. Pourquoi l'API « always 200 » perd-elle des cotisations, alors
   qu'elle répond à chaque requête ?
2. Pourquoi l'API « always 500 » envoie-t-elle 2 019 requêtes pour
   1 000 cotisations, alors qu'aucune n'est perdue ?
3. Pourquoi le texte d'une erreur inattendue ne part-il pas dans la
   réponse ?

### 1.c — Lire la supervision

Une équipe montre ce tableau de bord, sur une heure :

```text
2xx  9 412    4xx  0    5xx  0
```

Et l'application des membres reçoit, la même heure, 380 avis « ma
cotisation n'apparaît pas ». Donne deux explications possibles, et la
question à poser à l'équipe pour trancher.

---

## Exercice 2 — Code : les erreurs des prêts

*Niveau 2. Écrire la traduction des erreurs ; les tests sont fournis.*

Les prêts d'une tontine ont leurs propres erreurs, et une erreur de
validation qui nomme le champ fautif :

```go
@@P:en/e61/ex2/loans.go|// The errors of the loans.@@
```

```go
@@P:en/e61/ex2/loans.go|// FieldError says@@
```

Écris `ProblemFor` :

```go
@@P:en/e61/ex2/loans.go|// ProblemFor returns@@
```

Les erreurs peuvent arriver **enveloppées** par les couches qu'elles
ont traversées (`fmt.Errorf("grant loan 7: %w", err)`). Les tests de
`ex2/loans_test.go` :

```text
--- FAIL: TestEachErrorHasItsStatusAndType (0.00s)
    loans_test.go:26: no such loan: 500 about:blank, want 404 https://api.tontine.example/problems/no-loan
    loans_test.go:29: no such loan: no detail
    loans_test.go:26: grant loan 7: no such loan: 500 about:blank, want 404 https://api.tontine.example/problems/no-loan
[...]
--- FAIL: TestTheFieldIsNamed (0.00s)
    loans_test.go:38: detail "" does not name the field
FAIL
FAIL    example/api61/ex2       0.004s
FAIL
```

Questions :

1. Quel statut pour `ErrLimitReached`, et pourquoi pas le même que
   `ErrTooHigh` ?
2. Pourquoi `errors.As` pour `FieldError`, et `errors.Is` pour les
   autres ?

---

## Exercice 3 — Refactoring : l'API des actions

*Niveau 3. Réécrire une API ; les tests sont fournis.*

L'application d'une tontine utilise aujourd'hui cette API : chaque
action est un `GET` sur `/api`, et chaque réponse est `200`.

```go
@@P:en/e61/ex3/api.go|// Old is the API@@
```

Depuis que les trésorières partagent des liens dans WhatsApp, des
membres quittent leur tontine sans l'avoir demandé.

Écris `New` dans `ex3/api.go` :

- `POST /contributions` paie (corps JSON `member`, `round`,
  `amount_fcfa`) : `201` avec `Location`, ou un problème RFC 9457 ;
- `GET /members/{member}/contributions` lit : `200`, ou `404` ;
- `DELETE /members/{member}` fait quitter : `204`, ou `404` ;
- l'ancienne `/api` continue de servir `action=list` **exactement comme
  avant** (les applications installées le lisent), et ne change plus
  rien : les autres actions répondent `405` avec un problème.

```text
--- FAIL: TestPayIsAPost (0.00s)
    api_test.go:32: 404, Location ""; want 201 and /contributions/1
--- FAIL: TestContributionsAreRead (0.00s)
    api_test.go:60: 404 404 page not found
        , want 200 and one contribution
--- FAIL: TestLeavingIsADelete (0.00s)
    api_test.go:71: DELETE: 404, want 204
    api_test.go:77: members [awa bintou]
--- FAIL: TestOpeningLinksChangesNothing (0.00s)
    api_test.go:94: GETs removed members: [bintou]
    api_test.go:100: old leave: 200, want 405 with a problem
FAIL
FAIL    example/api61/ex3       0.003s
FAIL
```

Question : pourquoi ne pas simplement supprimer `/api` ?

---

## Exercice 4 — Design : l'API de l'application

*Niveau 4. Aucune ligne de code : un tableau, et des choix justifiés.*

L'application des tontines a ces cas d'utilisation (niveau 4) :

1. un membre consulte les tontines dont il fait partie ;
2. un membre paie sa cotisation d'un tour ;
3. une trésorière ouvre un nouveau tour ;
4. une trésorière clôt un tour et désigne le bénéficiaire ;
5. un membre demande un prêt ;
6. une trésorière accorde ou refuse un prêt ;
7. une trésorière retire un membre ;
8. un membre consulte l'historique de ses cotisations, page par page.

Pour chacun, donne : la méthode et le chemin ; le statut en cas de
succès ; les erreurs possibles (statut et `type`) ; ce que le client
fait de chacune. Dis ensuite ce que la supervision doit compter, et ce
qui doit réveiller l'astreinte.

---

## Exercice 5 — Incident : le vendredi des 500

*Niveau 7. Un incident à expliquer avec le journal, puis à corriger.*

Le vendredi 6 novembre 2026 à 14 h, l'équipe déploie une couche de
service qui journalise chaque cotisation :

```go
@@P:en/e61/ex5/service.go|// Service is the layer@@
```

Les tests de `httpapi` passent ; personne ne voit rien jusqu'à 14 h 20,
quand l'alerte « plus de 5 % de 5xx » se déclenche. L'astreinte
redémarre les instances, sans effet ; l'équipe annule le déploiement le
soir.

`ex5/day.go` rejoue la journée : 24 000 cotisations de 08 h à 20 h,
envoyées par le client de la leçon, à l'API d'avant 14 h, puis à celle
d'après. `Day()` rend le journal d'accès, une ligne par requête reçue :

```go
@@P:en/e61/ex5/day.go|// Line is one line@@
```

1. **Analyse.** Écris `Analyze` dans `ex5/analyze.go`, qui remplit ce
   rapport :

```go
@@P:en/e61/ex5/analyze.go|// Report is what@@
```

   Le test de `ex5/analyze_test.go` porte sur un petit journal écrit à la
   main :

```text
--- FAIL: TestAnalyze (0.00s)
    analyze_test.go:34: 0 requests, 0 lines; want 27 and 32
    analyze_test.go:37: 5xx by hour map[], total map[]
    analyze_test.go:40: first bad hour 0, want 9 (at 08:00, 1 line of 22 is below 5 %)
    analyze_test.go:43: refusals as 500 0, members 0, extra 0; want 1, 1, 3
FAIL
FAIL    example/api61/ex5       0.003s
FAIL
```

2. **Les chiffres.** Lance `Analyze(Day())` : à quelle heure le taux de
   5xx dépasse-t-il 5 % ? Combien de requêtes de refus ont été répondues
   `500`, pour combien de membres, et combien de requêtes en plus ont-elles
   coûté ?
3. **La cause.** Trouve la ligne qui a tout déclenché, et explique
   pourquoi les tests de `httpapi` n'ont rien vu.
4. **La correction**, et **le test** qui aurait arrêté le déploiement.
5. **Le compte rendu** : quoi, cause, détection, correction,
   prévention, en cinq points.
