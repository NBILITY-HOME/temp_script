#!/bin/bash

###############################################################################
# Module 02 : Vérification Emplacement et Clonage GitHub
###############################################################################

check_location_and_clone() {
  section "2/11 - Vérification de l'emplacement et clonage"

  # 1) Si on est déjà dans le dépôt cloné, on ne touche pas au chemin
  if [ -f "docker-compose.yml" ] && [ -d ".git" ]; then
    ok "Exécution depuis le dépôt cloné"
    ok "Répertoire actuel : $(pwd)"

    # Créer le dossier logs si nécessaire
    if [ ! -d "logs" ]; then
      info "Création du dossier logs..."
      mkdir -p logs
      ok "Dossier logs créé"
    fi

    # Vérifier le submodule bolt.diy
    if [ -d "bolt.diy/.git" ]; then
      ok "Submodule bolt.diy : présent"
    else
      warn "Submodule bolt.diy : absent"
      info "Initialisation du submodule..."
      git submodule update --init --recursive
      ok "Submodule initialisé"
    fi

    return 0
  fi

  # 2) On n'est pas dans le dépôt: demander / confirmer le chemin d'installation
  warn "Script exécuté hors du dépôt"

  echo ""
  echo -e "${CYAN}Chemin d'installation du projet :${NC}"
  echo " Chemin par défaut proposé : $TARGET_DIR"
  echo ""

  read -p "→ Entrer le chemin d'installation [ENTER pour garder le défaut] : " USER_TARGET_DIR

  if [ -n "$USER_TARGET_DIR" ]; then
    TARGET_DIR="$USER_TARGET_DIR"
  fi

  # Normaliser le chemin (enlever un éventuel trailing slash)
  TARGET_DIR="${TARGET_DIR%/}"

  info "Le dépôt sera installé dans : $TARGET_DIR"

  # 3) Vérifier si le dossier existe déjà
  if [ -d "$TARGET_DIR" ]; then
    warn "Le dossier $TARGET_DIR existe déjà"

    if confirm "Supprimer et re-cloner ?" "N"; then
      info "Suppression de l'ancien dossier..."
      rm -rf "$TARGET_DIR"
      ok "Ancien dossier supprimé"
    else
      info "Utilisation du dossier existant..."
      cd "$TARGET_DIR" || fail "Impossible d'accéder à $TARGET_DIR"

      # Vérifier que c'est bien le bon dépôt
      if [ ! -f "docker-compose.yml" ]; then
        error "Le dossier existant n'est pas un dépôt BOLT.DIY-INTRANET valide"
        fail "Supprimer manuellement : rm -rf $TARGET_DIR"
      fi

      # Créer le dossier logs si nécessaire
      if [ ! -d "logs" ]; then
        info "Création du dossier logs..."
        mkdir -p logs
        ok "Dossier logs créé"
      fi

      # Mettre à jour le dépôt si possible
      info "Mise à jour du dépôt existant..."
      if git pull origin main &>/dev/null; then
        ok "Dépôt mis à jour"
      else
        warn "Impossible de mettre à jour, poursuite avec version existante"
      fi

      # Relancer le script depuis le dépôt
      info "Relance du script depuis le dépôt..."

      if [ "$EUID" -eq 0 ]; then
        exec bash "$TARGET_DIR/install_bolt_v10.5.sh"
      else
        exec sudo -E bash "$TARGET_DIR/install_bolt_v10.5.sh"
      fi
    fi
  fi

  # 4) Authentification GitHub (dépôt privé) - UNE SEULE FOIS
  section "Authentification GitHub"

  info "Le dépôt BOLT.DIY-INTRANET est privé"
  info "Vous devez vous authentifier avec vos identifiants GitHub"
  echo ""
  echo "Pour créer un Personal Access Token (PAT) :"
  echo " 1. Aller sur : https://github.com/settings/tokens"
  echo " 2. Generate new token (classic)"
  echo " 3. Sélectionner le scope : repo (Full control of private repositories)"
  echo " 4. Copier le token généré"
  echo ""

  # Vérifier si les variables GitHub sont déjà exportées (relance)
  if [ -n "${GH_USER:-}" ] && [ -n "${GH_TOKEN:-}" ]; then
    info "Utilisation des credentials GitHub existants..."
    ok "Username : $GH_USER"
  else
    # Demander les identifiants
    read -p "Username GitHub : " GH_USER
    echo ""
    read -sp "Personal Access Token : " GH_TOKEN
    echo ""
    echo ""

    # Vérifier que les identifiants sont fournis
    if [ -z "$GH_USER" ] || [ -z "$GH_TOKEN" ]; then
      fail "Username et Token requis pour accéder au dépôt privé"
    fi

    # Exporter les variables pour les conserver lors de la relance
    export GH_USER
    export GH_TOKEN
  fi

  # Construire l'URL avec authentification
  CLONE_URL="https://$GH_USER:$GH_TOKEN@github.com/NBILITY-HOME/BOLT.DIY-INTRANET.git"

  # Vérifier l'authentification
  info "Vérification de l'authentification..."
  if ! git ls-remote "$CLONE_URL" &>/dev/null; then
    error "Authentification échouée"
    fail "Vérifier votre username et token GitHub"
  fi
  ok "Authentification GitHub : OK"

  # 5) Créer le dossier parent
  info "Création du dossier parent..."
  mkdir -p "$(dirname "$TARGET_DIR")"
  ok "Dossier parent créé : $(dirname "$TARGET_DIR")"

  # 6) Cloner le dépôt avec les submodules
  info "Clonage du dépôt (avec submodules, peut prendre 2-3 minutes)..."
  if git clone --recurse-submodules "$CLONE_URL" "$TARGET_DIR"; then
    ok "Dépôt cloné avec succès"
  else
    error "Échec du clonage"
    fail "Vérifier l'authentification GitHub et réessayer"
  fi

  # 7) Créer le dossier logs dans le dépôt fraîchement cloné
  info "Création du dossier logs..."
  mkdir -p "$TARGET_DIR/logs"

  # Changer le propriétaire si on est root
  if [ "$EUID" -eq 0 ] && [ -n "$REAL_USER" ]; then
    chown -R "$REAL_USER:$REAL_USER" "$TARGET_DIR/logs"
  fi
  ok "Dossier logs créé : $TARGET_DIR/logs"

  # 8) Vérifier que les fichiers essentiels sont présents
  info "Vérification des fichiers du projet..."
  local files_ok=true

  if [ -f "$TARGET_DIR/docker-compose.yml" ]; then
    ok "docker-compose.yml : ✓"
  else
    error "docker-compose.yml : ✗"
    files_ok=false
  fi

  if [ -d "$TARGET_DIR/bolt.diy" ]; then
    ok "bolt.diy/ : ✓"
  else
    error "bolt.diy/ : ✗"
    files_ok=false
  fi

  if [ -f "$TARGET_DIR/bolt.diy/Dockerfile" ]; then
    ok "bolt.diy/Dockerfile : ✓"
  else
    error "bolt.diy/Dockerfile : ✗"
    files_ok=false
  fi

  if [ "$files_ok" = false ]; then
    error "Certains fichiers essentiels sont manquants"
    fail "Vérifier l'intégrité du dépôt GitHub"
  fi

  ok "Dépôt cloné et vérifié avec succès"

  # 9) Relancer le script depuis le dépôt avec les variables GitHub préservées
  info "Relance du script depuis le dépôt cloné..."
  echo ""
  echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
  echo -e "${YELLOW} Le script va maintenant se relancer depuis le dépôt cloné${NC}"
  echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
  echo ""
  sleep 2

  cd "$TARGET_DIR" || fail "Impossible d'accéder à $TARGET_DIR"

  if [ "$EUID" -eq 0 ]; then
    exec env GH_USER="$GH_USER" GH_TOKEN="$GH_TOKEN" bash "$TARGET_DIR/install_bolt_v10.5.sh"
  else
    exec sudo -E GH_USER="$GH_USER" GH_TOKEN="$GH_TOKEN" bash "$TARGET_DIR/install_bolt_v10.5.sh"
  fi
}
