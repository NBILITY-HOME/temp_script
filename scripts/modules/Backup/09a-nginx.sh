#!/bin/bash

###############################################################################
# Module 09 : Configuration Nginx
###############################################################################

configure_nginx() {
    section "9/11 - Configuration Nginx"

    info "Vérification de la configuration Nginx..."

    if [ -f DATA-LOCAL/nginx-portal/nginx.conf ]; then
        ok "Configuration Nginx existante"
    else
        warn "Configuration Nginx manquante"
        fail "Relancer le module 04-directories.sh"
    fi

    if [ -f DATA-LOCAL/nginx-portal/html/index.html ]; then
        ok "Page d'accueil HTML existante"
    else
        warn "Page d'accueil manquante"
        fail "Relancer le module 04-directories.sh"
    fi

    ok "Nginx configuré avec succès"
}

