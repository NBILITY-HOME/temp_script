#!/bin/bash

clear

###############################################################################
# Module 00 : Variables Globales et Fonctions Utilitaires
###############################################################################

# ==================== COULEURS ====================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# ==================== FICHIERS DE LOG ====================

INSTALL_LOG="/tmp/bolt-install-$(date +%Y%m%d_%H%M%S).log"
ERROR_LOG="/tmp/bolt-install-errors-$(date +%Y%m%d_%H%M%S).log"

# ==================== VARIABLES PROJET ====================

PROJECT_NAME="BOLT.DIY-INTRANET"
PROJECT_VERSION="10.5.0"
GITHUB_REPO_URL="https://github.com/NBILITY-HOME/BOLT.DIY-INTRANET.git"

# FIX: Obtenir le vrai home de l'utilisateur même avec sudo
if [ -n "$SUDO_USER" ]; then
  # Script lancé avec sudo, récupérer le home de l'utilisateur réel
  REAL_USER="$SUDO_USER"
  REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
  # Script lancé sans sudo
  REAL_USER="$USER"
  REAL_HOME="$HOME"
fi

# Chemin d'installation par défaut (proposé à l'utilisateur dans 02-clone.sh)
TARGET_DIR="$REAL_HOME/DOCKER-PROJETS/BOLT.DIY-INTRANET"
LOGS_DIR="$TARGET_DIR/logs"

# ==================== FONCTIONS UTILITAIRES ====================

# Fonction : Sauvegarder les logs dans le projet
save_logs() {
  # Vérifier si le dossier logs existe
  if [ -d "$LOGS_DIR" ]; then
    info "Sauvegarde des logs dans le projet..."
    # Copier les logs
    cp "$INSTALL_LOG" "$LOGS_DIR/" 2>/dev/null || true
    cp "$ERROR_LOG" "$LOGS_DIR/" 2>/dev/null || true

    # Changer le propriétaire si on est root
    if [ "$EUID" -eq 0 ] && [ -n "$REAL_USER" ]; then
      chown -R "$REAL_USER:$REAL_USER" "$LOGS_DIR" 2>/dev/null || true
    fi

    ok "Logs sauvegardés : $LOGS_DIR"
    echo " - $(basename "$INSTALL_LOG")"
    echo " - $(basename "$ERROR_LOG")"
  fi
}

# Fonction : Affichage section
section() {
  echo ""
  echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
  echo -e "${CYAN} $1${NC}"
  echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
  echo ""
}

# Fonction : Information
info() {
  echo -e "${BLUE}ℹ${NC} $1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1" >> "$INSTALL_LOG"
}

# Fonction : Succès
ok() {
  echo -e "${GREEN}✔${NC} $1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] OK: $1" >> "$INSTALL_LOG"
}

# Fonction : Avertissement
warn() {
  echo -e "${YELLOW}⚠${NC} $1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARN: $1" >> "$INSTALL_LOG"
}

# Fonction : Erreur
error() {
  echo -e "${RED}✖${NC} $1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "$ERROR_LOG"
}

# Fonction : Erreur fatale (avec sortie)
fail() {
  error "$1"
  echo ""
  echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
  echo -e "${RED} Installation interrompue${NC}"
  echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
  echo ""

  # Sauvegarder les logs dans le projet (si possible)
  save_logs

  echo "Logs disponibles :"
  echo " - Installation : $INSTALL_LOG"
  echo " - Erreurs      : $ERROR_LOG"

  if [ -d "$LOGS_DIR" ]; then
    echo ""
    echo "Logs également sauvegardés dans :"
    echo " $LOGS_DIR"
  fi

  exit 1
}

# Fonction : Confirmation utilisateur
confirm() {
  local prompt="$1"
  local default="${2:-N}"

  if [ "$default" = "Y" ]; then
    prompt="$prompt [Y/n] "
  else
    prompt="$prompt [y/N] "
  fi

  read -p "$prompt" -r response
  response=${response:-$default}

  case "$response" in
    [yY][eE][sS]|[yY])
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# Fonction : Instructions finales
print_final_instructions() {
  # Sauvegarder les logs dans le projet
  save_logs

  section "✅ INSTALLATION TERMINÉE AVEC SUCCÈS"

  echo ""
  echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║ BOLT.DIY-INTRANET v10.5 est maintenant installé !          ║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${CYAN}📋 ACCÈS AUX SERVICES :${NC}"
  echo ""
  echo " 🌐 Portail Nginx : http://$PUBLIC_IP:$HOST_PORT_PORTAL"
  echo " 🔐 Keycloak Admin : http://$PUBLIC_IP:$HOST_PORT_KEYCLOAK"
  echo "    Username: admin"
  echo "    Password: $KEYCLOAK_ADMIN_PASSWORD"
  echo ""
  echo " 🚀 Bolt.DIY (via OAuth2): http://$PUBLIC_IP:$HOST_PORT_BOLT"
  echo ""
  echo -e "${CYAN}📖 PROCHAINES ÉTAPES :${NC}"
  echo ""
  echo " 1. Accéder à Keycloak Admin Console"
  echo "    → http://$PUBLIC_IP:$HOST_PORT_KEYCLOAK"
  echo ""
  echo " 2. Créer un Realm 'bolt'"
  echo " 3. Créer un Client 'bolt-diy-client'"
  echo " 4. Récupérer le Client Secret et mettre à jour .env"
  echo " 5. Créer un utilisateur test"
  echo ""
  echo " Guide complet : README-KEYCLOAK.md"
  echo ""
  echo -e "${YELLOW}⚠️  IMPORTANT :${NC}"
  echo " Sauvegarder le fichier .env en lieu sûr !"
  echo ""
  echo -e "${CYAN}📂 EMPLACEMENT DU PROJET :${NC}"
  echo " $TARGET_DIR"
  echo " (Propriétaire : $REAL_USER)"
  echo ""
  echo -e "${CYAN}📝 LOGS D'INSTALLATION :${NC}"
  echo " $LOGS_DIR"
  echo ""
}
