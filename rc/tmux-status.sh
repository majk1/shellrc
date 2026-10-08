#!/usr/bin/env bash

cpu=$(top -bn1 | awk '/Cpu\(s\)/ {print int($2 + $4)}')
mem=$(free | awk '/Mem:/ {printf "%d", $3/$2 * 100.0}')
git_branch=$(git -C "$PWD" branch --show-current 2>/dev/null)

printf "CPU:%s%% MEM:%s%%" "$cpu" "$mem"
[ -n "$git_branch" ] && printf "  %s" "$git_branch"
