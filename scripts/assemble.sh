#!/bin/bash

###############################################################################
# BOLT.DIY-INTRANET v10.5 - Script d'Assemblage des Modules
#
# Ce script assemble tous les modules en un seul fichier install_bolt_v10.5.sh
# Utiliser ce script pour régénérer l'installeur après modification d'un module
#
# Usage : bash scripts/assemble.sh
###############################################################################

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "═══════════════════════════════════════════════════════════════"
echo "  BOLT.DIY-INTRANET v10.5 - Assemblage des Modules"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Répertoires
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
MODULES_DIR="$SCRIPT_DIR/modules"
OUTPUT_FILE="$PROJECT_DIR/install_bolt_v10.5.sh"

# Vérifier que le dossier modules existe
if [ ! -d "$MODULES_DIR" ]; then
    echo -e "${RED}✖${NC} Erreur : Dossier modules introuvable : $MODULES_DIR"
    exit 1
fi

echo -e "${BLUE}ℹ${NC}  Répertoire modules : $MODULES_DIR"
echo -e "${BLUE}ℹ${NC}  Fichier de sortie : $OUTPUT_FILE"
echo ""

# Liste des modules (AVEC 09a et 09b)
MODULES=(
    "00-variables.sh"
    "01-prerequisites.sh"
    "02-clone.sh"
    "03-network.sh"
    "04-directories.sh"
    "05-secrets.sh"
    "06-database.sh"
    "07-keycloak.sh"
    "08-oauth2proxy.sh"
    "09a-nginx.sh"
    "09b-bolt-prepare.sh"
    "10-docker.sh"
    "11-tests.sh"
)

# Créer le fichier de sortie
echo -e "${BLUE}ℹ${NC}  Création du fichier $OUTPUT_FILE..."

cat > "$OUTPUT_FILE" <<'HEADER'
#!/bin/bash

###############################################################################
# BOLT.DIY-INTRANET v10.5 - Script d'Installation Complet
#
# Architecture : Keycloak + OAuth2-Proxy + Bolt.DIY
# Auteur : NBILITY
# Date : 2025-11-24
#
# ⚠️  FICHIER GÉNÉRÉ AUTOMATIQUEMENT PAR scripts/assemble.sh
# ⚠️  NE PAS MODIFIER DIRECTEMENT - MODIFIER LES MODULES DANS scripts/modules/
#
# Usage : sudo bash install_bolt_v10.5.sh
###############################################################################

set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════
# CHARGEMENT DES MODULES
# ═══════════════════════════════════════════════════════════════════════════

HEADER

echo -e "${GREEN}✔${NC}  En-tête ajouté"

# Assembler tous les modules
echo ""
echo "Assemblage des modules :"

for module in "${MODULES[@]}"; do
    module_path="$MODULES_DIR/$module"

    if [ -f "$module_path" ]; then
        echo -e "${BLUE}  →${NC} $module"

        # Ajouter un séparateur
        cat >> "$OUTPUT_FILE" <<EOF

# ═══════════════════════════════════════════════════════════════════════════
# MODULE : $module
# ═══════════════════════════════════════════════════════════════════════════

EOF

        # Ajouter le contenu du module (sans le shebang)
        tail -n +2 "$module_path" >> "$OUTPUT_FILE"

        echo -e "${GREEN}  ✔${NC} Ajouté"
    else
        echo -e "${RED}  ✖${NC} Module introuvable : $module_path"
        exit 1
    fi
done

# Ajouter la fonction main
cat >> "$OUTPUT_FILE" <<'FOOTER'

# ═══════════════════════════════════════════════════════════════════════════
# FONCTION PRINCIPALE
# ═══════════════════════════════════════════════════════════════════════════

main() {
    # Afficher le titre
    echo "═══════════════════════════════════════════════════════════════"
    echo "  BOLT.DIY-INTRANET v10.5 - Installation avec Keycloak"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""

    # Exécuter les modules dans l'ordre
    check_prerequisites
    check_location_and_clone
    configure_network
    create_directories
    generate_secrets
    init_database
    configure_keycloak
    generate_oauth2proxy_config
    configure_nginx
    prepare_bolt_diy
    start_docker
    run_tests

    # Afficher les instructions finales
    print_final_instructions
}

# ═══════════════════════════════════════════════════════════════════════════
# POINT D'ENTRÉE
# ═══════════════════════════════════════════════════════════════════════════

# Lancer l'installation
main

exit 0
FOOTER

echo -e "${GREEN}✔${NC}  Fonction main ajoutée"

# Rendre le fichier exécutable
chmod +x "$OUTPUT_FILE"
echo -e "${GREEN}✔${NC}  Permissions exécutables ajoutées"

# Compter les lignes
line_count=$(wc -l < "$OUTPUT_FILE")

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo -e "${GREEN}✔ Assemblage terminé avec succès${NC}"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Fichier généré : $OUTPUT_FILE"
echo "Nombre de lignes : $line_count"
echo "Nombre de modules : ${#MODULES[@]}"
echo ""
echo "Pour lancer l'installation :"
echo "  sudo bash install_bolt_v10.5.sh"
echo ""
