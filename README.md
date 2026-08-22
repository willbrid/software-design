# Software Design — Programme de formation

Formation longue durée : de développeur junior à concepteur de systèmes complexes.
Langage de référence pour les exemples backend : **Go**. Contenu en français.

Ce dépôt est un **support de cours ouvert**. Il ne contient que du matériel
réutilisable — leçons, énoncés d'exercices, corrections. Aucune progression
personnelle n'y est versionnée : chacun avance à son rythme, en local.

## Principe directeur

On ne mémorise pas des architectures. On apprend à répondre à :

1. Pourquoi cette architecture ?
2. Pourquoi pas une autre ?
3. Quels sont les compromis ?
4. Quelles contraintes justifient cette décision ?

Toute technologie arrive **après** le problème, jamais avant.

## Méthode

Pour chaque notion : concept → intuition → bon exemple → mauvais exemple →
pourquoi c'est mauvais → exercice → réponse du lecteur → correction →
exercice plus dur → problème réaliste.

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

## Comment travailler avec ce dépôt

1. Lis la leçon dans `cours/`.
2. Traite l'exercice de `exercices/` **avant** d'ouvrir la correction.
   Écris tes réponses dans `mes-reponses/` — ce dossier est ignoré par Git,
   il t'appartient et ne sera jamais publié.
3. Compare ensuite avec `corrections/`. La correction explique le *mécanisme*,
   pas seulement le résultat : c'est là que se trouve l'essentiel.
4. Ne saute pas un mauvais exemple. Comprendre pourquoi une conception échoue
   vaut plus que retenir celle qui marche.

## Parcours

| # | Niveau | Contenu | Contenu publié |
|---|---|---|---|
| 1 | Fondations du design | Effets de bord, responsabilités, couplage/cohésion, abstraction, testabilité | 🟡 partiel |
| 2 | OOP & SOLID | Modélisation, polymorphisme, principes, limites | ⚪ à venir |
| 3 | Design patterns | Le problème d'abord, le pattern ensuite | ⚪ à venir |
| 4 | Données & backend | Modélisation, transactions, concurrence, caching | ⚪ à venir |
| 5 | API & frontières | API design, contrats, idempotence, versioning, frontend | ⚪ à venir |
| 6 | DDD & architectures applicatives | Hexagonale, Clean Architecture, modular monolith | ⚪ à venir |
| 7 | Messaging & event-driven | Découplage, cohérence éventuelle, sagas | ⚪ à venir |
| 8 | Systèmes distribués | Scalabilité, résilience, observabilité, sécurité | ⚪ à venir |
| 9 | SaaS | Multi-tenancy, RBAC, billing, quotas, audit, webhooks | ⚪ à venir |
| 10 | Architecture avancée | System design guidé façon CTO | ⚪ à venir |

Transverse tout du long : tests, CI/CD, performance, ADR, migration d'architecture.

## Niveau 1 — Fondations du design

| Leçon | Sujet | Cours | Exercices | Corrections |
|---|---|---|---|---|
| 1.1 | [Effet de bord et propriété des données](01-fondations/cours/1.1-effet-de-bord.md) | ✅ | [5 exercices](01-fondations/exercices/1.1-exercices.md) | [2/5](01-fondations/corrections/) |
| 1.2 | Responsabilités : une seule raison de changer | ⚪ | ⚪ | ⚪ |
| 1.3 | Couplage et cohésion | ⚪ | ⚪ | ⚪ |
| 1.4 | Abstraction : quoi cacher, quoi exposer | ⚪ | ⚪ | ⚪ |
| 1.5 | Erreurs et contrats | ⚪ | ⚪ | ⚪ |
| 1.6 | La testabilité comme révélateur de conception | ⚪ | ⚪ | ⚪ |

## Organisation du dépôt

```
NN-<niveau>/
  cours/             Leçons                          → versionné
  exercices/         Énoncés                         → versionné
  corrections/       Corrections détaillées          → versionné
  mes-reponses/      Tes réponses                    → LOCAL, ignoré par Git
adr/                 Architecture Decision Records rédigés en exercice
```

Le `.gitignore` exclut délibérément tout ce qui est personnel : `mes-reponses/`,
`evaluations/`, notes de progression. Le dépôt reste ainsi utilisable tel quel
par n'importe qui.
