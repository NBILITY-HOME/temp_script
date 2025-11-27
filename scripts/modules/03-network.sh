#!/bin/bash

###############################################################################
# Module 03 : Configuration Réseau et Ports
###############################################################################

configure_network() {
    section "3/11 - Configuration réseau et ports"

    # Détection IP locale
    info "Détection de l'adresse IP locale..."
    LOCAL_IP=$(ip route get 1 | awk '{print $7; exit}')

    if [ -z "$LOCAL_IP" ]; then
        warn "Impossible de détecter automatiquement l'IP"
        read -p "Entrer l'IP locale manuellement : " LOCAL_IP
    fi

    ok "IP locale détectée : $LOCAL_IP"

    # Demander l'IP publique
    info "Configuration de l'adresse IP publique..."
    read -p "IP publique (défaut: $LOCAL_IP) : " PUBLIC_IP
    PUBLIC_IP=${PUBLIC_IP:-$LOCAL_IP}
    ok "IP publique : $PUBLIC_IP"

    # Demander les ports
    info "Configuration des ports d'exposition..."

    read -p "Port Portail Nginx (défaut: 8585) : " HOST_PORT_PORTAL
    HOST_PORT_PORTAL=${HOST_PORT_PORTAL:-8585}
    ok "Port Portail : $HOST_PORT_PORTAL"

    read -p "Port Bolt.DIY (défaut: 3000) : " HOST_PORT_BOLT
    HOST_PORT_BOLT=${HOST_PORT_BOLT:-3000}
    ok "Port Bolt.DIY : $HOST_PORT_BOLT"

    read -p "Port Keycloak (défaut: 8080) : " HOST_PORT_KEYCLOAK
    HOST_PORT_KEYCLOAK=${HOST_PORT_KEYCLOAK:-8080}

    # Vérifier que le port Keycloak est disponible
    if netstat -tuln 2>/dev/null | grep -q ":$HOST_PORT_KEYCLOAK "; then
        warn "Le port $HOST_PORT_KEYCLOAK est déjà utilisé"
        read -p "Choisir un autre port pour Keycloak : " HOST_PORT_KEYCLOAK
    fi
    ok "Port Keycloak : $HOST_PORT_KEYCLOAK"

    # Créer le réseau Docker si nécessaire
    info "Vérification du réseau Docker..."
    if ! docker network inspect bolt-network &>/dev/null; then
        info "Création du réseau Docker 'bolt-network'..."
        docker network create bolt-network
        ok "Réseau Docker créé"
    else
        ok "Réseau Docker existant"
    fi

    # Exporter les variables
    export LOCAL_IP
    export PUBLIC_IP
    export HOST_PORT_PORTAL
    export HOST_PORT_BOLT
    export HOST_PORT_KEYCLOAK
}

