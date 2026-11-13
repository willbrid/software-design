# Correction 6.5 — Exercice 1 : une version de plus ?

> Rappel de l'énoncé : six changements à classer ; trois pourquoi ; un
> client qui fait les deux tiers des appels à v1.

## En bref

- **La plupart des changements évitent une version** : un ajout, un
  champ à côté de l'ancien, une règle métier qui change dans le cœur.
- **Une règle métier ne demande jamais de version** : elle change pour
  tous les clients, ce qui exige que toutes les versions passent par le
  même calcul.
- **Un client qui pèse lourd s'appelle par son nom**, avant toute
  coupure.

## 1.a — Six changements

| # | Nouvelle version ? | Comment |
|---|---|---|
| 1 | non | un ajout (leçon 6.4) |
| 2 | **non, et surtout pas** | c'est une règle, pas une forme : elle change dans `ledger`, et v1 comme v2 l'appliquent. La section 2 de la leçon montre ce qui arrive quand une seule version la reçoit |
| 3 | pas tout de suite | ajouter `balance` à côté de `balance_fcfa` ; une version 2 seulement le jour où `balance_fcfa` doit disparaître (par exemple, des tontines dans une autre devise, que `balance_fcfa` ne peut pas dire : exercice 5) |
| 4 | **oui**, ou garder les deux valeurs | `"closed"` est lu par les applications installées. Soit v2 dit `"finished"` et v1 continue de dire `"closed"` (une ligne de traduction), soit le serveur garde `"closed"` |
| 5 | non | un champ `members_page` à côté de `members` (exercice 3 de la leçon 6.4) |
| 6 | pas tout de suite | `id_str` à côté de `id` ; `id` retiré dans la version suivante |

## 1.b — Trois pourquoi

1. **Personne n'y a touché**, et c'est la cause. Le plafond des pénalités
   a été ajouté dans `ledger.Penalty`, que v2 appelle ; v1 recopiée a son
   propre calcul, figé au jour de la copie. Elle continue d'appliquer
   l'ancienne règle à 448 membres sur 500.
2. **`410` dit « ceci a existé, et n'existe plus »**. Un client qui le
   reçoit sait qu'il doit migrer, pas qu'il s'est trompé d'adresse. Le
   corps du problème donne le guide. `404` ferait chercher une faute de
   frappe dans l'URL.
3. **kash ne lit pas les en-têtes**, ni les annonces : son intégration
   marche, personne ne la regarde. Seule une erreur le fait réagir. La
   coupure d'une heure lui donne cette erreur cinq semaines avant
   l'arrêt, au lieu du jour même. (C'est le modèle de la leçon ; en
   production, c'est ce que le compteur permet de vérifier.)

## 1.c — Lire le compteur

4 000 appels sur 5 986, c'est **67 % des appels restants** à v1 par un
seul client, à huit semaines de l'arrêt. Trois actions :

- écrire **directement** à ce partenaire, à la personne technique de son
  intégration, avec la date d'arrêt, le guide, et ses propres chiffres
  (« vous avez fait 4 000 appels à v1 la semaine dernière ») ;
- lui proposer une date de coupure de test, avec lui ;
- décider à l'avance ce qu'on fait s'il n'a pas migré : repousser l'arrêt
  **pour lui seul** (une exception par client authentifié), plutôt que
  pour tout le monde.

Les 1 986 autres appels sont des applications : eux se traitent par le
message « mettez à jour » de l'application, et par le temps.

## Ce qu'il faut retenir

- Une règle métier change pour toutes les versions à la fois.
- `410` est un message : « migrez ».
- Le compteur par client dit à qui écrire.
