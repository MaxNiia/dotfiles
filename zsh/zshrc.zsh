#!/usr/env zsh

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
HISTCONTROL=ignoreboth

setopt inc_append_history

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
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

export FZF_BASE=/usr/bin/fzf

if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
else
   export EDITOR='nvim'
fi

# TODO: Move to script file
lfs_fix() {
   git rm --cached -r .
   git reset --hard
   git rm .gitattributes
   git reset .
   git checkout .
}

cr (){
   exec firefox "https://duckduckgo.com/\?sites=cppreference.com&q=$1"
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#000000,spinner:#f5e0dc,hl:#f38ba8 <F12>\
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

. "$HOME/.cargo/env"


export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/.local/bin"

alias f='nvim "$(fzf)"'
alias tmux="TERM=screen-256color-bce tmux"
alias ls=lsd

ENABLE_CORRECTION="true"

local dotpath=$(dirname `dirname $0`)
local plugins="${dotpath}/plugins"
local scripts="${dotpath}/scripts"

source "$dotpath/mocha.zsh"

# Scripts.
source "$scripts/source_venv.zsh"
source "$scripts/tmux-sessioner.zsh"

# Plugins.
source "$plugins/powerlevel10k/powerlevel10k.zsh-theme"
source "$plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
source "$plugins/zsh-fzf-history-search/zsh-fzf-history-search.plugin.zsh"
source "$plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
source "$plugins/forgit/forgit.plugin.zsh"
source "$plugins/forgit/completions/git-forgit.zsh"
export PATH="$PATH:$plugins/forgit/bin"

setopt autocd

bindkey -v

export VI_MODE_SET_CURSOR=true

ZVM_VI_INSERT_ESCAPE_BINDKEY=jk

function my_init() {
  [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh 
}

# NOTE: Keep last.
source "$plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

zvm_after_init_commands+=(my_init)

# . /etc/profile.d/wezterm.sh &> /dev/null 2>&1

# precmd () {
#     printf "\033]7;file://%s\033\\" "$PWD"
# }
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
git config --global interactive.diffFilter "diff-so-fancy --patch"
