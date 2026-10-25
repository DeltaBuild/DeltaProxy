# DeltaProxy

Fork de BungeeCord 1.6.4 pour l'infrastructure DeltaBuild. Il fait le lien entre les clients Forge et les serveurs MCPC+, gère l'authentification Recube et le monde étendu NGHeight (Y de -64 à 319).

Le code de BungeeCord n'est pas versionné dans ce dépôt : DeltaProxy est un ensemble de patchs appliqués sur [DeltaBuild/BungeeCord](https://github.com/DeltaBuild/BungeeCord).

## Patchs

| Patch | Rôle |
|---|---|
| `0001-POM-Changes` | Renommage Maven en `fr.deltabuild:deltaproxy-*`, compilation Java 7 |
| `0002-Rename-references-from-BungeeCord-to-DeltaProxy` | Nom DeltaProxy dans les logs, commandes et messages |
| `0003-Delete-old-Metrics-system` | Suppression des statistiques mcstats.org |
| `0004-Add-Forge-compatibility` | Handshake FML entre le client Forge et les serveurs MCPC+ |
| `0005-Add-Recube-auth` | Authentification Recube à la place de l'authentification Mojang |
| `0006-Add-NGHeight` | Prise en charge du protocole NGHeight (Y de -64 à 319) |

### Compatibilité Forge

À la première connexion, le proxy relaie au client la demande de mods du serveur et garde sa réponse en cache. Lors d'un changement de serveur, il répond lui-même depuis ce cache ; si le nouveau serveur demande d'autres mods, le joueur est expulsé avec `Mod mismatch`.

Pour le débogage, lancer le proxy avec `-Ddeltaproxy.debugFml=true` : les messages du canal `FML` sont alors affichés en hexadécimal dans les logs.

### Authentification Recube

- Le proxy vérifie le joueur via `has-joined` sur `https://recube.gg` (tenant `nationsglory`), en HTTPS TLS 1.2 avec vérification du certificat.
- L'authentification se fait uniquement entre le client et le proxy. Les serveurs restent en offline.
- Seuls les clients lancés par le launcher Recube peuvent se connecter.

### NGHeight

Le proxy lit les paquets au format NGHeight :

- `0x0E`, `0x0F`, `0x35` : Y sur un short ;
- `0x33`, `0x38` : masques de sections sur un int.

Ce format s'applique à toutes les connexions : tous les serveurs et tous les clients doivent utiliser NGHeight.

## Workflow des patchs

Les scripts PowerShell sont dans `scripts/`.

### Première installation

```powershell
.\scripts\setup.ps1
.\scripts\apply-patches.ps1
```

- `setup.ps1` clone `DeltaBuild/BungeeCord` dans `BungeeCord/` et crée le commit de base sur la branche `main`.
- `apply-patches.ps1` recrée la branche `deltaproxy` depuis `main` et y applique les patchs de `patches/` avec `git am --3way`.

### Modifier ou ajouter un patch

1. Travailler dans `BungeeCord/`, sur la branche `deltaproxy`.
2. Commiter les modifications (un commit = un patch). Pour modifier un patch existant, amender ou réécrire son commit.
3. Régénérer les patchs :

   ```powershell
   .\scripts\generate-patches.ps1
   ```

4. Commiter le contenu de `patches/` dans DeltaProxy.

Les patchs sont générés avec `-N --zero-commit --no-signature` : seuls les patchs dont le contenu change sont modifiés.

> **Attention :** `apply-patches.ps1` supprime et recrée la branche `deltaproxy`. Tout commit non exporté avec `generate-patches.ps1` est perdu.

### En cas de conflit

```powershell
git am --show-current-patch   # voir le patch en cours
git add .                     # après résolution
git am --continue             # continuer
git am --abort                # annuler
```

## Compilation

Prérequis : **JDK 7** et Maven.

```powershell
mvn clean package
```

Le jar exécutable est généré dans `BungeeCord\bootstrap\target\DeltaProxy.jar`. Pour sauter les tests : `mvn clean package -DskipTests`.

## Configuration

### Proxy

- `online_mode: true` dans `config.yml` : obligatoire pour l'authentification Recube.
- Le proxy se lance avec `java -jar DeltaProxy.jar`, sous Java 7.

### Serveurs MCPC+

- `online-mode=false` dans `server.properties`.
- `bungeecord: true` dans `spigot.yml` : le serveur reçoit l'IP réelle du joueur transmise par le proxy.
- Serveurs injoignables directement (pare-feu) : seul le proxy doit pouvoir s'y connecter.
- Mêmes mods, mêmes versions et mêmes IDs de blocs et d'objets sur tous les serveurs.
- Agent NGHeight installé sur tous les serveurs ([DeltaBuild/DeltaHeight](https://github.com/DeltaBuild/DeltaHeight)).

## Licence

BungeeCord est distribué sous licence BSD, voir `BungeeCord/LICENSE`.

Les sources de BungeeCord utilisées sont sur [DeltaBuild/BungeeCord](https://github.com/DeltaBuild/BungeeCord).
