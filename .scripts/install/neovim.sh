#!/usr/bin/env bash

set -e

if [ $USER != "max" ]; then
    apt_install gettext curl build-essential unzip libreadline-dev

    # Install installers.
    source $SCRIPTS/installers.sh
fi

if [ ! -e "${HOME}/.nvimstty" ]; then
    echo "Disabling XON/XOFF flow control"
    touch "${HOME}/.nvimstty" &> /dev/null
    echo "stty -ixon" >>"${HOME}/.nvimstty"
    if [ "${SHELL}" = "/usr/bin/zsh" ]; then
        echo "source \"${HOME}/.nvimstty\" &> /dev/null" >>"${HOME}/.zshrc"
    elif [ "${SHELL}" = "/usr/bin/bash" ]; then
        echo "source \"${HOME}/.nvimstty\"" >>"${HOME}/.bashrc"
    elif [ "${SHELL}" = "/bin/bash" ]; then
        echo "source \"${HOME}/.nvimstty\"" >>"${HOME}/.bashrc"
    else
        echo "Error, can't find suitable shell. Run the following line but change {shellrc} to applicable shell file"
        echo "echo source \"\${HOME}/.nvimstty\" >> \"\${HOME}/.{shellrc}\""
    fi
fi

cargo_install ripgrep
cargo_install fd-find
pipx_install debugpy
npm_install @ast-grep/cli

# Lua.
LUA_VERSION="5.1.5"
lua_version=""
if command -v lua &>/dev/null; then
    lua_version=$(lua -v 2>&1 | awk '{print $2}')
fi

if [ "$lua_version" != "$LUA_VERSION" ]; then
    echo "Lua not installed, installing"
    sudo apt install -y libreadline-dev
    curl -R -O "https://www.lua.org/ftp/lua-$LUA_VERSION.tar.gz"
    tar -zxf "lua-$LUA_VERSION.tar.gz"
    (
        cd lua-$LUA_VERSION || exit
        make linux test
        sudo make install
    )
    rm -rf lua-$LUA_VERSION
    rm lua-$LUA_VERSION.tar.gz
fi

LUAROCKS_VERSION="3.11.1"
luarocks_version=""
if command -v luarocks &>/dev/null; then
    luarocks_version=$(luarocks --version | head -n1 | grep -oP '\d+\.\d+\.\d+')
fi
if [ "$luarocks_version" != "$LUAROCKS_VERSION" ]; then
    echo "Luarocks not installed, installing"
    wget "https://luarocks.github.io/luarocks/releases/luarocks-$LUAROCKS_VERSION.tar.gz"
    tar -zxf "luarocks-$LUAROCKS_VERSION.tar.gz"
    (
        cd "luarocks-$LUAROCKS_VERSION" || exit
        ./configure && make && sudo make install
    )
    rm -rf "luarocks-$LUAROCKS_VERSION"
    rm "luarocks-$LUAROCKS_VERSION.tar.gz"
fi


# Lazygit integration.
lazygit_version=""
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
if command -v lazygit &>/dev/null ; then
    lazygit_version=$(lazygit --version | head -n1 | grep -oP '\d+\.\d+\.\d+')
fi
if [ "$lazygit_version" != "$LAZYGIT_VERSION" ]; then
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit -D -t /usr/local/bin/
    rm -rf lazygit
    rm  lazygit.tar.gz
fi


NEOVIM_DIR="$HOME/.neovim"
neovim_version="5cead869fb6ddc57594c0dc7e6e575f9427630c8"
(
    if [ ! -d "$NEOVIM_DIR" ]; then
        git_update https://github.com/neovim/neovim.git "$NEOVIM_DIR" $neovim_version
        cd "$NEOVIM_DIR"
        sudo rm -rf .deps build docs
        make CMAKE_BUILD_TYPE=Release && sudo make install
    else
        cd "$NEOVIM_DIR"
        current_neovim_version=$(git rev-parse HEAD)
        if [ "$neovim_version" != "$current_neovim_version" ]; then
            git_update https://github.com/neovim/neovim.git "$NEOVIM_DIR" $neovim_version
            sudo rm -rf .deps build docs
            make CMAKE_BUILD_TYPE=Release && sudo make install
        fi
    fi


)
