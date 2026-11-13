# Leçon 6.6 — L'écran et l'API : écrire à deux, relire pour rien, attendre le réseau

## L'essentiel en deux minutes

**Le problème, en une phrase.** Un écran n'est pas un programme qui
appelle l'API une fois : il lit, laisse une personne réfléchir, puis
écrit ce qu'elle a changé ; il se rafraîchit toutes les trente secondes ;
il assemble une page à partir de dix réponses, sur un réseau mobile où
chaque aller-retour coûte un tiers de seconde.

**Trois images.**

- **Le cahier de la tontine** : deux trésorières recopient chacune la
  page, la corrigent chez elles, puis la recollent dans le cahier. La
  seconde efface la correction de la première sans le savoir. Il
  suffisait de numéroter les pages : « je corrige la page 7 », et si le
  cahier en est à la page 8, on relit d'abord.
- **« Rien de neuf »** : à celle qui demande toutes les cinq minutes si le
  règlement a changé, on répond « non, toujours la version 7 », au lieu
  de lui relire tout le règlement.
- **Le coursier** : plutôt que d'envoyer le membre faire huit guichets au
  bout d'une route lente, on envoie un coursier qui fait les huit
  guichets à côté, et rapporte une seule enveloppe.

**Le code, en quelques lignes.** Une écriture dit quelle version elle a
lue ; le serveur refuse si la version a changé :

```go
        v, ok := s.Put(rules, read)
        if !ok {
            w.Header().Set("ETag", ETag(v))
            problem(w, http.StatusPreconditionFailed, "stale", "the rules changed since you read them: read them again")
            return
        }
```

**Les règles à retenir.**

1. **Lire, modifier, réécrire depuis un écran perd des modifications**,
   comme dans la base (leçon 5.3) : l'écran envoie la version qu'il a lue
   dans `If-Match`, et le serveur répond `412` si elle a changé.
2. **Un serveur qui l'exige répond `428`** à une écriture sans `If-Match`.
3. **Un écran qui relit envoie `If-None-Match`** : `304`, sans corps,
   quand rien n'a changé.
4. **Sur un réseau mobile, on compte les allers-retours**, pas les
   octets : huit appels l'un après l'autre coûtent huit fois la latence.
5. **Un point d'entrée fait pour l'écran (BFF)** fait les appels à côté
   de l'API, et ne renvoie que ce que l'écran affiche.

La suite le mesure avec deux trésorières, un écran qui se rafraîchit, et
l'écran d'accueil d'un membre sur 3G.

---

Les leçons 6.1 à 6.5 ont regardé l'API depuis le serveur, et depuis des
programmes clients. Cette dernière leçon du niveau la regarde depuis
l'**écran**, avec une personne devant et un réseau mobile entre les deux.
Le problème :

> **Que doit offrir l'API pour qu'un écran ne perde pas de modifications,
> ne relise pas pour rien, et ne fasse pas attendre son utilisatrice ?**

Le module de la leçon est `l66`. Il n'a besoin que de la bibliothèque
standard. Tout ce qui suit est mesuré sur un module vert sous
`gofmt -l`, `go vet ./...` et `go test -race -count=1 ./...`.

## 1. Deux trésorières, un règlement

Le paquet `rules` sert le règlement d'une tontine : la part, la pénalité
par jour, l'ordre de passage, le jour de réunion. Le stockage garde une
**version**, qui augmente à chaque changement :

@@P:en/l66/rules/rules.go|// Put replaces@@

La version voyage dans l'en-tête `ETag`, entre guillemets comme le veut
la RFC 9110 :

@@P:en/l66/rules/rules.go|// ETag is the entity tag@@

L'écran d'une trésorière lit le règlement, la laisse changer une chose,
et renvoie le règlement entier. S'il reçoit `412`, il relit, et
réapplique **le même changement** sur la version fraîche :

@@P:en/l66/rules/screen.go|// Edit applies@@

Le gestionnaire du `PUT` sert les deux façons : sans condition (le
dernier qui écrit gagne), ou avec `If-Match` :

@@P:en/l66/rules/rules.go|// Handler serves@@

## 2. Mesure : la modification perdue

`cmd/lostedit` fait 200 fois la même scène : une trésorière passe la part
à 12 500 FCFA, l'autre la pénalité à 1 000 FCFA par jour. Chacune ouvre
l'écran à un moment tiré au hasard dans les 100 ms de l'autre, et le
regarde jusqu'à 20 ms avant d'enregistrer. Deux changements **différents**,
qui ne se contredisent pas :

```text
last one wins  a change lost in  40 of 200 pairs of edits  412 answered   0 times  edits refused in the end 0
If-Match       a change lost in   0 of 200 pairs of edits  412 answered  43 times  edits refused in the end 0
```

- **Sans condition, une modification sur deux est perdue dans 40 scènes
  sur 200** : chaque fois que les deux écrans ont lu avant que l'un
  n'écrive. Celle qui enregistre en second renvoie l'ancienne part avec
  sa nouvelle pénalité, et efface la part de sa collègue. Aucune ne
  reçoit d'erreur.
- **Avec `If-Match`, aucune perte**. Le serveur a répondu `412` 43 fois ;
  chaque fois, l'écran a relu et réappliqué son changement. Les deux
  changements sont dans le règlement final.

La RFC 9110 nomme ce problème : les préconditions servent à éviter le
« *lost update* ». C'est la mise à jour perdue de la leçon 5.3, à
l'échelle d'un écran : la transaction ne peut rien pour elle, puisque la
lecture et l'écriture sont deux requêtes séparées de plusieurs secondes,
ou de plusieurs minutes quand une personne réfléchit.

Le réflexe de l'écran compte autant que le serveur : ici, il réapplique
un changement simple sur la version fraîche. Quand les deux trésorières
ont changé **le même** champ, réappliquer écraserait l'autre en
connaissance de cause ; l'écran doit alors montrer les deux valeurs et
laisser choisir.

## 3. Mesure : relire pour rien

`cmd/poll` fait lire le règlement d'une tontine de 60 membres 1 000 fois,
comme un écran qui se rafraîchit toutes les trente secondes pendant huit
heures ; le règlement change trois fois dans la journée :

```text
no If-None-Match  200: 1000  304:    0  bytes of body received: 1054000
If-None-Match     200:    4  304:  996  bytes of body received:    4216
```

Avec `If-None-Match`, le serveur répond **`304` 996 fois**, sans corps :
4 216 octets reçus au lieu de 1 054 000, **250 fois moins**. Le
téléphone ne reçoit le règlement que quatre fois : la première, et après
chacun des trois changements. Sur un forfait de données de quelques
centaines de mégaoctets par mois, la différence se voit sur la facture du
membre.

Le `304` n'économise pas d'aller-retour : la question part quand même.
Il économise la réponse, et le travail de l'écran qui la redessine.

## 4. Mesure : l'écran d'accueil sur 3G

L'écran d'accueil d'un membre affiche son nom, et pour chacune de ses
trois tontines la date du prochain tour, le bénéficiaire, et ce qu'il
doit. L'API de la leçon est fine : une ressource par point d'entrée
(le membre, ses tontines, le prochain tour d'une tontine, son solde),
comme les leçons précédentes l'ont construite.

Trois façons de construire l'écran :

@@P:en/l66/home/screen.go|// OneByOne builds@@

@@P:en/l66/home/screen.go|// InWaves builds@@

La troisième est un **point d'entrée fait pour cet écran**, placé à côté
de l'API : il fait les mêmes appels, là où un aller-retour coûte une
milliseconde, et renvoie seulement ce que l'écran affiche. Sam Newman
appelle ce point d'entrée un *Backend For Frontend* (BFF) : un serveur
par expérience utilisateur, maintenu par l'équipe de l'écran.

@@P:en/l66/home/screen.go|// BFF serves@@

Le paquet `slow` ajoute à chaque requête la durée d'un aller-retour :
300 ms pour la 3G, 50 ms pour la 4G. `cmd/homescreen` :

```text
RTT 300ms  one by one   8 requests from the phone    2592 bytes  2.433s
RTT 300ms  in waves     8 requests from the phone    2592 bytes  609ms
RTT 300ms  via the BFF  1 requests from the phone     322 bytes  313ms
RTT 50ms   one by one   8 requests from the phone    2592 bytes  430ms
RTT 50ms   in waves     8 requests from the phone    2592 bytes  108ms
RTT 50ms   via the BFF  1 requests from the phone     322 bytes  60ms
```

- **Un par un, sur 3G : 2,4 secondes** pour afficher l'accueil. Huit
  allers-retours de 300 ms, l'un après l'autre. Le temps de travail de
  l'API (2 ms par appel) ne compte presque pas.
- **En deux vagues : 609 ms**. Les appels qui ne dépendent pas l'un de
  l'autre partent ensemble : deux allers-retours au lieu de huit.
- **Par le BFF : 313 ms**, un seul aller-retour depuis le téléphone, et
  **322 octets** au lieu de 2 592 : le règlement des tontines, l'adresse
  du membre et l'historique des soldes ne quittent pas le centre de
  données.

Une limite du modèle : `slow` compte un aller-retour par requête, sur une
connexion déjà ouverte. Une vraie connexion mobile ajoute l'ouverture de
la connexion et la négociation TLS, plusieurs allers-retours de plus, et
la bande passante limite les requêtes parallèles. Le classement des
trois façons ne change pas ; les écarts grandissent.

## 5. La campagne

Dix mutations, dans les préconditions, l'écran et le BFF :

```text
If-None-Match ignoré                         tuee
If-Match facultatif                          tuee
version jamais comparée                      tuee
412 sans l'ETag courant                      tuee
version jamais augmentée                     tuee
ETag sans guillemets                         tuee
Get rend la liste partagée                   tuee
l'écran ne relit pas après 412               tuee
BFF : mauvais champ                          tuee
BFF : nom oublié                             tuee
10/10 tuees
```

Aucune survivante. Deux tests méritent d'être lus, parce qu'ils
vérifient ce que les mesures montrent :

@@P:en/l66/rules/rules_test.go|func TestTwoScreensKeepBothChanges@@

Le second cas vérifie que le test **fait vraiment se chevaucher** les
deux écritures : sans lui, un test qui passerait sans condition ne
prouverait rien pour `If-Match`.

@@P:en/l66/rules/rules_test.go|func TestGetReturnsACopy@@

`Get` rend une copie de l'ordre de passage : sans elle, un écran (ou un
gestionnaire) qui trie la liste pour l'afficher modifierait le règlement
du stockage, sans verrou et sans version.

## 6. La grille

| L'écran… | L'API offre | Statut |
|---|---|---|
| lit pour modifier | `ETag` dans la réponse | `200` |
| écrit ce qu'il a lu | `If-Match` exigé | `200`, `412` si la version a changé, `428` sans `If-Match` |
| se rafraîchit | `If-None-Match` | `304` sans corps si rien n'a changé |
| assemble plusieurs ressources | des appels indépendants, envoyés ensemble | — |
| a besoin d'une page entière, vite, sur mobile | un BFF pour cet écran | un seul aller-retour |
| défile une longue liste | un curseur (leçon 5.5) | — |

## 7. Les trois erreurs qui restent

### « Deux personnes ne modifient jamais en même temps »

La mesure en trouve 40 sur 200 avec des fenêtres de 100 ms. Une vraie
trésorière laisse l'écran ouvert des minutes, pendant la réunion, pendant
qu'on lui parle : la fenêtre est des milliers de fois plus grande. Et
personne ne voit l'erreur : la modification disparaît, c'est tout.

### « Le BFF, c'est une couche de plus »

Oui, et elle a un coût : un serveur à déployer, une équipe qui le
maintient, et la tentation d'y mettre des règles métier. Elle se justifie
par une mesure : 2,4 s contre 0,3 s sur 3G pour l'écran le plus ouvert de
l'application. Les règles, elles, restent derrière, dans l'API : le BFF
assemble et met en forme, il ne décide pas.

### « Il suffit d'envoyer les appels en parallèle »

Les vagues ramènent 2,4 s à 0,6 s, et c'est souvent le premier pas, sans
nouveau serveur. Mais l'écran reçoit toujours 2 592 octets pour en
afficher 322, et chaque nouvelle information sur l'accueil ajoute un
appel. Le BFF garde l'écran à un aller-retour quoi qu'on y ajoute.

## 8. Le lien avec la production

- **`If-Match` sur toutes les écritures d'une ressource éditée par des
  personnes** : le règlement, la liste des membres, l'ordre de passage.
  Le serveur répond `428` aux écritures sans condition, ce qui force les
  nouveaux écrans à la prévoir.
- **Les `412` se comptent** : un taux qui monte dit que des personnes se
  marchent dessus sur une ressource, et qu'il faut peut-être la découper
  (une ressource par champ éditable, ou des actions au lieu d'un `PUT`
  du tout).
- **Les caches et les CDN** comprennent `ETag` et `304` : la même
  précondition sert l'écran et les intermédiaires.
- **Le BFF se mesure côté téléphone** : le temps d'affichage de l'écran,
  par type de réseau, est la métrique qui le justifie et qui dit s'il
  faut en créer un pour l'écran suivant.

## 9. Ce qu'il faut retenir

1. Un écran qui lit puis réécrit perd des modifications ; `If-Match` et
   `412` les protègent.
2. `428` oblige les clients à envoyer `If-Match`.
3. `If-None-Match` et `304` évitent de renvoyer ce qui n'a pas changé.
4. Sur mobile, on compte les allers-retours : en parallèle d'abord, un
   BFF quand l'écran le mérite.
5. Le BFF assemble ; les règles restent dans l'API.

## 10. Approfondissement

### Des actions plutôt qu'un `PUT` du tout

Les deux trésorières ne voulaient pas « remplacer le règlement », mais
« changer la part » et « changer la pénalité ». Une API qui offre
`PATCH /rules` avec seulement le champ changé, ou des actions
(`POST /rules/share`), supprime le conflit entre deux changements qui ne
se touchent pas, et garde `If-Match` pour ceux qui se touchent.

### GraphQL et les BFF

GraphQL laisse l'écran décrire, dans une seule requête, les champs dont
il a besoin : c'est une autre réponse au même problème d'allers-retours
et d'octets. Il déplace le travail du BFF vers une couche générique, au
prix de requêtes plus difficiles à mettre en cache et à limiter.

## 11. Le réflexe à installer

Devant chaque écran, demande-toi :

1. Lit-il pour réécrire ? Envoie-t-il la version qu'il a lue ?
2. Que fait-il d'un `412` : relire et réappliquer, ou montrer le
   conflit ?
3. Se rafraîchit-il ? Envoie-t-il `If-None-Match` ?
4. Combien d'allers-retours pour l'afficher, et lesquels peuvent partir
   ensemble ?
5. Combien de temps sur 3G, et combien d'octets pour ce qu'il affiche ?

## Sources

- IETF, [RFC 9110 — HTTP Semantics](https://www.rfc-editor.org/rfc/rfc9110.html),
  section 13.1.1 : « The "If-Match" header field makes the request
  method conditional on the recipient origin server [...] having a
  current representation of the target resource that has an entity tag
  matching a member of the list » ; section 15.5.13 : « The 412
  (Precondition Failed) status code indicates that one or more
  conditions given in the request header fields evaluated to false when
  tested on the server » ; section 15.4.5 : « there is no need for the
  server to transfer a representation of the target resource ».
- IETF, [RFC 6585 — Additional HTTP Status Codes](https://www.rfc-editor.org/rfc/rfc6585.html) :
  « The 428 status code indicates that the origin server requires the
  request to be conditional. Its typical use is to avoid the "lost
  update" problem ».
- Sam Newman, [Pattern: Backends For Frontends](https://samnewman.io/patterns/architectural/bff/) :
  « rather than have a general-purpose API backend, instead you have one
  backend per user experience » ; « The BFF is tightly coupled to a
  specific user experience, and will typically be maintained by the
  same team as the user interface ».

---

➡️ Exercices : [6.6-exercices.md](../exercices/6.6-exercices.md)
