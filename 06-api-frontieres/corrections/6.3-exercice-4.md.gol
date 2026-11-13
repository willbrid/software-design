# Correction 6.3 — Exercice 4 : cinq opérations à rendre sûres

> Rappel de l'énoncé : pour cinq opérations, d'où vient la clé, ce qui
> est gardé, combien de temps, et ce que reçoivent les renvois.

## En bref

- **La clé vient de celui qui renvoie** : le téléphone pour ce qu'il
  envoie, l'opérateur pour ses rappels.
- **Un traitement long garde un état « en cours »**, validé avant
  l'appel externe ; un renvoi pendant ce temps reçoit `409`.
- **Une contrainte métier vaut mieux qu'une clé** quand elle existe :
  rejoindre une tontine deux fois est déjà impossible.

## Le tableau

| # | Clé, et sa portée | Gardé avec la clé | Durée | Renvoi pendant le traitement | Autre corps |
|---|---|---|---|---|---|
| 1 | tirée par le téléphone, unique par membre | statut et réponse | 7 jours (exercice 5) | attend la transaction (quelques ms), puis la réponse | `422` |
| 2 | tirée par l'application de la trésorière, unique par trésorière | l'état (`pending`, `sent`, `failed`) et la réponse ; l'ordre part dans l'outbox (leçon 5.2) | 7 jours | **`409` avec `Retry-After`** : l'appel à l'opérateur dure, on ne fait pas attendre une connexion | `422` |
| 3 | **pas de clé** | — | — | — | — |
| 4 | tirée par l'application, unique par trésorière | statut et réponse | 7 jours | attend la transaction | `422` |
| 5 | **l'identifiant de transfert de l'opérateur**, unique par opérateur | le fait que le résultat a été appliqué | au moins la durée pendant laquelle l'opérateur rappelle (sa documentation la donne), et plus | attend la transaction | un autre statut pour le même transfert : on le garde et on alerte, sans l'appliquer |

## Les choix

- **Opération 2, en deux temps.** La transaction valide la clé dans
  l'état `pending` et l'ordre dans l'outbox, puis répond `202 Accepted`
  avec l'adresse du versement. L'envoi à l'opérateur se fait hors de la
  requête, avec la clé de l'ordre comme clé d'idempotence **chez
  l'opérateur**. Un renvoi de la trésorière reçoit la réponse gardée
  (`202`), ou `409` si la transaction n'est pas encore validée.
- **Opération 3, sans clé.** Rejoindre une tontine crée une adhésion
  `(tontine, member)`, que la base rend unique. Le second essai rencontre
  la contrainte : le serveur répond `200` avec l'adhésion existante. La
  règle métier fait le travail de la clé, et protège aussi contre deux
  liens d'invitation ouverts l'un après l'autre.
- **Opération 4, avec clé et contrainte.** La clé protège du renvoi ;
  la limite de prêts ouverts (leçon 5.3) protège de deux trésorières qui
  accordent chacune un prêt différent.
- **Opération 5, la clé est imposée.** L'opérateur ne connaît pas nos
  clés ; il envoie la sienne, l'identifiant du transfert. La table des
  rappels traités a cet identifiant pour clé primaire. Un rappel
  contradictoire (« réussi » puis « échoué ») est un signal d'incident,
  pas une mise à jour.

## Ce qu'il faut retenir

- La clé appartient à qui renvoie.
- Le long se fait hors de la requête : `202`, et `409` pour le renvoi
  qui arrive trop tôt.
- Quand une contrainte métier rend l'opération idempotente, elle
  remplace la clé.
