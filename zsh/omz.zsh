#!/usr/bin/zsh

export ZSH="$HOME/.oh-my-zsh"

ENABLE_CORRECTION="true"

ZVM_VI_INSERT_ESCAPE_BINDKEY=jk

plugins=(
   git
   git-auto-fetch
   zsh-vi-mode
   zsh-autosuggestions
   zsh-history-substring-search
   fd
   fzf
   web-search
   sudo
   colored-man-pages
   rust
   pre-commit
   man
)

export FZF_BASE=/usr/bin/fzf

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

source $ZSH/oh-my-zsh.sh

bindkey -v

PS1=""

eval "$(starship init zsh)"

if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
else
   export EDITOR='nvim'
fi

export VI_MODE_SET_CURSOR=true

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 <F12>\
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

. "$HOME/.cargo/env"


export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/.local/bin"

cr (){
   exec firefox "https://duckduckgo.com/\?sites=cppreference.com&q=$1"
}

alias f='nvim "$(fzf)"'

alias tmux="TERM=screen-256color-bce tmux"

function my_init() {
  [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh 
}

zvm_after_init_commands+=(my_init)
