# Correction 6.1 — Exercice 1 : quel statut, et que fait le client ?

> Rappel de l'énoncé : huit situations à traduire en statut ; trois
> pourquoi ; un tableau de bord qui ne voit rien.

## En bref

- **Le statut dit ce que le client peut faire** : `4xx`, corriger ;
  `5xx`, réessayer plus tard.
- **Un statut faux ne casse aucun affichage**, il casse les décisions
  des programmes qui le lisent.
- **Une supervision sans erreur ne prouve rien** si l'API répond `200`
  aux échecs.

## 1.a — Huit situations

| # | Statut | Le client de la leçon renvoie ? |
|---|---|---|
| 1 | `201 Created`, avec `Location` | non |
| 2 | `422`, type `bad-amount` | non : la même requête aura la même réponse |
| 3 | `409`, type `already-paid` | non |
| 4 | `503`, avec `Retry-After` | **oui**, après le délai annoncé |
| 5 | `400`, type `malformed` | non : c'est un défaut du code client |
| 6 | `405`, avec `Allow: POST` (le routeur le fait seul) | non |
| 7 | `500`, sans détail ; le texte part dans le journal | **oui** : le client ne sait pas si c'est passager. C'est pourquoi un refus ne doit jamais devenir un `500` |
| 8 | `404` | non. `403` dirait que la cotisation existe |

## 1.b — Trois pourquoi

1. **« always 200 »** : quand le stockage échoue, l'API répond `200`
   avec `"ok": false`. Le client décide sur le statut : rien à
   réessayer. 97 cotisations sur 700 sont restées sur le téléphone, qui a
   affiché une erreur que le membre n'a peut-être pas lue.
2. **« always 500 »** : le client renvoie les `500`, ce qui sauve les
   pannes passagères, mais aussi les 300 refus, qui reçoivent chacun
   quatre fois la même réponse : 1 035 refus calculés pour 300, et 2 019
   requêtes au lieu de 1 179.
3. **Le texte d'une erreur inattendue** décrit l'intérieur du système :
   une adresse (`10.0.3.7:5432`), un nom de table, une requête SQL. Il
   aide un attaquant et ne sert à aucun client, qui ne peut rien en
   faire. Il va dans le journal, avec un identifiant de requête que la
   réponse peut porter.

## 1.c — Lire la supervision

Deux explications :

- l'API répond `200` à des échecs (la ligne « always 200 » de la
  leçon) : la supervision compte des succès qui n'en sont pas ;
- les requêtes n'arrivent pas jusqu'à l'API (réseau mobile, DNS, un
  proxy en amont qui répond lui-même) : la supervision ne compte que ce
  qui l'atteint.

La question qui tranche : **« combien de cotisations ont été
enregistrées dans la base pendant cette heure, comparé aux requêtes
`POST` comptées ? »** Si les deux sont égaux, les requêtes manquantes ne
sont jamais arrivées ; si la base en a moins, l'API répond `200` à des
échecs.

## Ce qu'il faut retenir

- Le client décide sur le statut ; le `type` dit lequel des refus.
- `500` veut dire « je ne sais pas » : le client réessaie.
- Une supervision se vérifie contre une autre source : la base, le
  nombre de cotisations attendues.
