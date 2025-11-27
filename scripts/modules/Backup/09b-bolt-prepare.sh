#!/bin/bash

###############################################################################
# Module 09b : Préparation et Build de Bolt.DIY
###############################################################################

prepare_bolt_diy() {
    section "9b/12 - Préparation et Build de Bolt.DIY"

    # =========================================================================
    # 1. VÉRIFICATION DU SUBMODULE
    # =========================================================================
    info "Vérification du sous-module bolt.diy..."

    if [ ! -d "bolt.diy" ]; then
        error "Le dossier bolt.diy n'existe pas"
        fail "Vérifier le clonage du dépôt avec --recurse-submodules"
    fi
    ok "Dossier bolt.diy : présent"

    if [ ! -d bolt.diy/.git ]; then
        warn "Submodule bolt.diy non initialisé"
        info "Initialisation du submodule..."
        git submodule update --init --recursive bolt.diy
        ok "Submodule initialisé"
    else
        ok "Submodule bolt.diy initialisé"

        # 👇 AJOUT ICI : Mise à jour du submodule pour être sûr
        info "Mise à jour du submodule bolt.diy..."
        git submodule update --init --recursive bolt.diy
        ok "Submodule mis à jour"
    fi

    # =========================================================================
    # 2. GESTION DU FICHIER .env
    # =========================================================================
    info "Configuration du fichier .env pour Bolt.DIY..."

    if [ ! -f "bolt.diy/.env.production" ]; then
        error "Le fichier bolt.diy/.env.production n'existe pas"
        fail "Vérifier l'intégrité du sous-module bolt.diy"
    fi
    ok "Fichier .env.production : présent"

    # Copier .env.production vers .env
    info "Création de bolt.diy/.env depuis .env.production..."
    cp bolt.diy/.env.production bolt.diy/.env

    if [ ! -f "bolt.diy/.env" ]; then
        error "Échec de la création de bolt.diy/.env"
        fail "Vérifier les permissions"
    fi
    ok "Fichier bolt.diy/.env créé"

    # =========================================================================
    # 3. GESTION DU DOCKERFILE CUSTOM
    # =========================================================================
    info "Vérification du Dockerfile custom NBILITY..."

    if [ ! -f "templates/bolt.diy/Dockerfile" ]; then
        error "Dockerfile custom introuvable : templates/bolt.diy/Dockerfile"
        fail "Le Dockerfile custom est nécessaire pour les corrections essentielles"
    fi
    ok "Dockerfile custom NBILITY : présent"

    # Afficher les corrections apportées
    info "Corrections NBILITY dans le Dockerfile custom :"
    echo "   ✓ Fix Wrangler PATH (/app/node_modules/.bin)"
    echo "   ✓ Copie de wrangler.toml"
    echo "   ✓ Copie de bindings.sh"
    echo "   ✓ Copie du dossier functions/"
    echo "   ✓ Désactivation des métriques Wrangler"

    # Sauvegarder le Dockerfile original si présent
    if [ -f "bolt.diy/Dockerfile" ] && [ ! -f "bolt.diy/Dockerfile.original" ]; then
        info "Sauvegarde du Dockerfile original..."
        cp bolt.diy/Dockerfile bolt.diy/Dockerfile.original
        ok "Dockerfile original sauvegardé"
    fi

    info "Copie des fichiers personnalisés..."

    # Copier le Dockerfile custom
    cp templates/bolt.diy/Dockerfile bolt.diy/Dockerfile

    if [ ! -f "bolt.diy/Dockerfile" ]; then
        error "Échec de la copie du Dockerfile custom"
        fail "Vérifier les permissions"
    fi
    ok "Dockerfile custom appliqué : bolt.diy/Dockerfile"

    # Création dossier header
    mkdir -p bolt.diy/app/components/header
    if [ ! -d "bolt.diy/app/components/header" ]; then
        error "Échec : dossier bolt.diy/app/components/header non créé"
        fail "Arrêt de l'installation, vérifiez les droits et l'arborescence."
    fi
    ok "Dossier créé : bolt.diy/app/components/header"

    # Création dossier public
    mkdir -p bolt.diy/app/public
    if [ ! -d "bolt.diy/app/public" ]; then
        error "Échec : dossier bolt.diy/app/public non créé"
        fail "Arrêt de l'installation, vérifiez les droits et l'arborescence."
    fi
    ok "Dossier créé : bolt.diy/app/public"

    # Vérification puis copie de Header.tsx
    if [ -f "templates/bolt.diy/Header.tsx" ]; then
    cp templates/bolt.diy/Header.tsx bolt.diy/app/components/header/Header.tsx
    if [ ! -f "bolt.diy/app/components/header/Header.tsx" ]; then
        error "Échec : Header.tsx n'a pas pu être copié"
        fail "Arrêt du script (copie impossible !)"
    fi
    ok "Fichier Header.tsx copié"
    else
        error "Fichier source absent : templates/bolt.diy/Header.tsx"
        fail "Arrêt du script."
    fi

    # Vérification puis copie de logout.html
    if [ -f "templates/bolt.diy/logout.html" ]; then
    cp templates/bolt.diy/logout.html bolt.diy/app/public/logout.html
    if [ ! -f "bolt.diy/app/public/logout.html" ]; then
        error "Échec : logout.html n'a pas pu être copié"
        fail "Arrêt du script (copie impossible !)"
    fi
    ok "Fichier logout.html copié"
    ok "Fichiers personnalisés copiés dans bolt.diy/"
    else
        error "Fichier source absent : templates/bolt.diy/logout.html"
        fail "Arrêt du script."
    fi

    # =========================================================================
    # 4. VÉRIFICATION DES DÉPENDANCES
    # =========================================================================
    info "Vérification des fichiers requis pour le build..."

    local files_ok=true
    local required_files=(
        "bolt.diy/package.json"
        "bolt.diy/pnpm-lock.yaml"
        "bolt.diy/vite.config.ts"
        "bolt.diy/wrangler.toml"
    )

    for file in "${required_files[@]}"; do
        if [ -f "$file" ]; then
            echo "   ✓ $(basename $file)"
        else
            echo "   ✗ $(basename $file)"
            files_ok=false
        fi
    done

    if [ "$files_ok" = false ]; then
        error "Certains fichiers requis sont manquants"
        fail "Vérifier l'intégrité du submodule bolt.diy"
    fi
    ok "Tous les fichiers requis sont présents"

    # =========================================================================
    # 5. BUILD DE L'IMAGE DOCKER
    # =========================================================================
    info "Build de l'image Docker Bolt.DIY..."
    info "Cela peut prendre 5-10 minutes (téléchargement + compilation)..."
    echo ""

    # Build avec docker compose
    if docker compose build bolt-app \
        --build-arg VITE_PUBLIC_APP_URL="http://$PUBLIC_IP:$HOST_PORT_BOLT" 2>&1; then
        ok "Image Docker Bolt.DIY construite avec succès"
    else
        error "Échec du build de l'image Docker"
        warn "Vérifier les logs ci-dessus pour identifier l'erreur"
        fail "Consulter la documentation : https://github.com/NBILITY-HOME/BOLT.DIY-INTRANET/wiki"
    fi

    # =========================================================================
    # 6. VÉRIFICATION DE L'IMAGE (MÉTHODE AMÉLIORÉE)
    # =========================================================================
    info "Vérification de l'image Docker..."

    # Méthode 1 : docker images avec format JSON
    local image_exists=false
    local image_name=""

    # Récupérer le nom de l'image depuis docker-compose.yml
    if docker compose config | grep -A 5 "bolt-app:" | grep -q "image:"; then
        image_name=$(docker compose config | grep -A 5 "bolt-app:" | grep "image:" | awk '{print $2}')
    fi

    # Si pas d'image name explicite, utiliser le nom par défaut de compose
    if [ -z "$image_name" ]; then
        # Nom généré par docker compose = <project>-<service>
        local project_name=$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]' | tr '.' '-')
        image_name="${project_name}-bolt-app"
    fi

    info "Recherche de l'image : $image_name"

    # Vérifier avec docker images format JSON
    if docker images --format "{{.Repository}}" | grep -q "^${image_name}$"; then
        image_exists=true
        ok "Image Docker trouvée : $image_name"
    elif docker images --format "{{.Repository}}" | grep -q "bolt-app"; then
        image_exists=true
        image_name=$(docker images --format "{{.Repository}}" | grep "bolt-app" | head -1)
        ok "Image Docker trouvée : $image_name"
    else
        # Dernière tentative : chercher toutes les images récentes
        if docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.CreatedAt}}" | grep -E "bolt.*app|boltdiy" | head -5; then
            warn "Image possiblement trouvée ci-dessus"
            image_exists=true
        fi
    fi

    if [ "$image_exists" = false ]; then
        error "Aucune image Docker Bolt.DIY trouvée"
        error "Le build a peut-être échoué silencieusement"

        info "Images Docker disponibles :"
        docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" | head -10

        fail "L'image Docker n'a pas été créée correctement"
    fi

    # =========================================================================
    # 7. INFORMATIONS FINALES
    # =========================================================================
    echo ""
    info "Configuration Bolt.DIY :"
    echo "   - Image Docker    : $image_name"
    echo "   - Port interne    : 5173"
    echo "   - URL publique    : http://$PUBLIC_IP:$HOST_PORT_BOLT"
    echo "   - Dockerfile      : Custom NBILITY (avec corrections)"
    echo "   - Node.js         : v22"
    echo "   - Package manager : pnpm 9.15.9"
    echo "   - Mode            : Production"
    echo ""

    ok "Bolt.DIY préparé et buildé avec succès"
}
