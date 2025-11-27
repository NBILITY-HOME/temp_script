#!/bin/bash

###############################################################################
# Module 07 : Configuration Keycloak
###############################################################################

configure_keycloak() {
    section "7/11 - Configuration Keycloak"

    info "Keycloak sera configuré au premier démarrage..."

    ok "Variables Keycloak exportées :"
    echo "   - Admin: admin"
    echo "   - Password: $KEYCLOAK_ADMIN_PASSWORD"
    echo "   - Database: keycloak"
    echo "   - Port: $HOST_PORT_KEYCLOAK"

    warn "Configuration post-installation requise :"
    echo "   1. Créer le Realm 'bolt'"
    echo "   2. Créer le Client 'bolt-diy-client'"
    echo "   3. Configurer les Redirect URIs"
    echo "   4. Créer les utilisateurs"

    ok "Keycloak prêt pour le démarrage"
}

