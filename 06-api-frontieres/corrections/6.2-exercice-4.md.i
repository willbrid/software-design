# Correction 6.2 — Exercice 4 : cinq frontières

> Rappel de l'énoncé : cinq chemins d'entrée ; pour chacun, la taille,
> ce que le décodage refuse, les types produits, les statuts.

## En bref

- **Chaque chemin a sa limite**, réglée sur la taille réelle de ce qu'il
  transporte.
- **Les cinq produisent les mêmes types du domaine** : une cotisation
  reçue par USSD ou par l'application devient la même `Contribution`.
- **Le rappel de l'opérateur se vérifie d'abord par sa signature** :
  avant de lire le contenu, on vérifie qui l'envoie.

## Le tableau

| # | Taille au plus | Le décodage refuse | Types produits | Statuts |
|---|---|---|---|---|
| 1 | 4 Ko | JSON ambigu, champ inconnu, second objet | `Contribution` (`Phone`, `Amount`, tour) | `201`, `400`, `413`, `422` |
| 2 | 16 Ko | signature absente ou fausse **avant tout** ; puis JSON strict | `TransferResult` (identifiant en texte, statut parmi une liste fermée) | `204` si traité ou **déjà traité**, `401` signature, `400`, `422` |
| 3 | 256 Ko (500 lignes × environ 200 octets, et de la marge) | encodage autre qu'UTF-8, colonnes inattendues, plus de 500 lignes | une liste de `NewMember` (`Phone`, nom borné), et les erreurs **par ligne** | `201` ; `422` avec le numéro de ligne et le champ de chaque erreur |
| 4 | la longueur de l'URL (le serveur a sa limite) | paramètres inconnus, `page` non numérique ou au-delà d'un plafond | `MemberQuery` (nom de 1 à 50 caractères, curseur opaque) | `200`, `400` |
| 5 | 182 caractères (la longueur maximale d'un message USSD) | tout ce qui n'est pas `*123*<menu>*<tour>*<montant>#`, chiffres ASCII seulement | la même `Contribution`, avec le numéro **donné par l'opérateur**, jamais tapé | une réponse en texte au format de l'opérateur |

Trois choix à justifier :

- **Le CSV renvoie toutes les erreurs, par ligne.** Une trésorière qui
  importe 300 membres corrige tout en une fois, comme `Parse` le fait
  pour les champs. Rien n'est importé tant qu'une ligne est fausse :
  l'import est une transaction (leçon 5.2).
- **La recherche borne la page.** `page=100000` avec un `OFFSET`
  coûterait une lecture complète (leçon 5.5) ; un curseur opaque, signé
  ou chiffré, empêche le client d'en fabriquer un.
- **L'USSD ne fait pas confiance au numéro tapé.** Le numéro du payeur
  est celui que l'opérateur a authentifié, pas celui écrit dans le menu.

## Le chemin 2, que personne n'écrit

Le rappel de l'opérateur n'est écrit ni par un membre ni par une
trésorière, mais il vient quand même de l'extérieur, par le réseau :
n'importe qui peut envoyer un `POST` à cette adresse. Trois différences :

1. **L'authenticité d'abord** : la signature (un HMAC du corps avec un
   secret partagé, en général) se vérifie sur les **octets reçus**, avant
   le décodage. Un corps non signé n'est pas lu.
2. **Les rappels sont renvoyés** : l'opérateur rappelle tant qu'il n'a
   pas reçu de `2xx`. Le même résultat arrivera deux fois, ou plus.
   C'est la leçon 6.3 : le traitement doit être idempotent, et
   « déjà traité » répond `204`.
3. **Les valeurs fermées** : le statut du transfert est `succeeded` ou
   `failed`. Une troisième valeur, ajoutée un jour par l'opérateur,
   doit être **gardée et signalée**, pas traitée comme un succès ni
   rejetée en boucle (le rejet ferait rappeler indéfiniment). La leçon
   6.4 y revient.

## Ce qu'il faut retenir

- Une limite par chemin, réglée sur sa taille réelle.
- Tous les chemins produisent les mêmes types.
- Ce qui vient d'un système se vérifie d'abord par son authenticité.
