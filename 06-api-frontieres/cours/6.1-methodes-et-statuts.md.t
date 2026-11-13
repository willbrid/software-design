# Leçon 6.1 — Concevoir une API HTTP : des méthodes et des statuts qui disent quoi faire

## L'essentiel en deux minutes

**Le problème, en une phrase.** Une API n'est pas lue par des personnes,
mais par des programmes : une application mobile, un partenaire, un
proxy, un tableau de bord. Ces programmes ne lisent pas les messages
d'erreur, ils lisent la **méthode** et le **statut**, et ils décident
dessus : renvoyer la requête, abandonner, alerter.

**Trois images.**

- **Le feu tricolore** : un conducteur ne lit pas une explication, il
  lit une couleur. Un feu toujours vert avec un panneau « en fait,
  arrêtez-vous » provoque des accidents. Une API qui répond `200 OK`
  avec `{"ok": false}` dans le corps, c'est ce feu-là.
- **Le guichet qui dit « revenez dans une heure »** : on revient, et
  ça marche. Le guichet qui dit « ce formulaire est faux » : revenir ne
  sert à rien, il faut le corriger. Le client doit savoir lequel des
  deux il a entendu : c'est la différence entre `503` et `422`.
- **La lettre qu'on ouvre** : ouvrir une lettre ne doit pas signer le
  chèque qu'elle contient. Ouvrir un lien (un `GET`) ne doit rien
  changer : des robots ouvrent les liens avant les personnes.

**Le code, en quelques lignes.** Chaque erreur du domaine devient un
statut (ce que le client peut faire) et un type stable (laquelle) :

```go
    case errors.Is(err, tontine.ErrAlreadyPaid):
        return Problem{TypeAlreadyPaid, "Already paid for this round", http.StatusConflict, ""}
    case errors.Is(err, tontine.ErrUnavailable):
        return Problem{TypeUnavailable, "Temporarily unavailable", http.StatusServiceUnavailable, ""}
```

**Les règles à retenir.**

1. **La méthode dit ce que fait la requête** : `GET` lit et ne change
   rien ; `POST` crée ou déclenche. Un `GET` qui change quelque chose
   sera appelé par des robots.
2. **Le statut dit ce que le client peut faire ensuite** : `2xx` c'est
   fait ; `4xx` c'est ta requête, inutile de la renvoyer telle quelle ;
   `5xx` c'est le serveur, tu peux réessayer plus tard.
3. **Le corps d'erreur dit laquelle**, avec un `type` stable (RFC 9457) :
   le client décide sur le `type`, jamais sur le texte.
4. **Une erreur inattendue reste sur le serveur** : `500`, sans son
   texte, qui peut nommer une table ou une adresse.

La suite le mesure avec le même client envoyé sur trois API.

---

Le niveau 5 a protégé les données dans la base. Les requêtes qui les
modifient arrivent maintenant de l'extérieur : l'application mobile des
membres, l'écran des trésorières, demain un partenaire. Le problème de
cette leçon :

> **Comment une API dit-elle à un programme ce qui s'est passé, pour
> qu'il fasse la bonne chose sans qu'une personne lise le message ?**

Le module de la leçon est `l61`. Il n'a besoin que de la bibliothèque
standard : `net/http`, et `httptest` pour lancer de vrais serveurs HTTP
dans le processus. Tout ce qui suit est mesuré sur un module vert sous
`gofmt -l`, `go vet ./...` et `go test -race -count=1 ./...`.

## 1. Qui lit une réponse HTTP

Quand un membre paie sa cotisation, la réponse traverse plusieurs
programmes avant d'arriver à une personne, si elle y arrive :

| Qui | Ce qu'il lit | Ce qu'il décide |
|---|---|---|
| la bibliothèque HTTP de l'application | le statut | renvoyer la requête ou non |
| le répartiteur de charge, le proxy | le statut | retirer une instance malade, compter les erreurs |
| la supervision | le statut | déclencher une alerte la nuit |
| l'application | le statut, puis le `type` de l'erreur | afficher « déjà payé » ou « réessayez » |
| le membre | le message affiché | rien d'autre |

Le texte de l'erreur n'arrive qu'à la fin de la chaîne, et souvent
jamais. Tout ce qui décide avant lit des nombres.

## 2. L'API de la leçon

Le paquet `tontine` garde les cotisations en mémoire et ne connaît rien
de HTTP. Ses erreurs disent ce qui ne va pas : tontine inconnue, montant
qui n'est pas la part, personne qui n'est pas membre, tour déjà payé, et
`ErrUnavailable` quand le stockage ne répond pas.

Le paquet `httpapi` les traduit, **en un seul endroit** :

@@P:en/l61/httpapi/problem.go|// problemFor maps@@

Le statut répond à la question « que peut faire le client ? » :

- `404` : ce que tu vises n'existe pas ;
- `422` : ta requête est bien formée, mais le domaine la refuse ;
- `409` : elle est juste, mais l'état actuel l'empêche (le tour est déjà
  payé) ;
- `503` : réessaie plus tard, et `Retry-After` dit quand.

Le `type` répond à « laquelle ? ». C'est une URI stable, que
l'application compare pour choisir son message. Le format est celui de
la RFC 9457 (*Problem Details for HTTP APIs*), servi en
`application/problem+json`.

L'erreur inattendue est traitée à part :

@@P:en/l61/httpapi/problem.go|// writeError answers@@

La route dit la méthode et la ressource. Depuis Go 1.22, le routeur de
la bibliothèque standard comprend `"POST /tontines/{tontine}/contributions"`,
et `r.PathValue("tontine")` rend le segment :

@@P:en/l61/httpapi/api.go|// New returns@@

Une création répond `201 Created`, avec l'adresse de ce qui a été créé
dans `Location`. Le chemin nomme des **choses** (les cotisations d'une
tontine), pas des actions (`/payContribution`) : la méthode porte
l'action.

## 3. Mesure : le même client, trois façons de répondre

Le paquet `client` envoie les requêtes comme la plupart des
bibliothèques et des SDK : il regarde le statut, et renvoie la requête
quand le statut dit que l'échec est passager.

@@P:en/l61/client/client.go|// Retryable reports@@

Le programme `cmd/statuses` envoie 1 000 cotisations, avec ce client
(4 tentatives au plus), à trois API qui ne diffèrent que par leurs
réponses :

- **always 200** répond toujours `200`, avec `{"ok": false, "error": ...}`
  dans le corps en cas d'échec ;
- **always 500** répond `500` à toute erreur, avec son texte ;
- **lesson** est l'API de la section 2.

Les 1 000 cotisations : 700 justes, et 300 qui doivent être refusées
(100 mauvais montants, 100 inconnus, 100 deuxièmes paiements d'un tour).
Pendant la mesure, le stockage échoue au hasard **15 %** des appels,
sans rien écrire, comme une base qui ne répond pas un instant.

```text
always 200  recorded 603/700  refusals  247/300  sent 1000  monitoring: 2xx 1000  4xx   0  5xx   0
always 500  recorded 700/700  refusals 1035/300  sent 2019  monitoring: 2xx  700  4xx   0  5xx 1319
lesson      recorded 700/700  refusals  299/300  sent 1179  monitoring: 2xx  700  4xx 299  5xx 180
```

Ligne par ligne :

- **always 200** : **97 cotisations justes perdues**. Le stockage a
  échoué, l'API a répondu `200`, le client n'avait aucune raison de
  réessayer. Et la supervision voit **1 000 succès sur 1 000** : aucune
  alerte. Les membres découvrent le problème le jour du tour, quand
  leur cotisation n'apparaît pas.
- **always 500** : toutes les cotisations passent, puisque le client
  réessaie les `500`. Mais il réessaie **aussi** les refus : 1 035 refus
  calculés pour 300, et **2 019 requêtes** pour 1 000 demandes. La
  supervision voit 1 319 erreurs serveur : l'astreinte est réveillée
  parce que des membres se trompent de montant.
- **lesson** : 700 sur 700, 299 refus pour 300 (un refus a rencontré
  quatre pannes de suite, et le membre a lu « réessayez »). 1 179
  requêtes : les 1 000, plus 179 nouvelles tentatives **toutes dues à
  une vraie panne**. La supervision voit 180 erreurs serveur (les pannes)
  et 299 refus : chaque nombre mesure ce qu'il prétend mesurer.

Un statut faux ne casse rien de visible pendant les tests : chaque API
répond, chaque membre a un message. Il casse ce que les autres
programmes décident.

## 4. Mesure : le lien qui confirme tout seul

Une trésorière confirme un versement par un lien reçu par SMS ou par
WhatsApp. Première version : ouvrir le lien confirme.

```go
mux.HandleFunc("GET /payouts/{token}/confirm", p.confirm)
```

Les applications de messagerie ouvrent les liens **avant** la personne,
pour afficher un aperçu ; les antivirus de messagerie font de même.
`cmd/preview` envoie 100 liens et fait comme l'application : un `GET`
sur chacun, sans personne derrière.

```text
GET confirms   confirmed by the previews, before any tap: 100/100
POST confirms  confirmed by the previews, before any tap:   0/100
```

Les 100 versements sont partis avant que la trésorière ait lu un seul
message. C'est la raison d'être des méthodes **sûres** : la RFC 9110 dit
qu'elles existent pour que les robots (*spiders*) et le préchargement
(*pre-fetching*) puissent fonctionner « sans craindre de causer de
dommage ». Le serveur qui fait changer un `GET` casse cette promesse, et
les robots ne la vérifient pas.

La deuxième version montre une page, et confirme sur le bouton :

@@P:en/l61/httpapi/payout.go|// FormConfirms shows@@

Le lien ouvert affiche le versement ; c'est le `POST` du bouton qui le
confirme. Aucun robot n'envoie de `POST` en ouvrant un lien.

## 5. Ce que le routeur fait pour toi

`cmd/routes` envoie quelques requêtes directement au routeur :

```text
POST   /tontines/1/contributions   -> 201  Location: /tontines/1/contributions/1
       {"id":1,"tontine":1,"member":"awa","round":1,"amount_fcfa":10000}
POST   /tontines/1/contributions   -> 409
       {"type":"https://api.tontine.example/problems/already-paid","title":"Already paid for this round","status":409,"detail":"already paid for this round"}
POST   /tontines/1/contributions   -> 422
       {"type":"https://api.tontine.example/problems/bad-amount","title":"Amount is not the share","status":422,"detail":"amount is not the share of the tontine"}
POST   /tontines/1/contributions   -> 400
       {"type":"https://api.tontine.example/problems/malformed","title":"Malformed body","status":400,"detail":"unexpected EOF"}
DELETE /tontines/1/contributions   -> 405  Allow: POST
       Method Not Allowed
POST   /tontines/1/payContribution -> 404
       404 page not found
```

Le `DELETE` reçoit `405 Method Not Allowed` avec `Allow: POST`, sans une
ligne de code : la route déclare sa méthode, et le routeur en déduit le
reste. Le corps tronqué reçoit `400` : il n'est même pas du JSON. La
leçon 6.2 rendra ce décodage strict ; ici, il suffit qu'un corps illisible
ne devienne jamais une cotisation.

## 6. La campagne

Treize mutations, chacune une erreur plausible dans l'API ou dans le
client :

```text
déjà payé répondu 500                        tuee
indisponible répondu 500                     tuee
503 sans Retry-After                         tuee
Retry-After: 0                               SURVIT
texte de l'erreur 500 envoyé                 tuee
problème servi en application/json           tuee
201 sans Location                            tuee
création répondue 200                        tuee
route sans méthode                           tuee
le GET du formulaire confirme                tuee
409 renvoyé                                  tuee
une tentative de trop                        tuee
Retry-After ignoré                           tuee
12/13 tuees
```

La survivante, **`Retry-After: 0`**, a l'air inoffensive : le test
vérifiait que l'en-tête existe, pas sa valeur. Mais `0` dit à tous les
clients de revenir **tout de suite**. Quand le stockage tombe, chaque
client renvoie sa requête immédiatement, et le stockage qui peinait
reçoit d'un coup la charge multipliée par le nombre de tentatives.
C'est l'afflux de la leçon 5.6, déclenché par l'API elle-même. Le test
ajouté :

```go
    // Retry-After: 0 would send every client back at once, on a store that
    // is already failing.
    if s, err := strconv.Atoi(w.Header().Get("Retry-After")); err != nil || s < 1 {
        t.Errorf("Retry-After %q, want at least 1 second", w.Header().Get("Retry-After"))
    }
```

```text
déjà payé répondu 500                        tuee
indisponible répondu 500                     tuee
503 sans Retry-After                         tuee
Retry-After: 0                               tuee
texte de l'erreur 500 envoyé                 tuee
problème servi en application/json           tuee
201 sans Location                            tuee
création répondue 200                        tuee
route sans méthode                           tuee
le GET du formulaire confirme                tuee
409 renvoyé                                  tuee
une tentative de trop                        tuee
Retry-After ignoré                           tuee
13/13 tuees
```

## 7. La grille

| Ce qui s'est passé | Statut | Le client peut |
|---|---|---|
| créé | `201`, avec `Location` | lire la ressource à cette adresse |
| fait, rien à créer | `200` (avec un corps) ou `204` (sans) | continuer |
| corps illisible | `400` | corriger son code : renvoyer ne sert à rien |
| pas authentifié / pas le droit | `401` / `403` | se connecter / abandonner |
| la ressource n'existe pas | `404` | abandonner, ou vérifier l'adresse |
| mauvaise méthode | `405`, avec `Allow` | corriger son code |
| l'état actuel l'empêche (déjà payé, déjà clos) | `409` | relire l'état, puis décider |
| bien formé, refusé par le domaine | `422` | montrer l'erreur à la personne |
| trop de requêtes | `429`, avec `Retry-After` | attendre, puis réessayer |
| erreur inattendue | `500`, sans détail | réessayer peut-être, alerter |
| passager (base, dépendance) | `503`, avec `Retry-After` | attendre, puis réessayer |

## 8. Les trois erreurs qui restent

### « Le client lit le corps, le statut n'a pas d'importance »

**Ton** client lit peut-être le corps. Le proxy, la supervision, la
bibliothèque HTTP et le prochain partenaire lisent le statut. La
section 3 : 97 cotisations perdues et une supervision à 100 % de succès.

### « Une erreur est une erreur, `500` suffit »

Le client ne sait plus distinguer « réessaie » de « corrige ». Il
réessaie tout (2 019 requêtes au lieu de 1 179) ou rien (et perd les
pannes passagères). Et l'astreinte ne distingue plus une panne d'un
membre qui se trompe de montant.

### « Ce `GET` change peu de chose, ce n'est pas grave »

Un `GET` est ouvert par les aperçus, les antivirus, les préchargements
des navigateurs, les robots d'indexation et les caches. La section 4 :
100 versements sur 100. La règle ne souffre pas d'exception pour une
action qui compte.

## 9. Le lien avec la production

- **Les tableaux de bord** se construisent sur le statut : le taux de
  `5xx` dit la santé du **serveur**, le taux de `4xx` dit la qualité des
  **clients** (une nouvelle version de l'application qui envoie un
  mauvais montant). Ils ne servent que si les statuts sont justes.
- **Les répartiteurs de charge** retirent une instance qui répond trop
  de `5xx` : une API qui répond `500` aux erreurs des membres fait
  retirer des instances saines.
- **Les journaux** gardent le texte de l'erreur inattendue, avec un
  identifiant de requête ; la réponse ne garde que le statut et le
  `type`. Un `detail` qui contient `dial tcp 10.0.3.7:5432` donne
  l'architecture interne à qui le lit.
- **Les nouvelles tentatives** ne sont sûres que si refaire la requête
  ne la fait pas deux fois. Ici, le stockage échoue **avant** d'écrire.
  Quand la réponse se perd **après** l'écriture, c'est la leçon 6.3.

## 10. Ce qu'il faut retenir

1. Une réponse HTTP est lue d'abord par des programmes, qui décident
   sur la méthode et le statut.
2. `4xx` : la requête du client ; `5xx` : le serveur. Le client
   réessaie l'un et pas l'autre.
3. Un corps d'erreur au format RFC 9457 porte un `type` stable, sur
   lequel l'application décide.
4. `GET` ne change rien, parce que des robots l'appellent.
5. Les erreurs se traduisent en un seul endroit, et l'inattendu reste
   sur le serveur.

## 11. Approfondissement

### Une action est souvent une ressource

« Confirmer un versement » ressemble à une action. On peut aussi la
voir comme la création d'une **confirmation** :
`POST /payouts/{id}/confirmations`. La confirmation a alors une
adresse, une date, un auteur, et on peut la lire avec `GET`. Quand une
action a besoin d'être retrouvée ou auditée, en faire une ressource lui
donne tout cela.

### `PUT`, `PATCH` et `POST`

`PUT` remplace la ressource entière à une adresse connue du client, et
le refaire donne le même résultat : il est **idempotent** (RFC 9110). `PATCH`
modifie une partie. `POST` crée sous une adresse choisie par le serveur,
ou déclenche un traitement ; le refaire peut le faire deux fois. La
leçon 6.3 montre comment rendre un `POST` sûr à refaire.

### `404` ou `403` ?

Répondre `403` à « la cotisation 42 d'une autre tontine » apprend à
l'appelant qu'elle existe. Quand l'existence même est une information,
on répond `404` à qui n'a pas le droit de la voir.

## 12. Le réflexe à installer

Avant d'écrire un point d'entrée, demande-toi :

1. Cette requête change-t-elle quelque chose ? Si oui, ce n'est pas un
   `GET`.
2. Pour chaque erreur possible : est-ce la faute du client (`4xx`) ou du
   serveur (`5xx`) ? Le client doit-il réessayer ?
3. Quel `type` stable l'application comparera-t-elle ?
4. Que verra la supervision, et que doit-elle voir ?
5. Que révèle le corps d'une erreur inattendue ?

## Sources

- IETF, [RFC 9110 — HTTP Semantics](https://www.rfc-editor.org/rfc/rfc9110.html),
  section 9.2.1 : « The purpose of distinguishing between safe and
  unsafe methods is to allow automated retrieval processes (spiders)
  and cache performance optimization (pre-fetching) to work without fear
  of causing harm. » ; section 15.5.10 : « The 409 (Conflict) status code
  indicates that the request could not be completed due to a conflict
  with the current state of the target resource. » ; section 10.2.3 :
  « When sent with a 503 (Service Unavailable) response, Retry-After
  indicates how long the service is expected to be unavailable to the
  client. »
- IETF, [RFC 9457 — Problem Details for HTTP APIs](https://www.rfc-editor.org/rfc/rfc9457.html) :
  « Consumers MUST use the "type" URI (after resolution, if necessary)
  as the problem type's primary identifier. » et « Consumers SHOULD NOT
  parse the "detail" member for information ».
- Go, [package net/http](https://pkg.go.dev/net/http), `ServeMux` :
  « Patterns can match the method, host and path of a request. »
- Go blog, [Routing Enhancements for Go 1.22](https://go.dev/blog/routing-enhancements) :
  « a net/http server will reply to such a request with a 405 Method Not
  Allowed error that lists the available methods in an Allow header. »

---

➡️ Exercices : [6.1-exercices.md](../exercices/6.1-exercices.md)
