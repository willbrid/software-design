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
| 1 | Fondations du design | Effets de bord, responsabilités, couplage/cohésion, abstraction, erreurs, testabilité | ✅ **complet** |
| 2 | OOP & SOLID | Modélisation, polymorphisme, principes, limites | ✅ **complet** |
| 3 | Design patterns | Le problème d'abord, le pattern ensuite | ✅ **complet** |
| 4 | Analyser avant de concevoir | Exigences, qualités mesurables, modèle du domaine, diagrammes utiles, C4, ADR | ✅ **complet** |
| 5 | Données & backend | Modélisation, transactions, concurrence, caching | ✅ **complet** |
| 6 | API & frontières | API design, contrats, idempotence, versioning, frontend | ✅ **complet** |
| 7 | DDD & architectures applicatives | Hexagonale, Clean Architecture, modular monolith | ✅ **complet** |
| 8 | Messaging & event-driven | Découplage, cohérence éventuelle, sagas | ✅ **complet** |
| 9 | Systèmes distribués | Scalabilité, résilience, observabilité, sécurité | ✅ **complet** |
| 10 | SaaS | Multi-tenancy, RBAC, billing, quotas, audit, webhooks | 🟡 en cours |
| 11 | Architecture avancée | System design guidé façon CTO | ⚪ à venir |

Transverse tout du long : tests, CI/CD, performance, ADR, migration d'architecture.

## Niveau 1 — Fondations du design

| Leçon | Sujet | Cours | Exercices | Corrections |
|---|---|---|---|---|
| 1.1 | [Effet de bord et propriété des données](01-fondations/cours/1.1-effet-de-bord.md) | ✅ | [5 exercices](01-fondations/exercices/1.1-exercices.md) | [5/5](01-fondations/corrections/) |
| 1.2 | [Responsabilités : une seule raison de changer](01-fondations/cours/1.2-responsabilites.md) | ✅ | [5 exercices](01-fondations/exercices/1.2-exercices.md) | [5/5](01-fondations/corrections/) |
| 1.3 | [Couplage et cohésion](01-fondations/cours/1.3-couplage-cohesion.md) | ✅ | [5 exercices](01-fondations/exercices/1.3-exercices.md) | [5/5](01-fondations/corrections/) |
| 1.4 | [Abstraction : quoi cacher, quoi exposer](01-fondations/cours/1.4-abstraction.md) | ✅ | [5 exercices](01-fondations/exercices/1.4-exercices.md) | [5/5](01-fondations/corrections/) |
| 1.5 | [Erreurs et contrats](01-fondations/cours/1.5-erreurs-contrats.md) | ✅ | [5 exercices](01-fondations/exercices/1.5-exercices.md) | [5/5](01-fondations/corrections/) |
| 1.6 | [La testabilité comme révélateur de conception](01-fondations/cours/1.6-testabilite.md) | ✅ | [5 exercices](01-fondations/exercices/1.6-exercices.md) | [5/5](01-fondations/corrections/) |

## Niveau 2 — OOP & SOLID

Go n'a ni classes ni héritage. C'est un avantage pour ce niveau : on y apprend
à quoi les principes servent, et non la syntaxe qui les imite.

| Leçon | Sujet | Cours | Exercices | Corrections |
|---|---|---|---|---|
| 2.1 | [Modéliser : ce qui a une identité, ce qui n'en a pas](02-oop-solid/cours/2.1-modeliser.md) | ✅ | [5 exercices](02-oop-solid/exercices/2.1-exercices.md) | [5/5](02-oop-solid/corrections/) |
| 2.2 | [Polymorphisme : à quoi il sert vraiment](02-oop-solid/cours/2.2-polymorphisme.md) | ✅ | [5 exercices](02-oop-solid/exercices/2.2-exercices.md) | [5/5](02-oop-solid/corrections/) |
| 2.3 | [Composition contre héritage, et pourquoi Go a tranché](02-oop-solid/cours/2.3-composition.md) | ✅ | [5 exercices](02-oop-solid/exercices/2.3-exercices.md) | [5/5](02-oop-solid/corrections/) |
| 2.4 | [SOLID : SRP, OCP, LSP](02-oop-solid/cours/2.4-solid-srp-ocp-lsp.md) | ✅ | [5 exercices](02-oop-solid/exercices/2.4-exercices.md) | [5/5](02-oop-solid/corrections/) |
| 2.5 | [SOLID : ISP, DIP](02-oop-solid/cours/2.5-solid-isp-dip.md) | ✅ | [5 exercices](02-oop-solid/exercices/2.5-exercices.md) | [5/5](02-oop-solid/corrections/) |
| 2.6 | [Les limites : quand ces principes coûtent plus qu'ils ne rapportent](02-oop-solid/cours/2.6-limites.md) | ✅ | [5 exercices](02-oop-solid/exercices/2.6-exercices.md) | [5/5](02-oop-solid/corrections/) |

## Niveau 3 — Design patterns

Le problème d'abord, le pattern ensuite. Chaque leçon part d'une contrainte
qui revient, écrit les façons de la résoudre en Go, et mesure ce que chacune
coûte le jour où la contrainte change. Le nom du pattern arrive à la fin.

| Leçon | Sujet | Cours | Exercices | Corrections |
|---|---|---|---|---|
| 3.1 | [Faire varier une règle : la stratégie, et quand une fonction suffit](03-design-patterns/cours/3.1-strategie.md) | ✅ | [5 exercices](03-design-patterns/exercices/3.1-exercices.md) | [5/5](03-design-patterns/corrections/) |
| 3.2 | [Construire un objet valide : constructeurs, options, builder, fabrique](03-design-patterns/cours/3.2-construire.md) | ✅ | [5 exercices](03-design-patterns/exercices/3.2-exercices.md) | [5/5](03-design-patterns/corrections/) |
| 3.3 | [Ajouter un comportement autour d'un autre : décorateur, middleware, adaptateur, proxy](03-design-patterns/cours/3.3-decorer.md) | ✅ | [5 exercices](03-design-patterns/exercices/3.3-exercices.md) | [5/5](03-design-patterns/corrections/) |
| 3.4 | [Prévenir sans coupler : observateur, bus en mémoire, et la concurrence](03-design-patterns/cours/3.4-prevenir.md) | ✅ | [5 exercices](03-design-patterns/exercices/3.4-exercices.md) | [5/5](03-design-patterns/corrections/) |
| 3.5 | [Représenter des états et des étapes : machine à états, commande, pipeline](03-design-patterns/cours/3.5-etats-etapes.md) | ✅ | [5 exercices](03-design-patterns/exercices/3.5-exercices.md) | [5/5](03-design-patterns/corrections/) |
| 3.6 | [Les patterns qui coûtent : singleton, service locator, fabrique abstraite](03-design-patterns/cours/3.6-patterns-qui-coutent.md) | ✅ | [5 exercices](03-design-patterns/exercices/3.6-exercices.md) | [5/5](03-design-patterns/corrections/) |

## Niveau 4 — Analyser avant de concevoir

Concevoir, c'est répondre à un problème : encore faut-il l'avoir compris.
Ce niveau apprend à dire **ce que le système doit faire**, **à quel point il
doit bien le faire**, et **à le montrer** à d'autres — avec juste assez de
notation. On n'y apprend pas UML en entier : seulement les quelques
diagrammes qui servent, écrits en texte dans le dépôt.

| Leçon | Sujet | Cours | Exercices | Corrections |
|---|---|---|---|---|
| 4.1 | [Comprendre le problème : cas d'utilisation, récits utilisateur, critères d'acceptation](04-analyse/cours/4.1-comprendre-le-probleme.md) | ✅ | [5 exercices](04-analyse/exercices/4.1-exercices.md) | [5/5](04-analyse/corrections/) |
| 4.2 | [Les exigences de qualité : des scénarios qu'on peut mesurer](04-analyse/cours/4.2-exigences-de-qualite.md) | ✅ | [5 exercices](04-analyse/exercices/4.2-exercices.md) | [5/5](04-analyse/corrections/) |
| 4.3 | [Modéliser le domaine sans code : le modèle conceptuel](04-analyse/cours/4.3-modele-conceptuel.md) | ✅ | [5 exercices](04-analyse/exercices/4.3-exercices.md) | [5/5](04-analyse/corrections/) |
| 4.4 | [Les diagrammes qui servent : séquence, états, activité](04-analyse/cours/4.4-diagrammes.md) | ✅ | [5 exercices](04-analyse/exercices/4.4-exercices.md) | [5/5](04-analyse/corrections/) |
| 4.5 | [Décrire une architecture : le modèle C4 et les ADR](04-analyse/cours/4.5-c4-adr.md) | ✅ | [5 exercices](04-analyse/exercices/4.5-exercices.md) | [5/5](04-analyse/corrections/) |
| 4.6 | [Combien d'analyse ? Du script au système critique, et quand le DDD vaut son prix](04-analyse/cours/4.6-combien-d-analyse.md) | ✅ | [5 exercices](04-analyse/exercices/4.6-exercices.md) | [5/5](04-analyse/corrections/) |

## Niveau 5 — Données & backend

Les règles trouvées au niveau 4 doivent tenir quand le système tourne :
quand un script écrit dans la base sans passer par l'application, quand
deux requêtes arrivent au même instant, quand le schéma doit changer sans
arrêter le service. Ce niveau se pratique sur un vrai PostgreSQL 17,
lancé par exemple avec
`docker run -d --name sd-pg -p 55432:5432 -e POSTGRES_PASSWORD=dev postgres:17`.

| Leçon | Sujet | Cours | Exercices | Corrections |
|---|---|---|---|---|
| 5.1 | [Du modèle au schéma : la base de données comme dernier garde-fou](05-donnees-backend/cours/5.1-du-modele-au-schema.md) | ✅ | [5 exercices](05-donnees-backend/exercices/5.1-exercices.md) | [5/5](05-donnees-backend/corrections/) |
| 5.2 | [Les transactions : tout ou rien, et ce que « rien » veut dire](05-donnees-backend/cours/5.2-les-transactions.md) | ✅ | [5 exercices](05-donnees-backend/exercices/5.2-exercices.md) | [5/5](05-donnees-backend/corrections/) |
| 5.3 | [La concurrence : mises à jour perdues, isolation, verrous](05-donnees-backend/cours/5.3-la-concurrence.md) | ✅ | [5 exercices](05-donnees-backend/exercices/5.3-exercices.md) | [5/5](05-donnees-backend/corrections/) |
| 5.4 | [Faire évoluer un schéma sans coupure : les migrations](05-donnees-backend/cours/5.4-les-migrations.md) | ✅ | [5 exercices](05-donnees-backend/exercices/5.4-exercices.md) | [5/5](05-donnees-backend/corrections/) |
| 5.5 | [Lire vite : requêtes, index, et le N+1](05-donnees-backend/cours/5.5-lire-vite.md) | ✅ | [5 exercices](05-donnees-backend/exercices/5.5-exercices.md) | [5/5](05-donnees-backend/corrections/) |
| 5.6 | [Le cache : ce qu'il coûte, et quand il ment](05-donnees-backend/cours/5.6-le-cache.md) | ✅ | [5 exercices](05-donnees-backend/exercices/5.6-exercices.md) | [5/5](05-donnees-backend/corrections/) |

## Niveau 6 — API & frontières

Les données sont protégées dans la base ; les requêtes qui les changent
arrivent maintenant de l'extérieur, par des programmes qui ne lisent pas
les messages d'erreur. Ce niveau apprend à dire à ces programmes ce qui
s'est passé, à refuser ce qui ne doit pas entrer, à supporter les
requêtes renvoyées, et à faire évoluer une API sans casser les
applications installées. La bibliothèque standard suffit, avec le même
PostgreSQL 17 que le niveau 5 pour l'idempotence.

| Leçon | Sujet | Cours | Exercices | Corrections |
|---|---|---|---|---|
| 6.1 | [Concevoir une API HTTP : des méthodes et des statuts qui disent quoi faire](06-api-frontieres/cours/6.1-methodes-et-statuts.md) | ✅ | [5 exercices](06-api-frontieres/exercices/6.1-exercices.md) | [5/5](06-api-frontieres/corrections/) |
| 6.2 | [Valider à la frontière : décoder strictement, puis transformer en types sûrs](06-api-frontieres/cours/6.2-valider-a-la-frontiere.md) | ✅ | [5 exercices](06-api-frontieres/exercices/6.2-exercices.md) | [5/5](06-api-frontieres/corrections/) |
| 6.3 | [L'idempotence : quand le client renvoie la requête](06-api-frontieres/cours/6.3-idempotence.md) | ✅ | [5 exercices](06-api-frontieres/exercices/6.3-exercices.md) | [5/5](06-api-frontieres/corrections/) |
| 6.4 | [Les contrats : ce qu'une API promet, et comment le tester](06-api-frontieres/cours/6.4-les-contrats.md) | ✅ | [5 exercices](06-api-frontieres/exercices/6.4-exercices.md) | [5/5](06-api-frontieres/corrections/) |
| 6.5 | [Versionner une API : rompre sans casser, et savoir quand arrêter](06-api-frontieres/cours/6.5-versionner.md) | ✅ | [5 exercices](06-api-frontieres/exercices/6.5-exercices.md) | [5/5](06-api-frontieres/corrections/) |
| 6.6 | [L'écran et l'API : écrire à deux, relire pour rien, attendre le réseau](06-api-frontieres/cours/6.6-l-ecran-et-l-api.md) | ✅ | [5 exercices](06-api-frontieres/exercices/6.6-exercices.md) | [5/5](06-api-frontieres/corrections/) |

## Niveau 7 — DDD & architectures applicatives

Les règles du domaine sont trouvées (niveau 4), protégées dans la base
(niveau 5), exposées par l'API (niveau 6). Ce niveau se demande où elles
vivent **dans le code**, et comment le code s'organise autour d'elles :
des agrégats qui gardent leurs règles, des contextes qui ont chacun leur
langage, des dépendances qui pointent vers le domaine, et des modules qui
peuvent un jour devenir des services. Chaque architecture y est mesurée
à ce qu'elle coûte autant qu'à ce qu'elle protège.

| Leçon | Sujet | Cours | Exercices | Corrections |
|---|---|---|---|---|
| 7.1 | [Le modèle dans le code : des agrégats qui gardent leurs règles](07-ddd-architectures/cours/7.1-les-agregats.md) | ✅ | [5 exercices](07-ddd-architectures/exercices/7.1-exercices.md) | [5/5](07-ddd-architectures/corrections/) |
| 7.2 | [Le langage et les contextes délimités : un mot, un sens, une frontière](07-ddd-architectures/cours/7.2-les-contextes.md) | ✅ | [5 exercices](07-ddd-architectures/exercices/7.2-exercices.md) | [5/5](07-ddd-architectures/corrections/) |
| 7.3 | [L'architecture hexagonale : des ports, des adaptateurs, et des faux fidèles](07-ddd-architectures/cours/7.3-l-hexagone.md) | ✅ | [5 exercices](07-ddd-architectures/exercices/7.3-exercices.md) | [5/5](07-ddd-architectures/corrections/) |
| 7.4 | [Clean Architecture et les couches : ce qu'elles protègent, ce qu'elles coûtent](07-ddd-architectures/cours/7.4-le-cout-des-couches.md) | ✅ | [5 exercices](07-ddd-architectures/exercices/7.4-exercices.md) | [5/5](07-ddd-architectures/corrections/) |
| 7.5 | [Le monolithe modulaire : des frontières tenues, dans un seul programme](07-ddd-architectures/cours/7.5-le-monolithe-modulaire.md) | ✅ | [5 exercices](07-ddd-architectures/exercices/7.5-exercices.md) | [5/5](07-ddd-architectures/corrections/) |
| 7.6 | [Extraire un module en service : ce que coûte le réseau, et comment migrer sans sauter](07-ddd-architectures/cours/7.6-extraire-un-service.md) | ✅ | [5 exercices](07-ddd-architectures/exercices/7.6-exercices.md) | [5/5](07-ddd-architectures/corrections/) |

## Niveau 8 — Messaging & event-driven

Les modules ont des frontières (niveau 7) ; il faut maintenant qu'ils se
préviennent sans s'attendre. Ce niveau apprend à distinguer un fait d'un
ordre, à publier un événement sans le perdre ni l'inventer, à le
recevoir deux fois sans dommage, à vivre avec des vues en retard, à
mener une action en plusieurs étapes qui peut échouer au milieu, et à
faire évoluer des événements déjà écrits. Les leçons 8.2 à 8.4
s'appuient sur le même PostgreSQL 17 que le niveau 5 ; les autres n'ont
besoin que de la bibliothèque standard.

| Leçon | Sujet | Cours | Exercices | Corrections |
|---|---|---|---|---|
| 8.1 | [Commande ou événement : découpler par les messages](08-messaging-evenements/cours/8.1-commande-ou-evenement.md) | ✅ | [5 exercices](08-messaging-evenements/exercices/8.1-exercices.md) | [5/5](08-messaging-evenements/corrections/) |
| 8.2 | [L'outbox transactionnelle : publier sans perdre ni inventer](08-messaging-evenements/cours/8.2-l-outbox.md) | ✅ | [5 exercices](08-messaging-evenements/exercices/8.2-exercices.md) | [5/5](08-messaging-evenements/corrections/) |
| 8.3 | [Au moins une fois : des abonnés qui supportent le doublon, le désordre et le message empoisonné](08-messaging-evenements/cours/8.3-au-moins-une-fois.md) | ✅ | [5 exercices](08-messaging-evenements/exercices/8.3-exercices.md) | [5/5](08-messaging-evenements/corrections/) |
| 8.4 | [La cohérence éventuelle : des vues en retard, et comment vivre avec](08-messaging-evenements/cours/8.4-la-coherence-eventuelle.md) | ✅ | [5 exercices](08-messaging-evenements/exercices/8.4-exercices.md) | [5/5](08-messaging-evenements/corrections/) |
| 8.5 | [Les sagas : une action en plusieurs étapes, qui peut échouer au milieu](08-messaging-evenements/cours/8.5-les-sagas.md) | ✅ | [5 exercices](08-messaging-evenements/exercices/8.5-exercices.md) | [5/5](08-messaging-evenements/corrections/) |
| 8.6 | [Faire évoluer les événements, et les rejouer](08-messaging-evenements/cours/8.6-faire-evoluer-les-evenements.md) | ✅ | [5 exercices](08-messaging-evenements/exercices/8.6-exercices.md) | [5/5](08-messaging-evenements/corrections/) |

## Niveau 9 — Systèmes distribués

L'application tourne désormais sur plusieurs instances et plusieurs
services, sous une vraie charge. Ce niveau apprend à trouver ce qui
sature avant d'ajouter des machines, à survivre aux pannes partielles
sans les aggraver, à refuser tôt ce qu'on ne peut pas servir, à voir ce
qui se passe, à se protéger des requêtes hostiles, et à décider sans
horloge commune. Les mesures tournent sur un vrai PostgreSQL 17, ou avec
la bibliothèque standard seule.

| Leçon | Sujet | Cours | Exercices | Corrections |
|---|---|---|---|---|
| 9.1 | [La scalabilité : trouver le goulot avant d'ajouter des machines](09-systemes-distribues/cours/9.1-la-scalabilite.md) | ✅ | [5 exercices](09-systemes-distribues/exercices/9.1-exercices.md) | [5/5](09-systemes-distribues/corrections/) |
| 9.2 | [La résilience : des délais, des tentatives qui n'aggravent pas la panne, et un coupe-circuit](09-systemes-distribues/cours/9.2-la-resilience.md) | ✅ | [5 exercices](09-systemes-distribues/exercices/9.2-exercices.md) | [5/5](09-systemes-distribues/corrections/) |
| 9.3 | [La surcharge : refuser tôt, par ordre d'importance, et chaque client à sa mesure](09-systemes-distribues/cours/9.3-la-surcharge.md) | ✅ | [5 exercices](09-systemes-distribues/exercices/9.3-exercices.md) | [5/5](09-systemes-distribues/corrections/) |
| 9.4 | [L'observabilité : voir ce qui se passe, et ne réveiller quelqu'un que pour ce qui compte](09-systemes-distribues/cours/9.4-l-observabilite.md) | ✅ | [5 exercices](09-systemes-distribues/exercices/9.4-exercices.md) | [5/5](09-systemes-distribues/corrections/) |
| 9.5 | [La sécurité dans la conception : à qui est cet objet, qui m'appelle vraiment, et que peut faire mon code s'il est trompé](09-systemes-distribues/cours/9.5-la-securite.md) | ✅ | [5 exercices](09-systemes-distribues/exercices/9.5-exercices.md) | [5/5](09-systemes-distribues/corrections/) |
| 9.6 | [Le temps et l'accord : des horloges qui mentent, des baux qui expirent, et des jetons qui protègent](09-systemes-distribues/cours/9.6-le-temps-et-l-accord.md) | ✅ | [5 exercices](09-systemes-distribues/exercices/9.6-exercices.md) | [5/5](09-systemes-distribues/corrections/) |

## Niveau 10 — SaaS

L'application ne sert plus une tontine, mais des centaines
d'associations qui s'inscrivent, paient leur offre et branchent leurs
propres systèmes. Ce niveau apprend à tenir chaque association chez
elle dans des tables partagées, à dire qui peut faire quoi dans quelle
association, à facturer sans se tromper d'un franc, à empêcher un client
de prendre la place des autres, à prouver qui a fait quoi, et à prévenir
les systèmes des clients sans se laisser bloquer par eux. Les mesures
tournent sur le PostgreSQL 17 du niveau 5, ou avec la bibliothèque
standard seule.

| Leçon | Sujet | Cours | Exercices | Corrections |
|---|---|---|---|---|
| 10.1 | [Le multi-tenancy : chaque association chez elle, dans les mêmes tables](10-saas/cours/10.1-le-multi-tenancy.md) | ✅ | [5 exercices](10-saas/exercices/10.1-exercices.md) | ⚪ à venir |

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
