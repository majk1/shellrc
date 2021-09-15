#!/usr/bin/env bash
#
# TODO: utils/to-stereo.sh (draft)
#

# ${TITLE}_stereo.ac3: ${TITLE}_51.ac3
#         ffmpeg -i ${TITLE}_51.ac3 -ac 2 \
#         -af "pan=stereo|FL=FC+0.30*FL+0.30*BL|FR=FC+0.30*FR+0.30*BR"    \
#         ${TITLE}_stereo.ac3


#
# 
# ffmpeg -i input_51.mkv -c:v copy -c:a ac3 -ac 2 -af "pan=stereo|FL=FC+0.30*FL+0.30*BL|FR=FC+0.30*FR+0.30*BR" output_stereo.mkv
#
# -c:v copy -c:a ac3 -b:a 640k -vol 425 -af "pan=stereo|FL=0.5*FC+0.707*FL+0.707*BL+0.5*LFE|FR=0.5*FC+0.707*FR+0.707*BR+0.5*LFE"
#
# ffmpeg -i input_51.mkv -map 0:a:0 -map 0:v:0 -map 0:s -c:v copy -c:a ac3 -ac 2 -af "aresample=matrix_encoding=dplii" output_stereo.mkv
# 
# 

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
    ext="${src##*.}"
    base="${src%.*}"

    # ffmpeg_command="ffmpeg -i \"$src\" -map 0:a:0 -map 0:v:0 $map_subs -c:v copy -c:a ac3 -ac 2 -af \"aresample=matrix_encoding=dplii\" \"${base}-stereo.${ext}\""
    ffmpeg_command="ffmpeg -i \"$src\" -map 0:a:0 -map 0:v:0 $map_subs -c:v copy -c:a ac3 -b:a 640k -vol 425 -af \"pan=stereo|FL=0.5*FC+0.707*FL+0.707*BL+0.5*LFE|FR=0.5*FC+0.707*FR+0.707*BR+0.5*LFE\" \"${base}-stereo.${ext}\""

    echo "Running:"
    echo "${ffmpeg_command}"

    eval ${ffmpeg_command}
}

function ffmpeg-info() {
    ffmpeg -i "$1" 2>&1 | grep 'Stream #[0-9]\+:[0-9]\+\|Duration:'
}
