#!/usr/bin/env bash

set -e

SCRIPTS="$HOME/.scripts"
INSTALL="$SCRIPTS/install"
source "$INSTALL/utils.sh"

create_dir "$WORKSPACE"
create_dir "$APPLICATIONS"
create_dir "$DEV"
create_dir "$CONFIG"

apt_install \
    git \
    zsh \
    unzip \
    gettext \
    curl \
    build-essential \
    libreadline-dev

source "$INSTALL/installers.sh"

# Setup zsh
shell="$SHELL"
if [ ! "$shell" = "/usr/bin/zsh" ]; then
    sudo chsh -s "$(command -v zsh)" "${USER}"
fi

# Make fzf only install if changed.
FZF_DIR="$HOME/.fzf"
fzf_version=b89c77ec9a1931ec1eea9d57afe5321045feabea
(
    if [ ! -d "$FZF_DIR" ]; then
        git_update https://github.com/junegunn/fzf.git "$FZF_DIR" $fzf_version
    fi

    cd "$FZF_DIR"
    if [ ! "$fzf_version" = "$(git rev-parse HEAD)" ]; then
        git_update https://github.com/junegunn/fzf.git "$FZF_DIR" $fzf_version
        "$FZF_DIR/install"
    fi
)

npm_install diff-so-fancy

cargo_install bat
bat cache --build
cargo_install lsd
cargo_install zoxide
pipx_install cmake "3.31.4"

source "$INSTALL/neovim.sh"
source "$INSTALL/helix.sh"
