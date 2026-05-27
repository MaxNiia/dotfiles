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
    tmux \
    zsh \
    unzip \
    golang \
    gettext \
    curl \
    build-essential \
    libreadline-dev \
    diffstat \
    sway \
    waybar \
    swayidle \
    swaylock \
    grim \
    slurp \
    wl-clipboard \
    blueman \
    playerctl \
    kanshi \
    pavucontrol

# shellcheck source=./installers.sh
source "$INSTALL/installers.sh"
installers_install

# Setup zsh
shell="$SHELL"
if [ ! "$shell" = "/usr/bin/zsh" ]; then
    sudo chsh -s "$(command -v zsh)" "${USER}"
fi

npm_install diff-so-fancy
npm_install @bazel/bazelisk

cargo_install git-delta
cargo_install fd-find
cargo_install lsd
cargo_install zoxide
cargo_install ripgrep
cargo_install bat
cargo_install tree-sitter-cli
bat cache --build

pipx_install cmake "3.31.4"

if [[ $(grep -i Microsoft /proc/version) ]]; then
    apt_install wslu
fi

# Yazi
apt_install p7zip-full
apt_install p7zip-rar
apt_install ffmpeg
apt_install jq
apt_install poppler-utils
cargo_install resvg
cargo_install yazi-build

# FZF
git_update https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
if [ ! -f /usr/bin/fzf ]; then
    sudo ln -s "$HOME/.fzf/bin/fzf" /usr/bin/fzf
fi

# TPM
git_update https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Lazygit
go install github.com/jesseduffield/lazygit@latest
