# General
setopt autocd

autoload -Uz add-zsh-hook

bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

IS_MINGW=$(uname | sed -n "s/.*\( *MINGW *\).*/\1/ip")

# Utilities
alias sa="source $HOME/.zshrc"
alias dotfiles='git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'

if [[ $IS_MINGW ]]; then
	COOKIEPATH="%APPDATA%/Waterfox/Profiles"
else
	COOKIEPATH="$HOME/.waterfox"
fi
alias yt-dlp="yt-dlp --cookies-from-browser "firefox:$COOKIEPATH""

zedconfsort() {
	ZED_SETTINGS="$HOME/.config/zed/settings.json"
	jsonlint -Sf $ZED_SETTINGS | jq --sort-keys "." |
		prettier --stdin-filepath .jsonc | sponge $ZED_SETTINGS
}

source "$HOME/.pkgsync/pkgsync.zsh"

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
source $HOME/.zsh/async.zsh
async_init

setopt prompt_subst
autoload -Uz vcs_info

zstyle ":vcs_info:*" enable git
zstyle ":vcs_info:*" check-for-changes true
zstyle ":vcs_info:*" stagedstr "+"
zstyle ":vcs_info:*" unstagedstr "!"
zstyle ":vcs_info:*" formats "%b%u%c "
zstyle ":vcs_info:*" actionformats "%b|%a%u%c "

PROMPT=''
PROMPT+='%F{4}%2~%f '
PROMPT+='%F{8}${vcs_info_msg_0_}%f'
PROMPT+='%(?.$.%F{9}$%f) '

function vcs_callback() {
	vcs_info
	zle reset-prompt

	local tw_name=$1 tw_code=$2 tw_output=$3
	if ((tw_code == 2)) || ((tw_code == 3)) || ((tw_code == 130)); then
		async_stop_worker vcs_updater_worker
		vcs_updater_worker_init
	fi
}

vcs_updater_worker_init() {
	async_start_worker vcs_updater_worker
	async_register_callback vcs_updater_worker vcs_callback
}

vcs_updater_worker_init

function vcs_job_precmd() {
	async_flush_jobs vcs_updater_worker
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
	path+="/c/Program Files (x86)/Microsoft Visual Studio/18/BuildTools/VC/Tools/MSVC/14.50.35717/bin/HostX64/x64"
	path+="/c/Program Files/Alacritty"
fi

export GOPATH="$HOME/go"

if [[ -s "$HOME/.cargo/env" ]]; then
	source "$HOME/.cargo/env"
fi

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
if [[ -s "$NVM_DIR/bash_completion" ]]; then
	source "$NVM_DIR/bash_completion"
fi
