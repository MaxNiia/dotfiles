#!/bin/sh
# Toggle between US and Swedish keyboard layouts
current=$(setxkbmap -query | awk '/layout:/ {print $2}')
if [ "$current" = "us" ]; then
  setxkbmap se
else
  setxkbmap us
fi
