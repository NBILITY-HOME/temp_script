#!/bin/bash

###############################################################################
# Module 09a : Configuration Nginx
###############################################################################

configure_nginx() {

section "9/11 - Configuration Nginx"

info "Vérification de la configuration Nginx..."

if [ -f DATA-LOCAL/nginx-portal/nginx.conf ]; then
    ok "Configuration Nginx existante"
else
    warn "Configuration Nginx manquante"
    fail "Relancer le module 04-directories.sh"
fi

if [ -f DATA-LOCAL/nginx-portal/html/index.html ]; then
    ok "Page d'accueil HTML existante"
else
    warn "Page d'accueil manquante"
    fail "Relancer le module 04-directories.sh"
fi

# ──────────────────────────────────────────────────────────────
# Ajout optionnel : Configuration des headers COOP/COEP
# ──────────────────────────────────────────────────────────────

info "Configuration des headers de sécurité pour Bolt.DIY..."

# Créer un fichier de snippet pour les headers
cat > DATA-LOCAL/nginx-portal/bolt-headers.conf <<'EOF'
# Headers COOP/COEP pour WebContainers Bolt.DIY
# Ces headers sont OBLIGATOIRES pour le terminal (SharedArrayBuffer)
add_header Cross-Origin-Opener-Policy "same-origin" always;
add_header Cross-Origin-Embedder-Policy "require-corp" always;

# Headers de sécurité additionnels
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
EOF

ok "Headers de sécurité configurés dans bolt-headers.conf"

# Note: Le fichier nginx.conf principal doit inclure ce snippet
# avec la ligne : include /etc/nginx/conf.d/bolt-headers.conf;

ok "Nginx configuré avec succès"

}
