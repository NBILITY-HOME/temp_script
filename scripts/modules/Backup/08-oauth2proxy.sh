#!/bin/bash

###############################################################################
# Module 08 : Génération Configuration OAuth2-Proxy
###############################################################################

generate_oauth2proxy_config() {
    section "8/11 - Génération de la configuration OAuth2-Proxy"

    info "Création du dossier de configuration OAuth2-Proxy..."
    mkdir -p DATA-LOCAL/oauth2-proxy

    # Vérifier si le template existe, sinon le créer
    if [ ! -f templates/oauth2-proxy/oauth2-proxy.cfg.template ]; then
        warn "Template oauth2-proxy.cfg.template introuvable"
        info "Création du template à la volée..."

        # Créer le dossier templates si nécessaire
        mkdir -p templates/oauth2-proxy

        # Créer le template
        cat > templates/oauth2-proxy/oauth2-proxy.cfg.template <<'TEMPLATE_EOF'
# ═══════════════════════════════════════════════════════════════
# BOLT.DIY-INTRANET v10.5 - Configuration OAuth2-Proxy + Keycloak
# ═══════════════════════════════════════════════════════════════

# Serveur HTTP
http_address = "0.0.0.0:4180"
upstreams = ["http://bolt-app:5173"]

# ───────────────────────────────────────────────────────────────
# PROVIDER KEYCLOAK OIDC
# ───────────────────────────────────────────────────────────────
provider = "oidc"
oidc_issuer_url = "http://${PUBLIC_IP}:${HOST_PORT_KEYCLOAK}/realms/bolt"
redirect_url = "http://${PUBLIC_IP}:${HOST_PORT_BOLT}/oauth2/callback"

# ───────────────────────────────────────────────────────────────
# CLIENT OAUTH2 (configuré dans Keycloak)
# ───────────────────────────────────────────────────────────────
client_id = "${OAUTH2_CLIENT_ID}"
client_secret = "${OAUTH2_CLIENT_SECRET}"

# Scopes OIDC
scope = "openid profile email"

# ───────────────────────────────────────────────────────────────
# VALIDATION EMAIL
# ───────────────────────────────────────────────────────────────
email_domains = ["*"]

# ───────────────────────────────────────────────────────────────
# COOKIE SETTINGS
# ───────────────────────────────────────────────────────────────
cookie_name = "_oauth2_proxy_bolt"
cookie_secret = "${OAUTH2_COOKIE_SECRET}"
cookie_secure = false
cookie_httponly = true
cookie_samesite = "lax"
cookie_refresh = "1h"
cookie_expire = "168h"

# ───────────────────────────────────────────────────────────────
# SESSION
# ───────────────────────────────────────────────────────────────
session_cookie_minimal = false

# ───────────────────────────────────────────────────────────────
# HEADERS (transmission des infos utilisateur à l'application)
# ───────────────────────────────────────────────────────────────
pass_authorization_header = true
pass_access_token = true
pass_user_headers = true
set_authorization_header = true
set_xauthrequest = true

# ───────────────────────────────────────────────────────────────
# LOGGING
# ───────────────────────────────────────────────────────────────
request_logging = true
auth_logging = true

# ───────────────────────────────────────────────────────────────
# REVERSE PROXY
# ───────────────────────────────────────────────────────────────
reverse_proxy = true
real_client_ip_header = "X-Real-IP"
TEMPLATE_EOF

        ok "Template créé automatiquement"
    else
        ok "Template existant trouvé"
    fi

    info "Génération du fichier oauth2-proxy.cfg depuis le template..."

    # Générer le fichier depuis le template
    sed -e "s|\${PUBLIC_IP}|${PUBLIC_IP}|g" \
        -e "s|\${HOST_PORT_KEYCLOAK}|${HOST_PORT_KEYCLOAK}|g" \
        -e "s|\${HOST_PORT_BOLT}|${HOST_PORT_BOLT}|g" \
        -e "s|\${OAUTH2_CLIENT_ID}|${OAUTH2_CLIENT_ID}|g" \
        -e "s|\${OAUTH2_CLIENT_SECRET}|${OAUTH2_CLIENT_SECRET}|g" \
        -e "s|\${OAUTH2_COOKIE_SECRET}|${OAUTH2_COOKIE_SECRET}|g" \
        templates/oauth2-proxy/oauth2-proxy.cfg.template > DATA-LOCAL/oauth2-proxy/oauth2-proxy.cfg

    ok "Fichier oauth2-proxy.cfg généré"

    # Vérifier le contenu
    info "Vérification de la configuration..."

    if grep -q "bolt-diy-client" DATA-LOCAL/oauth2-proxy/oauth2-proxy.cfg; then
        ok "Client ID : bolt-diy-client"
    else
        error "Client ID non trouvé dans la configuration"
    fi

    if grep -q "http://$PUBLIC_IP:$HOST_PORT_KEYCLOAK/realms/bolt" DATA-LOCAL/oauth2-proxy/oauth2-proxy.cfg; then
        ok "OIDC Issuer URL : http://$PUBLIC_IP:$HOST_PORT_KEYCLOAK/realms/bolt"
    else
        error "OIDC Issuer URL incorrect"
    fi

    ok "Configuration OAuth2-Proxy générée avec succès"
}

