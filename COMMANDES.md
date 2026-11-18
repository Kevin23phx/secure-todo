# Commandes du projet

Ce document explique l’importance et l’utilité des commandes utilisées pour le projet `todo_api`. Les prochaines commandes pourront être ajoutées ici au fur et à mesure.

## `npm pkg set type=module`

### Utilité

Cette commande définit la propriété `"type": "module"` dans le `package.json` du projet. Node.js interprète alors les fichiers `.js` comme des modules ES, ce qui permet d’utiliser `import` et `export`.

### Importance

Elle permet de choisir une syntaxe de modules cohérente pour le code serveur. Sans cette propriété, Node.js traite généralement les fichiers `.js` comme des modules CommonJS (`require` et `module.exports`), ce qui peut provoquer des erreurs si le code utilise `import` ou `export`. Les fichiers CommonJS peuvent utiliser l’extension `.cjs`.

## `npm install express@5 mongoose@9 zod@4 jose argon2 helmet cors express-rate-limit pino pino-http`

### Utilité

Cette commande télécharge et ajoute les bibliothèques nécessaires à l’API dans les dépendances du projet, dans `package.json` et `package-lock.json`.

### Importance

Ces bibliothèques fournissent des fonctions courantes du serveur et de la sécurité, pour éviter de tout réécrire soi-même :

| Paquet | Rôle |
| --- | --- |
| `express@5` | Créer le serveur HTTP et organiser les routes de l’API. |
| `mongoose@9` | Modéliser les données et communiquer avec MongoDB. |
| `zod@4` | Valider les données reçues et vérifier leur forme. |
| `jose` | Créer et vérifier des jetons, notamment des JWT. |
| `argon2` | Hacher les mots de passe avant leur stockage. |
| `helmet` | Ajouter des en-têtes HTTP qui renforcent la sécurité. |
| `cors` | Contrôler les origines autorisées à appeler l’API depuis un navigateur. |
| `express-rate-limit` | Limiter la fréquence des requêtes, par exemple sur la connexion. |
| `pino` | Produire des journaux structurés côté serveur. |
| `pino-http` | Ajouter des journaux pour les requêtes et réponses HTTP Express. |

Les suffixes `@5`, `@9` et `@4` demandent les versions majeures correspondantes. Les autres paquets sont installés selon la version compatible résolue par npm et enregistrée dans le fichier de verrouillage.

## `npm install -D typescript @types/node @types/express @types/cors supertest @types/supertest pino-pretty`

### Utilité

Cette commande installe des dépendances destinées au développement et les enregistre dans `devDependencies` de `package.json`. L’option `-D` est l’abréviation de `--save-dev`.

### Importance

Ces outils aident à écrire, vérifier et tester le projet. Ils ne sont en général pas nécessaires à l’exécution normale de l’API en production :

| Paquet | Rôle |
| --- | --- |
| `typescript` | Compiler et vérifier le code TypeScript. |
| `@types/node` | Fournir à TypeScript les définitions de types des API intégrées de Node.js. |
| `@types/express` | Fournir les types TypeScript d’Express. |
| `@types/cors` | Fournir les types TypeScript du paquet `cors`. |
| `supertest` | Envoyer des requêtes HTTP à l’application pendant les tests, sans devoir démarrer un serveur accessible séparément. |
| `@types/supertest` | Fournir les types TypeScript de Supertest. |
| `pino-pretty` | Afficher les journaux Pino dans un format plus lisible en développement. |

Les paquets `@types/...` ajoutent des informations pour l’analyse et l’autocomplétion TypeScript ; ils n’ajoutent généralement pas le comportement correspondant à l’exécution. `supertest` sert à écrire des tests, tandis que `pino-pretty` facilite la lecture des journaux pendant le développement.

## `touch .gitignore`

À exécuter depuis le dossier `todo_api`. Cette commande crée un fichier `.gitignore` vide, s’il n’existe pas déjà. Le fichier indique à Git quels fichiers ou dossiers ne doivent pas être suivis ni ajoutés aux commits.

Pour cette API, le guide demande d’y inscrire :

```gitignore
node_modules/
.env
```

Cela évite d’ajouter au dépôt les dépendances installées localement et le fichier `.env`, qui contient les valeurs de configuration réelles et potentiellement des secrets. Le fichier `.env.example`, lui, peut être suivi par Git pour documenter les variables nécessaires.

## `docker compose up -d` — erreur « address already in use » sur le port 27017

### Cause

Dans `todo_api/docker-compose.yml`, la règle `"27017:27017"` demande à Docker de publier le port MongoDB du conteneur (à droite) sur le port `27017` de l’ordinateur (à gauche). Le message `failed to bind ... 0.0.0.0:27017 ... address already in use` signifie que ce port hôte est déjà occupé, souvent par un autre serveur MongoDB ou un autre conteneur. L’image a bien été téléchargée ; c’est l’ouverture du port qui a échoué.

### Diagnostic et solutions

Voir quel processus écoute sur ce port :

```bash
sudo ss -ltnp 'sport = :27017'
```

Si c’est un autre conteneur MongoDB dont tu n’as pas besoin, identifie-le avec `docker ps`, puis arrête seulement ce conteneur avec `docker stop NOM_OU_ID`. Si c’est le service MongoDB installé sur l’ordinateur et que tu n’en as pas besoin pour autre chose, tu peux l’arrêter avec `sudo systemctl stop mongod`.

Autre possibilité : conserver le service existant et publier le conteneur sur un autre port hôte. Dans `docker-compose.yml`, remplace la règle par :

```yaml
ports:
  - "27018:27017"
```

Puis change aussi le port de `MONGO_URI` dans `todo_api/.env` et `todo_api/.env.example` en `27018`, par exemple `mongodb://127.0.0.1:27018/todo_dev`. Redémarre ensuite Compose avec `docker compose up -d` depuis `todo_api`, puis vérifie avec `docker compose ps`.

Ne supprime pas le volume MongoDB pour résoudre ce conflit : le problème concerne le port réseau, pas les données. Dans cet environnement, l’accès au socket Docker est refusé, donc je n’ai pas pu identifier quel processus détient actuellement le port ; la commande `ss` ci-dessus permettra de le déterminer sur ta machine.

### Variables à mettre dans `.env`

Le fichier `.env` doit contenir toutes les variables lues et vérifiées par `src/config/env.ts`, pas seulement `MONGO_URI`. Pour la configuration de développement du guide, utilise :

```env
NODE_ENV=development
PORT=3000
MONGO_URI=mongodb://127.0.0.1:27018/todo_dev
JWT_ACCESS_SECRET=REMPLACER_PAR_UN_SECRET_ALEATOIRE
ACCESS_TOKEN_TTL=15m
REFRESH_TOKEN_TTL_DAYS=30
CORS_ORIGIN=*
```

Si tu utilises le MongoDB déjà installé sur l’ordinateur au port `27017` plutôt que le conteneur Docker, mets `mongodb://127.0.0.1:27017/todo_dev` dans `MONGO_URI`. Pour le conteneur configuré sur le port hôte `27018`, garde `27018` dans l’URI. Génère une vraie valeur pour `JWT_ACCESS_SECRET` avec `node -e "console.log(require('crypto').randomBytes(48).toString('base64url'))"`, puis colle le résultat à la place du texte provisoire. Ne partage pas cette valeur et ne la mets pas dans Git ; `.env` doit rester ignoré.

Le guide demande aussi un `.env.example` pour documenter les noms et valeurs de configuration sans y mettre de secret réel. Dans ce projet, il est réglé pour MongoDB Docker sur le port `27018`. Le `.env` privé doit contenir les mêmes variables, avec son propre secret JWT aléatoire. Ne recopie pas la valeur d’exemple du secret dans un environnement réel.

## Bilan du labo : pages 7 à 9

Vérification des fichiers présents dans `todo_api` par rapport aux étapes de ces pages :

| Page | Fichier / étape | État |
| --- | --- | --- |
| 7 | `src/config/env.ts` : valider les variables avec Zod, arrêter le processus si elles sont invalides, puis exporter `env`. | Présent ; l’export `export const env = parsed.data;` est bien après le contrôle d’erreur. |
| 7 | `src/shared/logger.ts` : configurer Pino, le format lisible en développement et le masquage des données sensibles. | Présent. |
| 7 | `src/config/db.ts` : connexion et déconnexion Mongoose. | Présent. |
| 8 | `src/shared/errors.ts` : définir `AppError` et ses constructeurs d’erreur usuels. | Présent. |
| 8–9 | `src/shared/error-handler.ts` : gérer les erreurs Zod, `AppError`, le JSON mal formé et les erreurs inattendues ; répondre avec une enveloppe JSON uniforme. | Présent maintenant ; les différentes erreurs ont des réponses JSON prévues, et les erreurs inattendues sont journalisées sans exposer leur détail au client. |

Le bilan porte sur la présence et le contenu observé des fichiers, pas sur leur compilation ou leur exécution.

## Bilan du labo : pages 10 à 12

### Pages 10–11 : application et serveur

Le guide sépare deux responsabilités :

- `src/app.ts` construit et configure l’application Express dans `createApp()`, sans ouvrir de port. Cela permet aux tests d’importer l’application et d’envoyer des requêtes sans démarrer un serveur réseau.
- `src/server.ts` est le point de démarrage : il se connecte d’abord à MongoDB, démarre ensuite l’écoute HTTP sur `PORT`, puis ferme proprement le serveur et la base lors d’un signal d’arrêt (`SIGINT` ou `SIGTERM`).

Dans `app.ts`, l’ordre des middlewares est important : `helmet` ajoute des en-têtes de sécurité ; `cors` contrôle les origines navigateur autorisées ; `express.json` lit le corps JSON (avec une limite de 100 Ko) ; `pino-http` journalise les requêtes ; viennent ensuite le contrôle `/health` et les routes. Le middleware de route introuvable puis le gestionnaire d’erreurs sont placés à la fin pour traiter les requêtes qui n’ont pas trouvé de route et les erreurs transmises par les étapes précédentes.

Les fichiers `app.ts` et `server.ts` sont présents. Les routes Auth sont maintenant branchées dans l’application, comme demandé à la fin du labo 1. Les routes Todos restent désactivées jusqu’au labo 2, car leur module n’existe pas encore.

### Erreur `npm run dev` lancée depuis la racine

L’erreur `ENOENT ... secure-todo/package.json` signifie que npm cherchait un `package.json` dans le dossier courant, la racine `secure-todo`. Le fichier qui définit le script `dev` est dans `todo_api`. Lance la commande depuis ce dossier :

```bash
cd ~/Documents/L3_CS27/mobile/secure-todo/todo_api
npm run dev
```

Ou, depuis la racine du projet, indique le dossier du paquet :

```bash
npm --prefix todo_api run dev
```

Dans un deuxième terminal, vérifie le point de contrôle de la page 12 :

```bash
curl http://localhost:3000/health
curl http://localhost:3000/nope
```

Le premier doit répondre avec un JSON contenant `"status":"ok"` et `uptime`. Le second doit répondre en JSON avec le code `NOT_FOUND`. Le terminal du serveur doit annoncer la connexion MongoDB et l’écoute sur le port 3000. Si le démarrage échoue, vérifie que le conteneur est actif (`docker compose ps` depuis `todo_api`), que `.env` contient les variables requises et que `MONGO_URI` pointe vers le port réellement publié.

Pour expliquer ce travail à l’oral : « L’application Express est construite séparément du démarrage pour faciliter les tests. Une requête passe dans les middlewares dans l’ordre ; le parseur JSON doit précéder les routes, et le gestionnaire d’erreurs doit venir en dernier. Le serveur attend la connexion MongoDB avant d’écouter et ferme proprement les connexions à l’arrêt. »

État : les fichiers nécessaires aux pages 10–11 sont présents. L’erreur `npm run dev` venait du dossier courant et se corrige en lançant npm depuis `todo_api`. Le point de contrôle à l’exécution est à confirmer sur ta machine.

## Labo 1.8 : `src/modules/auth/auth.service.ts`

Le service d’authentification contient la logique métier appelée par les contrôleurs. Le code de la section 1.8 a été ajouté dans ce fichier :

- `register` vérifie si l’adresse e-mail existe, hache le mot de passe avec Argon2id, crée l’utilisateur et renvoie une session.
- `login` récupère explicitement le champ `passwordHash` (caché par défaut par le modèle), vérifie le mot de passe avec Argon2 et renvoie un message d’authentification générique en cas d’échec, que l’e-mail soit inconnu ou le mot de passe incorrect.
- `buildSession` renvoie uniquement le DTO public de l’utilisateur et crée un jeton d’accès ainsi qu’un jeton de renouvellement.
- `refresh` fait tourner le jeton de renouvellement et signe un nouveau jeton d’accès.
- `logout` révoque la famille du jeton de renouvellement.
- `getProfile` retrouve l’utilisateur et renvoie son DTO public, sans le hash du mot de passe.

À expliquer à l’oral : un mot de passe n’est jamais stocké en clair ni chiffré de façon réversible ; Argon2id en stocke un hash lent à calculer. Le jeton d’accès sert à authentifier les requêtes et est de courte durée. Le jeton de renouvellement est stocké sous forme de hash et remplacé à chaque utilisation. Le DTO limite les données utilisateur exposées par l’API.

## Vérification du labo : pages 12 à 22

J’ai comparé le code présent aux étapes 1.5–1.9 du PDF. J’ai corrigé les points bloquants repérés : l’application importe maintenant les routes Auth existantes, les routes Todos restent désactivées jusqu’au labo 2, et l’extension Express est déclarée dans le fichier TypeScript attendu. Le fichier `requests.http` des requêtes manuelles a aussi été créé.

| Pages | Élément du labo | État après vérification |
| --- | --- | --- |
| 12 | Modèle d’authentification à deux jetons : access court et refresh plus long. | Implémenté par le service des jetons, avec les durées définies dans `.env`. |
| 13 | Modèle utilisateur, hash masqué par défaut et DTO public. | Implémenté dans `user.model.ts` ; le DTO ne contient pas le hash. |
| 14 | Modèle de refresh token et schémas d’entrée Zod. | Implémenté dans `refresh-token.model.ts` et `auth.schemas.ts`. |
| 15–16 | JWT signé/vérifié avec algorithme, émetteur et audience fixés ; refresh token aléatoire stocké sous forme de hash avec expiration et rotation. | Implémenté dans `token.service.ts`. La rotation réclame atomiquement l’ancien jeton et révoque sa famille si un jeton déjà utilisé est rejoué. |
| 17–18 | Inscription, connexion, hachage Argon2id, renouvellement, déconnexion et profil. | Implémenté dans `auth.service.ts`. La réponse de service expose le DTO et les jetons, pas le hash du mot de passe. |
| 19 | Middleware Bearer et ajout de `userId` au type Express. | Implémenté dans `shared/authenticate.ts` et `src/types/express.d.ts`. Les déclarations mal nommées trouvées pendant la vérification ont été remplacées par le fichier attendu. |
| 20 | Contrôleurs HTTP qui valident l’entrée, appellent le service et choisissent le statut/réponse. | Implémenté dans `auth.controller.ts`. |
| 20–21 | Routes register, login, refresh, logout et me ; limiteur sur register/login ; séparation route/contrôleur/service/modèle. | Implémenté dans `auth.routes.ts` et branché sous `/api/v1/auth` dans `app.ts`. Les routes Todo restent en attente du labo 2. |
| 22 | Requêtes manuelles Register, Login et Who am I. | Exemples présents dans `todo_api/requests.http`. Les réponses HTTP réelles restent à vérifier en lançant l’API et en envoyant ces requêtes. |

À retenir pour une présentation : les routes choisissent l’URL et les gardes ; les contrôleurs traduisent HTTP en appels métier ; les services appliquent les règles sans dépendre de `req`/`res` ; les modèles accèdent à MongoDB. Le mot de passe est haché avec Argon2id. Le JWT d’accès est signé et vérifié sans requête DB, tandis que le refresh token opaque est stocké sous forme de hash et renouvelé à chaque usage.

Vérification effectuée : `npm run typecheck` dans `todo_api` s’est terminé avec succès (`tsc --noEmit`, code de sortie 0). Cela confirme le contrôle TypeScript, mais ne prouve pas que MongoDB est disponible ni que les requêtes HTTP du point de contrôle fonctionnent. Il reste à lancer `npm run dev`, puis à envoyer les requêtes de `requests.http` et vérifier les statuts attendus : inscription 201, e-mail en doublon 409, entrée invalide 422, `/me` sans jeton 401 et avec jeton valide 200.
