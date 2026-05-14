<img width="1922" height="1080" alt="image" src="https://github.com/user-attachments/assets/18b9753c-1191-4868-a091-d6285839817f" />

#cuidado para instalar. a versão nao esta 100%

# Dotfiles — Galleti

Customizações do meu setup **Omarchy** (Arch + Hyprland): waybar com player de música, hyprlock, walker, terminais, shell (zsh + powerlevel10k + starship), TUIs (btop, lazygit, lazydocker, fastfetch) e sessão Wayland (uwsm, swayosd, wireplumber).

## Instalação automática

Pré-requisito: ter o [Omarchy](https://omarchy.org) já instalado.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Vinicius-Galleti/dotfiles/main/install.sh)
```

O `install.sh` é idempotente e faz, em sequência:

1. Verifica Arch + Omarchy.
2. Instala via `pacman`: `zsh git cava playerctl btop fastfetch qalculate-gtk imv jq python tmux kitty fcitx5`.
3. Instala via `yay` (AUR): `swayosd-git wiremix ghostty lazygit lazydocker`.
4. Clona o bare repo em `~/.cfg` e configura `status.showUntrackedFiles=no`.
5. Faz `checkout` com **backup automático** de conflitos em `~/.cfg-backup/<timestamp>/`.
6. Inicializa o submódulo de tema (`dark-xp-omarchy`).
7. Instala oh-my-zsh, powerlevel10k e mise (sem sobrescrever o `.zshrc` versionado).
8. Define `zsh` como shell padrão (`chsh`).
9. Recarrega `systemd --user`.

Depois de terminar, saia e entre de novo na sessão (ou `hyprctl dispatch exit`) para aplicar tudo.

## Estrutura do bare repo

Versionamento de dotfiles via **bare git repo** em `~/.cfg/`, com alias `config` no `~/.bashrc` / `~/.zshrc`:

```sh
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
```

Uso:

```bash
config status
config add <path>
config commit -m "..."
config push
```

## Escopo versionado

- **WM / barra / launcher / terminais**: `.config/{hypr,waybar,walker,alacritty,kitty,ghostty/config,mako}`
- **Editor / git / shell**: `.config/{nvim,git,tmux,fish}`, `.zshrc`, `.bashrc`, `.p10k.zsh`, `.profile`, `.bash_profile`, `.bash_logout`, `.XCompose`
- **TUI / CLI**: `.config/{btop,cava,fastfetch,mise,qalculate,starship.toml,imv,wiremix}`
- **Sessão Wayland / sistema**: `.config/{uwsm,swayosd,wireplumber,fontconfig,systemd,environment.d,user-dirs.dirs,xdg-terminals.list}`
- **Submódulo de tema em uso**: [dark-xp-omarchy](https://github.com/ITSZXY/dark-xp-omarchy)

## Instalação manual (alternativa)

Se preferir não rodar o script:

```bash
git clone --bare https://github.com/Vinicius-Galleti/dotfiles.git ~/.cfg
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config config status.showUntrackedFiles no
config checkout                    # se conflitar, mova os arquivos manualmente
config submodule update --init --recursive
```

E instale as dependências da seção "Instalação automática" acima.
