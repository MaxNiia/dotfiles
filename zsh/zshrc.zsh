#!/usr/env zsh

DISABLE_AUTO_UPDATE="true"

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
HISTCONTROL=ignoreboth
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS

if grep -q "microsoft" /proc/version &>/dev/null; then
   alias nvim="env TERM=wezterm nvim"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# WSL 2 specific settings.
if grep -q "microsoft" /proc/version &>/dev/null; then
    # Requires: https://sourceforge.net/projects/vcxsrv/ (or alternative)
    export DISPLAY="$(/sbin/ip route | awk '/default/ { print $3 }'):0"

    # Allows your gpg passphrase prompt to spawn (useful for signing commits).
    # export GPG_TTY=$(tty)
fi

export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export FZF_BASE=/usr/bin/fzf

if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
   export VISUAL='vim'
else
   export EDITOR='nvim'
   export VISUAL='nvim'
fi

# fnm
FNM_PATH="/home/max/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/home/max/.local/share/fnm:$PATH"
  eval "`fnm env`"
fi

local AUTOSUGGEST=""

local dotpath=$(dirname `dirname $0`)
local scripts="${dotpath}/scripts"
local plugins="${dotpath}/plugins"
local completions="${dotpath}/completion"

# Function to check if running in WSL
function check_wsl {
  if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
    echo "wsl"
  else
    echo "not_wsl"
  fi
}

# Function to get Windows appearance mode from WSL
function get_windows_appearance {
  powershell.exe -Command "Get-ItemPropertyValue -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme" 2>/dev/null | tr -d '\r'
}

# Function to check appearance mode
function check_appearance {
  if [[ "$(check_wsl)" == "wsl" ]]; then
    # WSL, get Windows appearance mode
    # mode=$(get_windows_appearance)
    # if [[ "$mode" == "0" ]]; then
    echo "dark"
    # else
    #   echo "light"
    # fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    mode=$(defaults read -g AppleInterfaceStyle 2>/dev/null)
    if [[ "$mode" == "Dark" ]]; then
      echo "dark"
    else
      echo "light"
    fi
  elif command -v gsettings > /dev/null 2>&1; then
    # GNOME (Linux)
    theme=$(gsettings get org.gnome.desktop.interface gtk-theme)
    if [[ "$theme" =~ "dark" ]]; then
      echo "dark"
    else
      echo "light"
    fi
  else
    # Default to light mode if detection fails
    echo "light"
  fi
}

local appearance=$(check_appearance)
local FZF_DEFAULT_OPTS="\
   --cycle \
   --highlight-line \
   --border=rounded \
   --multi \
   --info inline-right \
   --layout reverse \
   --marker ▏\
   --pointer ▌ \
   --prompt '▌ ' \
   "
# check if theme is 0
if [[ "$appearance" == "dark" ]]; then
   # Mocha
   # FZF
   FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
   --color gutter:-1 \
   --color selected-bg:#313244 \
   --color selected-fg:#cdd6f4 \
   --color bg:#1e1e2e \
   --color bg+:#45475a \
   --color fg:#cdd6f4 \
   --color fg+:#cdd6f4 \
   --color hl:#f5c2e7 \
   --color hl+:#f5c2e7 \
   --color selected-hl:#f5c2e7 \
   --color header:#f5c2e7 \
   --color info:#f5c2e7 \
   --color marker:#f9e2af \
   --color prompt:#f5c2e7 \
   --color pointer:#f5c2e7 \
   --color spinner:#f5c2e7 \
   --color query:#f5c2e7 \
   --color disabled:#cdd6f4 \
   --color border:#cdd6f4 \
   --color separator:#cdd6f4 \
   --color label:#cdd6f4 \
   "

   # Bat
   export BAT_THEME="Catppuccin Mocha"
   # Autosuggest
   AUTOSUGGEST="fg=#cdd6f4,bg=#313244,bold,underline"

   source "$plugins/catppuccin-syntax-highlighting/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh"
else
   # Latte
   # FZF
   FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
   --color gutter:-1 \
   --color selected-bg:#ccd0da \
   --color selected-fg:#4c4f69 \
   --color bg:#eff1f5 \
   --color bg+:#bcc0cc \
   --color fg:#4c4f69 \
   --color fg+:#4c4f69 \
   --color hl:#ea76cb \
   --color hl+:#ea76cb \
   --color selected-hl:#ea76cb \
   --color header:#ea76cb \
   --color info:#ea76cb \
   --color marker:#df8e1d \
   --color prompt:#ea76cb \
   --color pointer:#ea76cb \
   --color spinner:#ea76cb \
   --color query:#ea76cb \
   --color disabled:#4c4f69 \
   --color border:#4c4f69 \
   --color separator:#4c4f69 \
   --color label:#4c4f69 \
   "

   # Bat
   export BAT_THEME="Catppuccin Latte"

   # Autosuggest
   AUTOSUGGEST="fg=#4c4f69,bg=#ccd0da,bold,underline"

   source "$plugins/catppuccin-syntax-highlighting/themes/catppuccin_latte-zsh-syntax-highlighting.zsh"
fi

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
export KEYTIMEOUT="10"
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS"
export FZF_DEFAULT_COMMAND='fd --type file'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=numbers --line-range=:500 {}"'
export FZF_ALT_C_OPTS='--preview "tree -C {} | head -500"'
# export FZF_COMPLETION_TRIGGER=''
# bindkey '^T' fzf-completion
# bindkey '^I' $fzf_default_completion

export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/.local/bin"

alias f='nvim "$(fzf)"'
alias tmux="TERM=screen-256color-bce tmux"
alias ls=lsd

ENABLE_CORRECTION="true"

# Completion
fpath=($completions $fpath)

# Plugins.
export PATH="$PATH:$HOME/fzf-zsh-plugin/bin"
source "$plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh"

source "$dotpath/wezterm/wezterm.sh"

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="$AUTOSUGGEST"

setopt autocd

bindkey -v

set -o vi

export VI_MODE_SET_CURSOR=true

ZVM_VI_INSERT_ESCAPE_BINDKEY=jj

function my_init() {
    bindkey -r '^G'
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    . "$HOME/.cargo/env"
    source "$scripts/lfs.zsh"
    source "$scripts/zoxide.zsh"
    source "$scripts/fzf-git.sh"
    alias cd="z"
}

# NOTE: Keep last.
source "$plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
source "$plugins/zsh-autopair/autopair.zsh"
autopair-init
fpath=("$plugins/pure" $fpath)
fpath=("$plugins/zsh-completions/src" $fpath)

autoload -Uz compinit
compinit
autoload -U promptinit; promptinit

# turn on git stash status
zstyle :prompt:pure:git:stash show yes

prompt pure

alias v=nvim
eval "$(register-python-argcomplete pipx)"

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
# bindkey -M vicmd 'k' history-substring-search-up
# bindkey -M vicmd 'j' history-substring-search-down

zvm_after_init_commands+=(my_init)
