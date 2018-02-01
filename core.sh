
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
alias grephash='grep -v -e "^\s*#"'
alias grephashempty='grep -v -e "^\s*#" -e "^$"'

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
	echo -n "$1" | openssl md5 /dev/stdin
}
sha1() {
	echo -n "$1" | openssl sha1 /dev/stdin
}
sha256() {
	echo -n "$1" | openssl dgst -sha256 /dev/stdin
}
sha512() {
	echo -n "$1" | openssl dgst -sha512 /dev/stdin
}
rot13() {
	echo "$1" | tr "A-Za-z" "N-ZA-Mn-za-m"
}
rot47() {
	echo "$1" | tr "\!-~" "P-~\!-O"
}
urlencode() {
	python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1])" "$1"
}
urldecode() {
	python -c "import sys, urllib as ul; print ul.unquote_plus(sys.argv[1])" "$1"
}

millis() {
    python -c "import time; print(int(time.time()*1000))"
}
nanos() {
    python -c "import time; print(int(time.time()*1000000000))"
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

backup() {
    cp "${1}" "${1}.bck-$(date '+%Y%m%d%H%M%S')"
}

# [-d days|-b rsa-bits] <path-base (will be appended by .key and .crt)>
create-openssl-key-and-cert() {
    if [ $# -lt 1 ]; then
        echo "Usage: create-openssl-key-and-cert [-d days|-b rsa-bits] <path-base (will be appended by .key and .crt)>"
        return 1
    fi
    days=365; bits=2048; pathbase=""
    while [ ! -z "$1" ]; do
        param="$1"; shift
        case "${param}" in
            -d)
                if [ -z "$1" ]; then echo "parameter -d (days) requires a value" >&2; return 2; fi
                days=$1; shift
                ;;
            -b)
                if [ -z "$1" ]; then echo "parameter -b (rsa bits) requires a value" >&2; return 2; fi
                bits=$1; shift
                ;;
            *)
                pathbase="${param}"
                ;;
        esac
    done
    if [ -z "$pathbase" ]; then echo "base path required" >&2; return 3; fi

    openssl req -x509 -nodes -days $days -newkey rsa:$bits -keyout "${pathbase}.key" -out "${pathbase}.crt"

    echo ""
    echo "nginx config example: "
    echo -e "\tssl_certificate           ${pathbase}.crt;"
    echo -e "\tssl_certificate_key       ${pathbase}.key;"
    echo -e "\tssl_dhparam               /etc/ssl/certs/dhparam.pem;"
    echo -e "\t"
    echo -e "\tssl on;"
    echo -e "\tssl_session_cache  builtin:1000  shared:SSL:10m;"
    echo -e "\tssl_protocols  TLSv1 TLSv1.1 TLSv1.2;"
    echo -e "\tssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;"
    echo -e "\tssl_prefer_server_ciphers on;"
    echo ""
}

create-openssl-dh() {
    if [ $# -lt 1 ]; then
        echo "Usage: create-openssl-dh [-b bits] <path (ex: dh2048.pem)>"
        return 1
    fi
    bits=2048; pathbase=""
    while [ ! -z "$1" ]; do
        param="$1"; shift
        case "${param}" in
            -b)
                if [ -z "$1" ]; then echo "parameter -b (rsa bits) requires a value" >&2; return 2; fi
                bits=$1; shift
                ;;
            *)
                pathbase="${param}"
                ;;
        esac
    done
    if [ -z "$pathbase" ]; then echo "path required" >&2; return 3; fi

    openssl dhparam -out "${pathbase}" $bits

    echo ""
    echo "nginx config example: "
    echo -e "\tssl_dhparam\t\t\t${pathbase};"
    echo ""
}

run-in() {
    if [ "_$1" == "_-v" ]; then
        verbose=1
        shift
    else
        verbose=0
    fi

    target_dir="$1"
    shift
    run_command="$@"
    
    if [ -z "$run_command" ]; then
        echo "Run command has to be specified" >&2
        return 2
    fi
    if [ ! -d "$target_dir" ]; then
        echo "Target dir \"${target_dir}\" doestn't exists" >&2
        return 1
    fi
    
    curdir="$(pwd)"
    
    for run_in_dir in $(find "$target_dir" -type d -maxdepth 1 -not -name '.*'); do
        cd "$run_in_dir"
        if [ $? -ne 0 ]; then
            cd "$curdir"
            echo "Could not enter directory \"${run_in_dir}\"" >&2
            return 1
        else
            [ ${verbose} -eq 1 ] && echo "Running in \"${run_in_dir}\"... "
            eval ${run_command}
        fi
        cd "$curdir"
    done
}

set-session-title() {
    export SESSION_TITLE="$@"
}

unset-session-title() {
    export SESSION_TITLE=""
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
    VERSIONS="$(wget --no-cache -q -O- 'https://github.com/majk1/shellrc/releases' | grep "/majk1/shellrc/archive/.*\.tar\.gz" | sed '/\/majk1\/shellrc\/archive\/.*\.tar\.gz/s/.*href="\/majk1\/shellrc\/archive\/\([0-9\.]*\)\.tar\.gz".*/\1/' | sort -r)"
    LATEST="$(echo "$VERSIONS" | head -n 1)"
    if [ "$LATEST" != "$SHELLRC_VERSION" ]; then
        echo -n "Upgrade shellrc-scripts to version ${LATEST} [y/n]? "
        read ANSWER
		if [ "$ANSWER" != "y" ]; then
			echo "Stopping upgrade. Bye"
		else
            wget --no-cache -q -O- "https://majk1.github.io/shellrc/installer.sh" | bash -s -- -u
        fi
    else
        if [ ! -z "$1" ]; then
            if [ "$1" == "--force" ]; then
                echo -n "Reinstall shellrc-scripts version ${LATEST} [y/n]? "
                read ANSWER
                if [ "$ANSWER" != "y" ]; then
                    echo "Stopping reinstall. Bye"
                else
                    wget --no-cache -q -O- "https://majk1.github.io/shellrc/installer.sh" | bash -s -- -u
                fi
            fi
        else
            echo "You have the latest version (${LATEST})."
            echo "To force reinstall, run update-shellrc --force"
        fi
    fi
}

if type -p source-highlight >/dev/null 2>&1; then
    alias colorcat='source-highlight -n -f esc -i '
fi

# includes
source $SCRIPT_BASE_DIR/idea.sh
source $SCRIPT_BASE_DIR/git.sh
source $SCRIPT_BASE_DIR/java.sh
source $SCRIPT_BASE_DIR/mvn.sh
source $SCRIPT_BASE_DIR/docker.sh

if [ -f ${HOME}/.customshellrc ]; then
    source ${HOME}/.customshellrc
fi
