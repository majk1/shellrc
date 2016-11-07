
alias ls='ls --color'

MAIN_GROUP=$(groups $USER | sed "s/$USER : \([^ ]\+\).*/\1/")
export MAIN_GROUP

update_terminal_cwd() {
    echo -ne "\e]0;CYGWIN [${PWD}]\a"
}
