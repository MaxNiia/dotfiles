#!/usr/bin/env bash

set -e

# shellcheck source=~/.bashrc

installers_install() {
    apt_install pipx
    pipx ensurepath

    if ! command -v rustup &>/dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    else
        rustup update
    fi

    if ! command -v fnm &>/dev/null; then
        curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
        # shellcheck source=../../.bashrc
        source "$HOME/.bashrc"
    fi

    if ! command -v uv &>/dev/null; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
    else
        uv self update
    fi

    fnm install 23
    fnm use 23
}
