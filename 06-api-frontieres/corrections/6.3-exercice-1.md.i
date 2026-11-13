# Correction 6.3 — Exercice 1 : payé une fois, ou deux ?

> Rappel de l'énoncé : six situations avec le serveur `Keyed` ; trois
> pourquoi ; quelles opérations sont idempotentes par nature.

## En bref

- **Tant que la clé est gardée**, un renvoi reçoit la réponse gardée,
  quel que soit le moment où il arrive.
- **Ce qui n'a pas été validé n'a pas eu lieu** : un arrêt avant le
  `COMMIT`, un versement refusé, laissent la clé libre.
- **La clé de la leçon est globale** : deux clients qui tirent la même
  se volent leurs réponses. On la rend unique par client.

## 1.a — Six situations

| # | Versements | Le client reçoit |
|---|---|---|
| 1 | 1 | la réponse gardée, avec `Idempotent-Replayed: true` |
| 2 | **2** | un nouveau `201`, avec un autre identifiant : la clé n'existe plus, le serveur ne peut pas savoir. C'est l'incident de l'exercice 5 |
| 3 | **1 pour 2 demandes** | la seconde trésorière reçoit `422` si son corps diffère, ou **la réponse de la première** s'il est identique, et son versement n'est jamais fait. Il faut une clé unique par client : `PRIMARY KEY (client, key)` (exercice 2) |
| 4 | 1 | une erreur réseau ; au renvoi, la réponse gardée : elle a été validée avec le versement |
| 5 | 0, puis 1 au renvoi | une erreur réseau ; la transaction est annulée, la clé avec. Le renvoi paie |
| 6 | 1, du montant corrigé | le premier essai reçoit `503` et ne garde rien ; le renvoi, avec la même clé et un autre corps, est une première requête pour le serveur |

La situation 6 mérite une remarque : le serveur accepte un autre corps
avec la même clé **parce qu'il n'avait rien gardé**. C'est voulu : rien
n'a été fait, il n'y a rien à protéger. Si l'échec était un refus métier
définitif (une cagnotte vide), on pourrait au contraire vouloir le
garder avec la clé, pour que le renvoi reçoive le même refus.

## 1.b — Trois pourquoi

1. **La clé avant le versement** : l'`INSERT` de la clé est le
   **verrou**. Une seconde requête simultanée attend sur lui, puis
   trouve la clé prise. Avec la clé après le versement, les deux
   transactions versent d'abord, et c'est `CheckThenPay` : 192 versements
   en trop sur 500 doubles appuis.
2. **La réponse gardée** : le client qui renvoie veut **le résultat**
   (l'identifiant du versement, pour l'afficher ou le réclamer), pas
   seulement savoir que c'est fait. Et un client ne doit pas pouvoir
   distinguer « fait maintenant » de « fait avant » : la même réponse le
   garantit.
3. **1 273 contre 1 066** : le transport HTTP de Go renvoie de lui-même
   une requête après une erreur réseau, sur une connexion déjà utilisée,
   quand elle est idempotente, et sa documentation range dans ce cas
   toute requête qui porte `Idempotency-Key`. Les 207 requêtes de plus
   sont ses renvois, invisibles pour l'application.

## 1.c — Idempotent ou pas ?

| Opération | Idempotente par nature ? |
|---|---|
| fixer la part à 10 000 FCFA | **oui** : le résultat ne dépend pas du nombre de fois (`PUT`) |
| ajouter un membre | **oui si** le membre est identifié par son numéro et que la base l'impose unique dans la tontine ; sinon, non |
| marquer le tour 3 comme clos | **oui** : le second appel ne change rien. Il peut répondre `200` ou `409`, l'état est le même |
| verser la cagnotte du tour 3 | **non** : chaque appel déplace de l'argent. Il faut une clé, ou une contrainte « un versement par tour » |
| retirer le membre awa | **oui** : le second `DELETE` répond `404`, l'état est le même |
| augmenter la pénalité de 500 FCFA | **non** : c'est un incrément. « Fixer la pénalité à 1 500 FCFA » le serait |

Le versement a deux protections possibles : la clé, ou une **contrainte
métier** (`UNIQUE (tontine, round)` sur les versements). La seconde est
plus forte : elle protège aussi contre une trésorière qui crée deux
actions différentes pour le même tour.

## Ce qu'il faut retenir

- Une clé protège tant qu'elle est gardée, et pour qui elle est unique.
- Ce qui est annulé ne laisse pas de clé.
- Une opération qui fixe un état est idempotente par nature ; un
  incrément ne l'est pas.
