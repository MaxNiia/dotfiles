#!/bin/zsh

start_session() {
    session_name=$1

    if ! tmux has-session -t $session_name &> /dev/null
    then
        tmux new-session -s $session_name -n $session_name -d
        sleep 1
        tmux send-keys -t $session_name "cd ~/workspace/dev/$session_name" C-m
        tmux send-keys -t $session_name "git fetch" C-m
    fi
}

tmux_start() {
    tmux new-session -d -s "home"
    start_session 1
    start_session 2
    start_session 3
    start_session 4
    start_session 5
    start_session 6
    start_session dotfiles

    tmux attach -t dotfiles
}
