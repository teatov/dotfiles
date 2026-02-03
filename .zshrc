
# The following lines were added by compinstall

zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'
zstyle :compinstall filename '/home/teatov/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
setopt autocd
bindkey -e
# End of lines configured by zsh-newuser-install

setopt inc_append_history
setopt hist_ignore_dups
setopt hist_find_no_dups

bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'
