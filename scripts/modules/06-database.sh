#!/bin/bash

###############################################################################
# Module 06 : Initialisation Base de Données MariaDB
###############################################################################

init_database() {
    section "6/11 - Initialisation de la base de données MariaDB"

    info "Création du script d'initialisation MariaDB..."

    cat > DATA-LOCAL/mariadb/init/01-init-keycloak.sql <<EOF
-- ═══════════════════════════════════════════════════════════════
-- BOLT.DIY-INTRANET v10.5 - Initialisation Base Keycloak
-- ═══════════════════════════════════════════════════════════════

-- Créer la base de données Keycloak
CREATE DATABASE IF NOT EXISTS keycloak CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Créer l'utilisateur Keycloak
CREATE USER IF NOT EXISTS 'keycloak'@'%' IDENTIFIED BY '$KEYCLOAK_DB_PASSWORD';

-- Accorder tous les privilèges sur la base keycloak
GRANT ALL PRIVILEGES ON keycloak.* TO 'keycloak'@'%';

-- Appliquer les changements
FLUSH PRIVILEGES;

-- Log
SELECT 'Base de données Keycloak initialisée avec succès' AS Status;
EOF

    ok "Script d'initialisation MariaDB créé"

    info "Configuration des permissions..."
    chmod 644 DATA-LOCAL/mariadb/init/01-init-keycloak.sql
    ok "Permissions configurées"

    ok "Base de données MariaDB configurée"
}

