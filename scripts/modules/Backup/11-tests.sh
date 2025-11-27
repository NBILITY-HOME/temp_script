#!/bin/bash

###############################################################################
# Module 11 : Tests de Validation
###############################################################################

run_tests() {
    section "11/11 - Tests de validation"

    local tests_passed=true

    # Test 1 : Nginx Portal
    info "Test 1/5 : Nginx Portal"
    if curl -sf "http://localhost:$HOST_PORT_PORTAL" >/dev/null; then
        ok "Nginx Portal accessible (http://$PUBLIC_IP:$HOST_PORT_PORTAL)"
    else
        error "Nginx Portal non accessible"
        tests_passed=false
    fi

    # Test 2 : Keycloak
    info "Test 2/5 : Keycloak Admin Console"
    if curl -sf "http://localhost:$HOST_PORT_KEYCLOAK" >/dev/null; then
        ok "Keycloak accessible (http://$PUBLIC_IP:$HOST_PORT_KEYCLOAK)"
    else
        error "Keycloak non accessible"
        tests_passed=false
    fi

    # Test 3 : Keycloak Health
    info "Test 3/5 : Keycloak Health Check"
    if curl -sf "http://localhost:$HOST_PORT_KEYCLOAK/health/ready" >/dev/null; then
        ok "Keycloak Health : OK"
    else
        warn "Keycloak Health : Non prêt (normal au premier démarrage)"
    fi

    # Test 4 : OAuth2-Proxy Ping
    info "Test 4/5 : OAuth2-Proxy Ping"
    if curl -sf "http://localhost:$HOST_PORT_BOLT/ping" >/dev/null; then
        ok "OAuth2-Proxy Ping : OK"
    else
        warn "OAuth2-Proxy Ping : Échec (configuration Keycloak requise)"
    fi

    # Test 5 : MariaDB
    info "Test 5/5 : MariaDB Connection"
    if docker exec bolt-mariadb mysql -uroot -p"$MARIADB_ROOT_PASSWORD" -e "SELECT 1" &>/dev/null; then
        ok "MariaDB Connection : OK"

        # Vérifier que la base Keycloak existe
        if docker exec bolt-mariadb mysql -uroot -p"$MARIADB_ROOT_PASSWORD" -e "USE keycloak; SELECT 1;" &>/dev/null; then
            ok "Base de données Keycloak : OK"
        else
            error "Base de données Keycloak : Introuvable"
            tests_passed=false
        fi
    else
        error "MariaDB Connection : Échec"
        tests_passed=false
    fi

    echo ""

    if [ "$tests_passed" = true ]; then
        ok "Tous les tests sont passés avec succès ✅"
    else
        warn "Certains tests ont échoué, mais l'installation peut continuer"
        warn "Consulter les logs : docker compose logs"
    fi
}

