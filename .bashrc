# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

# Prompt Apple-like minimalista
parse_git_branch() {
    git branch 2>/dev/null | sed -n 's/* \(.*\)/ \1/p'
}

PS1='\[\e[38;5;244m\]\w\[\e[38;5;109m\]$(parse_git_branch)\[\e[0m\]\n\[\e[38;5;250m\]❯\[\e[0m\] '

# Dotfiles (bare git repo em ~/.cfg)
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

. "$HOME/.local/share/../bin/env"
