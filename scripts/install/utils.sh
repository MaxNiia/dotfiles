#!/usr/bin/env bash

set -e

apt_install() {
    if [ $# -eq 0 ]; then
        echo "No arguments provided to '${FUNCNAME[0]}'."
        exit 2
    fi

    apt_upgrade=()
    apt_install=()

    for var in "$@"; do
        if ! command -v $var &>/dev/null; then
            echo "Installing '$var'."
            apt_install+=("$var")
        else
            echo "Updating '$var'."
            apt_upgrade+=("$var")
        fi
    done

    sudo apt update
    sudo apt upgrade -y "${apt_upgrade[@]}"
    sudo apt install -y "${apt_install[@]}"
}

pipx_install() {
    if [ $# -lt 1 ]; then
        echo "No arguments provided to '${FUNCNAME[0]}'."
        exit 2
    fi

    if [ $# -eq 2 ]; then
        echo "Installing '$1'."
        pipx install "$1"=="$2" --force
    else
        echo "Installing '$1'."
        pipx install "$1"
    fi

}

npm_install() {
    if [ ! $# -eq 1 ]; then
        echo "No arguments provided to '${FUNCNAME[0]}'."
        exit 2
    fi

    if ! command -v $1 &>/dev/null; then
        echo "Installing '$1'."
        npm install -g $1
    else
        npm update -g $1
    fi
}

create_dir() {
    if [ ! $# -eq 1 ]; then
        echo "'${FUNCNAME[0]}' required a directory input."
        exit 2
    fi

    if [ ! -d "$1" ]; then
        mkdir "$1"
        echo "$1 created."
    fi
}

git_update() {
    if [ ! $# -gt 1 ]; then
        echo "Not enough arguments provided to '${FUNCNAME[0]}'."
        exit 2
    fi

    if [ ! -d "$2" ]; then
        git clone "$1" "$2"
    fi

    cd "$2"
    git fetch
    if [ $# -eq 3 ]; then
        git checkout $3
    else
        git pull
    fi
    git submodule update --recursive --init
    cd -
}

cargo_install() {
    if [ ! $# -eq 1 ]; then
        echo "No arguments provided to '${FUNCNAME[0]}'."
        exit 2
    fi

    cargo install --locked $1
}
