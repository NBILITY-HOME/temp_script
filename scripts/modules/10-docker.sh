#!/bin/bash

###############################################################################
# Module 10 : Démarrage de la Stack Docker Compose
###############################################################################

start_docker() {
    section "10/11 - Démarrage de la stack Docker Compose"

    # =========================================================================
    # ÉTAPE 0 : Vérifier que les réseaux Docker existent
    # =========================================================================

    info "Vérification des réseaux Docker..."

    # Réseau interne : bolt-network (créé par 03-network.sh)
    if docker network inspect bolt-network &>/dev/null; then
        ok "Réseau 'bolt-network' existe"
    else
        error "Réseau 'bolt-network' introuvable"
        fail "Vérifier que 03-network.sh a été exécuté correctement"
    fi

    # Réseau proxy (nginx-proxy-automation)
    NETWORK_NAME="${NETWORK:-proxy}"

    if docker network inspect "$NETWORK_NAME" &>/dev/null; then
        ok "Réseau '$NETWORK_NAME' existe (nginx-proxy-automation)"
    else
        error "Réseau '$NETWORK_NAME' introuvable"
        fail "Vérifier que nginx-proxy-automation est configuré"
    fi

    echo ""

    # =========================================================================
    # ÉTAPE 1 : Vérifier que docker-compose.yml existe
    # =========================================================================

    if [ ! -f docker-compose.yml ]; then
        error "Fichier docker-compose.yml introuvable"
        fail "Vérifier la structure du projet"
    fi

    ok "Fichier docker-compose.yml trouvé"
    echo ""

    # =========================================================================
    # ÉTAPE 2 : Arrêter les conteneurs existants
    # =========================================================================

    info "Arrêt des conteneurs existants (si présents)..."

    if docker compose down 2>/dev/null; then
        ok "Conteneurs arrêtés"
    else
        warn "Aucun conteneur à arrêter"
    fi

    echo ""

    # =========================================================================
    # ÉTAPE 3 : Démarrer la stack Docker Compose
    # =========================================================================

    info "Démarrage de la stack Docker Compose..."
    info "Cela peut prendre plusieurs minutes (téléchargement des images, init DB, etc.)"
    echo ""

    if docker compose up -d; then
        ok "Stack Docker Compose démarrée"
    else
        error "Échec du démarrage de Docker Compose"
        fail "Consulter les logs : docker compose logs"
    fi

    echo ""

    # =========================================================================
    # ÉTAPE 4 : Attendre le démarrage des services
    # =========================================================================

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
    info "Attente de Keycloak (peut prendre 1-2 minutes)...\n"
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

    # =========================================================================
    # ÉTAPE 5 : Vérifier la connectivité réseau
    # =========================================================================

    echo ""
    info "Vérification de la connectivité réseau..."

    # Vérifier que portal est connectée aux 2 réseaux
    if docker ps --filter "name=bolt-nginx-portal" --quiet &>/dev/null; then
        local portal_networks=$(docker inspect --format='{{range $name, $config := .NetworkSettings.Networks}}{{$name}} {{end}}' bolt-nginx-portal 2>/dev/null)

        if echo "$portal_networks" | grep -q "bolt-network"; then
            ok "Portal connectée à 'bolt-network'"
        else
            error "Portal NON connectée à 'bolt-network'"
        fi

        if echo "$portal_networks" | grep -q "$NETWORK_NAME"; then
            ok "Portal connectée à '$NETWORK_NAME' (nginx-proxy-automation)"
        else
            error "Portal NON connectée à '$NETWORK_NAME'"
        fi
    fi

    echo ""

    # =========================================================================
    # ÉTAPE 6 : Afficher le statut final
    # =========================================================================

    info "Statut des conteneurs :"
    echo ""
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "name=bolt-"
    echo ""

    ok "Stack Docker Compose démarrée avec succès"
}
