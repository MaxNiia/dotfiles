#!/usr/bin/env bash

git clone --bare https://github.com/MaxNiia/dotfiles/ "$HOME/.cfg"

alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Move conflicting files to backup.
mkdir -p .config-backup &&
    config checkout 2>&1 |
    grep -E "\s+\." |
        awk "{'print $1'}" |
        xargs -I{} mv {} .config-backup/{}

config checkout

config config --local status.showUntrackedFiles no
