#!/bin/bash

###############################################################################
# Module 05 : Génération des Secrets
###############################################################################

generate_secrets() {
    section "5/11 - Génération des secrets et clés de sécurité"

    info "Génération des mots de passe sécurisés..."

    # MariaDB root password
    MARIADB_ROOT_PASSWORD=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32)
    ok "Mot de passe root MariaDB généré"

    # Keycloak admin password
    KEYCLOAK_ADMIN_PASSWORD=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32)
    ok "Mot de passe admin Keycloak généré"

    # Keycloak database password
    KEYCLOAK_DB_PASSWORD=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32)
    ok "Mot de passe base Keycloak généré"

    info "Génération des secrets OAuth2..."

    # OAuth2 Client ID (fixe)
    OAUTH2_CLIENT_ID="bolt-diy-client"
    ok "Client ID OAuth2 : $OAUTH2_CLIENT_ID"

    # OAuth2 Client Secret
    OAUTH2_CLIENT_SECRET=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32)
    ok "Client secret OAuth2 généré"

    # OAuth2 Cookie Secret (32 caractères ASCII)
    info "Génération du cookie secret OAuth2..."
    OAUTH2_COOKIE_SECRET=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32)

    # Vérification de la longueur
    cookie_len=${#OAUTH2_COOKIE_SECRET}

    if [[ "$cookie_len" -eq 32 ]]; then
        ok "Cookie secret OAuth2 généré (32 caractères ASCII)"
    else
        error "Échec de la génération du cookie_secret ! Longueur : $cookie_len"
        fail "Longueur attendue : 32 caractères"
    fi

    # Générer le fichier .env
    info "Génération du fichier .env..."

    cat > .env <<EOF
# ═══════════════════════════════════════════════════════════════════════════
# BOLT.DIY-INTRANET v10.5 - Variables d'environnement
# Généré automatiquement le $(date '+%Y-%m-%d %H:%M:%S')
# ═══════════════════════════════════════════════════════════════════════════

# ───────────────────────────────────────────────────────────────────────────
# RÉSEAU ET PORTS
# ───────────────────────────────────────────────────────────────────────────
LOCAL_IP=$LOCAL_IP
PUBLIC_IP=$PUBLIC_IP
HOST_PORT_PORTAL=$HOST_PORT_PORTAL
HOST_PORT_BOLT=$HOST_PORT_BOLT
HOST_PORT_KEYCLOAK=$HOST_PORT_KEYCLOAK

# URL Documentation
DOCS_URL=https://github.com/NBILITY-HOME/BOLT.DIY-INTRANET/wiki

# ───────────────────────────────────────────────────────────────────────────
# BASE DE DONNÉES MARIADB
# ───────────────────────────────────────────────────────────────────────────
MARIADB_ROOT_PASSWORD=$MARIADB_ROOT_PASSWORD

# ───────────────────────────────────────────────────────────────────────────
# KEYCLOAK (Serveur d'authentification)
# ───────────────────────────────────────────────────────────────────────────
KEYCLOAK_ADMIN_PASSWORD=$KEYCLOAK_ADMIN_PASSWORD
KEYCLOAK_DB_PASSWORD=$KEYCLOAK_DB_PASSWORD

# ───────────────────────────────────────────────────────────────────────────
# OAUTH2-PROXY (Protection Bolt.DIY)
# ───────────────────────────────────────────────────────────────────────────
OAUTH2_CLIENT_ID=$OAUTH2_CLIENT_ID
OAUTH2_CLIENT_SECRET=$OAUTH2_CLIENT_SECRET
OAUTH2_COOKIE_SECRET=$OAUTH2_COOKIE_SECRET

# ───────────────────────────────────────────────────────────────────────────
# CHEMINS VOLUMES DOCKER
# ───────────────────────────────────────────────────────────────────────────
NGINX_PORTAL_CONFIG=./DATA-LOCAL/nginx-portal/nginx.conf
NGINX_PORTAL_HTML=./DATA-LOCAL/nginx-portal/html
MARIADB_DIR=./DATA-LOCAL/mariadb
OAUTH2_PROXY_CONFIG=./DATA-LOCAL/oauth2-proxy/oauth2-proxy.cfg
EOF

    chmod 600 .env
    ok "Fichier .env généré et sécurisé"

    # Exporter les variables
    export MARIADB_ROOT_PASSWORD
    export KEYCLOAK_ADMIN_PASSWORD
    export KEYCLOAK_DB_PASSWORD
    export OAUTH2_CLIENT_ID
    export OAUTH2_CLIENT_SECRET
    export OAUTH2_COOKIE_SECRET

    ok "Tous les secrets ont été générés avec succès"
}

