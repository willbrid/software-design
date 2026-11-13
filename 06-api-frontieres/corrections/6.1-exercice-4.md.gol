# Correction 6.1 — Exercice 4 : l'API de l'application

> Rappel de l'énoncé : huit cas d'utilisation à traduire en méthodes,
> chemins, statuts et erreurs ; ce que la supervision compte.

## En bref

- **Les chemins nomment des choses** : tontines, tours, cotisations,
  prêts, membres. Les actions deviennent des méthodes, ou des
  ressources créées (une décision sur un prêt).
- **Chaque refus a son `type`**, que l'application traduit en message.
- **L'astreinte se réveille sur les `5xx`**, jamais sur les `4xx` seuls.

## Le tableau

| # | Méthode et chemin | Succès | Erreurs (statut, `type`) | Le client |
|---|---|---|---|---|
| 1 | `GET /members/me/tontines` | `200` | `401` | se reconnecte |
| 2 | `POST /tontines/{t}/rounds/{r}/contributions` | `201` + `Location` | `422 bad-amount`, `422 not-member`, `409 already-paid`, `409 round-closed`, `503` | montre le refus ; réessaie le `503` |
| 3 | `POST /tontines/{t}/rounds` | `201` + `Location` | `403`, `409 round-open` (un tour est déjà ouvert) | montre le refus |
| 4 | `POST /tontines/{t}/rounds/{r}/closing` (corps : le bénéficiaire) | `201` | `403`, `409 contributions-missing`, `422 not-member`, `409 already-closed` | montre le refus ; relit le tour sur `409` |
| 5 | `POST /tontines/{t}/loans` | `201` + `Location` | `422 too-high`, `409 limit-reached`, `503` | montre le refus ; propose de réessayer après un remboursement sur `409` |
| 6 | `POST /tontines/{t}/loans/{l}/decision` (corps : `granted` ou `refused`) | `201` | `403`, `404`, `409 already-decided`, `409 limit-reached` | relit le prêt |
| 7 | `DELETE /tontines/{t}/members/{m}` | `204` | `403`, `404`, `409 has-open-loan` | montre le refus |
| 8 | `GET /members/me/contributions?after=<curseur>` | `200`, avec le curseur suivant | `400 bad-cursor` | recommence au début |

Quelques choix à justifier :

- **Clore un tour, décider d'un prêt** : ce sont des actions, mais elles
  ont une date, un auteur, et on veut les retrouver. En faire des
  ressources créées (`closing`, `decision`) leur donne une adresse.
- **`/members/me`** : le membre ne choisit pas qui il est, il est
  authentifié. Le serveur résout `me` ; un membre ne peut pas lire les
  cotisations d'un autre en changeant un identifiant.
- **La pagination par curseur** (leçon 5.5) : un `OFFSET` dans l'URL
  coûterait de plus en plus cher, et sauterait des lignes quand une
  cotisation arrive pendant le défilement.
- **Pas de `PUT` ici** : aucun cas ne remplace une ressource entière.
  Modifier le règlement d'une tontine en serait un.

## La supervision

À compter, par route et par `type` :

- le taux de `5xx` : **c'est lui qui réveille l'astreinte**, au-delà
  d'un seuil sur cinq minutes ;
- le taux de `4xx` par `type` : il ne réveille personne, mais un saut de
  `bad-amount` après une nouvelle version de l'application signale un
  défaut côté client, à traiter le jour même ;
- le nombre de `503` et leur durée : une dépendance qui faiblit ;
- le nombre de `POST` réussis comparé aux lignes écrites en base : la
  vérification de l'exercice 1.c.

## Ce qu'il faut retenir

- Une action qu'on veut retrouver devient une ressource.
- Chaque `type` est un message que l'application sait afficher.
- Les `5xx` réveillent, les `4xx` se lisent le matin.
