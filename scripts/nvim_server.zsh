#!/usr/env zsh
nvim_server() {
    while true ;
    do
        nvim --headless --listen localhost:6666
    done
}
