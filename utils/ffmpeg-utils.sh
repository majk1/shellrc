#!/usr/bin/env bash

function ffmpeg-to-stereo() {
    map_subs="-map 0:s"
    if [[ ! -z "$1" ]]; then
        if [[ "$1" == "--no-sub" ]]; then
            map_subs=""
            shift
        fi
    fi

    src="$1"
    if [[ ! -f "$src" ]]; then
        echo "Source file not found: $src"
        return 1
    fi
    shift
    ext="${src##*.}"
    base="${src%.*}"

	meta="-map_metadata 0"
    if [[ -f FFMETADATAFILE.txt ]]; then
    	meta="-i FFMETADATAFILE.txt -map_metadata 1"
    fi

    # ffmpeg_command="ffmpeg -i \"$src\" -map 0:a:0 -map 0:v:0 $map_subs -c:v copy -c:a ac3 -ac 2 -af \"aresample=matrix_encoding=dplii\" \"${base}-stereo.${ext}\""
    ffmpeg_command="ffmpeg -i \"$src\" $meta -map [filtered] -map 0:v:0 $map_subs -c:v copy -c:a ac3 -b:a 640k -filter_complex \"[0:a:0]pan=stereo|FL=0.5*FC+0.707*FL+0.707*BL+0.5*LFE|FR=0.5*FC+0.707*FR+0.707*BR+0.5*LFE[a];[a]volume=1.66[filtered]\" $* \"${base}-stereo.${ext}\""

    echo "Running:"
    echo "${ffmpeg_command}"

    eval ${ffmpeg_command}
}

function ffmpeg-info() {
    ffmpeg -i "$1" 2>&1 | grep 'Stream #[0-9]\+:[0-9]\+\|Duration:'
}
