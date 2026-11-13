# Correction 6.5 — Exercice 5 : les nairas en francs CFA

> Rappel de l'énoncé : des tontines en nairas, une version 1 qui ne sait
> dire que des FCFA ; mesurer, expliquer, corriger.

L'audit, la correction et leurs tests sont dans `ex5` du module de
correction, verts sous `go vet ./...` et `go test -race -count=1 ./...`.

## En bref

- **493 relevés faux, pour 141 membres de Lagos** : leur solde en nairas
  affiché comme des francs CFA, 3 409 500 NGN au total.
- **`ToV1` était juste le jour où elle a été écrite** : toutes les
  tontines étaient en franc CFA. Elle est devenue fausse le jour où une
  devise que v1 ne peut pas dire est apparue.
- **La correction** : v1 refuse ce qu'il ne sait pas dire, avec un
  problème qui demande la mise à jour, au lieu de le dire faux.

## 1. L'audit

@@P:en/c65/ex5/audit.go|// Audit reads@@

@@P:en/c65/ex5/audit.go|// isFCFA reports@@

XAF (Afrique centrale) et XOF (Afrique de l'Ouest) sont deux devises,
mais toutes deux des francs CFA, à parité : `balance_fcfa` les dit
justement. Le naira, non.

## 2. Les chiffres

`cmd/lagos` :

```text
11872 statements, 4103 by v1
v1 answers not in FCFA: 493 map[NGN:493], for 141 members, 3409500 NGN shown as FCFA
```

- **493 relevés** servis par v1 à des membres de tontines en nairas,
  pendant la semaine ;
- **141 membres** ont vu au moins un solde faux ; la somme de leurs
  derniers soldes affichés vaut 3 409 500 NGN, présentés comme des FCFA.
  Un naira vaut bien moins qu'un franc CFA : chaque membre croit devoir
  une somme plusieurs fois plus grande que sa dette réelle.

## 3. La cause

`ToV1` garde `s.Balance.Amount` et **jette** `s.Balance.Currency`. Tant
que toutes les devises étaient des francs CFA, la devise ne portait
aucune information pour v1, et la jeter était sans perte. Le lundi de
Lagos, elle en a porté une, et la traduction l'a perdue sans erreur.

Une traduction vers une ancienne forme est juste **pour les valeurs que
cette forme sait dire**. La question à se poser à chaque évolution de v2
(« et dans v1 ? », leçon 6.5) n'avait pas été posée le jour où le naira
est apparu : la devise ne changeait pas la forme de v2, seulement ses
valeurs.

## 4. La correction

@@P:en/c65/ex5/fix.go|// ToV1Checked writes@@

@@P:en/c65/ex5/audit_test.go|func TestV1RefusesWhatItCannotSay@@

```text
--- PASS: TestAudit (0.00s)
--- PASS: TestV1RefusesWhatItCannotSay (0.00s)
ok      example/version65/ex5   1.016s
```

Dans le gestionnaire de v1, `ErrRequiresV2` se traduit en `409`, avec le
type `requires-v2` et
le détail « mettez à jour l'application pour voir ce relevé ». Le membre
de Lagos ne voit plus son solde dans l'ancienne application, mais il ne
voit plus un solde faux. C'est le choix de l'exercice 2 de la leçon 6.4 :
« — » plutôt qu'une valeur devinée, ici à l'échelle d'une réponse
entière.

## 5. Le compte rendu

1. **Quoi** : du 9 au 15 novembre 2026, 141 membres des tontines de Lagos
   utilisant l'application 4.x ont vu leur solde en nairas affiché comme
   un montant en FCFA, dans 493 relevés.
2. **Cause** : la version 1 de l'API ne sait dire que des francs CFA ; sa
   traduction depuis la version 2 jetait la devise, ce qui était sans
   perte jusqu'à l'ouverture de tontines en nairas.
3. **Détection** : une trésorière de Lagos, le jeudi. Rien ne vérifiait
   qu'une traduction ne perdait pas d'information.
4. **Correction** : v1 refuse un relevé qui n'est pas en franc CFA
   (`409 requires-v2`) ; les 141 membres sont prévenus par leur
   trésorière, avec le lien de mise à jour.
5. **Prévention** : chaque nouvelle valeur possible d'un champ de v2
   (une devise, un statut) passe par la question « v1 sait-il la dire ? » ;
   un test de propriété vérifie que `ToV1Checked` refuse toute devise
   autre que XAF et XOF ; l'ouverture d'une région se prépare avec le
   compteur des versions de l'application dans cette région.

## Ce qu'il faut retenir

- Une traduction est juste pour les valeurs que l'ancienne forme sait
  dire.
- Ce qu'une ancienne version ne sait pas dire, elle le refuse.
- Une nouvelle valeur, même sans nouveau champ, peut casser une ancienne
  version.
