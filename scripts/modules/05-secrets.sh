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

  # Valeurs supplémentaires pour docker-compose et Nginx
  # (cohérentes avec docker-compose.yml et 04-directories.sh)

  HOST_PORT_MARIADB="${HOST_PORT_MARIADB:-3306}"
  OAUTH2_REALM="${OAUTH2_REALM:-bolt}"
  NGINX_DIR="DATA-LOCAL/nginx-portal"
  MARIADB_DIR="DATA-LOCAL/mariadb"


  info "Génération du fichier .env..."

  cat > .env <<EOF
# ===================================================================
# BOLT.DIY-INTRANET v10.5 - Configuration d'environnement (.env)
# ===================================================================
# ⚠️  NE PAS COMMITTER CE FICHIER DANS GIT - Contient des secrets !
# ===================================================================

# ===================================================================
# RÉSEAU ET ADRESSES
# ===================================================================
LOCAL_IP=${LOCAL_IP}
PUBLIC_IP=${PUBLIC_IP}

# ===================================================================
# PORTS D'EXPOSITION
# ===================================================================
HOST_PORT_PORTAL=${HOST_PORT_PORTAL}
HOST_PORT_BOLT=${HOST_PORT_BOLT}
HOST_PORT_KEYCLOAK=${HOST_PORT_KEYCLOAK}
HOST_PORT_MARIADB=${HOST_PORT_MARIADB}

# ===================================================================
# DOMAINES ET CERTIFICATS
# ===================================================================
DOMAINS=${DOMAINS}
LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL}
NETWORK=${NETWORK}

# ===================================================================
# MOTS DE PASSE ET SECRETS
# ===================================================================
MARIADB_ROOT_PASSWORD=${MARIADB_ROOT_PASSWORD}
KEYCLOAK_ADMIN_PASSWORD=${KEYCLOAK_ADMIN_PASSWORD}
KEYCLOAK_DB_PASSWORD=${KEYCLOAK_DB_PASSWORD}

# ===================================================================
# RÉPERTOIRES DE DONNÉES
# ===================================================================
NGINX_DIR=${NGINX_DIR}
MARIADB_DIR=${MARIADB_DIR}

# ===================================================================
# OAUTH2 ET KEYCLOAK
# ===================================================================
OAUTH2_CLIENT_ID=${OAUTH2_CLIENT_ID}
OAUTH2_CLIENT_SECRET=${OAUTH2_CLIENT_SECRET}
OAUTH2_COOKIE_SECRET=${OAUTH2_COOKIE_SECRET}
OAUTH2_REALM=${OAUTH2_REALM}
EOF

  ok "Fichier .env généré"

  # Résumé de la configuration
  echo
  section "Résumé de la configuration"
  echo "- LOCAL_IP: $LOCAL_IP"
  echo "- PUBLIC_IP: $PUBLIC_IP"
  echo "- DOMAINS: $DOMAINS"
  echo "- HOST_PORT_PORTAL: $HOST_PORT_PORTAL"
  echo "- HOST_PORT_BOLT: $HOST_PORT_BOLT"
  echo "- HOST_PORT_KEYCLOAK: $HOST_PORT_KEYCLOAK"
  echo "- HOST_PORT_MARIADB: $HOST_PORT_MARIADB"
  echo "- NGINX_DIR: $NGINX_DIR"
  echo "- MARIADB_DIR: $MARIADB_DIR"
  echo "- OAUTH2_REALM: $OAUTH2_REALM"
  echo

}
