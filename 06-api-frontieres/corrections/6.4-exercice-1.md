# Correction 6.4 — Exercice 1 : rupture ou pas ?

> Rappel de l'énoncé : huit changements de la réponse, trois
> applications ; trois pourquoi ; le partenaire sans contrat.

## En bref

- **Un champ nouveau ne casse que l'application stricte**, à chaque
  fois.
- **Un changement de type casse tout le monde**, y compris le lecteur
  tolérant de la leçon, qui n'est tolérant que pour ce qu'il a prévu.
- **Un changement d'ordre ou de sens ne casse rien de visible** : il
  faut le chercher dans ce que l'écran **veut dire**.

## 1.a — Huit changements

`cmd/ex1` du module de correction envoie les huit changements aux trois
applications (part, statut, prochain tour, nombre de membres) :

```text
no member                10 000 FCFA|Ouverte|3|0                      10 000 FCFA|Ouverte|3|0                      10 000 FCFA|Ouverte|3|0                     
long name                10 000 FCFA|Ouverte|3|2                      10 000 FCFA|Ouverte|3|2                      10 000 FCFA|Ouverte|3|2                     
next_round as a string   ERROR                                        ERROR                                        ERROR                                       
currency                 ERROR                                        10 000 FCFA|Ouverte|3|2                      10 000 FCFA|Ouverte|3|2                     
OPEN                     ERROR                                        ERROR                                        10 000 FCFA|Autre|3|2                       
decimals                 ERROR                                        ERROR                                        —|Ouverte|3|2                               
photo_url                ERROR                                        10 000 FCFA|Ouverte|3|2                      10 000 FCFA|Ouverte|3|2                     
members sorted           10 000 FCFA|Ouverte|3|2                      10 000 FCFA|Ouverte|3|2                      10 000 FCFA|Ouverte|3|2                     
```

| # | Stricte | Ordinaire | Tolérante | Commentaire |
|---|---|---|---|---|
| 1 | ok | ok | ok | une liste vide reste une liste |
| 2 | ok | ok | ok | côté lecture ; un écran qui coupe le nom à 30 caractères l'affichera mal, ce que la forme ne dit pas |
| 3 | ERROR | ERROR | **ERROR** | un changement de type. Le lecteur tolérant décode dans une structure où `next_round` est un `*int` : un seul champ du mauvais type fait échouer **tout** le décodage |
| 4 | ERROR | ok | ok | un ajout |
| 5 | ERROR | ERROR | dégradé (« Autre ») | une **nouvelle valeur**, pour les lecteurs : la casse fait partie de la valeur |
| 6 | ERROR | ERROR | dégradé (« — ») | un nombre décimal dans un entier |
| 7 | ERROR | ok | ok | un ajout dans chaque élément |
| 8 | ok | ok | ok | **en apparence**. Si l'écran montre les membres dans l'ordre de passage des tours, il montre maintenant un ordre faux, sans erreur |

La ligne 3 nuance la leçon : un lecteur tolérant ne l'est que champ par
champ **s'il lit champ par champ**. Celui de l'exercice 2 lit les nombres
avec `json.Number` pour cette raison ; pour être tolérant à un champ
quelconque du mauvais type, il faudrait décoder chaque champ à part
(dans un `map[string]json.RawMessage`), ce qui coûte de la lisibilité.
On choisit les champs pour lesquels on paie ce prix.

La ligne 8 est de la même famille que les centimes : l'ordre d'une liste
est une information. S'il compte, le contrat le dit (« triés par ordre
de passage ») et un exemple le vérifie.

## 1.b — Trois pourquoi

1. **Golden et réordonnancement** : le test compare des octets, et les
   octets ont changé. L'ordre des membres d'un objet JSON n'a pas de
   sens (RFC 8259), mais le test l'ignore. Il mesure « la réponse a-t-elle
   changé ? », pas « quelqu'un casse-t-il ? ».
2. **« Prochain tour : 0 »** : `encoding/json` laisse à sa valeur zéro un
   champ absent ou `null` dans une structure. L'application a déclaré
   `NextRound int` : elle ne peut pas distinguer « 0 » de « rien ». Un
   `*int` le pourrait.
3. **Les centimes** : un contrat de forme vérifie que `share_fcfa` est un
   nombre, et il l'est. Le sens (« des francs ») n'est écrit nulle part
   dans la forme : seul un exemple (« pour la tontine 1, 10 000 ») le
   fixe.

## 1.c — Le partenaire sans contrat

Le serveur ne sait rien de ce qu'il lit, et deux choses peuvent le lui
apprendre :

- **ses journaux** : quelles routes le partenaire appelle, avec quels
  paramètres. Cela dit ce qu'il **demande**, pas ce qu'il **lit** dans la
  réponse ;
- **lui demander** : lui proposer d'écrire son contrat, en lui
  fournissant le format et un exemple. Pour un partenaire important,
  c'est le serveur qui l'écrit avec lui, à partir de son code ou de ses
  écrans.

En attendant, le serveur applique la politique de l'exercice 4 :
uniquement des ajouts, et toute rupture annoncée longtemps à l'avance
(leçon 6.5).

## Ce qu'il faut retenir

- Un ajout ne casse que les lecteurs qui refusent l'inconnu.
- Un lecteur tolérant ne tolère que ce qu'il lit à part.
- Ce qui ne se voit pas dans la forme (sens, ordre) se fixe par un
  exemple.
