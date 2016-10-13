
# bash specific things

export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
export HISTCONTROL=ignoreboth
shopt -s histappend
shopt -s checkwinsize

# completion

[ -f /etc/bash_completion ] && . /etc/bash_completion
[ -f /opt/local/etc/bash_completion ] && . /opt/local/etc/bash_completion

# setting the prompt

function custom_prompt_command() {
	local EXIT=$?
	if [ "$USER" == "root" ]; then
		alias normalize='chown -R root:root *; find . -type d -exec chmod 755 {} \;; find . -type f -exec chmod 644 {} \;'
		PS1="\[\e[1;37m\][\[\e[m\]\A\[\e[1;37m\]] \[\e[m\][\[\e[1;31m\]$EXIT\[\e[m\]:\[\e[1;31m\]\h\[\e[m\]] \[\e[1;34m\]\w\[\e[m\] \[\e[0;32m\]\$ \[\e[m\]"
	else
		alias normalize='chown -R majki:staff *; find . -type d -exec chmod 755 {} \;; find . -type f -exec chmod 644 {} \;'
		PS1="\[\e[1;37m\][\[\e[m\]\A\[\e[1;37m\]] \[\e[m\][\[\e[1;31m\]$EXIT\[\e[m\]:\[\e[1;32m\]\u\[\e[m\]@\[\e[1;33m\]\h\[\e[m\]] \$(getProjectNameInDir .)\[\e[1;34m\]\w\[\e[m\]\[\e[0;35m\]\$(_git_ps1)\[\e[m\] \[\e[0;32m\]\$ \[\e[m\]"
	fi
	type -t update_terminal_cwd >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		update_terminal_cwd
	fi
}
PROMPT_COMMAND=custom_prompt_command

shortPrompt() {
	PS1="\[\e[1;37m\][\[\e[m\]\A\[\e[1;37m\]] \[\e[m\][\[\e[1;31m\]$?\[\e[m\]:\[\e[1;32m\]\u\[\e[m\]@\[\e[1;33m\]\h\[\e[m\]] \$(getProjectNameInDir .)\[\e[1;34m\]\W\[\e[m\]\[\e[0;35m\]\$(_git_ps1)\[\e[m\] \[\e[0;32m\]\$ \[\e[m\]"
}

longPrompt() {
	PS1="\[\e[1;37m\][\[\e[m\]\A\[\e[1;37m\]] \[\e[m\][\[\e[1;31m\]$?\[\e[m\]:\[\e[1;32m\]\u\[\e[m\]@\[\e[1;33m\]\h\[\e[m\]] \$(getProjectNameInDir .)\[\e[1;34m\]\w\[\e[m\]\[\e[0;35m\]\$(_git_ps1)\[\e[m\] \[\e[0;32m\]\$ \[\e[m\]"
}
