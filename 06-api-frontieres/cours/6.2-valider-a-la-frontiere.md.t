# Leçon 6.2 — Valider à la frontière : décoder strictement, puis transformer en types sûrs

## L'essentiel en deux minutes

**Le problème, en une phrase.** Tout ce qui arrive par le réseau a été
écrit par un programme que tu ne contrôles pas : une vieille version de
l'application, un script de partenaire, une personne qui teste tes
limites. Si la frontière laisse entrer une valeur fausse, chaque ligne
de code derrière doit s'en méfier, et une seule qui oublie suffit.

**Trois images.**

- **Le guichet de la banque** : le guichetier vérifie la pièce
  d'identité et le bordereau **avant** que l'argent n'entre dans le
  coffre. Derrière le guichet, personne ne revérifie.
- **Le bordereau illisible** : un chiffre raturé, deux montants
  différents sur la même ligne. Le bon guichetier ne choisit pas celui
  qui l'arrange : il refuse le bordereau.
- **Le colis trop gros** : on regarde la taille avant d'ouvrir. Un
  guichet qui accepte de déballer n'importe quoi peut être bloqué par un
  seul client.

**Le code, en quelques lignes.** La frontière lit au plus quelques
kilo-octets, refuse tout JSON ambigu, puis transforme chaque champ en un
type qui ne peut pas contenir de valeur fausse :

```go
    body := http.MaxBytesReader(w, r.Body, limit)
    err := json.UnmarshalRead(body, dst, json.RejectUnknownMembers(true))
```

**Les règles à retenir.**

1. **Limiter la taille** avant de lire : une cotisation fait une
   centaine d'octets.
2. **Décoder strictement** : pas de champ inconnu, pas de nom en double,
   pas de casse approximative, pas de second objet. Un JSON ambigu est
   refusé, pas interprété.
3. **Transformer, pas seulement vérifier** : le corps devient un type du
   domaine (`Phone`, `Amount`) qu'on ne peut construire que valide. Le
   code derrière la frontière n'a plus rien à vérifier.
4. **Dire toutes les erreurs d'un coup**, champ par champ, en `422`.
5. **Laisser un fuzzer chercher** ce que les tests écrits à la main
   n'imaginent pas.

La suite le mesure avec dix-huit corps, dont seize faux, envoyés à trois
façons de lire.

---

La leçon 6.1 a donné à chaque erreur son statut. Elle laissait le
décodage tel quel : `json.NewDecoder(r.Body).Decode(&req)`, puis le
stockage vérifiait le montant. Le problème de cette leçon :

> **Où vérifier ce qui arrive de l'extérieur, et comment être sûr que
> rien de faux ne passe ?**

Le module de la leçon est `l62`. Il n'a besoin que de la bibliothèque
standard, dont `encoding/json/v2`, nouveau en Go 1.27. Tout ce qui suit
est mesuré sur un module vert sous `gofmt -l`, `go vet ./...` et
`go test -race -count=1 ./...`.

## 1. Deux façons courantes de lire une cotisation

Une cotisation arrive avec un numéro de téléphone Mobile Money, un tour
et un montant. Le paquet `naive` la lit comme le fait souvent une
première version :

- **decode only** décode le corps avec `encoding/json`, et lui fait
  confiance ;
- **hand checked** décode de même, puis vérifie chaque champ à la main
  (`if req.AmountFCFA <= 0`) et répond la première erreur.

La vérification du téléphone, dans `hand checked` :

@@P:en/l62/naive/naive.go|// NormalizePhone returns@@

## 2. La frontière de la leçon

### Décoder : un seul objet, sans ambiguïté, de taille bornée

@@P:en/l62/border/decode.go|// Decode reads@@

Trois protections en quatre lignes :

- `http.MaxBytesReader` coupe la lecture au-delà de `limit` octets ;
- `encoding/json/v2` refuse par défaut ce que la version 1 accepte sans
  rien dire : un nom présent deux fois, un nom qui ne diffère que par la
  casse, de l'UTF-8 invalide, et tout ce qui suit l'objet ;
- `RejectUnknownMembers(true)` refuse un champ que le type ne connaît
  pas : une faute de frappe dans un nom devient une erreur, et non un
  champ vide.

### Transformer : des types qu'on ne peut construire que valides

Le corps tel que le client l'envoie, avec des pointeurs pour distinguer
« absent » de « zéro » :

@@P:en/l62/border/contribution.go|// ContributionRequest is@@

Et ce que le reste du code reçoit :

@@P:en/l62/border/contribution.go|// Contribution is a contribution@@

`Phone` et `Amount` ont leurs champs non exportés : hors du paquet, la
seule façon d'en obtenir un est de passer par `ParsePhone` ou
`ParseAmount`. Un `Phone` existe, donc il est valide. C'est l'idée que
résume Alexis King dans *Parse, don't validate* : un analyseur
(*parser*) prend une entrée peu structurée et rend une sortie plus
structurée. La vérification n'est pas faite puis oubliée : elle est
**inscrite dans le type**.

@@P:en/l62/border/contribution.go|// ParsePhone accepts@@

`Parse` rassemble toutes les erreurs avant de répondre :

@@P:en/l62/border/contribution.go|// Parse turns@@

Le gestionnaire enchaîne les deux. Rien après `Parse` ne voit une
requête qui n'est pas une cotisation valide :

@@P:en/l62/border/handler.go|// Handler serves@@

## 3. Mesure : dix-huit corps, trois façons de lire

`cmd/corpus` envoie, à un vrai serveur HTTP pour chaque façon de lire,
deux corps justes et seize faux. « in » veut dire accepté, ✗ marque une
erreur de la frontière.

```text
                      decode only   hand checked  border        
right                 in            in            in            
right, with spaces    in            in            in            
typo in a name        in ✗          422           400           
name twice            in ✗          in ✗          400           
names in capitals     in ✗          in ✗          400           
a second object after in ✗          in ✗          400           
round missing         in ✗          422           422           
amount null           in ✗          422           422           
amount negative       in ✗          422           422           
amount with decimals  400           400           400           
amount absurd         in ✗          in ✗          422           
round absurd          in ✗          in ✗          422           
phone too short       in ✗          PANIC         422           
phone with letters    in ✗          in ✗          422           
phone not mobile      in ✗          in ✗          422           
invalid UTF-8         in ✗          422           400           
an array              400           400           400           
8 KB of spaces        in ✗          in ✗          413           
wrong ones let in     14/16         8/16          0/16          
```

- **decode only** laisse entrer **14 corps faux sur 16**. Les deux
  seuls refus viennent du décodeur lui-même : un nombre décimal dans un
  `int64`, un tableau au lieu d'un objet.
- **hand checked** en laisse entrer **8**. Les vérifications à la main
  attrapent les valeurs manquantes et négatives, mais pas :
  - **le nom en double** : `encoding/json` garde la dernière valeur, ici
    `1` FCFA. Un proxy ou un autre service qui lit la première verrait
    10 000 : deux programmes lisent deux montants différents dans le même
    corps ;
  - **les noms en capitales** : la version 1 les fait correspondre sans
    tenir compte de la casse ;
  - **le second objet** : `Decoder.Decode` lit le premier et ignore le
    reste ;
  - **les valeurs absurdes** : 90 milliards de FCFA, le tour 4 000, un
    fixe à la place d'un mobile, des lettres dans le numéro. La
    vérification « positif » n'est pas la règle du domaine ;
  - **les 8 Ko d'espaces** : un JSON valide, mais 80 fois la taille d'une
    vraie cotisation, que rien ne limite.
- **hand checked** a aussi une ligne **PANIC** : `"phone":"677"` a trois
  caractères, et `s[:4]` sort du texte. Le serveur HTTP de Go rattrape
  la panique et coupe la connexion ; le client ne reçoit rien.
- **border** les refuse tous : `400` pour ce qui n'est pas un JSON sans
  ambiguïté, `413` pour la taille, `422` pour les valeurs.

Une remarque sur la faute de frappe (`"amount"` au lieu de
`"amount_fcfa"`) : `hand checked` la refuse quand même, parce que le
montant manquant vaut zéro et que zéro n'est pas positif. Avec une règle
« montant facultatif, 0 par défaut », elle passerait. La frontière la
refuse **pour la bonne raison** : un champ inconnu.

## 4. Mesure : le corps de 16 Mo

`cmd/bigbody` envoie dix cotisations valides **en même temps**, chacune
gonflée à 16 Mo d'espaces, et mesure la mémoire du serveur pendant la
lecture :

```text
decode only   statuses [201 201 201]   222ms  server heap above the start:  393 MB
border        statuses [413 413 413]     4ms  server heap above the start:    1 MB
```

Le décodeur de la version 1 garde en mémoire la valeur entière avant de
la décoder : 160 Mo envoyés, **393 Mo** occupés côté serveur, parce que
son tampon double à mesure qu'il grandit : près de 40 Mo par requête. Un conteneur limité à 1 Go
s'arrête avec environ 25 de ces requêtes simultanées. Avec `MaxBytesReader`, la
lecture s'arrête au quatrième kilo-octet : **1 Mo**, et la réponse
`413` part en 4 ms.

La documentation de `MaxBytesReader` dit exactement ce cas : il
empêche les clients d'envoyer, « par accident ou par malveillance », une
requête trop grosse qui gaspille les ressources du serveur.

## 5. Mesure : ce que le fuzzer trouve

Les tests écrits à la main ne contiennent que les cas auxquels on a
pensé. Le *fuzzing* de Go génère des entrées, guidé par la couverture du
code, et signale celles qui font échouer le test. Un test de fuzzing
pour la fonction naïve tient en quelques lignes :

```go
func FuzzNormalizePhone(f *testing.F) {
    f.Add("+237677123456")
    f.Fuzz(func(t *testing.T, s string) {
        NormalizePhone(s)
    })
}
```

`go test -fuzz=FuzzNormalizePhone ./naive` :

```text
fuzz: elapsed: 0s, gathering baseline coverage: 0/1 completed
fuzz: elapsed: 0s, gathering baseline coverage: 1/1 completed, now fuzzing with 8 workers
fuzz: elapsed: 0s, execs: 17 (397/sec), new interesting: 0 (total: 1)
--- FAIL: FuzzNormalizePhone (0.04s)
    --- FAIL: FuzzNormalizePhone (0.00s)
        testing.go:2078: panic: runtime error: slice bounds out of range [:4] with length 1
[...]
    Failing input written to testdata/fuzz/FuzzNormalizePhone/771e938e4458e983
```

**Dix-sept exécutions, quatre centièmes de seconde** : l'entrée `"0"`
fait paniquer la fonction. Le fichier écrit dans `testdata/fuzz/` est
rejoué ensuite par chaque `go test` : le cas trouvé devient un test
permanent.

Pour la frontière, le test vérifie une **propriété** : tout numéro
accepté a 13 caractères, commence par `+2376`, ne contient que des
chiffres, et se relit lui-même.

@@P:en/l62/border/border_test.go|func FuzzParsePhone@@

Trente secondes :

```text
fuzz: elapsed: 30s, execs: 1583400 (38089/sec), new interesting: 13 (total: 18)
fuzz: elapsed: 30s, execs: 1583400 (0/sec), new interesting: 13 (total: 18)
PASS
ok      example/border62/border 30.128s
```

Un million et demi d'entrées, aucune ne casse la propriété. Ce n'est
pas une preuve, mais c'est plus que les dix cas de `TestPhones`.

## 6. Les grands nombres et JavaScript

La frontière va dans les deux sens : ce que l'API **envoie** est lu
par d'autres programmes. Un navigateur lit les nombres JSON comme des
`float64`, le seul type numérique de JavaScript. Au-delà de 2⁵³, un
entier n'y tient plus exactement. `cmd/bigid` envoie des identifiants
de transfert Mobile Money sur 64 bits, et les relit comme le ferait
JavaScript :

```text
sent {"id":9007199254740993}  read by JavaScript as 9007199254740992  same: false  as a string: {"id":"9007199254740993"}
sent {"id":9007199254740995}  read by JavaScript as 9007199254740996  same: false  as a string: {"id":"9007199254740995"}
sent {"id":1234567890123456789}  read by JavaScript as 1234567890123456768  same: false  as a string: {"id":"1234567890123456789"}
```

L'écran affiche un identifiant voisin, et une réclamation envoyée avec
cet identifiant vise **un autre transfert**. La RFC 8259 prévient : on
n'obtient une bonne interopérabilité qu'en n'attendant pas plus de
précision que celle des `float64`. L'option `,string` envoie
l'identifiant en texte, que chaque client lit exactement. Les montants
en FCFA, eux, restent loin de 2⁵³.

## 7. La campagne

Treize mutations de la frontière :

```text
membres inconnus acceptés                    tuee
noms sans la casse                           tuee
limite multipliée par 1024                   tuee
trop gros répondu 400                        tuee
numéro fixe accepté                          tuee
lettres acceptées                            tuee
pas de plafond                               tuee
zéro accepté                                 tuee
tour sans plafond                            SURVIT
seulement la première erreur                 tuee
montant absent lu comme zéro                 SURVIT
numéro sans indicatif                        tuee
refus sans return                            tuee
11/13 tuees
```

Deux survivantes :

- **le tour sans plafond** : aucun test n'envoyait un tour au-delà de
  60. Le tour 4 000 aurait été accepté, et aurait ouvert une ligne
  absurde dans le calendrier de la tontine ;
- **le montant absent lu comme zéro** : la requête est toujours refusée,
  mais avec « doit être entre 1 et 5 000 000 » au lieu de « requis ».
  Le développeur de l'application cherche alors une erreur de valeur, et
  non le champ qu'il a oublié d'envoyer.

Les tests ajoutés :

@@P:en/l62/border/border_test.go|// A missing amount is not@@

@@P:en/l62/border/border_test.go|func TestRounds@@

```text
membres inconnus acceptés                    tuee
noms sans la casse                           tuee
limite multipliée par 1024                   tuee
trop gros répondu 400                        tuee
numéro fixe accepté                          tuee
lettres acceptées                            tuee
pas de plafond                               tuee
zéro accepté                                 tuee
tour sans plafond                            tuee
seulement la première erreur                 tuee
montant absent lu comme zéro                 tuee
numéro sans indicatif                        tuee
refus sans return                            tuee
13/13 tuees
```

## 8. La grille

| Ce qui arrive | Où le refuser | Statut |
|---|---|---|
| un corps trop gros | `MaxBytesReader`, avant de lire | `413` |
| un JSON illisible, ambigu (nom en double, casse, second objet, UTF-8 invalide) | le décodeur strict | `400` |
| un champ inconnu | le décodeur (`RejectUnknownMembers`) | `400` |
| un champ manquant | `Parse`, grâce aux pointeurs | `422`, « required » |
| une valeur hors des règles du domaine | `Parse`, dans le constructeur du type | `422`, avec le champ |
| une règle qui dépend de l'état (déjà payé) | le domaine ou la base (leçons 5.1, 5.3) | `409` |

La frontière vérifie ce qu'on peut savoir **sans regarder l'état** :
forme, type, plage. Ce qui dépend de l'état reste au domaine et à la
base, qui restent le dernier garde-fou (leçon 5.1).

## 9. Les trois erreurs qui restent

### « On valide dans le domaine, pas besoin de frontière »

Le domaine vérifie des règles ; il ne voit pas le nom en double, la
casse, le second objet, ni la taille. Ce sont des défauts du
**transport**, que seul le décodeur voit. Et sans frontière, chaque
fonction du domaine reçoit des `int64` qui peuvent valoir n'importe
quoi.

### « Accepter large, c'est être tolérant »

Accepter un nom en double, c'est laisser deux programmes lire deux
montants différents. Accepter des champs inconnus **dans une requête**,
c'est transformer une faute de frappe en valeur vide. La tolérance a sa
place côté **client**, qui lit une réponse (leçon 6.4), pas côté serveur
qui reçoit un ordre de paiement.

### « Une erreur à la fois, c'est plus simple »

Pour le serveur. Pour la personne qui remplit le formulaire, trois
erreurs dites une par une, ce sont trois allers-retours sur un réseau
mobile. `Parse` les rend toutes, en un `422`, champ par champ.

## 10. Le lien avec la production

- **La limite de taille** se met aussi en amont : le proxy ou le
  répartiteur de charge a la sienne. Les deux servent : le proxy protège
  le service, `MaxBytesReader` protège chaque route, avec la limite qui
  lui convient (4 Ko pour une cotisation, davantage pour l'envoi d'une
  pièce d'identité).
- **Les `400` et `422` par route** se suivent comme les `5xx` : une
  nouvelle version de l'application qui envoie `"amount"` fait monter
  les `400` le jour de sa sortie.
- **Les journaux ne gardent pas le corps** d'une requête refusée en
  entier : il peut faire 16 Mo, ou contenir un numéro de téléphone. On
  garde le champ fautif et la raison.
- **Le fuzzing** tourne en continu sur les fonctions qui lisent
  l'extérieur, et chaque cas trouvé rejoint `testdata/fuzz/`.

## 11. Ce qu'il faut retenir

1. La frontière est le seul endroit où l'on vérifie la forme : après,
   le code ne manipule que des types valides.
2. Limiter la taille, puis décoder sans ambiguïté :
   `MaxBytesReader` et `encoding/json/v2` avec `RejectUnknownMembers`.
3. Des pointeurs pour savoir ce qui manque ; des types aux champs non
   exportés pour ce qui est valide.
4. Toutes les erreurs d'un coup, champ par champ.
5. Le fuzzer trouve en un instant les entrées auxquelles personne n'a
   pensé.

## 12. Approfondissement

### `encoding/json` version 1, en attendant

Un service qui ne peut pas encore passer à la version 2 obtient une
partie des protections avec `Decoder.DisallowUnknownFields()`, et en
vérifiant qu'un second `Decode` rend `io.EOF` (rien après l'objet). Il
reste sans protection contre les noms en double et la casse, que seule
la version 2 refuse.

### Les messages pour les personnes

`"must be between 1 and 5000000"` est pour le développeur.
L'application traduit le couple (champ, raison) en message pour le
membre, dans sa langue. La frontière renvoie des raisons stables, comme
le `type` de la leçon 6.1, pas des phrases à afficher.

## 13. Le réflexe à installer

Avant d'écrire un point d'entrée, demande-toi :

1. Quelle taille au plus ? Est-elle limitée avant la lecture ?
2. Que se passe-t-il avec un champ inconnu, en double, en capitales,
   absent ?
3. Dans quel type du domaine chaque champ devient-il valide ?
4. Les erreurs sont-elles toutes rendues, champ par champ ?
5. Un fuzzer a-t-il tourné sur la fonction qui lit ?

## Sources

- Go, [notes de version de Go 1.27](https://go.dev/doc/go1.27) : « The
  encoding/json/v2 package is a major revision of encoding/json. »
- Go, [package encoding/json/v2](https://pkg.go.dev/encoding/json/v2) :
  « By default, v1 allows for the presence of duplicate names, while v2
  rejects duplicate names. » ; « v1 replaces invalid bytes of UTF-8 in
  JSON strings with the Unicode replacement character, while v2 rejects
  inputs with invalid UTF-8. » ; « By default, unmarshaling uses
  case-sensitive matching ».
- Go, [package net/http](https://pkg.go.dev/net/http), `MaxBytesReader` :
  « MaxBytesReader prevents clients from accidentally or maliciously
  sending a large request and wasting server resources. »
- Go, [Go Fuzzing](https://go.dev/doc/security/fuzz/) : « Fuzzing is a
  type of automated testing which continuously manipulates inputs to a
  program to find bugs. »
- IETF, [RFC 8259 — The JSON Data Interchange Format](https://www.rfc-editor.org/rfc/rfc8259.html) :
  « The names within an object SHOULD be unique. » ; « good
  interoperability can be achieved by implementations that expect no
  more precision or range than these provide ».
- Alexis King, [Parse, don't validate](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/) :
  « a parser is just a function that consumes less-structured input and
  produces more-structured output. »

---

➡️ Exercices : [6.2-exercices.md](../exercices/6.2-exercices.md)
