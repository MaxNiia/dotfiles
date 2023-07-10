local dotpath=$(dirname `dirname $0`)
export STARSHIP_CONFIG="$dotpath/starship.toml"
source "$dotpath/zsh/omz.zsh"
source "$dotpath/scripts/source_venv.zsh"
source "$dotpath/scripts/tmux-sessioner.zsh"
source "$dotpath/mocha.zsh"
source "$dotpath/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
