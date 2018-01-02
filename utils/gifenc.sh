#!/usr/bin/env bash
#
# TODO: utils/gifenc.sh (draft)
#

from_file="$1"
to_file="$2"


if [ ! -z "$3" ]; then
    fps="$3"
    if [[ $fps = -1 ]]; then
        fps=10
    fi
    if [ ! -z "$4" ]; then
        scalex="$4"
    fi
fi

palette="/tmp/palette.png"
filters="fps=${fps}"

if [ ! -z "$scalex" ]; then
    filters="${filters},scale=${scalex}:-1:flags=lanczos"
fi

ffmpeg -i "$from_file" -vf "${filters},palettegen" -y "$palette"
ffmpeg -i "$from_file" -i "$palette" -r 3 -lavfi "${filters} [x]; [x][1:v] paletteuse" -y "${to_file}"

rm -f "${palette}"
