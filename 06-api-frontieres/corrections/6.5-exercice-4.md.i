# Correction 6.5 — Exercice 4 : le plan de retrait de v1

> Rappel de l'énoncé : 30 % des appels par l'application 4.x, 8 % par
> trois partenaires ; écrire le plan de retrait de v1.

## En bref

- **Deux populations, deux plans** : les partenaires se traitent un par
  un, par leur nom ; les applications se traitent par l'application
  elle-même.
- **Chaque étape a un seuil mesuré**, pas seulement une date.
- **L'application 4.x doit déjà savoir lire `410`** : sinon, il faut une
  version 4.x corrective avant tout.

## Le plan

| Quand | Étape | Seuil pour passer à la suivante |
|---|---|---|
| J | `Deprecation`, `Sunset` (J + 6 mois) et `Link` sur toutes les réponses de v1 ; guide de migration publié ; message aux trois partenaires, nommément | — |
| J | un message « une nouvelle version est disponible » aux membres en 4.x, par la bannière que l'application affiche déjà si elle en a une, sinon par SMS et par les trésorières | — |
| J + 1 mois | point avec chaque partenaire : date de migration écrite | les trois ont une date |
| J + 3 mois | première coupure d'une heure, annoncée une semaine avant | moins de 10 % des appels sur v1 |
| J + 4 mois | coupure de quatre heures | aucun partenaire sur v1, sauf exception écrite |
| J + 5 mois | coupure d'une journée | applications 4.x sous 3 % des sessions |
| J + 6 mois | arrêt : `410` pour tous, sauf exceptions par client authentifié | — |
| J + 7 mois | retrait du code de v1, des tests, et de la traduction | plus aucune exception |

Si un seuil n'est pas atteint, l'étape suivante **attend** : la date de
`Sunset` peut être repoussée (l'en-tête change, et c'est permis), elle ne
se rapproche jamais.

## L'application 4.x et le `410`

Deux cas :

- **elle sait afficher un message sur `410`** (« cette version n'est plus
  servie, mettez à jour ») : le jour de l'arrêt, ses membres voient ce
  message, et le lien vers la boutique d'applications ;
- **elle ne le sait pas** : elle affiche une erreur générique, ou
  plante. Il faut alors une **4.x corrective** qui ne fait que cela, et
  attendre qu'elle soit installée : c'est le même problème que le repli
  de la leçon 6.4, et la même leçon, à décider dans la première version.

Une application qui affiche déjà les messages que le serveur lui envoie
(une bannière configurable) est plus facile à retirer que toute autre :
le serveur peut écrire « mettez à jour » sans attendre de version.

## Le jour de l'arrêt

- le nombre de `410` par minute, par client : un pic chez un partenaire
  qu'on croyait parti ;
- les sessions de l'application 5.x : une hausse dit que des membres
  mettent à jour ;
- les appels au support et les avis de la boutique d'applications ;
- une personne de l'équipe disponible pour une exception d'urgence.

## Ce qu'il faut retenir

- Les partenaires par leur nom, les applications par leur écran.
- Un seuil mesuré déclenche chaque étape ; la date ne fait que la
  viser.
- Savoir afficher `410` se décide dans la première version.
