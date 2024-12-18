#!/bin/zsh

curl -fsSL https://fnm.vercel.app/install | zsh

npm install -g diff-so-fancy

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

cargo install --locked bat
