#!/usr/env zsh

lfs_fix() {
   git rm --cached -r .
   git reset --hard
   git rm .gitattributes
   git reset .
   git checkout .
}

