#!/usr/bin/env bash

VERSIONS="$(wget -q -O- 'https://bitbucket.org/mn3monic/scripts/downloads?tab=tags' | grep "/mn3monic/scripts/get/.*\.tar\.gz" | sed '/\/mn3monic\/scripts\/get\/.*\.tar\.gz/s/.*href="\/mn3monic\/scripts\/get\/\([0-9\.]*\)\.tar\.gz".*/\1/' | sort -r)"
LATEST_VERSION="$(echo "$VERSIONS" | head -n 1)"

getArchiveDirectoryName() {
    echo "mn3monic-scripts-$(tar -tvzf "$1" | head -n 1 | sed 's/.*mn3monic-scripts-\([^\/]*\)\/.*/\1/')"
}

download() {
    ARCHIVE_DIR="$(mktemp -d -t "mn3monic-scripts-")"
    if type -p wget 2>&1 >/dev/null; then
        wget -q -O "${ARCHIVE_DIR}/${LATEST_VERSION}.tar.gz" "https://bitbucket.org/mn3monic/scripts/get/${LATEST_VERSION}.tar.gz"
    elif type -p curl 2>&1 >/dev/null; then
        curl -L -s -o "${ARCHIVE_DIR}/${LATEST_VERSION}.tar.gz" "https://bitbucket.org/mn3monic/scripts/get/${LATEST_VERSION}.tar.gz"
    else
        echo "Cannot download archive, no wget or curl has been found :(" >&2
        rm -rf "$ARCHIVE_DIR"
        exit 1
    fi
    if [ $? -ne 0 ]; then
        echo "Could not download archive from url: https://bitbucket.org/mn3monic/scripts/get/${LATEST_VERSION}.tar.gz" >&2
        rm -rf "$ARCHIVE_DIR"
        exit 2
    fi
    DIR_NAME="$(getArchiveDirectoryName "${ARCHIVE_DIR}/${LATEST_VERSION}.tar.gz")"
    if [ ! -z "$DIR_NAME" ]; then
        tar -C "$ARCHIVE_DIR" -xzf "${ARCHIVE_DIR}/${LATEST_VERSION}.tar.gz" 2>&1 >/dev/null
        if [ $? -ne 0 ]; then
            echo "Cannot extract archive :(" >&2
            rm -rf "$ARCHIVE_DIR"
            exit 4
        else
            if [ ! -z "$SCRIPT_BASE_DIR" ]; then
                rm -rf "${SCRIPT_BASE_DIR}/*"
                mv "${ARCHIVE_DIR}/${DIR_NAME}/*" "${SCRIPT_BASE_DIR}/"
            else
                mkdir "${HOME}/.scripts" 2>&1 >/dev/null
                if [ $? -ne 0 ]; then
                    echo "Could not create script base directory: ${HOME}/.scripts :(" >&2
                    rm -rf "$ARCHIVE_DIR"
                    exit 5
                fi
                mv "${ARCHIVE_DIR}/${DIR_NAME}/*" "${HOME}/.scripts/"
            fi
            rm -rf "$ARCHIVE_DIR"
        fi
    else
        echo "Could not get archive dir name :(" >&2
        rm -rf "$ARCHIVE_DIR"
        exit 3
    fi
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
            download
        ;;
    esac
fi
