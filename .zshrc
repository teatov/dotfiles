# General
setopt autocd

bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Utilities
printexec() {
	{
		printf "%q " "$@"
		echo
	} >&2
	"$@"
}

alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'
alias sa="printexec source ~/.zshrc"

autoload -Uz add-zsh-hook

# Completion
zstyle ":completion:*" matcher-list "m:{[:lower:]}={[:upper:]}"
zstyle ":compinstall" filename "$HOME/.zshrc"

autoload -Uz compinit
compinit

# History
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000

setopt inc_append_history
setopt hist_ignore_dups
setopt hist_find_no_dups

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# Prompt
autoload -Uz vcs_info
add-zsh-hook precmd vcs_info
setopt prompt_subst

zstyle ":vcs_info:*" enable git
zstyle ":vcs_info:*:*" check-for-changes true
zstyle ":vcs_info:git:*" formats "%b%u%c "

PROMPT="%F{blue}%2~%f %F{8}${vcs_info_msg_0_}%f$ "

# Tooling
export GOPATH="$HOME/go"

[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

export NVM_DIR="$HOME/.nvm"
[[ -f "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -f "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# Path
typeset -TUx PATH path

path+="$HOME/.local/bin"
path+="$HOME/bin"

if [ $(uname | sed -n 's/.*\( *MINGW *\).*/\1/ip') ]; then
	path+="$HOME/AppData/Local/Programs/Python/Python313/Scripts"
	path+="$HOME/AppData/Local/Programs/Python/Python313"
	path+="$HOME/AppData/Local/Programs/Python/Launcher"
	path+="$HOME/AppData/Local/Microsoft/WindowsApps"
	path+="$HOME/AppData/Roaming/Composer/vendor/bin"
	path+="$HOME/AppData/Local/Programs/Zed/bin"
	path+="$HOME/AppData/Roaming/npm"

	path+="/c/ProgramData/chocolatey/bin"
	path+="/c/Program Files/Docker/Docker/resources/bin"
	path+="/c/tools/php85"
	path+="/c/ProgramData/ComposerSetup/bin"
	path+="/c/Program Files/nodejs"
	path+="/c/Program Files/GitHub CLI/"
fi
