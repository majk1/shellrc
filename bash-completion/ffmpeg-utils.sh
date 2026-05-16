# ffmpeg-info completion

_ffmpeg_video_path_completions() {
    local cur candidate
    local IFS=$'\n'

    cur="$1"
    COMPREPLY=()

    for candidate in $(compgen -f -- "$cur"); do
        if [[ -d "$candidate" || "$candidate" =~ \.([mM][kK][vV]|[mM][pP]4|[aA][vV][iI]|[mM][oO][vV])$ ]]; then
            COMPREPLY+=("$candidate")
        fi
    done
}

if [[ -n ${ZSH_VERSION:-} ]]; then
    _ffmpeg_video_files_zsh() {
        _alternative \
            'directories:directories:_files -/' \
            'videos:video files:_files -g "(*.[mM][kK][vV]|*.[mM][pP]4|*.[aA][vV][iI]|*.[mM][oO][vV])(-.)"'
    }

    _ffmpeg_info_zsh() {
        _ffmpeg_video_files_zsh
    }

    _ffmpeg_to_stereo_zsh() {
        if [[ ${words[CURRENT]} == -* ]]; then
            compadd -- --no-sub
        else
            _ffmpeg_video_files_zsh
        fi
    }

    compdef _ffmpeg_info_zsh ffmpeg-info
    compdef _ffmpeg_to_stereo_zsh ffmpeg-to-stereo
else
    _ffmpeg_info() {
        local cur prev
        local IFS=$'\n'

        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"

        if [[ ${prev} == ffmpeg-info ]]; then
            _ffmpeg_video_path_completions "$cur"
        fi
    }

    complete -o filenames -F _ffmpeg_info ffmpeg-info

    _ffmpeg_to_stereo() {
        local cur prev
        local IFS=$'\n'

        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"

        if [[ ${cur} =~ ^-.* ]]; then
            COMPREPLY=($(compgen -W "--no-sub" -- "$cur"))
        else
            _ffmpeg_video_path_completions "$cur"
        fi
    }

    complete -o filenames -F _ffmpeg_to_stereo ffmpeg-to-stereo
fi

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

if [[ -z ${ZSH_VERSION:-} ]]; then
    complete -F _mkv_merge_sub mkvMergeSub
else
    _mkv_merge_sub_zsh() {
        if [[ ${words[CURRENT]} == -* ]]; then
            compadd -- --no-conv
        elif [[ ${words[CURRENT-1]} == *.mkv ]]; then
            _files -g '*.[sS][rR][tT](-.)'
        else
            _alternative \
                'options:options:compadd -- --no-conv' \
                'mkv files:mkv files:_files -g "*.[mM][kK][vV](-.)"'
        fi
    }
    compdef _mkv_merge_sub_zsh mkvMergeSub
fi
