# Correction 6.2 — Exercice 1 : qui laisse passer quoi ?

> Rappel de l'énoncé : six corps à juger avec les trois façons de lire ;
> trois pourquoi ; un identifiant de 19 chiffres.

## En bref

- **La version 1 de `encoding/json` interprète**, la frontière refuse :
  un nom en capitales devient un second montant pour l'une, un champ
  inconnu pour l'autre.
- **Les pointeurs disent ce qui manque**, les champs non exportés
  garantissent ce qui est valide.
- **Un identifiant au-delà de 2⁵³** voyage en texte.

## 1.a — Six corps

Les six corps envoyés aux trois façons de lire (`cmd/ex1` du module de
correction), dans l'ordre : `decode only`, `hand checked`, `border`.

```text
201 201 400 201 201 201 
201 422 400 201 PANIC 201 
400 422 400 400 422 201 
```

| # | decode only | hand checked | border | Pourquoi |
|---|---|---|---|---|
| 1 | `201`, **1 FCFA** | `201`, **1 FCFA** | `400` | la version 1 fait correspondre `Amount_FCFA` à `amount_fcfa` sans la casse, et garde la dernière valeur. Pour la version 2, c'est un champ inconnu |
| 2 | `201`, montant 0 | `422` | `422`, « required » | sans pointeur, l'absence vaut zéro ; seul le contrôle à la main ou le pointeur le voit |
| 3 | `400` | `400` | `400` | un texte dans un `int64` : les deux versions refusent |
| 4 | `201` | `201` | `400` | `note` est inconnu. Si l'application veut envoyer une note, le type doit la prévoir |
| 5 | `201` | **coupure** (panique de `s[:4]`) | `422` | le texte a 2 octets |
| 6 | `201` | `201` | `201` | 3 Ko est sous la limite de 4 Ko : la limite borne la mémoire, elle ne juge pas le contenu |

## 1.b — Trois pourquoi

1. **Les pointeurs** : `ContributionRequest` décrit ce que le client a
   **envoyé**, et un champ absent n'est pas un zéro. `Contribution`
   décrit ce qui **est** : après `Parse`, chaque champ existe, et le
   pointeur n'aurait plus rien à dire.
2. **Le champ non exporté** : hors du paquet, `border.Phone{}` est la
   seule valeur qu'on puisse écrire sans `ParsePhone`, et elle est vide.
   On ne peut pas fabriquer un `Phone` qui contient `"+2376AB"`. Le
   compilateur garde la règle à la place des revues de code.
3. **Requête contre réponse** : une requête est un **ordre** (payer,
   retirer). Un champ inconnu y est presque toujours une faute (un nom
   mal écrit) et l'ignorer exécute un ordre différent de celui qui était
   voulu. Une réponse est une **information** que le client lit : un
   champ nouveau ajouté par le serveur ne doit pas casser les clients
   installés. Le serveur est strict sur ce qu'il exécute, le client
   tolérant sur ce qu'il lit.

## 1.c — L'identifiant de 19 chiffres

Le tableau de bord est en JavaScript : il lit les nombres JSON comme des
`float64`, exacts jusqu'à 2⁵³ (16 chiffres). Un identifiant de 19
chiffres est arrondi, et la réclamation part avec un identifiant voisin,
celui d'un autre transfert ou d'aucun. La leçon le mesure :
`1234567890123456789` devient `1234567890123456768`.

Le changement : envoyer l'identifiant en **texte** (`json:"id,string"`,
ou un type `string` dès le départ), et l'accepter en texte dans les
requêtes de réclamation. C'est une rupture du contrat pour les clients
qui le lisaient comme un nombre : la leçon 6.5 montre comment la
conduire.

## Ce qu'il faut retenir

- La version 1 de `encoding/json` choisit pour toi ; la version 2 refuse.
- Un pointeur pour ce qui peut manquer, un type sûr pour ce qui est
  valide.
- Strict sur ce qu'on exécute, tolérant sur ce qu'on lit.
