
# bash specific things

export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
export HISTCONTROL=ignoreboth
shopt -s histappend
shopt -s checkwinsize

# completion

[[ -f /etc/bash_completion ]] && . /etc/bash_completion
[[ -f /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion
[[ -f /usr/local/etc/bash_completion ]] && . /usr/local/etc/bash_completion
[[ -f /opt/local/etc/bash_completion ]] && . /opt/local/etc/bash_completion
[[ -f ~/.fzf.bash ]] && . ~/.fzf.bash

# Cygwin specific
if ! echo "$(uname)" | grep -q -i 'cygwin'; then
    for compfile in ${SCRIPT_BASE_DIR}/bash-completion/*.sh; do
        . ${compfile}
    done
fi

# setting the prompt

[[ -z "$PROMPT_DIRECTORY" ]] && PROMPT_DIRECTORY='\w'

function custom_prompt_command() {
	local EXIT=$?
	if [[ "$USER" == "root" ]]; then
		PS1="\[\e[0;37m\][\A] \[\e[m\][\[\e[1;31m\]$EXIT\[\e[m\]:\[\e[1;31m\]\h\[\e[m\]] \[\e[1;36m\]$PROMPT_DIRECTORY\[\e[m\] \[\e[0;32m\]\$ \[\e[m\]"
	else
		PS1="\[\e[0;37m\][\A] \[\e[m\][\[\e[1;31m\]$EXIT\[\e[m\]:\[\e[1;32m\]\u\[\e[m\]@\[\e[1;33m\]\h\[\e[m\]] \$(getProjectNameInDir .)\[\e[1;36m\]$PROMPT_DIRECTORY\[\e[m\]\[\e[0;35m\]\$(_git_ps1)\[\e[m\] \[\e[0;32m\]\$ \[\e[m\]"
	fi
	type -t update_terminal_cwd >/dev/null 2>&1
	if [[ $? -eq 0 ]]; then
		update_terminal_cwd
	fi
    if [[ ! -z "${SESSION_TITLE}" ]]; then
        echo -ne "\033]0;${SESSION_TITLE} - ${USER}@${HOSTNAME} - ${PWD/#$HOME/\~} \007"
    else
	    echo -ne "\033]0;${USER}@${HOSTNAME} - ${PWD/#$HOME/\~} \007"
    fi
}

PROMPT_COMMAND=custom_prompt_command

shortPrompt() {
    PROMPT_DIRECTORY='\W'
}

longPrompt() {
    PROMPT_DIRECTORY='\w'
}

bind '"\C-e": backward-kill-word'

