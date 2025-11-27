#!/bin/bash

###############################################################################
# Module 09a : Configuration Nginx (production avec nginx-proxy-automation)
###############################################################################

configure_nginx() {

  section "9/11 - Configuration Nginx"

  info "Préparation de la configuration Nginx pour le portail..."

  # ──────────────────────────────────────────────────────────────
  # Vérification / création du répertoire Nginx
  # ──────────────────────────────────────────────────────────────

  if [ ! -d "DATA-LOCAL/nginx-portal" ]; then
    mkdir -p DATA-LOCAL/nginx-portal
    ok "Répertoire DATA-LOCAL/nginx-portal créé"
  else
    ok "Répertoire DATA-LOCAL/nginx-portal existant"
  fi

  if [ ! -d "DATA-LOCAL/nginx-portal/html" ]; then
    mkdir -p DATA-LOCAL/nginx-portal/html
    ok "Répertoire DATA-LOCAL/nginx-portal/html créé"
  else
    ok "Répertoire DATA-LOCAL/nginx-portal/html existant"
  fi

  # ──────────────────────────────────────────────────────────────
  # Vérification de la page d'accueil HTML
  # ──────────────────────────────────────────────────────────────

  if [ -f "DATA-LOCAL/nginx-portal/html/index.html" ]; then
    ok "Page d'accueil HTML existante"
  else
    warn "Page d'accueil manquante : DATA-LOCAL/nginx-portal/html/index.html"
    warn "Elle sera copiée depuis templates/html par le module 04-directories.sh"
  fi

  # ──────────────────────────────────────────────────────────────
  # Copie du template Nginx de production
  # ──────────────────────────────────────────────────────────────

  info "Copie du template Nginx de production (nginx-portal-prod.conf)..."

  TEMPLATE_SRC="templates/nginx/nginx-portal-prod.conf"
  TEMPLATE_DEST="DATA-LOCAL/nginx-portal/nginx.conf"

  if [ ! -f "$TEMPLATE_SRC" ]; then
    fail "Template Nginx manquant : $TEMPLATE_SRC"
    fail "Vérifier le dépôt ou recréer le template."
    return 1
  fi

  ok "Template trouvé : $TEMPLATE_SRC"

  cp "$TEMPLATE_SRC" "$TEMPLATE_DEST"

  if [ $? -eq 0 ]; then
    ok "Template Nginx copié avec succès vers $TEMPLATE_DEST"
  else
    fail "Erreur lors de la copie du template Nginx"
    return 1
  fi

  if [ ! -f "$TEMPLATE_DEST" ]; then
    fail "Configuration Nginx non trouvée après copie"
    return 1
  fi

  ok "Configuration Nginx disponible"

  # ──────────────────────────────────────────────────────────────
  # Création du snippet des headers de sécurité (COOP/COEP)
  # ──────────────────────────────────────────────────────────────

  info "Création du fichier de headers de sécurité pour Bolt.DIY..."

  cat > "DATA-LOCAL/nginx-portal/bolt-headers.conf" <<'EOF'
# Headers de sécurité pour Bolt.DIY WebContainers
# Ces headers sont OBLIGATOIRES pour le terminal (SharedArrayBuffer)

add_header Cross-Origin-Opener-Policy "same-origin" always;
add_header Cross-Origin-Embedder-Policy "require-corp" always;

# Headers de sécurité additionnels
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
EOF

  if [ $? -eq 0 ]; then
    ok "Headers de sécurité configurés (DATA-LOCAL/nginx-portal/bolt-headers.conf)"
  else
    fail "Erreur lors de la création du fichier de headers"
    return 1
  fi

  ok "Configuration Nginx prête à l'emploi (mode production via nginx-proxy-automation)"
  echo ""

}
