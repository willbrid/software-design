# Correction 6.6 — Exercice 4 : le BFF de l'écran de réunion

> Rappel de l'énoncé : un BFF pour l'écran de réunion de la trésorière ;
> ses appels, son budget, son cache, et le bouton « clore le tour ».

## En bref

- **Un appel depuis le téléphone**, deux vagues à côté de l'API.
- **Indispensable** : le tour, les membres, les paiements. **Peut
  manquer** : les prêts en retard, la cagnotte calculée.
- **« Clore le tour » ne passe pas par le BFF** de lecture : c'est une
  écriture, qui va à l'API avec sa clé d'idempotence et son `If-Match`.

## Les appels

| Vague | Appel | Indispensable ? |
|---|---|---|
| 1 | le tour en cours (numéro, bénéficiaire, `ETag`) | oui |
| 1 | les membres de la tontine | oui |
| 2 | les paiements du tour | oui : sans eux, l'écran ne dit pas qui a payé |
| 2 | la présence (pointée pendant la réunion) | non : « — » |
| 2 | la cagnotte | non : la somme des paiements la remplace, avec la mention « calculée » |
| 2 | les prêts en retard | non : un bandeau « prêts indisponibles » |

**Le budget** : 800 ms côté BFF. C'est plus que l'accueil (300 ms),
parce que la trésorière attend cet écran, assise, au début de la
réunion, et qu'un écran incomplet y a plus de conséquences. Au-delà, le
BFF répond avec ce qu'il a, et `X-Partial` liste ce qui manque.

## Le cache

- **les membres** : 1 minute, invalidés à chaque ajout ou retrait (leçon
  5.6). Ils changent rarement pendant une réunion ;
- **les prêts en retard** : 5 minutes ; c'est une information, pas une
  décision ;
- **les paiements et la cagnotte** : **pas de cache**. Ils changent
  pendant la réunion, et la trésorière décide dessus (clore le tour).
  C'est la règle de la leçon 5.6 : on ne décide pas sur une valeur en
  cache.

## Le bouton « clore le tour »

Il envoie `POST /tontines/{t}/rounds/{r}/closing` à l'API, avec :

- une **clé d'idempotence** (leçon 6.3) : la trésorière appuiera deux
  fois si la réponse tarde ;
- **`If-Match`** avec l'`ETag` du tour lu par l'écran : si un paiement est
  arrivé entre-temps, l'API répond `412`, et l'écran se rafraîchit avant
  de clore.

Le faire passer par le BFF n'apporterait rien (un seul appel) et
mélangerait deux rôles : le BFF assemble des lectures pour un écran,
l'API exécute les décisions avec leurs règles. Si l'équipe veut un seul
point d'entrée pour le téléphone, le BFF peut **relayer** l'écriture
telle quelle, sans y ajouter de logique.

## Ce qu'il faut retenir

- Un BFF par écran : ses vagues, son budget, ses parties facultatives.
- Ce qui sert à décider n'est pas en cache, même dans un BFF.
- Une écriture garde sa clé et sa précondition, quel que soit le chemin.
