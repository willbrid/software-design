# Software Design — Programme de formation

Formation longue durée : de développeur junior à concepteur de systèmes complexes.
Langage de référence pour les exemples backend : **Go**. Contenu en français.

## Principe directeur

On ne mémorise pas des architectures. On apprend à répondre à :

1. Pourquoi cette architecture ?
2. Pourquoi pas une autre ?
3. Quels sont les compromis ?
4. Quelles contraintes justifient cette décision ?

Toute technologie arrive **après** le problème, jamais avant.

## Méthode

Pour chaque notion : concept → intuition → bon exemple → mauvais exemple →
pourquoi c'est mauvais → exercice → ta réponse → correction → exercice plus dur →
problème réaliste.

Les exercices sont gradués :

| Niveau | Type |
|---|---|
| 1 | Compréhension |
| 2 | Code |
| 3 | Refactoring |
| 4 | Design |
| 5 | Architecture |
| 6 | System design |
| 7 | Incident de production |
| 8 | Évolution du système |
| 9 | Entretien senior |
| 10 | Problème ouvert expert |

## Parcours (10 niveaux)

| # | Niveau | Contenu | État |
|---|---|---|---|
| 0 | Diagnostic | Évaluation initiale | 🔵 en cours |
| 1 | Fondations du design | Clean code, responsabilités, abstractions, couplage/cohésion | ⚪ |
| 2 | OOP & SOLID | Modélisation, polymorphisme, principes, limites | ⚪ |
| 3 | Design patterns | Le problème d'abord, le pattern ensuite | ⚪ |
| 4 | Données & backend | BDD, transactions, concurrence, caching | ⚪ |
| 5 | API & frontières | API design, contrats, versioning, frontend architecture | ⚪ |
| 6 | DDD & architectures applicatives | Hexagonale, Clean Architecture, modular monolith | ⚪ |
| 7 | Messaging & event-driven | Découplage, cohérence éventuelle, sagas | ⚪ |
| 8 | Systèmes distribués | Scalabilité, résilience, observabilité, sécurité | ⚪ |
| 9 | SaaS | Multi-tenancy, RBAC, billing, quotas, audit, webhooks | ⚪ |
| 10 | Architecture avancée | System design guidé façon CTO | ⚪ |

Transverse tout du long : tests, CI/CD, performance, ADR, migration d'architecture.

## Organisation du dépôt

```
00-diagnostic/       Évaluation initiale et correction
NN-<niveau>/         Un dossier par niveau
  cours/             Leçons
  exercices/         Énoncés
  mes-reponses/      Tes réponses (tu écris ici)
  corrections/       Mes corrections
adr/                 Architecture Decision Records rédigés en exercice
evaluations/         Examens et notes de niveau
```

## Journal de progression

| Date | Étape | Note / niveau |
|---|---|---|
| 2026-08-19 | Diagnostic initial envoyé | — |
