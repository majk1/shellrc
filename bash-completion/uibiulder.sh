# uibuilder completion

_uibuilder() {
    local cur prev
    local IFS=' '
    
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    if [[ ${prev} == uibuilder ]]; then
        COMPREPLY=($(compgen -W "1.3.0 2.0.2 2.1.2 2.1.3-SNAPSHOT" -- "$cur"))
    fi
}

complete -F _uibuilder uibuilder
