
# core things

# environment variables

[ -d ${HOME}/bin ] && export PATH="${PATH}:${HOME}/bin"
export MC_COLOR_TABLE=editnormal=:normal=
export LESSCHARSET=utf-8
export GREP_COLOR="1;33"

# aliases

alias grep='grep --color=auto'
alias   ls='ls -G'
alias   ll='ls -lh'
alias   la='ll -a'
alias  lll='ll -@'

alias pstree='pstree -g 2'

alias top='top -o cpu -O rsize'
alias scr='screen -r'
alias cdc='cd;clear'
alias grephash='grep -v -e "^.*#"'
alias grephashempty='grep -v -e "^.*#" -e "^$"'

alias 7zPPMd='7z a -t7z -mx=9 -m0=PPMd'
alias 7zUltra='7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on'
alias openPorts='lsof -P -iTCP -sTCP:LISTEN'
alias normalize='chown -R $USER:$MAIN_GROUP *; find . -type d -exec chmod 755 {} \;; find . -type f -exec chmod 644 {} \;'
alias toUTF8='iconv -f iso8859-2 -t utf-8'

alias make_sh_executable='find . -type f -iname "*.sh" -exec chmod 755 {} \;'

if [ "$USER" = "root" ]; then
    alias rm='rm -i'
    alias cp='cp -i'
    alias mv='mv -i'
fi

# functions

sortedless() {
	sort "$1" | less
}

ex() {
    if [[ -f $1 ]]; then
        case $1 in
          *.tar.bz2) tar xvjf $1;;
          *.tar.gz) tar xvzf $1;;
          *.tar.xz) tar xvJf $1;;
          *.tar.lzma) tar --lzma xvf $1;;
          *.bz2) bunzip $1;;
          *.rar) unrar $1;;
          *.gz) gunzip $1;;
          *.tar) tar xvf $1;;
          *.tbz2) tar xvjf $1;;
          *.tgz) tar xvzf $1;;
          *.zip) unzip $1;;
          *.Z) uncompress $1;;
          *.7z) 7z x $1;;
          *.dmg) hdiutul mount $1;; # mount OS X disk images
          *) echo "'$1' cannot be extracted via >ex<";;
    esac
    else
        echo "'$1' is not a valid file"
    fi
}
mcd() {
	mkdir -p "$1" && cd "$1";
}
md5() {
	echo -n $1 | openssl md5 /dev/stdin
}
sha1() {
	echo -n $1 | openssl sha1 /dev/stdin
}
sha256() {
	echo -n $1 | openssl dgst -sha256 /dev/stdin
}
sha512() {
	echo -n $1 | openssl dgst -sha512 /dev/stdin
}
rot13() {
	echo $1 | tr "A-Za-z" "N-ZA-Mn-za-m"
}
rot47() {
	echo $1 | tr "\!-~" "P-~\!-O"
}
urlencode() {
	python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1])" $1
}
urldecode() {
	python -c "import sys, urllib as ul; print ul.unquote_plus(sys.argv[1])" $1
}

weather() {
	wget -q -O- http://wttr.in/Budapest
}

findAll() {
	eval "find \"$1\" -iname '$2'"
}

findFile() {
	eval "find \"$1\" -type f -iname '$2'"
}

findDir() {
	eval "find \"$1\" -type d -iname '$2'"
}

withoutExt() {
	echo "${1%.*}"
}

link-rc-scripts() {
    for RC in ${SCRIPT_BASE_DIR}/rc/*rc; do
        HOMERCNAME="${HOME}/.$(basename ${RC})"
        echo "Linking $RC to $HOMERCNAME ..."
        if [ -f "${HOMERCNAME}" ]; then
            rm -f "${HOMERCNAME}" 2>&1 >/dev/null
        fi
        ln -s "${RC}" "${HOMERCNAME}"
    done
}

update-shellrc() {
    VERSIONS="$(wget --no-cache -q -O- 'https://bitbucket.org/mn3monic/scripts/downloads?tab=tags' | grep "/mn3monic/scripts/get/.*\.tar\.gz" | sed '/\/mn3monic\/scripts\/get\/.*\.tar\.gz/s/.*href="\/mn3monic\/scripts\/get\/\([0-9\.]*\)\.tar\.gz".*/\1/' | sort -r)"
    LATEST="$(echo "$VERSIONS" | head -n 1)"
    if [ "$LATEST" != "$SHELLRC_VERSION" ]; then
        echo -n "Upgrade mn3monic-scripts to version ${LATEST} [y/n]? "
        read ANSWER
		if [ "$ANSWER" != "y" ]; then
			echo "Stopping upgrade. Bye"
		else
            wget --no-cache -q -O- "https://bitbucket.org/mn3monic/scripts/downloads/installer.sh" | bash -s -- -u
        fi
    else
        if [ ! -z "$1" ]; then
            if [ "$1" == "--force" ]; then
                echo -n "Reinstall mn3monic-scripts version ${LATEST} [y/n]? "
                read ANSWER
                if [ "$ANSWER" != "y" ]; then
                    echo "Stopping reinstall. Bye"
                else
                    wget --no-cache -q -O- "https://bitbucket.org/mn3monic/scripts/downloads/installer.sh" | bash -s -- -u
                fi
            fi
        else
            echo "You have the latest version (${LATEST})."
            echo "To force reinstall, run update-shellrc --force"
        fi
    fi
}

# includes
source $SCRIPT_BASE_DIR/idea.sh
source $SCRIPT_BASE_DIR/git.sh
source $SCRIPT_BASE_DIR/java.sh
source $SCRIPT_BASE_DIR/mvn.sh
source $SCRIPT_BASE_DIR/docker.sh

if [ -f ${HOME}/.customshellrc ]; then
    source ${HOME}/.customshellrc
fi
