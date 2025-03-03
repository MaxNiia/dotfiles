#!/usr/bin/env bash

set -e

SCRIPTS="$HOME/.scripts"
INSTALL="$SCRIPTS/install"
source "$INSTALL/utils.sh"

if [ $USER != "max" ]; then
    # Install installers.
    source $SCRIPTS/installers.sh
fi

HELIX_DIR="$HOME/.helix"
helix_version="1a28999002e907f79105d64fc05b8a7c37f4792f"
(
    if [ ! -d "$HELIX_DIR" ]; then
        git_update https://github.com/helix-editor/helix.git "$HELIX_DIR" $helix_version
        cd "$HELIX_DIR"
        cargo install --path helix-term --locked
    else
        cd "$HELIX_DIR"
        current_version=$(git rev-parse HEAD)
        if [ "$helix_version" != "$current_version" ]; then
            git_update https://github.com/helix-editor/helix.git "$HELIX_DIR" $helix_version
            cargo install --path helix-term --locked
        fi
    fi

)
