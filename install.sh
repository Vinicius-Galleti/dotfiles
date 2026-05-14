#!/usr/bin/env bash
#
# Instalador dos dotfiles do Vinicius (Omarchy).
# Uso:
#   bash <(curl -fsSL https://raw.githubusercontent.com/Vinicius-Galleti/dotfiles/main/install.sh)
#
# Pré-requisito: Omarchy já instalado (https://omarchy.org).
# O script é idempotente — pode rodar várias vezes sem efeitos colaterais.

set -euo pipefail

REPO="https://github.com/Vinicius-Galleti/dotfiles.git"
DEST="$HOME/.cfg"
BACKUP_BASE="$HOME/.cfg-backup"

PACMAN_PKGS=(zsh git cava playerctl btop fastfetch qalculate-gtk imv jq python tmux kitty fcitx5)
AUR_PKGS=(swayosd-git wiremix ghostty lazygit lazydocker)

C_BLUE=$'\e[1;34m'; C_GREEN=$'\e[1;32m'; C_YELLOW=$'\e[1;33m'; C_RED=$'\e[1;31m'; C_RESET=$'\e[0m'
info()  { printf "%s==>%s %s\n" "$C_BLUE" "$C_RESET" "$*"; }
ok()    { printf "%s ✓%s %s\n" "$C_GREEN" "$C_RESET" "$*"; }
warn()  { printf "%s !!%s %s\n" "$C_YELLOW" "$C_RESET" "$*"; }
fail()  { printf "%s xx%s %s\n" "$C_RED" "$C_RESET" "$*" >&2; exit 1; }

config() { git --git-dir="$DEST" --work-tree="$HOME" "$@"; }

# 1. Pré-flight
preflight() {
    info "Pré-flight"
    [[ -f /etc/arch-release ]] || fail "Este instalador só funciona em Arch Linux."
    command -v omarchy-menu >/dev/null \
        || fail "Omarchy não encontrado. Instale primeiro: https://omarchy.org"
    if ! command -v git >/dev/null; then
        info "Instalando git"
        sudo pacman -S --noconfirm --needed git
    fi
    ok "Sistema base OK"
}

# 2. Pacotes
install_packages() {
    info "Instalando pacotes oficiais (pacman)"
    sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"
    ok "Pacman pronto"

    info "Instalando pacotes AUR (yay)"
    if command -v yay >/dev/null; then
        yay -S --needed --noconfirm "${AUR_PKGS[@]}" || warn "Algum pacote AUR falhou — siga manualmente."
        ok "AUR pronto"
    else
        warn "yay não encontrado. Pule ou instale com: sudo pacman -S --needed base-devel && git clone https://aur.archlinux.org/yay.git && (cd yay && makepkg -si)"
        warn "Pacotes AUR pendentes: ${AUR_PKGS[*]}"
    fi
}

# 3. Clonar bare repo
clone_repo() {
    info "Configurando bare repo em $DEST"
    if [[ -d "$DEST" ]]; then
        warn "$DEST já existe — atualizando do remote em vez de clonar"
        config fetch --all
    else
        git clone --bare "$REPO" "$DEST"
    fi
    config config status.showUntrackedFiles no
    ok "Bare repo pronto"
}

# 4. Checkout com backup automático
checkout_with_backup() {
    info "Aplicando dotfiles (checkout)"
    local ts
    ts=$(date +%Y%m%d-%H%M%S)
    local backup="$BACKUP_BASE/$ts"
    local err
    err=$(mktemp)

    if config checkout 2>"$err"; then
        ok "Checkout limpo (sem conflitos)"
    else
        # Linhas com path conflitante começam com tab/espaços + caminho
        local conflicts
        conflicts=$(grep -E "^[[:space:]]+\." "$err" | awk '{print $1}' || true)
        if [[ -z "$conflicts" ]]; then
            cat "$err" >&2
            rm -f "$err"
            fail "Checkout falhou e não consegui identificar conflitos."
        fi
        warn "Os seguintes arquivos do PC atual serão movidos para backup:"
        echo "$conflicts" | sed 's/^/    /'
        echo
        printf "Backup vai para: %s\n" "$backup"
        read -r -p "Aplicar (mover originais para backup e sobrescrever)? [y/N] " ans
        case "$ans" in
            [yY]|[yY][eE][sS]) ;;
            *) rm -f "$err"; fail "Cancelado pelo usuário. Nada foi alterado." ;;
        esac
        mkdir -p "$backup"
        while read -r f; do
            [[ -e "$HOME/$f" ]] || continue
            mkdir -p "$backup/$(dirname "$f")"
            mv "$HOME/$f" "$backup/$f"
        done <<< "$conflicts"
        config checkout
        ok "Conflitos movidos para $backup"
    fi
    rm -f "$err"
}

# 5. Submódulos (tema dark-xp)
init_submodules() {
    info "Inicializando submódulos"
    config submodule update --init --recursive
    ok "Submódulos prontos"
}

# 6. Shell: oh-my-zsh + p10k + mise + chsh
provision_shell() {
    info "Provisionando shell (oh-my-zsh, p10k, mise)"

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        RUNZSH=no KEEP_ZSHRC=yes sh -c \
            "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
            "" --unattended --keep-zshrc
    else
        ok "oh-my-zsh já presente"
    fi

    local p10k="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [[ ! -d "$p10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k"
    else
        ok "Powerlevel10k já presente"
    fi

    if ! command -v mise >/dev/null; then
        curl -fsSL https://mise.run | sh
    else
        ok "mise já presente"
    fi

    ok "Shell provisionado. Quando quiser tornar zsh o shell padrão, rode manualmente:"
    printf "    chsh -s %s\n" "$(command -v zsh)"
}

# 7. systemd user
reload_systemd_user() {
    info "Recarregando systemd --user"
    systemctl --user daemon-reload 2>/dev/null || warn "daemon-reload falhou (sessão sem user bus?)"
    ok "Services definidos em .config/systemd/user/ disponíveis."
    info "Para habilitar serviços opcionais, rode:"
    printf "    systemctl --user enable --now swayosd-server elephant\n"
}

# 8. Mensagem final
finale() {
    cat <<EOF

${C_GREEN}Tudo pronto.${C_RESET}

${C_YELLOW}Antes de relogar, ajuste para o SEU hardware:${C_RESET}
  • Monitores:  nvim ~/.config/hypr/monitors.conf
                (default já cobre auto-detect; edite se quiser posições/escala)
  • NVIDIA:     se tiver GPU NVIDIA Turing+, descomente os envs em
                ~/.config/hypr/envs.conf
  • Services:   habilite opcionais com
                systemctl --user enable --now swayosd-server elephant
  • Shell zsh:  chsh -s \$(command -v zsh)   (faça DEPOIS de testar o login normal)

Outros pontos:
  • Backups (se houve conflito) ficam em: ${BACKUP_BASE}/<timestamp>/
  • Alias 'config' já está no .bashrc/.zshrc:
      config status / config add / config commit / config push
  • Para aplicar tudo: saia e entre na sessão (ou: hyprctl dispatch exit)

EOF
}

main() {
    preflight
    install_packages
    clone_repo
    checkout_with_backup
    init_submodules
    provision_shell
    reload_systemd_user
    finale
}

main "$@"
