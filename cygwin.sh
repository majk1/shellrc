
alias ls='ls --color'

update_terminal_cwd() {
    echo -ne "\e]0;CYGWIN [${PWD}]\a"
}
