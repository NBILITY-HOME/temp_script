#!/bin/bash

###############################################################################
# Module 10 : Démarrage de la Stack Docker Compose
###############################################################################

start_docker() {
    section "10/11 - Démarrage de la stack Docker Compose"

    # Vérifier que docker-compose.yml existe
    if [ ! -f docker-compose.yml ]; then
        error "Fichier docker-compose.yml introuvable"
        fail "Vérifier la structure du projet"
    fi

    info "Arrêt des conteneurs existants (si présents)..."
    docker compose down 2>/dev/null || true
    ok "Conteneurs arrêtés"

    info "Démarrage de la stack Docker Compose..."
    info "Cela peut prendre plusieurs minutes (téléchargement des images, init DB, etc.)"
    echo ""

    if docker compose up -d; then
        ok "Stack Docker Compose démarrée"
    else
        error "Échec du démarrage de Docker Compose"
        fail "Consulter les logs : docker compose logs"
    fi

    info "Attente du démarrage des services..."
    echo ""

    # Attendre MariaDB
    info "Attente de MariaDB..."
    local retry=0
    local max_retries=30

    while [ $retry -lt $max_retries ]; do
        if docker exec bolt-mariadb mysql -uroot -p"$MARIADB_ROOT_PASSWORD" -e "SELECT 1" &>/dev/null; then
            ok "MariaDB opérationnel"
            break
        fi

        retry=$((retry + 1))
        echo -n "."
        sleep 2
    done
    echo ""

    if [ $retry -eq $max_retries ]; then
        warn "Timeout MariaDB, mais poursuite de l'installation"
    fi

    # Attendre Keycloak
    info "Attente de Keycloak (peut prendre 1-2 minutes)..."
    retry=0
    max_retries=60

    while [ $retry -lt $max_retries ]; do
        if curl -sf "http://localhost:$HOST_PORT_KEYCLOAK/health/ready" &>/dev/null; then
            ok "Keycloak opérationnel"
            break
        fi

        retry=$((retry + 1))
        echo -n "."
        sleep 2
    done
    echo ""

    if [ $retry -eq $max_retries ]; then
        warn "Timeout Keycloak, vérifier manuellement"
    fi

    # Attendre OAuth2-Proxy
    info "Attente de OAuth2-Proxy..."
    retry=0
    max_retries=30

    while [ $retry -lt $max_retries ]; do
        if curl -sf "http://localhost:$HOST_PORT_BOLT/ping" &>/dev/null; then
            ok "OAuth2-Proxy opérationnel"
            break
        fi

        retry=$((retry + 1))
        echo -n "."
        sleep 2
    done
    echo ""

    if [ $retry -eq $max_retries ]; then
        warn "Timeout OAuth2-Proxy, vérifier la configuration Keycloak"
    fi

    # Afficher le statut des conteneurs
    info "Statut des conteneurs :"
    echo ""
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "name=bolt-"
    echo ""

    ok "Stack Docker Compose démarrée avec succès"
}

