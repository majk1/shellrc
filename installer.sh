#!/usr/bin/env bash

getLatestVersion() {
    local VERSIONS="$(wget --no-cache -q -O- 'https://bitbucket.org/mn3monic/scripts/downloads?tab=tags' | grep "/mn3monic/scripts/get/.*\.tar\.gz" | sed '/\/mn3monic\/scripts\/get\/.*\.tar\.gz/s/.*href="\/mn3monic\/scripts\/get\/\([0-9\.]*\)\.tar\.gz".*/\1/' | sort -r)"
    local LATEST="$(echo "$VERSIONS" | head -n 1)"
    echo "${LATEST}"
}

LATEST_VERSION="$(getLatestVersion)"

getArchiveDirectoryName() {
    echo "mn3monic-scripts-$(tar -tvzf "$1" | head -n 1 | sed 's/.*mn3monic-scripts-\([^\/]*\)\/.*/\1/')"
}

SILENT=0

log() {
    if [ $SILENT -eq 0 ]; then
        echo "$@"
    fi
}

err() {
    echo "$@" >&2
}

download() {
    log "Installing/upgrading scripts version $LATEST_VERSION"
    ARCHIVE_DIR="$(mktemp -d -t "mn3monic-scripts-XXXX")"
    log "Created temp directory: $ARCHIVE_DIR"
    if type -p wget 2>&1 >/dev/null; then
        log "Using wget to fetch archive"
        wget -q -O "${ARCHIVE_DIR}/${LATEST_VERSION}.tar.gz" "https://bitbucket.org/mn3monic/scripts/get/${LATEST_VERSION}.tar.gz"
    elif type -p curl 2>&1 >/dev/null; then
        log "Using curl to fetch archive"
        curl -L -s -o "${ARCHIVE_DIR}/${LATEST_VERSION}.tar.gz" "https://bitbucket.org/mn3monic/scripts/get/${LATEST_VERSION}.tar.gz"
    else
        err "Cannot download archive, no wget or curl has been found :("
        rm -rf "$ARCHIVE_DIR"
        exit 1
    fi
    if [ $? -ne 0 ]; then
        err "Could not download archive from url: https://bitbucket.org/mn3monic/scripts/get/${LATEST_VERSION}.tar.gz"
        rm -rf "$ARCHIVE_DIR"
        exit 2
    fi
    DIR_NAME="$(getArchiveDirectoryName "${ARCHIVE_DIR}/${LATEST_VERSION}.tar.gz")"
    if [ ! -z "$DIR_NAME" ]; then
        log "Extracting archive ${ARCHIVE_DIR}/${DIR_NAME}"
        tar -C "$ARCHIVE_DIR" -xzf "${ARCHIVE_DIR}/${LATEST_VERSION}.tar.gz" 2>&1 >/dev/null
        if [ $? -ne 0 ]; then
            err "Cannot extract archive :("
            rm -rf "$ARCHIVE_DIR"
            exit 4
        else
            if [ ! -z "$SCRIPT_BASE_DIR" ]; then
                log "Script base already exists at ${SCRIPT_BASE_DIR}, cleaning"
                rm -rf "${SCRIPT_BASE_DIR}/*"
                log "Moving extracted archive to ${SCRIPT_BASE_DIR}"
                mv ${ARCHIVE_DIR}/${DIR_NAME}/* "${SCRIPT_BASE_DIR}/"
            else
                SCRIPT_BASE_DIR="${HOME}/.scripts"
                log "Creating script base ${SCRIPT_BASE_DIR}"
                mkdir "${SCRIPT_BASE_DIR}" 2>&1 >/dev/null
                if [ $? -ne 0 ]; then
                    err "Could not create script base directory: ${SCRIPT_BASE_DIR} :("
                    rm -rf "$ARCHIVE_DIR"
                    exit 5
                fi
                log "Moving extracted archive to ${SCRIPT_BASE_DIR}"
                mv ${ARCHIVE_DIR}/${DIR_NAME}/* "${SCRIPT_BASE_DIR}/"
            fi
            log "Clearing temp dir ${ARCHIVE_DIR}"
            rm -rf "$ARCHIVE_DIR"
        fi
    else
        err "Could not get archive dir name :("
        rm -rf "$ARCHIVE_DIR"
        exit 3
    fi

    if [ -f "${HOME}/.bashrc" ]; then
        if [ ! -f "${HOME}/.bashrc.backup" ]; then
            log "Backing up existing .bashrc file"
            mv "${HOME}/.bashrc" "${HOME}/.bashrc.backup"
        else
            log "Backup .bashrc file already exists, not backing up"
        fi
        log "Generating ${HOME}.bashrc"
        cat << EOF > "${HOME}/.bashrc"
# Generated by mn3monic-scripts version ${LATEST_VERSION}
export SHELLRC_VERSION="${LATEST_VERSION}"
source "${SCRIPT_BASE_DIR}/shellrc.sh"
EOF
    fi

    if [ -f "${HOME}/.zshrc" ]; then
        if [ ! -f "${HOME}/.zshrc.backup" ]; then
            log "Backing up existing .zshrc file"
            mv "${HOME}/.zshrc" "${HOME}/.zshrc.backup"
        else
            log "Backup .zshrc file already exists, not backing up"
        fi
        log "Generating ${HOME}.zshrc"
        cat << EOF > "${HOME}/.zshrc"
# Generated by mn3monic-scripts version ${LATEST_VERSION}
export SHELLRC_VERSION="${LATEST_VERSION}"
source "${SCRIPT_BASE_DIR}/shellrc.sh"
EOF
    fi

    log "Installation of scripts (ver ${LATEST_VERSION}) has finished successfully"
}

if [ ! -z "$1" ]; then
    case "$1" in
        "-a")
            if [ ! -z "$SHELLRC_VERSION" ]; then
                if [ "$SHELLRC_VERSION" != "$LATEST_VERSION" ]; then
                    echo "$LATEST_VERSION"
                fi
            else
                echo "$LATEST_VERSION"
            fi
        ;;
        "-u")
            read -n 1 -p "This will install mn3monic-scripts ${LATEST_VERSION}. Continue [y/n]? " ANSWER
            if [ "$ANSWER" != "y" ]; then
                echo
                echo "Stopping installation. Bye"
                exit 127
            fi
            download
        ;;
        "-su")
            SILENT=1
            download
        ;;
    esac
fi