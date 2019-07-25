# zsh

# import profile.d
if [[ -d /etc/profile.d ]]; then
	for i in /etc/profile.d/*.sh; do
		if [[ -r ${i} ]]; then
			. ${i}
		fi
	done
	unset i
fi

zstyle ':completion:*' completer _expand _complete _ignored
zstyle ':completion:*' max-errors 2
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle :compinstall filename "~/.zshrc"

autoload -Uz compinit && compinit
autoload -U promptinit && promptinit
autoload -U colors && colors
autoload bashcompinit && bashcompinit

for compfile in ${SCRIPT_BASE_DIR}/bash-completion/*.sh; do
	. ${compfile}
done

if [[ -d /usr/local/share/zsh-completions ]]; then
	fpath=(/usr/local/share/zsh-completions ${fpath})
fi

HISTFILE=~/.histfile
HISTSIZE=10000000
SAVEHIST=10000000
setopt appendhistory autocd extendedglob hist_ignore_dups
unsetopt beep nomatch notify
bindkey -e

bindkey "\e[1~" beginning-of-line    # Home
bindkey "\e[4~" end-of-line          # End
bindkey "\e[5~" beginning-of-history # PageUp
bindkey "\e[6~" end-of-history       # PageDown
bindkey "\e[2~" quoted-insert        # Ins
bindkey "\e[3~" delete-char          # Del
bindkey "\e[5C" forward-word
bindkey "\eOc" emacs-forward-word
bindkey "\e[5D" backward-word
bindkey "\eOd" emacs-backward-word
bindkey "\e\e[C" forward-word
bindkey "\e\e[D" backward-word
# for rxvt
bindkey "\e[7~" beginning-of-line # Home
bindkey "\e[8~" end-of-line       # End
# # for non RH/Debian xterm, can't hurt for RH/Debian xterm
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line
# # for freebsd console
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line

bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

zle -N bash-backward-kill-word
bash-backward-kill-word() {
  local WORDCHARS="${WORDCHARS:s#/#}"
  zle backward-delete-word
}
bindkey '^e' bash-backward-kill-word

type -p dircolors >/dev/null 2>&1
[[ $? -eq 0 ]] && eval $(dircolors -b)

# prompt

setopt PROMPT_SUBST
[[ -z "$PROMPT_DIRECTORY" ]] && PROMPT_DIRECTORY='~'

if [[ "$USER" == "root" ]]; then
	PS1="$(print "[%{\e[0;31m%}%?%{\e[0m%}:%{\e[1;31m%}%m%{\e[0m%}] %{\e[1;36m%}%\$PROMPT_DIRECTORY%{\e[0m%} %{\e[0;32m%}\$%{\e[0m%}") "
else
	PS1="$(print "[%{\e[0;31m%}%?%{\e[0m%}:%{\e[1;32m%}%n%{\e[0m%}@%{\e[1;33m%}%m%{\e[0m%}] \$(getProjectNameInDir .)%{\e[1;36m%}%\$PROMPT_DIRECTORY%{\e[0m%}%{\e[0;35m%}\$(_git_ps1)%{\e[0m%} %{\e[0;32m%}\$%{\e[0m%}") "
fi

precmd() {
	if [[ ! -z "$SESSION_TITLE" ]]; then
		print -Pn "\e]0;${SESSION_TITLE} - %n@%m: %~\a"
	else
		print -Pn "\e]0;%n@%m: %~\a"
	fi
}

[[ -z $MC_SID ]] && RPROMPT="$(print '%{\e[2;38m%}%y | %T%{\e[0m%}')"

shortPrompt() {
	PROMPT_DIRECTORY='1~'
}

longPrompt() {
	PROMPT_DIRECTORY='~'
}
