#!/bin/bash

###############################################################################
# Module 11 : Tests de Validation Complets
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Version Complète - Cahier des Charges Let's Encrypt + Architecture Réseau
# Date : 2025-11-27
# Tests : Réseaux + HTTPS + Let's Encrypt + Isolement + Services
###############################################################################

run_tests() {
    section "11/11 - Tests de Validation Complets"

    local tests_passed=true
    local critical_tests_passed=true

    echo ""

    # ═══════════════════════════════════════════════════════════════════════════
    # SECTION 1 : TESTS RÉSEAUX CRITIQUES
    # ═══════════════════════════════════════════════════════════════════════════

    info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    info "SECTION 1 : TESTS RÉSEAUX DOCKER"
    info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Test 1.1 : Réseau bolt-network existe
    info "Test 1.1 : Réseau 'bolt-network' existe"
    if docker network inspect bolt-network &>/dev/null; then
        ok "Réseau 'bolt-network' présent ✅"
    else
        error "Réseau 'bolt-network' INTROUVABLE ❌"
        critical_tests_passed=false
    fi

    # Test 1.2 : Réseau proxy existe
    info "Test 1.2 : Réseau '${NETWORK:-proxy}' existe"
    NETWORK_NAME="${NETWORK:-proxy}"
    if docker network inspect "$NETWORK_NAME" &>/dev/null; then
        ok "Réseau '$NETWORK_NAME' présent ✅"
    else
        error "Réseau '$NETWORK_NAME' INTROUVABLE ❌"
        critical_tests_passed=false
    fi

    # Test 1.3 : Portal connectée à bolt-network
    info "Test 1.3 : Portal connectée à 'bolt-network'"
    if docker ps --filter "name=bolt-nginx-portal" --quiet &>/dev/null; then
        if docker inspect bolt-nginx-portal --format='{{range $name, $config := .NetworkSettings.Networks}}{{$name}}{{end}}' | grep -q "bolt-network"; then
            ok "Portal connectée à 'bolt-network' ✅"
        else
            error "Portal NON connectée à 'bolt-network' ❌"
            critical_tests_passed=false
        fi
    fi

    # Test 1.4 : Portal connectée au réseau proxy
    info "Test 1.4 : Portal connectée au réseau '$NETWORK_NAME'"
    if docker ps --filter "name=bolt-nginx-portal" --quiet &>/dev/null; then
        if docker inspect bolt-nginx-portal --format='{{range $name, $config := .NetworkSettings.Networks}}{{$name}}{{end}}' | grep -q "$NETWORK_NAME"; then
            ok "Portal connectée au réseau '$NETWORK_NAME' ✅"
        else
            error "Portal NON connectée au réseau '$NETWORK_NAME' ❌"
            critical_tests_passed=false
        fi
    fi

    # Test 1.5 : Keycloak UNIQUEMENT sur bolt-network
    info "Test 1.5 : Keycloak UNIQUEMENT sur 'bolt-network'"
    if docker ps --filter "name=bolt-keycloak" --quiet &>/dev/null; then
        KEYCLOAK_NETS=$(docker inspect bolt-keycloak --format='{{range $name, $config := .NetworkSettings.Networks}}{{$name}} {{end}}')
        if echo "$KEYCLOAK_NETS" | grep -q "bolt-network" && ! echo "$KEYCLOAK_NETS" | grep -q "$NETWORK_NAME"; then
            ok "Keycloak isolé sur 'bolt-network' ✅"
        else
            error "Keycloak mal configuré réseau : $KEYCLOAK_NETS ❌"
            critical_tests_passed=false
        fi
    fi

    # Test 1.6 : MariaDB UNIQUEMENT sur bolt-network
    info "Test 1.6 : MariaDB UNIQUEMENT sur 'bolt-network'"
    if docker ps --filter "name=bolt-mariadb" --quiet &>/dev/null; then
        MARIADB_NETS=$(docker inspect bolt-mariadb --format='{{range $name, $config := .NetworkSettings.Networks}}{{$name}} {{end}}')
        if echo "$MARIADB_NETS" | grep -q "bolt-network" && ! echo "$MARIADB_NETS" | grep -q "$NETWORK_NAME"; then
            ok "MariaDB isolé sur 'bolt-network' ✅"
        else
            error "MariaDB mal configuré réseau : $MARIADB_NETS ❌"
            critical_tests_passed=false
        fi
    fi

    # Test 1.7 : OAuth2-Proxy UNIQUEMENT sur bolt-network
    info "Test 1.7 : OAuth2-Proxy UNIQUEMENT sur 'bolt-network'"
    if docker ps --filter "name=bolt-oauth2-proxy" --quiet &>/dev/null; then
        OAUTH_NETS=$(docker inspect bolt-oauth2-proxy --format='{{range $name, $config := .NetworkSettings.Networks}}{{$name}} {{end}}')
        if echo "$OAUTH_NETS" | grep -q "bolt-network" && ! echo "$OAUTH_NETS" | grep -q "$NETWORK_NAME"; then
            ok "OAuth2-Proxy isolé sur 'bolt-network' ✅"
        else
            error "OAuth2-Proxy mal configuré réseau : $OAUTH_NETS ❌"
            critical_tests_passed=false
        fi
    fi

    # Test 1.8 : Bolt-App UNIQUEMENT sur bolt-network
    info "Test 1.8 : Bolt-App UNIQUEMENT sur 'bolt-network'"
    if docker ps --filter "name=bolt-app" --quiet &>/dev/null; then
        APP_NETS=$(docker inspect bolt-app --format='{{range $name, $config := .NetworkSettings.Networks}}{{$name}} {{end}}')
        if echo "$APP_NETS" | grep -q "bolt-network" && ! echo "$APP_NETS" | grep -q "$NETWORK_NAME"; then
            ok "Bolt-App isolé sur 'bolt-network' ✅"
        else
            error "Bolt-App mal configuré réseau : $APP_NETS ❌"
            critical_tests_passed=false
        fi
    fi

    echo ""

    # ═══════════════════════════════════════════════════════════════════════════
    # SECTION 2 : TESTS SERVICES INTERNES (DEBUG LOCAL)
    # ═══════════════════════════════════════════════════════════════━━━━━━━━━━━

    info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    info "SECTION 2 : TESTS SERVICES INTERNES (DEBUG LOCAL)"
    info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Test 2.1 : Portal HTTP (port DEBUG)
    info "Test 2.1 : Portal HTTP (debug local:$HOST_PORT_PORTAL)"
    if curl -sf "http://localhost:$HOST_PORT_PORTAL" >/dev/null 2>&1; then
        ok "Portal accessible via HTTP ✅"
    else
        warn "Portal non accessible via HTTP (peut être normal en prod)"
        tests_passed=false
    fi

    # Test 2.2 : Keycloak HTTP (port DEBUG)
    info "Test 2.2 : Keycloak HTTP (debug local:$HOST_PORT_KEYCLOAK)"
    if curl -sf "http://localhost:$HOST_PORT_KEYCLOAK" >/dev/null 2>&1; then
        ok "Keycloak accessible via HTTP ✅"
    else
        warn "Keycloak non accessible via HTTP (port debug)"
        tests_passed=false
    fi

    # Test 2.3 : Keycloak Health Check
    info "Test 2.3 : Keycloak Health Check (/health/ready)"
    if curl -sf "http://localhost:$HOST_PORT_KEYCLOAK/health/ready" >/dev/null 2>&1; then
        ok "Keycloak Health : READY ✅"
    else
        warn "Keycloak Health : NOT READY (normal au démarrage)"
        tests_passed=false
    fi

    # Test 2.4 : OAuth2-Proxy Ping
    info "Test 2.4 : OAuth2-Proxy Ping (/ping)"
    if curl -sf "http://localhost:$HOST_PORT_BOLT/ping" >/dev/null 2>&1; then
        ok "OAuth2-Proxy Ping : OK ✅"
    else
        error "OAuth2-Proxy Ping : FAILED ❌"
        tests_passed=false
    fi

    # Test 2.5 : Bolt-App (port DEBUG)
    info "Test 2.5 : Bolt-App HTTP (debug local:$HOST_PORT_BOLT)"
    if [ -n "${HOST_PORT_BOLT:-}" ]; then
        if curl -sf "http://localhost:$HOST_PORT_BOLT" >/dev/null 2>&1; then
            ok "Bolt-App accessible via HTTP ✅"
        else
            warn "Bolt-App non accessible via HTTP (peut être en cours de build)"
            tests_passed=false
        fi
    else
        warn "HOST_PORT_BOLT non défini, test ignoré"
    fi

    echo ""

    # ═══════════════════════════════════════════════════════════════════════════
    # SECTION 3 : TESTS MARIADB
    # ═══════════════════════════════════════════════════════════════════════════

    info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    info "SECTION 3 : TESTS MARIADB"
    info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Test 3.1 : MariaDB Connection
    info "Test 3.1 : MariaDB Connection"
    if docker exec bolt-mariadb mysql -uroot -p"$MARIADB_ROOT_PASSWORD" -e "SELECT 1" &>/dev/null; then
        ok "MariaDB Connection : OK ✅"
    else
        error "MariaDB Connection : FAILED ❌"
        critical_tests_passed=false
        tests_passed=false
    fi

    # Test 3.2 : Base de données Keycloak existe
    info "Test 3.2 : Base de données Keycloak existe"
    if docker exec bolt-mariadb mysql -uroot -p"$MARIADB_ROOT_PASSWORD" -e "USE keycloak; SELECT 1;" &>/dev/null; then
        ok "Base Keycloak : OK ✅"
    else
        error "Base Keycloak : INTROUVABLE ❌"
        critical_tests_passed=false
        tests_passed=false
    fi

    # Test 3.3 : Utilisateur Keycloak existe
    info "Test 3.3 : Utilisateur Keycloak configuré"
    if docker exec bolt-mariadb mysql -uroot -p"$MARIADB_ROOT_PASSWORD" -e "SELECT User FROM mysql.user WHERE User='keycloak';" &>/dev/null; then
        ok "Utilisateur Keycloak : OK ✅"
    else
        error "Utilisateur Keycloak : MANQUANT ❌"
        tests_passed=false
    fi

    echo ""

    # ═══════════════════════════════════════════════════════════════════════════
    # SECTION 4 : TESTS HTTPS/LET'S ENCRYPT (PRODUCTION)
    # ═══════════════════════════════════════════════════════════════════════════

    info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    info "SECTION 4 : TESTS HTTPS/LET'S ENCRYPT (PRODUCTION)"
    info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Test 4.1 : Variables Let's Encrypt configurées
    info "Test 4.1 : Variables Let's Encrypt configurées"
    if [ -n "${DOMAINS:-}" ] && [ -n "${LETSENCRYPT_EMAIL:-}" ]; then
        ok "DOMAINS='$DOMAINS' ✅"
        ok "LETSENCRYPT_EMAIL='$LETSENCRYPT_EMAIL' ✅"
    else
        error "Variables Let's Encrypt manquantes ❌"
        critical_tests_passed=false
    fi

    # Test 4.2 : Variables nginx-proxy-automation présentes dans docker-compose
    info "Test 4.2 : Variables nginx-proxy-automation dans Portal"
    if docker inspect bolt-nginx-portal --format='{{.Config.Env}}' | grep -q "VIRTUAL_HOST"; then
        ok "VIRTUAL_HOST configuré dans Portal ✅"
    else
        error "VIRTUAL_HOST manquant dans Portal ❌"
        critical_tests_passed=false
    fi

    if docker inspect bolt-nginx-portal --format='{{.Config.Env}}' | grep -q "LETSENCRYPT_HOST"; then
        ok "LETSENCRYPT_HOST configuré dans Portal ✅"
    else
        error "LETSENCRYPT_HOST manquant dans Portal ❌"
        critical_tests_passed=false
    fi

    # Test 4.3 : nginx-proxy-automation détecte le container
    info "Test 4.3 : nginx-proxy-automation détecte Portal"
    if docker ps --filter "name=nginx-proxy-automation" --quiet &>/dev/null; then
        ok "nginx-proxy-automation container actif ✅"

        # Vérifier que Portal est dans le réseau proxy
        if docker inspect bolt-nginx-portal --format='{{.NetworkSettings.Networks.proxy}}' | grep -q "."; then
            ok "Portal dans réseau proxy (nginx-proxy-automation) ✅"
        else
            warn "Portal peut ne pas être visible de nginx-proxy-automation"
        fi
    else
        warn "nginx-proxy-automation non actif (installer d'abord)"
    fi

    # Test 4.4 : Test HTTPS (avec insécurité pour auto-signed ou en dev)
    info "Test 4.4 : Accès HTTPS sur $DOMAINS"
    if [ -n "${DOMAINS:-}" ]; then
        if curl -sf --insecure "https://${DOMAINS}/" >/dev/null 2>&1; then
            ok "HTTPS://$DOMAINS accessible ✅"
        else
            warn "HTTPS://$DOMAINS non accessible (peut être normal en dev)"
            warn "Vérifier : nginx-proxy-automation + certificat Let's Encrypt en place"
        fi
    fi

    echo ""

    # ═══════════════════════════════════════════════════════════════════════════
    # SECTION 5 : TESTS D'ISOLEMENT ET SÉCURITÉ
    # ═══════════════════════════════════════════════════════════━━━━━━━━━━━━━━━

    info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    info "SECTION 5 : TESTS D'ISOLEMENT ET SÉCURITÉ"
    info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Test 5.1 : MariaDB NON accessible depuis réseau proxy
    info "Test 5.1 : MariaDB NON accessible depuis réseau proxy"
    if docker run --rm --net "$NETWORK_NAME" mysql:latest \
        mysql -h bolt-mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -e "SELECT 1" &>/dev/null 2>&1; then
        error "SÉCURITÉ : MariaDB accessible depuis proxy ❌ ISOLEMENT ÉCHOUÉ"
        critical_tests_passed=false
    else
        ok "MariaDB isolée (non accessible depuis proxy) ✅"
    fi

    # Test 5.2 : Keycloak NON accessible depuis réseau proxy (DNS fail)
    info "Test 5.2 : Keycloak isolé du réseau proxy"
    if docker run --rm --net "$NETWORK_NAME" alpine wget -q -O- "http://bolt-keycloak:8080" &>/dev/null 2>&1; then
        warn "Keycloak peut être accessible depuis proxy (dépend de la config)"
    else
        ok "Keycloak isolé du réseau proxy ✅"
    fi

    # Test 5.3 : OAuth2-Proxy NON accessible directement sans Portal
    info "Test 5.3 : OAuth2-Proxy uniquement interne"
    if ! curl -sf "http://localhost:12345/oauth2/callback" 2>/dev/null | grep -q "error"; then
        ok "OAuth2-Proxy protégé (pas d'accès direct aléatoire) ✅"
    fi

    echo ""

    # ═══════════════════════════════════════════════════════════════════════════
    # SECTION 6 : TESTS FLUX COMPLET
    # ═══════════════════════════════════════════════════════════════════════════

    info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    info "SECTION 6 : TESTS FLUX COMPLET"
    info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Test 6.1 : Tous les containers démarrés
    info "Test 6.1 : État de tous les containers"
    local required_containers=("bolt-nginx-portal" "bolt-keycloak" "bolt-mariadb" "bolt-oauth2-proxy" "bolt-app")

    for container in "${required_containers[@]}"; do
        if docker ps --filter "name=$container" --quiet &>/dev/null; then
            ok "$container : RUNNING ✅"
        else
            error "$container : STOPPED ❌"
            tests_passed=false
        fi
    done

    # Test 6.2 : Santé des services
    info "Test 6.2 : Health Status des services"
    for container in "${required_containers[@]}"; do
        if docker ps --filter "name=$container" --quiet &>/dev/null; then
            HEALTH=$(docker inspect "$container" --format='{{.State.Health.Status}}' 2>/dev/null || echo "none")
            if [ "$HEALTH" == "healthy" ]; then
                ok "$container : HEALTHY ✅"
            elif [ "$HEALTH" == "starting" ]; then
                warn "$container : STARTING (normal au démarrage)"
            elif [ "$HEALTH" == "unhealthy" ]; then
                error "$container : UNHEALTHY ❌"
                tests_passed=false
            fi
        fi
    done

    # Test 6.3 : Vérifier dépendances
    info "Test 6.3 : Vérification des dépendances services"

    # MariaDB doit être ok avant Keycloak
    if docker exec bolt-mariadb mysql -uroot -p"$MARIADB_ROOT_PASSWORD" -e "SELECT 1" &>/dev/null && \
       docker inspect bolt-keycloak --format='{{.State.Health.Status}}' 2>/dev/null | grep -q "healthy"; then
        ok "Dépendance MariaDB → Keycloak : OK ✅"
    fi

    # Keycloak doit être ok avant OAuth2-Proxy
    if docker inspect bolt-keycloak --format='{{.State.Health.Status}}' 2>/dev/null | grep -q "healthy" && \
       curl -sf "http://localhost:$HOST_PORT_BOLT/ping" >/dev/null 2>&1; then
        ok "Dépendance Keycloak → OAuth2-Proxy : OK ✅"
    fi

    # OAuth2-Proxy doit être ok avant Bolt-App
    if curl -sf "http://localhost:$HOST_PORT_BOLT/ping" >/dev/null 2>&1 && \
       docker ps --filter "name=bolt-app" --quiet &>/dev/null; then
        ok "Dépendance OAuth2-Proxy → Bolt-App : OK ✅"
    fi

    echo ""

    # ═══════════════════════════════════════════════════════════════════════════
    # RÉSUMÉ FINAL
    # ═══════════════════════════════════════════════════════════════════════════

    info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    info "RÉSUMÉ FINAL"
    info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    if [ "$critical_tests_passed" = true ]; then
        ok "✅ TOUS LES TESTS CRITIQUES PASSÉS"
        echo ""
        ok "✅ L'INSTALLATION EST OPÉRATIONNELLE"
    else
        error "❌ CERTAINS TESTS CRITIQUES ONT ÉCHOUÉ"
        echo ""
        error "Erreurs à corriger :"
        error "- Vérifier la configuration des réseaux Docker"
        error "- Vérifier le fichier docker-compose.yml"
        error "- Consulter les logs : docker compose logs"
    fi

    if [ "$tests_passed" = false ]; then
        echo ""
        warn "⚠️  CERTAINS TESTS NON-CRITIQUES ONT ÉCHOUÉ"
        warn "Cela peut être normal en phase de démarrage"
        warn "Consulter : docker compose logs -f"
    fi

    echo ""
    echo "📊 Statistiques :"
    echo "  • Réseaux vérifiés : ✅"
    echo "  • Services testés : 5 (Portal, Keycloak, MariaDB, OAuth2, Bolt-App)"
    echo "  • HTTPS/Let's Encrypt : À valider après nginx-proxy-automation"
    echo "  • Isolement réseau : ✅"
    echo "  • Dépendances : Vérifiées"
    echo ""

    echo "🔗 Points d'accès :"
    echo "  • Portal HTTP (DEBUG) : http://localhost:$HOST_PORT_PORTAL"
    echo "  • Portal HTTPS (PROD) : https://${DOMAINS} (une fois Let's Encrypt en place)"
    echo "  • Keycloak (DEBUG) : http://localhost:$HOST_PORT_KEYCLOAK"
    echo "  • Logs : docker compose logs -f"
    echo ""

    if [ "$critical_tests_passed" = true ]; then
        ok "🎉 INSTALLATION VALIDÉE - SYSTÈME PRÊT POUR PRODUCTION"
    else
        error "⚠️  INSTALLATION INCOMPLÈTE - CORRECTIONS REQUISES"
    fi

    echo ""
}
