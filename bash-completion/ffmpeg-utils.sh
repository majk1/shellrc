# ffmpeg-info completion

_ffmpeg_info() {
    local cur prev
    local IFS=$'\n'
    
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    if [[ ${prev} == ffmpeg-info ]]; then
        COMPREPLY=($(compgen -W "$(ls -1 | grep -i '.*\(\.mkv\|\.mp4\|\.avi\|\.mov\)$')" -- "$cur"))
    fi
}

complete -F _ffmpeg_info ffmpeg-info

_ffmpeg_to_stereo() {
    local cur prev
    local IFS=$'\n'
    
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    if [[ ${cur} =~ ^-.* ]]; then
        COMPREPLY=($(compgen -W "--no-sub" -- "$cur"))
    else 
        COMPREPLY=($(compgen -W "$(ls -1 | grep -i '.*\(\.mkv\|\.mp4\|\.avi\|\.mov\)$')" -- "$cur"))
    fi
}

complete -F _ffmpeg_to_stereo ffmpeg-to-stereo

_mkv_merge_sub() {
    local cur prev
    local IFS=$'\n'
    
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    if [[ ${prev} == mkvMergeSub ]]; then
    		COMPREPLY=($(compgen -W "$(ls -1 | grep -i '.*\.mkv$'; echo '--no-conv')" -- "$cur"))
    elif [[ ${prev} == "--no-conv" ]]; then
        COMPREPLY=($(compgen -W "$(ls -1 | grep -i '.*\.mkv$')" -- "$cur"))
    elif [[ ${prev} =~ .*\.mkv ]]; then
        COMPREPLY=($(compgen -W "$(ls -1 | grep -i '.*\.srt$')" -- "$cur"))
    fi
}

complete -F _mkv_merge_sub mkvMergeSub
