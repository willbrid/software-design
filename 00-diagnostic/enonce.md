# Diagnostic initial — 10 questions

**But** : mesurer précisément où tu en es, pas te piéger. Le résultat sert à
construire ton programme personnalisé.

## Règles

1. Réponds avec **tes mots**, sans chercher sur internet, sans IA.
2. « Je ne sais pas » est une réponse **utile et acceptée**. Le bluff fausse le
   diagnostic et me fera enseigner au mauvais niveau.
3. Sur chaque question, dis aussi **ce dont tu n'es pas sûr**.
4. Réponds dans `00-diagnostic/mes-reponses.md`, ou directement dans le chat.
5. Tu peux répondre en plusieurs fois (ex. Q1 à Q4 puis le reste).
6. Pas de limite de temps, mais vise 5–10 min par question. Si une question te
   bloque totalement, écris pourquoi et passe à la suivante.

---

## Q1 — Programmation : lecture critique de code

```go
func AppliquerRemise(prix []float64, pourcentage float64) []float64 {
    for i, p := range prix {
        prix[i] = p * (1 - pourcentage/100)
    }
    return prix
}
```

Cette fonction compile et « marche ». Liste tous les problèmes que tu y vois, et
pour chacun : **dans quelle situation concrète** ce problème se manifeste-t-il ?

---

## Q2 — OOP : modélisation

Ton lead te dit :

> « Crée une classe `Rectangle` avec `setLargeur()` et `setHauteur()`. Ensuite
> fais hériter `Carre` de `Rectangle` : un carré **est** un rectangle, c'est
> logique. »

Es-tu d'accord ? Argumente. Si tu n'es pas d'accord, montre par un exemple de
code appelant ce qui casse, et propose autre chose.

---

## Q3 — Conception : responsabilités

```go
func (s *Service) CreerCommande(ctx context.Context, r Requete) error {
    if r.ClientID == "" || len(r.Lignes) == 0 {
        return errors.New("requête invalide")
    }

    total := 0.0
    for _, l := range r.Lignes {
        total += l.PrixUnitaire * float64(l.Quantite)
    }
    if total > 1000 {
        total = total * 0.95
    }

    _, err := s.db.Exec("INSERT INTO commandes (client_id, total) VALUES ($1, $2)", r.ClientID, total)
    if err != nil {
        return err
    }

    s.smtp.Envoyer(r.Email, "Votre commande", fmt.Sprintf("Total : %.2f €", total))
    log.Printf("commande créée pour %s", r.ClientID)
    return nil
}
```

1. Combien de responsabilités distinctes vois-tu ? Nomme-les.
2. Écris le test qui vérifie **uniquement** la règle « 5 % de remise au-dessus de
   1000 € ». Qu'es-tu obligé de mettre en place pour y arriver ? Est-ce normal ?
3. Comment découperais-tu ce code, et **pourquoi ce découpage-là** plutôt qu'un
   autre ?

---

## Q4 — Bases de données : modélisation et trade-off

Une table `commandes` et une table `lignes_commande`.

1. Faut-il stocker une colonne `total` dans `commandes`, ou le recalculer à
   chaque lecture depuis les lignes ? Donne les arguments **des deux côtés**,
   puis tranche et justifie.
2. Même question pour le **prix unitaire** dans `lignes_commande` : on le stocke,
   ou on fait une jointure vers `produits.prix` ? Attention, ce n'est pas la même
   réponse que la question 1 — explique pourquoi.
3. La requête `SELECT * FROM commandes WHERE client_id = ? ORDER BY creee_le DESC
   LIMIT 20` devient lente avec 50 millions de lignes. Que fais-tu, et comment
   vérifies-tu que ça a marché ?

---

## Q5 — Backend : transactions et concurrence

Virement d'argent du compte A vers le compte B.

1. Décris les étapes (pseudo-code ou Go).
2. Le serveur crashe juste après avoir débité A, avant de créditer B. Que se
   passe-t-il ? Qu'est-ce qui te protège ?
3. Deux virements de 100 € partent **en même temps** depuis le compte A qui
   contient 150 €. Décris précisément comment le solde peut devenir négatif.
   Comment l'empêches-tu ? Donne au moins deux mécanismes différents et leur
   différence.

---

## Q6 — API design

Tu exposes `POST /api/payments` qui débite une carte bancaire.

1. Le client mobile envoie la requête, le réseau coupe, il ne reçoit pas la
   réponse et **réessaie**. Que se passe-t-il ? Comment conçois-tu l'API pour que
   ce soit sûr ?
2. Quel code HTTP renvoies-tu si : le paiement réussit / le montant est négatif /
   la carte est refusée par la banque / le service bancaire est indisponible ?
   Justifie chaque choix.
3. Un client te demande d'ajouter un champ dans la réponse. Un autre te demande
   d'en supprimer un. Lequel des deux est dangereux, et pourquoi ?

---

## Q7 — Tests

Un service crée un utilisateur en base puis lui envoie un email de bienvenue.

1. Quels tests écris-tu ? Liste-les.
2. Qu'est-ce que tu remplaces par un faux (mock/stub/fake) et qu'est-ce que tu
   laisses réel ? Sur quel critère décides-tu ?
3. Donne un exemple de test qui **ne sert à rien** ou qui est nuisible. Explique
   ce qui le rend inutile.

---

## Q8 — Architecture : frontières et couplage

Application monolithique. Deux modules : `Facturation` et `Utilisateurs`.
Le module `Facturation` fait directement `SELECT * FROM users WHERE id = ?`.

1. Est-ce un problème ? Argumente — si tu penses que non, dis pourquoi.
2. Qu'est-ce que ça coûte concrètement 18 mois plus tard ?
3. Quelle alternative proposes-tu, et **quel nouveau coût** introduit-elle ? (Il
   y en a toujours un.)

---

## Q9 — Systèmes distribués

Ton API :

```
1. INSERT commande en base (statut = "en attente")
2. POST https://paiement.interne/charge   →  timeout au bout de 30s
```

1. Après le timeout, liste **tout** ce qui a pu réellement se passer côté service
   Paiement. Combien de cas distincts ?
2. Tu réessaies l'appel. Quel risque prends-tu ?
3. Comment le système finit-il dans un état correct ? Décris le mécanisme, pas
   une techno.

---

## Q10 — System design (ouvert)

Concevoir un raccourcisseur d'URL (type bit.ly).
Contraintes : 100 millions de liens stockés, 10 000 redirections par seconde,
500 créations par seconde.

**Ne me donne pas une architecture toute faite.** Je veux, dans cet ordre :

1. Les **questions** que tu poserais avant de commencer à concevoir (c'est la
   partie la plus importante de cette question).
2. Les composants que tu vois, et le rôle de chacun.
3. Comment tu génères un code court unique — et ce qui casse si deux serveurs
   génèrent en même temps.
4. Où est le goulot d'étranglement selon toi, et pourquoi.

---

## Contexte (hors notation)

Réponds aussi brièvement à :

- Depuis combien de temps codes-tu, et en professionnel depuis combien de temps ?
- Quels langages / frameworks utilises-tu réellement au quotidien ?
- Quelle est la plus grosse application sur laquelle tu as travaillé (users,
  taille d'équipe, volume de données) ?
- As-tu déjà : mis en prod ? géré un incident en prod ? conçu une base de données
  de zéro ? travaillé avec une file de messages ?
- Qu'est-ce qui te bloque le plus aujourd'hui dans ton travail ?
