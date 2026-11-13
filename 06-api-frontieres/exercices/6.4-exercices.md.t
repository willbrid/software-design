# Exercices 6.4 — Les contrats

Cinq exercices, du plus simple au plus ouvert. Traite-les **dans l'ordre** et
écris tes réponses dans `mes-reponses/` avant d'ouvrir les corrections.

Les exercices s'appuient sur les paquets de la
[leçon 6.4](../cours/6.4-les-contrats.md) (`api`, `clients`, `contract`),
recopiés tels quels dans le module des exercices. Ils n'ont besoin que de
la bibliothèque standard. Tout le code ci-dessous compile et passe
`go vet` ; les applications, les versions et l'incident sont **fictifs**.

---

## Exercice 1 — Compréhension : rupture ou pas ?

*Niveau 1. Aucune ligne de code à écrire.*

### 1.a — Huit changements

Pour chaque changement de la réponse de `GET /tontines/1`, dis quelles
applications de la leçon (stricte, ordinaire, tolérante) il casse, et
comment : erreur, valeur fausse, écran dégradé.

1. `members` passe de 2 à 0 éléments pour une tontine vide.
2. `name` peut désormais dépasser 100 caractères.
3. `next_round` devient `"3"`.
4. Le serveur ajoute `"currency": "XAF"`.
5. `status` vaut `"OPEN"` au lieu de `"open"`.
6. `share_fcfa` passe de 10 000 à 10 000,5 pour une tontine qui arrondit.
7. Chaque membre gagne un champ `"photo_url"`.
8. Le serveur renvoie `members` trié par nom au lieu de l'ordre
   d'arrivée.

### 1.b — Trois pourquoi

1. Pourquoi le test golden échoue-t-il sur « reorder the fields »,
   alors qu'aucune application ne casse ?
2. Pourquoi l'application ordinaire affiche-t-elle « prochain tour : 0 »
   au lieu d'une erreur ?
3. Pourquoi aucun contrat de forme ne voit-il le passage aux centimes ?

### 1.c — Qui doit écrire le contrat ?

Un partenaire intègre l'API sans jamais écrire de contrat. Que sait le
serveur de ce que ce partenaire lit, et que peut-il faire pour le
savoir ?

---

## Exercice 2 — Code : le lecteur tolérant d'un prêt

*Niveau 2. Réécrire un lecteur ; les tests sont fournis.*

L'écran d'un prêt lit `GET /loans/{id}` ainsi :

@@P:en/e64/ex2/loan.go|// LoanView is@@

@@P:en/e64/ex2/loan.go|// ReadLoan reads@@

Réécris `ReadLoan` en lecteur tolérant : il affiche « — » pour un
montant qu'il ne sait pas lire, « Autre » pour un statut inconnu, et ne
devine jamais ce que veut dire un `null`. Les tests de `ex2/loan_test.go` :

```text
--- FAIL: TestReadLoan (0.00s)
    loan_test.go:29: a new status: {Member: Amount: Status: Left:} unknown status "late", want {Member:Awa Amount:150 000 FCFA Status:Autre Left:100 000 FCFA}
    loan_test.go:29: repaid null: {Member:Awa Amount:150 000 FCFA Status:En cours Left:150 000 FCFA} <nil>, want {Member:Awa Amount:150 000 FCFA Status:En cours Left:—}
    loan_test.go:29: repaid absent: {Member:Awa Amount:150 000 FCFA Status:En cours Left:150 000 FCFA} <nil>, want {Member:Awa Amount:150 000 FCFA Status:En cours Left:—}
    loan_test.go:29: amount absent: {Member:Awa Amount:0 FCFA Status:Remboursé Left:- 150 000 FCFA} <nil>, want {Member:Awa Amount:— Status:Remboursé Left:—}
    loan_test.go:29: amount as a string: {Member: Amount: Status: Left:} json: cannot unmarshal string into Go struct field .amount_fcfa of type int64, want {Member:Awa Amount:150 000 FCFA Status:En cours Left:150 000 FCFA}
FAIL
FAIL    example/contract64/ex2  0.002s
FAIL
```


Question : pour `repaid_fcfa` à `null`, pourquoi afficher « — » plutôt
que le montant entier ?

---

## Exercice 3 — Refactoring : faire évoluer la réponse sans casser

*Niveau 3. Réécrire l'encodeur de la réponse ; les tests sont fournis.*

L'équipe veut trois choses dans la réponse de `GET /tontines/{id}` :

- l'identifiant en texte, `id_str`, pour les navigateurs (leçon 6.2) ;
- la part avec sa devise, `share: {"amount": 10000, "currency": "XAF"}` ;
- les membres paginés, `members_page: {"items": [...50 au plus],
  "next": <curseur ou null>}`.

@@P:en/e64/ex3/encode.go|// Encode writes@@

Les trois applications installées doivent continuer de passer leur
contrat de la leçon. Les tests de `ex3/encode_test.go` :

```text
--- FAIL: TestTheOthersGetTheNewFields (0.00s)
    encode_test.go:50: plain/3.1: id_str "", share <nil>
    encode_test.go:53: plain/3.1: members_page <nil>, 120 members
    encode_test.go:50: tolerant/1.4: id_str "", share <nil>
    encode_test.go:53: tolerant/1.4: members_page <nil>, 120 members
    encode_test.go:50: web/1.0: id_str "", share <nil>
    encode_test.go:53: web/1.0: members_page <nil>, 120 members
--- FAIL: TestTheLastPageHasNoNext (0.00s)
    encode_test.go:62: members_page <nil>
FAIL
FAIL    example/contract64/ex3  0.004s
FAIL
```

Question : l'application stricte refuse tout champ qu'elle ne connaît
pas. Que reçoit-elle, et combien de temps peut-on la servir ainsi ?

---

## Exercice 4 — Design : la politique de compatibilité

*Niveau 4. Aucune ligne de code : un document d'une page.*

Rédige la politique de compatibilité de l'API des tontines, publiée avec
sa documentation, en répondant à :

1. Quels changements le serveur s'autorise **sans prévenir** ?
2. Qu'exige-t-il des clients en échange (comment lire une réponse) ?
3. Quels changements sont des **ruptures**, et comment sont-ils
   annoncés ?
4. Comment un client déclare-t-il ce qu'il lit (contrat, version) ?
5. Pour les listes fermées (statuts), quelle règle dès la première
   version ?

Écris ensuite le contrat, au format du paquet `contract`, de l'écran
« versement » de l'application des trésorières, qui affiche le
bénéficiaire, le montant, la date et le statut d'un versement.

---

## Exercice 5 — Incident : le statut `late`

*Niveau 7. Un incident à mesurer, puis à corriger côté serveur.*

Le lundi 2 novembre 2026 à 6 h, le serveur commence à renvoyer le statut
`late` pour les prêts en retard. Les versions 3.1 à 3.3 de l'application
lisent ainsi la liste des prêts :

@@P:en/e64/ex5/loans.go|// ReadBefore34 is@@

La version 3.4, qui connaît `late`, sort le mercredi 4 ; les membres
l'installent peu à peu. `ex5/week.go` rejoue la semaine : 4 000 membres
qui ont un prêt ouvrent l'écran à peu près une fois par jour.

@@P:en/e64/ex5/week.go|// Session is one@@

@@P:en/e64/ex5/week.go|// Week replays@@

1. **L'audit.** Écris `Audit` dans `ex5/audit.go` :

@@P:en/e64/ex5/audit.go|// Report is what@@

   Le test de `ex5/audit_test.go` :

```text
--- FAIL: TestAudit (0.00s)
    audit_test.go:21: 0 sessions, 0 failed, by version map[]
    audit_test.go:24: 0 members, 0 still failing, first 0001-01-01 00:00:00 +0000 UTC; want 2, 1, 2 Nov 10:00
FAIL
FAIL    example/contract64/ex5  0.079s
FAIL
```

2. **Les chiffres.** Combien d'écrans en erreur, pour combien de
   membres ? Combien le sont encore le dimanche, cinq jours après la
   sortie de la 3.4 ?
3. **La cause.** Ajouter une valeur à un statut était-il une rupture ?
   Pour qui ?
4. **La correction**, côté serveur, sans attendre que tous les membres
   mettent à jour : écris `AnswerFor(loans, version)`, et vérifie que la
   semaine rejouée avec elle n'a plus d'erreur.
5. **Le compte rendu**, en cinq points.
