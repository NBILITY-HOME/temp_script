#!/bin/bash

###############################################################################
# Module 04 : Création de l'Arborescence
###############################################################################

create_directories() {

section "4/11 - Création de l'arborescence"

info "Création des répertoires de données..."

# Répertoires principaux
mkdir -p DATA-LOCAL/{nginx-portal,oauth2-proxy,mariadb/{data,init}}
ok "Arborescence DATA-LOCAL créée"

# Vérifier les permissions
info "Configuration des permissions..."
chmod -R 755 DATA-LOCAL/
ok "Permissions configurées"

# ──────────────────────────────────────────────────────────────
# Nginx : configuration
# ──────────────────────────────────────────────────────────────
# NOTE :
# La configuration Nginx finale (nginx.conf) est maintenant gérée
# par le module 09a-nginx.sh qui copie :
# templates/nginx/nginx-portal-prod.conf → DATA-LOCAL/nginx-portal/nginx.conf
#
# Ici, on ne crée plus de nginx.conf minimal pour éviter les conflits.
# On se contente de préparer les dossiers nécessaires.

info "Préparation de la structure Nginx (sans générer nginx.conf)..."

if [ ! -d DATA-LOCAL/nginx-portal/html ]; then
  mkdir -p DATA-LOCAL/nginx-portal/html
  ok "Répertoire DATA-LOCAL/nginx-portal/html créé"
else
  ok "Répertoire DATA-LOCAL/nginx-portal/html existant"
fi

# ──────────────────────────────────────────────────────────────
# Nginx : pages HTML à partir des templates
# ──────────────────────────────────────────────────────────────

info "Installation des templates HTML du portail..."

TEMPLATES_HTML_DIR="templates/html"
DEST_HTML_DIR="DATA-LOCAL/nginx-portal/html"

# Vérifier que le dossier templates/html existe
if [ ! -d "$TEMPLATES_HTML_DIR" ]; then
  warn "Dossier de templates HTML introuvable : $TEMPLATES_HTML_DIR"
  warn "Aucune page HTML n'a été copiée. Vérifie ton dépôt."
else
  # Copier uniquement si aucun index.html n'existe déjà (pour ne pas écraser une customisation)
  if [ ! -f "$DEST_HTML_DIR/index.html" ]; then
    cp "$TEMPLATES_HTML_DIR"/*.html "$DEST_HTML_DIR"/ 2>/dev/null || true
    ok "Templates HTML copiés depuis $TEMPLATES_HTML_DIR vers $DEST_HTML_DIR"
  else
    ok "Un index.html existe déjà dans $DEST_HTML_DIR, aucune copie de templates effectuée"
  fi
fi

# ──────────────────────────────────────────────────────────────
# Nginx : copie des assets (CSS, images, etc.)
# ──────────────────────────────────────────────────────────────

info "Installation des assets du portail (CSS, images, etc.)..."

TEMPLATES_ASSETS_DIR="templates/html/assets"
DEST_ASSETS_DIR="DATA-LOCAL/nginx-portal/html/assets"

if [ ! -d "$TEMPLATES_ASSETS_DIR" ]; then
  warn "Dossier d'assets introuvable : $TEMPLATES_ASSETS_DIR"
  warn "Aucun CSS/images ne sera copié. Vérifie ton dépôt."
else
  # Créer le répertoire destination
  mkdir -p "$DEST_ASSETS_DIR"

  if [ $? -ne 0 ]; then
    fail "Erreur : impossible de créer le répertoire $DEST_ASSETS_DIR"
    return 1
  fi

  # Copier les assets
  if cp "$TEMPLATES_ASSETS_DIR"/* "$DEST_ASSETS_DIR"/ 2>/dev/null; then
    ok "Assets copiés avec succès (CSS, images, etc.)"
  else
    warn "Erreur lors de la copie des assets (continu quand même)"
    warn "Vérifie les permissions ou l'espace disque disponible"
  fi
fi


ok "Arborescence complète créée"

}
