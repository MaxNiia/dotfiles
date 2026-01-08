#!/usr/bin/env zsh

export XDG_CONFIG="$HOME/.config"

local dotpath=$HOME
local scripts="${dotpath}/scripts"
local config="${XDG_CONFIG}"
local plugins="${config}/zsh"
local private_config="${dotpath}/.private"
local completions="${scripts}/completion"

if [[ -f "$private_config/zshrc.zsh" ]]; then
    source "$private_config/zshrc.zsh"
fi

DISABLE_AUTO_UPDATE="true"

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

# WSL 2 specific settings.
if grep -q "microsoft" /proc/version &>/dev/null; then
    # Requires: https://sourceforge.net/projects/vcxsrv/ (or alternative)
    export DISPLAY="$(/sbin/ip route | awk '/default/ { print $3 }'):0"

    if [[ ! -f /etc/profile.d/wezterm.sh ]]; then
        sudo cp "$scripts/sh/wezterm.sh" /etc/profile.d/wezterm.sh
    fi
    # Allows your gpg passphrase prompt to spawn (useful for signing commits).
    # export GPG_TTY=$(tty)
fi

export MANROFFOPT='-c'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"

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

# Function to check appearance mode
function check_appearance() {
    if [ -e gsettings ]; then
        if [ "$(gsettings get org.gnome.desktop.interface color-scheme)" = "'prefer-dark'" ]; then
            echo "dark"
            return
        elif [ "$(gsettings get org.gnome.desktop.interface color-scheme)" = "'default'" ]; then
            echo "light"
            return
        fi
    fi
    # wezterm/wsl fallback
    if [[ -n "${NVIM_BACKGROUND:-}" ]]; then
      echo "$NVIM_BACKGROUND"
      return
    else
      echo "light"
      return
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

   alias lazygit='lazygit --use-config-file="/home/max/.config/lazygit/config.yml,/home/max/.config/lazygit/mocha.yml"'

   sed -i "s/dark = false/dark = true/g"  ~/.gitconfig
   sed -i "s/features = catppuccin-latte/features = catppuccin-mocha/g"  ~/.gitconfig

   export NVIM_BACKGROUND="dark"
   export LS_COLORS="$(vivid generate catppuccin-mocha)"
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

   alias lazygit='lazygit --use-config-file="/home/max/.config/lazygit/config.yml,/home/max/.config/lazygit/latte.yml"'

   sed -i "s/dark = true/dark = false/g"  ~/.gitconfig
   sed -i "s/features = catppuccin-mocha/features = catppuccin-latte/g"  ~/.gitconfig

   export NVIM_BACKGROUND="light"
   export LS_COLORS="$(vivid generate catppuccin-latte)"
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

export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/applications/magick"

ENABLE_CORRECTION="true"

# Completion
fpath=($completions $fpath)

# Plugins.
export PATH="$PATH:$plugins/fzf-zsh-plugin/bin"
source "$plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh"

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="$AUTOSUGGEST"

setopt autocd

bindkey -v

set -o vi

export VI_MODE_SET_CURSOR=true

ZVM_VI_INSERT_ESCAPE_BINDKEY=jj

function my_init() {
    bindkey -r '^G'
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    # Set up fzf key bindings and fuzzy completion
    source <(fzf --zsh)
    source "$scripts/zsh/lfs.zsh"
    source "$scripts/zsh/zoxide.zsh"
    source "$scripts/sh/fzf-git.sh"
    alias cd="z"
    alias config='/usr/bin/git --git-dir=/home/max/.cfg/ --work-tree=/home/max'
    alias cat="bat -pp"

    fzf-edit-files-fd() {
        local files
        files=$(fd --type f --hidden --follow --exclude .git \
            | fzf --multi --height=40% --reverse \
            --preview 'bat --style=numbers --color=always {} 2>/dev/null || sed -n "1,200p" {}')

        if [[ -n "$files" ]]; then
            ${EDITOR:-nvim} ${(f)files}
        fi
  
        zle reset-prompt
    }

    zle -N fzf-edit-files-fd
    bindkey '^[e' fzf-edit-files-fd

    fzf-rg-edit() {
      local matches
      matches=$(rg --line-number --no-heading --color=always "" \
        | fzf --multi --ansi --height=40% --reverse \
              --preview 'bat --style=numbers --color=always {1} --highlight-line {2} 2>/dev/null'
      )

      if [[ -n "$matches" ]]; then
        local args=()
        while IFS=: read -r file line _; do
          args+=("+${line}" "$file")
        done <<< "$matches"

        ${EDITOR:-nvim} "${args[@]}"
      fi

      zle reset-prompt
    }

    zle -N fzf-rg-edit
    bindkey '^[s' fzf-rg-edit

    alias ls=lsd
    alias gs="git status --short"
    alias gd="git diff"
    alias ga="git add"
    alias gap="git add --patch"
    alias gc="git commit"
    alias gp="git push"
    alias gu="git pull"
    alias gl="git log --all --graph --pretty=format:'%C(magenta)%h %C(white) %an  %ar%C(auto)  %D%n%s%n'"
    gb() {
        if [ "$#" -eq 0 ]; then
            # Use fzf to pick a branch when no args are given
            local branch
            branch=$(_fzf_git_branches) && [ -n "$branch" ] && git switch "$branch"
        else
            git switch "$@"
        fi
    }
    alias gi="git init"
    alias gcl="git clone"
    alias tree="ls --tree"
    # alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
    # alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
}

# NOTE: Keep last.
source "$plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
source "$plugins/zsh-autopair/autopair.zsh"
autopair-init
fpath=("$plugins/zsh-completions/src" $fpath)
fpath=("$config/pure" $fpath)

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

zvm_after_init_commands+=(my_init)
