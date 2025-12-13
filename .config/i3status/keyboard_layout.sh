#!/bin/sh
# Simple keyboard layout indicator for i3status run_watch
layout=$(setxkbmap -query 2>/dev/null | awk '/layout/{print $2}')
[ -z "$layout" ] && layout=unknown
printf "KB: %s\n" "$layout"
