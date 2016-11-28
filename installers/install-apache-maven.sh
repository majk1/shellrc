#!/usr/bin/env bash

if [ "$USER" == "root" ]; then
    echo "Root install of Apache Maven is not recommended" >&2
    exit 1
fi

DOWNLOAD_URL="$(wget -q -O- "https://maven.apache.org/download.cgi" | grep "\"http://.*apache-maven-.*-bin.tar.gz\"" | sed 's/.*href="\([^"]*\).*/\1/')"
AVAILABLE_VERSION="$(echo "$DOWNLOAD_URL" | sed 's/.*\/apache-maven-\([0-9\.]*\)-bin.tar.gz.*/\1/')"
MAVEN_BASE_DIR="${HOME}/Developer"

SCRIPT_NAME=$(basename $0)

FORCE=0
SILENT=0
ENVVARS=1

yesno() {
	local yes
	local no
	if [ -z $2 ]; then
		yes="yes"
		no="no"
	else
		yes="$2"
		no="$3"
	fi
	[ $1 -eq 1 ] && echo -n "$yes" || echo -n "$no"
}

confirmInterractive() {
	if [ $SILENT -ne 1 ]; then
		read -n 1 -p "$1 [y/n]? " ANSWER
		if [ "$ANSWER" != "y" ]; then
			echo
			echo "Stopping installation. Bye"
			exit 127
		fi
		echo
	fi
}

printUsage() {
    echo ""
    echo "Usage: $SCRIPT_NAME [options]"
    echo ""
    echo "-h | --help                this :)"
    echo "-b | --base-dir            set base directory, under this dir will be the maven package extracted"
    echo "-f | --force               force reinstall even if current version is already installed"
    echo "-s | --silent              doesn't ask for install confirmation"
    echo "-e | --disable-env-vars    disable environment variable generation into bash or zsh rc files"
    echo ""
}

processParams() {
    while [ ! -z "$1" ]; do
        local CMD="$1"
        shift
        case "$CMD" in
            "-h"|"--help")
                printUsage
                exit 1
                ;;
            "-f"|"--force")
                FORCE=1
                ;;
            "-s"|"--silent")
                SILENT=1
                ;;
            "-e"|"--disable-env-vars")
                ENVVARS=0
                ;;
            "-b"|"--base-dir")
                if [ ! -z "$1" ]; then
                    shift
                    MAVEN_BASE_DIR="$1"
                else
                    echo "The $CMD needs a parameter" >&2
                fi
                ;;
        esac
    done
}

extract() {
    echo "Downloading and extracting maven $AVAILABLE_VERSION ..."
    wget -q -O- "$DOWNLOAD_URL" | tar -C $MAVEN_BASE_DIR -xzf -
    if [ $? -ne 0 ]; then
        echo "Could not download or extract, stopping installation, sorry :(" >&2
        exit 3
    fi
    if [ -e "$MAVEN_BASE_DIR/maven" ]; then
        rm -f "$MAVEN_BASE_DIR/maven" 2>&1 >/dev/null
    fi
    ln -s "$MAVEN_BASE_DIR/apache-maven-$AVAILABLE_VERSION" "$MAVEN_BASE_DIR/maven"
}

ensureBaseDir() {
    if [ -f "$MAVEN_BASE_DIR" ]; then
        echo "Basedir is a file, cannot install :(" >&2
        exit 1
    fi
    if [ ! -d "$MAVEN_BASE_DIR" ]; then
        mkdir "$MAVEN_BASE_DIR" 2>&1 >/dev/null
        if [ $? -ne 0 ]; then
            echo "Could not create base dir \"$MAVEN_BASE_DIR\" :(" >&2
            exit 2
        fi
    fi
}

setupEnvVars() {
    if [ $ENVVARS -eq 1 ]; then
        echo "Generating maven config shell rc file ~/.mvnrc ..."
        cat << EOF > "${HOME}/.mvnrc"
export M2_HOME="${MAVEN_BASE_DIR}/maven"
export PATH="\$PATH:\$M2_HOME/bin"
EOF
        echo "Shell type is $SHELL_TYPE, inserting settings into ~/.${SHELL_TYPE}rc ..."
        SHELLRCFILE="${HOME}/.${SHELL_TYPE}rc"

        if grep -q "^source ${HOME}/.mvnrc" "$SHELLRCFILE"; then
            echo "Maven rc file already sourced into shell rc file"
        else
            LINE=1
            if head -n 1 ~/.bashrc | grep -q "^#"; then
                LINE=2
            fi
            awk "NR==1{print \"source ${HOME}/.mvnrc\"}1" "${SHELLRCFILE}" > "${SHELLRCFILE}.new"
            mv "${SHELLRCFILE}.new" "${SHELLRCFILE}"
        fi
    else
        echo "Generating mvn rc file and source into shell rc is disabled"
    fi
}

checkCurrent() {
    if type -p mvn 2>&1 >/dev/null; then
        local CURRENT_VERSION="$(mvn --version | grep 'Apache Maven' | sed 's/.*Apache\ Maven\ \([0-9\.]*\)\ .*/\1/')"
        if [ "$CURRENT_VERSION" == "$AVAILABLE_VERSION" ]; then
            if [ $FORCE -eq 1 ]; then
                echo "The same version ($AVAILABLE_VERSION) is already installed, but install is forced"
            else
                echo "The same version ($AVAILABLE_VERSION) is already installed"
                exit 0
            fi
        else
            confirmInterractive "Current version is \"$CURRENT_VERSION\". Install version \"$AVAILABLE_VERSION\""
        fi
    fi
}

install() {
    echo ""
    echo "Base directory: $MAVEN_BASE_DIR"
    echo "Maven version:  $AVAILABLE_VERSION"
    echo "RC generation:  $(yesno $ENVVARS)"
    echo ""

    confirmInterractive "Start installation"

    ensureBaseDir
    extract
    setupEnvVars
}

# -------- main ---------

processParams $@
checkCurrent
install

echo ""
echo "Apache Maven has been successfully installed"
echo "source ~/.mvnrc and type mvn --version to test"
echo ""
