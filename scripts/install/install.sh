#!/usr/bin/env bash

set -e

WORKSPACE="$HOME/workspace"
APPLICATIONS="$HOME/applications"
DEV="$WORKSPACE/dev"
CONFIG="$XDG_CONFIG"
SCRIPTS="$HOME/scripts"
NOTES="$HOME/notes"
INSTALL="$SCRIPTS/install"
# shellcheck source=./utils.sh
source "$INSTALL/utils.sh"

create_dir "$WORKSPACE"
create_dir "$APPLICATIONS"
create_dir "$DEV"
create_dir "$CONFIG"
create_dir "$NOTES"

apt_install \
    git \
    zsh \
    unzip \
    gettext \
    curl \
    build-essential \
    libreadline-dev \
    diffstat

# shellcheck source=./installers.sh
source "$INSTALL/installers.sh"

# Setup zsh
shell="$SHELL"
if [ ! "$shell" = "/usr/bin/zsh" ]; then
    sudo chsh -s "$(command -v zsh)" "${USER}"
fi

# Make fzf only install if changed.
FZF_DIR="fzf"
fzf_version=b89c77ec9a1931ec1eea9d57afe5321045feabea
(
    cd "$APPLICATIONS"
    if [ ! -d "$FZF_DIR" ]; then
        git_update https://github.com/junegunn/fzf.git "$FZF_DIR" $fzf_version
    fi

    cd "$FZF_DIR"
    if [ ! "$fzf_version" = "$(git rev-parse HEAD)" ]; then
        git_update https://github.com/junegunn/fzf.git "$FZF_DIR" $fzf_version
        "install"
    fi
)

npm_install diff-so-fancy
cargo_install bat
bat cache --build
cargo_install lsd
cargo_install zoxide
pipx_install cmake "3.31.4"

# shellcheck source=../../.config/nvim/script/init.sh
source "$CONFIG/nvim/scripts/init.sh"
# shellcheck source=../../.config/helix/script/init.sh
# source "$CONFIG/helix/scripts/init.sh"
