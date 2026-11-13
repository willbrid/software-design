# Correction 6.6 — Exercice 1 : que voit l'écran ?

> Rappel de l'énoncé : six situations avec le serveur de la leçon ; trois
> pourquoi ; une règle métier dans le BFF.

## En bref

- **`428`, `412`, `304`** disent chacun à l'écran ce qu'il doit faire :
  envoyer la version, relire, ou ne rien redessiner.
- **Relire et réappliquer n'est pas toujours juste** : quand les deux ont
  changé le même champ, l'écran de la leçon écrase l'autre, en
  connaissance de cause cette fois.
- **Le BFF assemble, il ne décide pas.**

## 1.a — Six situations

| # | L'écran reçoit | Il doit |
|---|---|---|
| 1 | `428 Precondition Required` | relire pour obtenir l'`ETag`, puis réécrire avec `If-Match` : c'est un défaut de l'écran, à corriger |
| 2 | `412`, avec `ETag: "v5"` | relire la version 5, réappliquer ou fusionner (exercice 3), puis réécrire |
| 3 | `304 Not Modified`, sans corps | garder ce qu'il affiche |
| 4 | l'une `200`, l'autre `412` | celle qui reçoit `412` relit et voit 15 000 (ou 12 500). L'écran de la leçon réapplique son changement **sans regarder** : il écrase la valeur de sa collègue. C'est un conflit, à montrer (exercice 3) |
| 5 | `412`, « unknown ETag » | un `ETag` est une chaîne **entre guillemets** (RFC 9110) ; l'écran doit renvoyer la valeur reçue telle quelle, sans la réécrire |
| 6 | rien, longtemps : le BFF de la leçon attend le service des soldes sans limite | rien de bon. Le BFF doit avoir un budget et rendre un écran partiel (exercice 5) |

## 1.b — Trois pourquoi

1. **La transaction** dure le temps d'une requête : quelques
   millisecondes. Entre la lecture (le `GET` qui affiche l'écran) et
   l'écriture (le `PUT` du bouton « enregistrer »), il s'écoule des
   secondes ou des minutes, et deux requêtes, donc deux transactions. La
   version portée par `If-Match` fait le travail d'un verrou optimiste qui
   survit entre les requêtes.
2. **Le `304`** économise la réponse, pas la question : l'aller-retour de
   300 ms est toujours payé. Le BFF supprime **sept allers-retours** sur
   huit ; le `304` supprime des octets.
3. **Les vagues** ne peuvent pas tout envoyer d'un coup : il faut
   connaître les tontines avant de demander leur prochain tour. Deux
   allers-retours dépendants, plus le travail : 609 ms. Seul un appel
   unique, dont les dépendances se résolvent à côté de l'API, descend à
   un aller-retour.

## 1.c — La règle dans le BFF

« À jour de ses cotisations » est une **règle** : elle dépend du
règlement, des pénalités, des tours clos, et elle sert ailleurs (pour
accorder un prêt, leçon 5.6). Calculée dans le BFF de l'accueil, elle
serait recalculée autrement dans le service des prêts, et les deux
finiraient par diverger, comme la version 1 recopiée de la leçon 6.5.

La règle va dans l'API (le domaine), exposée comme un champ
(`"up_to_date": true`) ou une ressource ; le BFF la **lit** et l'affiche.

## Ce qu'il faut retenir

- Chaque statut conditionnel a un geste de l'écran qui lui répond.
- Réappliquer après `412` ne suffit pas quand le même champ a changé.
- Le BFF assemble et met en forme ; les règles restent derrière lui.
