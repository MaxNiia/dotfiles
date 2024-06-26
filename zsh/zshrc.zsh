#!/usr/env zsh

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
HISTCONTROL=ignoreboth
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY

if grep -q "microsoft" /proc/version &>/dev/null; then
   alias nvim="env TERM=wezterm nvim"
fi

ZSH_THEME="powerlevel10k/powerlevel10k"

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
else
   export EDITOR='nvim'
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

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
    mode=$(get_windows_appearance)
    if [[ "$mode" == "0" ]]; then
      echo "dark"
    else
      echo "light"
    fi
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
# check if theme is 0
if [[ "$appearance" == "dark" ]]; then
   # Mocha
   # FZF
   export FZF_DEFAULT_OPTS=" \
   --color=bg+:#313244,bg:#000000,spinner:#f5e0dc,hl:#f38ba8 <F12>\
   --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
   --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

   # Bat
   export BAT_THEME="Catppuccin Mocha"
   # Autosuggest
   AUTOSUGGEST="fg=#cdd6f4#,bg=#313244,bold,underline"

   source "$plugins/catppuccin-syntax-highlighting/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh"
else
   # Latte
   # FZF
   export FZF_DEFAULT_OPTS=" \
   --color=bg+:#ccd0da,bg:#eff1f5,spinner:#dc8a78,hl:#d20f39 \
   --color=fg:#4c4f69,header:#d20f39,info:#8839ef,pointer:#dc8a78 \
   --color=marker:#dc8a78,fg+:#4c4f69,prompt:#8839ef,hl+:#d20f39"

   # Bat
   export BAT_THEME="Catppuccin Latte"

   # Autosuggest
   AUTOSUGGEST="fg=#4c4f69,bg=#ccd0da,bold,underline"

   source "$plugins/catppuccin-syntax-highlighting/themes/catppuccin_latte-zsh-syntax-highlighting.zsh"
fi


. "$HOME/.cargo/env"


export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/.local/bin"

alias f='nvim "$(fzf)"'
alias tmux="TERM=screen-256color-bce tmux"
alias ls=lsd

ENABLE_CORRECTION="true"

# Completion
fpath=($completions $fpath)
autoload -Uz compinit
compinit

# Scripts.
source "$scripts/source_venv.zsh"
source "$scripts/tmux-sessioner.zsh"
source "$scripts/nvim_server.zsh"
source "$scripts/lfs.zsh"

# Plugins.
export PATH="$PATH:$HOME/fzf-zsh-plugin/bin"
source "$plugins/powerlevel10k/powerlevel10k.zsh-theme"
source "$plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
source "$plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh"


export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="$AUTOSUGGEST"

setopt autocd

bindkey -v

export VI_MODE_SET_CURSOR=true

ZVM_VI_INSERT_ESCAPE_BINDKEY=jk

function my_init() {
   [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
   [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
}

# NOTE: Keep last.
source "$plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
# bindkey -M vicmd 'k' history-substring-search-up
# bindkey -M vicmd 'j' history-substring-search-down

zvm_after_init_commands+=(my_init)

# . /etc/profile.d/wezterm.sh &> /dev/null 2>&1

# precmd () {
#     printf "\033]7;file://%s\033\\" "$PWD"
# }
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
git config --global interactive.diffFilter "diff-so-fancy --patch"
