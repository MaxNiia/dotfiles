#!/usr/bin/env bash

set -e

apt_install pipx
pipx ensurepath

if ! command -v rustup &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
else
    rustup update
fi

curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
source $HOME/.bashrc

fnm install 23
fnm use 23
