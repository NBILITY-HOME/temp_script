#!/bin/bash

###############################################################################
# Module 04 : Création de l'Arborescence
###############################################################################

create_directories() {
    section "4/11 - Création de l'arborescence"

    info "Création des répertoires de données..."

    # Répertoires principaux
    mkdir -p DATA-LOCAL/{nginx-portal,oauth2-proxy,mariadb/{data,init}}

    ok "Arborescence DATA-LOCAL créée"

    # Vérifier les permissions
    info "Configuration des permissions..."
    chmod -R 755 DATA-LOCAL/
    ok "Permissions configurées"

    # Créer les fichiers de base
    info "Création des fichiers de configuration de base..."

    # Nginx config minimal
    if [ ! -f DATA-LOCAL/nginx-portal/nginx.conf ]; then
        cat > DATA-LOCAL/nginx-portal/nginx.conf <<'EOF'
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        listen 80;
        server_name _;
        root /usr/share/nginx/html;
        index index.html;

        location / {
            try_files $uri $uri/ =404;
        }
    }
}
EOF
        ok "Configuration Nginx créée"
    fi

    # Page d'accueil HTML
    if [ ! -f DATA-LOCAL/nginx-portal/html/index.html ]; then
        mkdir -p DATA-LOCAL/nginx-portal/html
        cat > DATA-LOCAL/nginx-portal/html/index.html <<EOF
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BOLT.DIY-INTRANET</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }
        .container {
            text-align: center;
            padding: 2rem;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
            max-width: 600px;
        }
        h1 { font-size: 3rem; margin-bottom: 1rem; }
        p { font-size: 1.2rem; margin-bottom: 2rem; opacity: 0.9; }
        .links {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
        }
        a {
            display: inline-block;
            padding: 1rem 2rem;
            background: white;
            color: #667eea;
            text-decoration: none;
            border-radius: 10px;
            font-weight: bold;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        a:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 BOLT.DIY-INTRANET</h1>
        <p>Plateforme de développement IA avec authentification Keycloak</p>
        <div class="links">
            <a href="http://$PUBLIC_IP:$HOST_PORT_BOLT">Accéder à Bolt.DIY</a>
            <a href="http://$PUBLIC_IP:$HOST_PORT_KEYCLOAK">Keycloak Admin</a>
        </div>
    </div>
</body>
</html>
EOF
        ok "Page d'accueil HTML créée"
    fi

    ok "Arborescence complète créée"
}

