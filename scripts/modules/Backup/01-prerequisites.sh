#!/bin/bash

###############################################################################
# Module 01 : Vérification des Prérequis Système
###############################################################################

check_prerequisites() {
    section "1/11 - Vérification des prérequis système"

    local checks_passed=true

    # Vérifier root
    if [ "$EUID" -ne 0 ]; then
        error "Ce script doit être exécuté en tant que root (sudo)"
        fail "Relancer avec : sudo bash $0"
    fi
    ok "Droits administrateur : OK"

    # Vérifier Docker
    if command -v docker &>/dev/null; then
        local docker_version=$(docker --version 2>&1 | head -n1)
        ok "Docker installé : $docker_version"
    else
        error "Docker n'est pas installé"
        checks_passed=false
    fi

    # Vérifier Docker Compose
    if docker compose version &>/dev/null; then
        local compose_version=$(docker compose version --short)
        ok "Docker Compose installé : v$compose_version"
    else
        error "Docker Compose n'est pas installé"
        checks_passed=false
    fi

    # Vérifier Git
    if command -v git &>/dev/null; then
        local git_version=$(git --version 2>&1)
        ok "Git installé : $git_version"
    else
        error "Git n'est pas installé"
        checks_passed=false
    fi

    # Vérifier OpenSSL
    if command -v openssl &>/dev/null; then
        ok "OpenSSL installé"
    else
        error "OpenSSL n'est pas installé"
        checks_passed=false
    fi

    # Vérifier Curl
    if command -v curl &>/dev/null; then
        ok "Curl installé"
    else
        error "Curl n'est pas installé"
        checks_passed=false
    fi

    # Vérifier la connexion Internet
    info "Vérification de la connexion Internet..."
    if curl -sf https://www.google.com &>/dev/null; then
        ok "Connexion Internet : OK"
    else
        error "Pas de connexion Internet"
        checks_passed=false
    fi

    # Vérifier la connectivité GitHub
    info "Vérification de la connectivité GitHub..."
    if curl -sf https://github.com &>/dev/null; then
        ok "Connectivité GitHub : OK"
    else
        error "Impossible de se connecter à GitHub"
        checks_passed=false
    fi

    if [ "$checks_passed" = false ]; then
        fail "Certains prérequis ne sont pas satisfaits"
    fi

    ok "Tous les prérequis sont satisfaits"
}
