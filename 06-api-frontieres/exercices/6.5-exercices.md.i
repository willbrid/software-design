# Exercices 6.5 — Versionner une API

Cinq exercices, du plus simple au plus ouvert. Traite-les **dans l'ordre** et
écris tes réponses dans `mes-reponses/` avant d'ouvrir les corrections.

Les exercices s'appuient sur les paquets de la
[leçon 6.5](../cours/6.5-versionner.md) (`ledger`, `api`), recopiés tels
quels dans le module des exercices. Ils n'ont besoin que de la
bibliothèque standard. Tout le code ci-dessous compile et passe
`go vet` ; les partenaires, les tontines de Lagos et l'incident sont
**fictifs**.

---

## Exercice 1 — Compréhension : une version de plus ?

*Niveau 1. Aucune ligne de code à écrire.*

### 1.a — Six changements

Pour chacun, dis s'il faut une nouvelle version de l'API, ou comment
l'éviter.

1. Ajouter la date du prochain tour au relevé.
2. Les pénalités passent de 500 à 600 FCFA par jour, décision du bureau.
3. `balance_fcfa` doit devenir un montant avec sa devise.
4. Le statut `"closed"` est remplacé par `"finished"`.
5. La liste des membres doit être paginée.
6. L'identifiant d'un membre passe d'un nombre à un texte.

### 1.b — Trois pourquoi

1. Pourquoi la version 1 recopiée demande-t-elle 5 293 500 FCFA de trop,
   alors que personne n'y a touché ?
2. Pourquoi répondre `410` après l'arrêt, et pas `404` ?
3. Pourquoi le partenaire kash n'a-t-il migré qu'après la coupure de la
   semaine 20 ?

### 1.c — Lire le compteur

En semaine 18, le compteur de v1 montre 5 986 appels, dont 4 000 d'un
seul client. Que fais-tu, et à qui écris-tu ?

---

## Exercice 2 — Code : l'arrêt planifié

*Niveau 2. Écrire un middleware de retrait ; les tests sont fournis.*

```go
@@P:en/e65/ex2/sunset.go|// Window is a span@@
```

```go
@@P:en/e65/ex2/sunset.go|// Retirement serves@@
```

```go
@@P:en/e65/ex2/sunset.go|// NewRetirement checks@@
```

Les tests de `ex2/sunset_test.go` :

```text
--- FAIL: TestAWrongPlanIsRefused (0.00s)
    sunset_test.go:46: sunset before deprecation: accepted
    sunset_test.go:46: brownout before: accepted
    sunset_test.go:46: brownout after sunset: accepted
--- FAIL: TestEveryAnswerAnnouncesTheEnd (0.00s)
    sunset_test.go:55: 200 map[]
--- FAIL: TestABrownoutAnswers410UntilItsEnd (0.00s)
    sunset_test.go:77: 2026-09-21 09:59:00 +0000 UTC: no Sunset
    sunset_test.go:74: 2026-09-21 10:00:00 +0000 UTC: 200 "", want 410 with "11:00"
    sunset_test.go:77: 2026-09-21 10:00:00 +0000 UTC: no Sunset
    sunset_test.go:74: 2026-09-21 10:59:00 +0000 UTC: 200 "", want 410 with "11:00"
    sunset_test.go:77: 2026-09-21 10:59:00 +0000 UTC: no Sunset
    sunset_test.go:77: 2026-09-21 11:00:00 +0000 UTC: no Sunset
    sunset_test.go:74: 2026-10-12 13:30:00 +0000 UTC: 200 "", want 410 with "14:00"
    sunset_test.go:77: 2026-10-12 13:30:00 +0000 UTC: no Sunset
    sunset_test.go:74: 2026-11-02 00:00:00 +0000 UTC: 200 "", want 410 with "https://api.tontine.example/docs/migrate-v2"
    sunset_test.go:77: 2026-11-02 00:00:00 +0000 UTC: no Sunset
FAIL
FAIL    example/version65/ex2   0.004s
FAIL
```

Question : pendant une coupure, pourquoi `410` plutôt que `503` ?

---

## Exercice 3 — Refactoring : l'échéancier en double

*Niveau 3. Réécrire v1 ; les tests sont fournis.*

L'échéancier d'un prêt est calculé par `Plan` :

```go
@@P:en/e65/ex3/schedule.go|// Plan returns@@
```

La version 2 l'utilise. La version 1, écrite avant que `Plan` arrondisse
à 5 FCFA et égalise la dernière échéance, a gardé son propre calcul :

```go
@@P:en/e65/ex3/schedule.go|// V1 serves@@
```

Le test `TestV1IsAFormOfV2` demande 200 prêts aux deux versions :

```text
--- FAIL: TestV1IsAFormOfV2 (0.01s)
    schedule_test.go:46: loan 41, installment 1: v1 {Due:25/08/2026 AmountFCFA:283733}, v2 {Due:2026-08-25 Amount:{Amount:283730 Currency:XAF}}
    schedule_test.go:46: loan 112, installment 1: v1 {Due:13/07/2026 AmountFCFA:127842}, v2 {Due:2026-07-13 Amount:{Amount:127840 Currency:XAF}}
    schedule_test.go:46: loan 181, installment 1: v1 {Due:24/02/2026 AmountFCFA:43866}, v2 {Due:2026-02-24 Amount:{Amount:43865 Currency:XAF}}
[...]
FAIL
FAIL    example/version65/ex3   0.012s
FAIL
```

75 prêts sur 200 ont au moins une échéance différente.

Réécris v1 pour qu'il soit une traduction de v2, sans changer sa forme
(`due_date` au format `02/01/2006`, `amount_fcfa`).

Question : que dire aux membres dont l'ancienne application affichait
283 733 FCFA au lieu de 283 730 ?

---

## Exercice 4 — Design : le plan de retrait de v1

*Niveau 4. Aucune ligne de code : un plan d'une page.*

La version 1 du relevé doit s'arrêter. Le compteur montre aujourd'hui :
62 % des appels par l'application 5.x (v2), 30 % par l'application 4.x
(v1), 8 % par trois partenaires sur v1. Écris le plan : les dates, les
seuils qui décident de chaque étape, les messages (à qui, par quel
canal), les coupures, ce que fait l'application 4.x en recevant `410`,
et ce que tu surveilles le jour de l'arrêt.

---

## Exercice 5 — Incident : les nairas en francs CFA

*Niveau 7. Un incident à mesurer, puis à corriger.*

Le lundi 9 novembre 2026, les premières tontines de Lagos ouvrent, en
nairas (NGN). La version 2 du relevé porte la devise. La version 1, que
lit encore l'application 4.x, est servie par la traduction de la
leçon :

```go
@@P:en/e65/ex5/served.go|// Served is one@@
```

```go
@@P:en/e65/ex5/served.go|// Week replays@@
```

Le jeudi, une trésorière de Lagos signale que des membres « croient
devoir des francs CFA ».

1. **L'audit.** Écris `Audit` dans `ex5/audit.go` :

```go
@@P:en/e65/ex5/audit.go|// Report is what@@
```

   Le test de `ex5/audit_test.go` :

```text
--- FAIL: TestAudit (0.00s)
    audit_test.go:24: {Wrong:0 Members:0 ByCurrency:map[] ShownNGN:0}; want 2 wrong, 1 member, 2 in NGN, 15000 shown
FAIL
FAIL    example/version65/ex5   0.004s
FAIL
```

2. **Les chiffres.** Combien de relevés faux, pour combien de membres ?
3. **La cause.** La traduction `ToV1` était-elle fausse le jour où elle a
   été écrite ?
4. **La correction** : que doit répondre v1 pour un relevé qu'il ne sait
   pas dire ?
5. **Le compte rendu**, en cinq points.
