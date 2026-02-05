# Plugins
source $HOME/.zsh/async.zsh
async_init

# General
setopt autocd

autoload -Uz add-zsh-hook

bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

IS_MINGW=$(uname | sed -n "s/.*\( *MINGW *\).*/\1/ip")

# Utilities
alias sa="source $HOME/.zshrc"
alias dotfiles="git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME""

if [[ $IS_MINGW ]]; then
	COOKIEPATH="%APPDATA%/Waterfox/Profiles"
else
	COOKIEPATH="$HOME/.waterfox"
fi
alias yt-dlp="yt-dlp --cookies-from-browser "firefox:$COOKIEPATH""

PKGSYNCDIR="$HOME/.pkgsync"

pkgsave() {
	set -x

	pipx list --short | cut -d ' ' -f 1 >"$PKGSYNCDIR/pipx.txt"

	pip list --user --format freeze |
		awk -F "==" "{print $1}" >"$PKGSYNCDIR/pip.txt"

	npm list -g --depth 0 | sed '1d' | cut -d ' ' -f 2 |
		cut -d '@' -f 1 >"$PKGSYNCDIR/npm.txt"

	if [[ $IS_MINGW ]]; then
		pacman -Qe | cut -d ' ' -f 1 >"$PKGSYNCDIR/pacman.txt"

		choco list | sed '$d' | cut -d ' ' -f 1 >"$PKGSYNCDIR/choco.txt"
	else
		dnf list --userinstalled >"$PKGSYNCDIR/dnf.txt"
	fi
}

zedconfsort() {
	set -x
	ZED_SETTINGS="$HOME/.config/zed/settings.json"
	jsonlint -Sf $ZED_SETTINGS | jq --sort-keys "." |
		prettier --stdin-filepath .jsonc | sponge $ZED_SETTINGS
}

# Completion
autoload -Uz compinit
compinit

zstyle ":completion:*" matcher-list "m:{[:lower:]}={[:upper:]}"
zstyle ":compinstall" filename "$HOME/.zshrc"

# History
HISTFILE=$HOME/.histfile
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
setopt prompt_subst
autoload -Uz vcs_info

zstyle ":vcs_info:*" enable git
zstyle ":vcs_info:*" check-for-changes true
zstyle ":vcs_info:*" stagedstr "+"
zstyle ":vcs_info:*" unstagedstr "!"
zstyle ":vcs_info:*" formats "%b%u%c "
zstyle ":vcs_info:*" actionformats "%b|%a%u%c "

PROMPT=''
PROMPT+='%F{6}%2~%f '
PROMPT+='%F{8}${vcs_info_msg_0_}%f'
PROMPT+='%(?.$.%F{9}$%f) '

function vcs_callback() {
	vcs_info
	zle reset-prompt
}

async_start_worker vcs_updater_worker
async_register_callback vcs_updater_worker vcs_callback

function vcs_job_precmd() {
	async_job vcs_updater_worker
}

add-zsh-hook precmd vcs_job_precmd

# Environment
typeset -TUx PATH path

path+="$HOME/.local/bin"
path+="$HOME/bin"

if [[ $IS_MINGW ]]; then
	path+="$HOME/AppData/Local/Microsoft/WindowsApps"
	path+="$HOME/AppData/Roaming/Composer/vendor/bin"
	path+="$HOME/AppData/Local/Programs/Zed/bin"

	path+="/c/ProgramData/chocolatey/bin"
	path+="/c/Program Files/Docker/Docker/resources/bin"
	path+="/c/tools/php85"
	path+="/c/ProgramData/ComposerSetup/bin"
	path+="/c/Program Files/GitHub CLI/"
	path+="/c/Program Files/Git/cmd"
fi

export GOPATH="$HOME/go"

[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
	NODE_GLOBALS=($(find $NVM_DIR/versions/node -maxdepth 3 -type l \
		-wholename "*/bin/*" | xargs -n1 basename | sort | uniq))
	NODE_GLOBALS+=("node")
	NODE_GLOBALS+=("nvm")
	load_nvm() {
		[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
	}
	for cmd in "${NODE_GLOBALS[@]}"; do
		eval "${cmd}(){ unset -f ${NODE_GLOBALS}; load_nvm; ${cmd} \$@ }"
	done
fi
