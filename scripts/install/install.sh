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
installers_install

# Setup zsh
shell="$SHELL"
if [ ! "$shell" = "/usr/bin/zsh" ]; then
    sudo chsh -s "$(command -v zsh)" "${USER}"
fi

npm_install diff-so-fancy
npm_install @bazel/bazelisk
cargo_install bat
bat cache --build
cargo_install lsd
cargo_install zoxide
pipx_install cmake "3.31.4"

if [[ $(grep -i Microsoft /proc/version) ]]; then
    apt_install wslu
fi


# shellcheck source=../../.config/nvim/script/init.sh
source "$CONFIG/nvim/scripts/init.sh"
# shellcheck source=../../.config/helix/script/init.sh
# source "$CONFIG/helix/scripts/init.sh"

curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg
apt_install wezterm-nightly


# Yazi
apt_install p7zip-full
apt_install p7zip-rar
apt_install ffmpeg
apt_install jq
apt_install poppler-utils
cargo_install resvg
cargo install --locked --git https://github.com/sxyazi/yazi.git yazi-fm yazi-cli
