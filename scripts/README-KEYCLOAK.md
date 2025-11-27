# 🔐 Configuration Keycloak pour BOLT.DIY-INTRANET v10.5

## 📋 Prérequis

Installation terminée avec succès via `install_bolt_v10.5.sh`.

---

## 🚀 Étape 1 : Accéder à Keycloak Admin Console

1. Ouvrir un navigateur
2. Accéder à : `http://<PUBLIC_IP>:<HOST_PORT_KEYCLOAK>`
3. Cliquer sur **Administration Console**
4. Se connecter :
   - **Username** : `admin`
   - **Password** : (disponible dans le fichier `.env` → `KEYCLOAK_ADMIN_PASSWORD`)

---

## 🏰 Étape 2 : Créer le Realm `bolt`

1. Cliquer sur le dropdown **"master"** en haut à gauche
2. Cliquer sur **"Create Realm"**
3. Remplir :
   - **Realm name** : `bolt`
   - **Enabled** : ✅ ON
4. Cliquer sur **"Create"**

✅ Le Realm `bolt` est maintenant créé.

---

## 🔑 Étape 3 : Créer le Client `bolt-diy-client`

1. Dans le Realm `bolt`, aller dans **Clients** (menu de gauche)
2. Cliquer sur **"Create client"**
3. **General Settings** :
   - **Client type** : `OpenID Connect`
   - **Client ID** : `bolt-diy-client`
4. Cliquer sur **"Next"**
5. **Capability config** :
   - **Client authentication** : ✅ ON
   - **Authorization** : ❌ OFF
   - **Standard flow** : ✅ ON
   - **Direct access grants** : ✅ ON
6. Cliquer sur **"Next"**
7. **Login settings** :
   - **Root URL** : `http://<PUBLIC_IP>:<HOST_PORT_BOLT>`
   - **Valid redirect URIs** : `http://<PUBLIC_IP>:<HOST_PORT_BOLT>/oauth2/callback`
   - **Valid post logout redirect URIs** : `http://<PUBLIC_IP>:<HOST_PORT_BOLT>`
   - **Web origins** : `http://<PUBLIC_IP>:<HOST_PORT_BOLT>`
8. Cliquer sur **"Save"**

✅ Le Client `bolt-diy-client` est maintenant créé.

---

## 🔐 Étape 4 : Récupérer le Client Secret

1. Rester dans **Clients** → `bolt-diy-client`
2. Aller dans l'onglet **"Credentials"**
3. Copier le **Client Secret**
4. Mettre à jour le fichier `.env` :

