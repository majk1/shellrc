#!/bin/bash

SEP=" "
DEC="."
DEC_MAX_CNT=3

NUM="$1"

if [[ "$NUM" =~ \. ]]; then
    part1="${NUM%\.*}"
    part2="${NUM#*\.}"
elif [[ "$NUM" =~ , ]]; then
    part1="${NUM%,*}"
    part2="${NUM#*,}"
else
    part1="$NUM"
    part2=""
fi

part1=$(echo -n "$part1" | rev | sed "s/\([0-9]\{3\}\)/\1${SEP}/g" | rev | sed "s/^${SEP}//")
if [ -z "$part2" ]; then
    echo "${part1}"
else
    part2mod="$(echo "$part2" | tr -d '0')"
    if [ -z "$part2mod" ]; then
        echo "${part1}"
    else
        echo "${part1}${DEC}${part2:0:${DEC_MAX_CNT}}"
    fi
fi
