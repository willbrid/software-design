# Correction 6.4 — Exercice 4 : la politique de compatibilité

> Rappel de l'énoncé : une page qui dit ce que le serveur s'autorise, ce
> qu'il exige des clients, et comment il annonce une rupture ; puis le
> contrat d'un écran.

## En bref

- **Le serveur s'autorise les ajouts**, et les clients s'engagent à les
  ignorer : c'est un échange.
- **Une rupture s'annonce, se mesure, et se fait à une date** : jamais
  par surprise.
- **Les listes fermées sont ouvertes dès le premier jour** : une valeur
  inconnue s'affiche « Autre ».

## La politique

> **Compatibilité de l'API des tontines**
>
> 1. **Sans prévenir**, l'API peut : ajouter un champ à une réponse ;
>    ajouter un élément à un objet d'une liste ; ajouter une valeur à une
>    liste ouverte (statuts, types) ; changer l'ordre des champs d'un
>    objet ; ajouter une route ; ajouter un paramètre **facultatif** à
>    une requête.
> 2. **En échange, un client** : ignore les champs qu'il ne connaît pas ;
>    affiche une valeur de repli pour une valeur inconnue d'une liste
>    ouverte ; ne dépend pas de l'ordre des champs ; traite un champ
>    `null` ou absent comme « inconnu », sauf si la documentation dit
>    autre chose ; envoie son nom et sa version dans `User-Agent`.
> 3. **Sont des ruptures** : retirer ou renommer un champ ; changer son
>    type, son unité ou son sens ; envelopper une liste ; rendre
>    obligatoire un paramètre de requête ; changer l'ordre d'une liste
>    quand il est documenté ; changer un statut HTTP de succès. Une
>    rupture est annoncée au moins 6 mois à l'avance, par la
>    documentation, par l'en-tête `Deprecation` sur les routes
>    concernées, et par un message aux partenaires (leçon 6.5).
> 4. **Les contrats** : chaque client peut déposer le contrat de ce qu'il
>    lit (format `contract`), par version. Le serveur les vérifie à
>    chaque changement, pour toutes les versions qui ont appelé l'API
>    dans les 90 derniers jours.
> 5. **Les listes** : toute liste de valeurs de l'API est **ouverte**. La
>    documentation de chacune le rappelle : « d'autres valeurs pourront
>    s'ajouter ».

## Le contrat de l'écran « versement »

Le paquet `contract` de la leçon ne lit pas les chemins imbriqués
(`beneficiary.name`) : seulement `champ` et `liste[].champ`. Deux choix :
étendre `lookup` (une ligne : découper sur `.`), ou garder des champs
plats dans la réponse. En supposant l'extension faite, le contrat est :

| Path | Kinds | Optional | Values | Example |
|---|---|---|---|---|
| `id` | string | | | `"p_8812"` |
| `beneficiary.name` | string | | | `"Bintou"` |
| `amount_fcfa` | number | | | `250000` |
| `sent_at` | string, null | oui | | |
| `status` | string | | (ouverte : repli « Autre ») | `"sent"` |

Trois remarques :

- `sent_at` est `null` tant que l'opérateur n'a pas confirmé : l'écran
  affiche « en attente », ce que le contrat déclare en acceptant `null`.
- `status` n'a pas de `Values` : l'écran a un repli, il n'interdit
  aucune valeur nouvelle.
- Les exemples fixent le **sens** : 250 000 FCFA pour le versement
  d'exemple, pas 25 000 000 centimes.

## Ce qu'il faut retenir

- La politique échange une liberté du serveur contre une discipline des
  clients.
- Une rupture a une date, et une mesure de qui en souffrira.
- Un contrat déclare aussi ce que l'écran sait ne pas savoir (`null`,
  repli).
