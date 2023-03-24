# Dotfiles

Collection of dotfiles for personal use.

## Usage


In zshrc define a variable holding the path to this git shell. Export the
starship path and source the .zsh files as wanted. Example:
```zsh
local dotpath="/home/max/workspace/dotfiles"
export STARSHIP_CONFIG="$dotpath/starship.toml"
source "$dotpath/zsh/epiroc.zsh"
source "$dotpath/zsh/omz.zsh"
source ../mocha.zsh
source ../zsh-syntax-highlighting.zsh
```

