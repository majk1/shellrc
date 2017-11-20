#!/bin/sh
#
# Shell script that can be included into .bashrc or .zshrc
#

[ -z "$PS1" ] && return
[ -f ${HOME}/.profile ] && . ${HOME}/.profile

# script base
if [ ! -z "${BASH_VERSION}" ]; then
    SCRIPT_BASE_DIR="$(dirname "$BASH_SOURCE")"
fi
if [ ! -z "${ZSH_VERSION}" ]; then
    SCRIPT_BASE_DIR="$(dirname "${(%):-%N}")"
fi
export SCRIPT_BASE_DIR

# source the core
source ${SCRIPT_BASE_DIR}/core.sh

# bash specific
if [ ! -z "${BASH_VERSION}" ]; then
    export SHELL_TYPE=bash
    source ${SCRIPT_BASE_DIR}/bashrc.sh
fi

# zsh specific
if [ ! -z "${ZSH_VERSION}" ]; then
    export SHELL_TYPE=zsh
    source ${SCRIPT_BASE_DIR}/zshrc.sh
fi

# OSX specific
if [ "$(uname)" = "Darwin" ]; then
    source ${SCRIPT_BASE_DIR}/darwin.sh
fi

# Linux specific
if [ "$(uname)" = "Linux" ]; then
    source ${SCRIPT_BASE_DIR}/linux.sh
fi

# Cygwin specific
if echo "$(uname)" | grep -q -i 'cygwin'; then
    source ${SCRIPT_BASE_DIR}/cygwin.sh
fi

# Universal utils
. "${SCRIPT_BASE_DIR}/utils/mkvMergeSub.sh"
. "${SCRIPT_BASE_DIR}/utils/createShellCommandFromJar.sh"
[ -e "${SCRIPT_BASE_DIR}/utils/z/z.sh" ] && . "${SCRIPT_BASE_DIR}/utils/z/z.sh"
alias imgcat="${SCRIPT_BASE_DIR}/utils/imgcat.sh"
alias imgls="${SCRIPT_BASE_DIR}/utils/imgls.sh"

# show status if exists
if [ -x ~/bin/status.sh ]; then
	bash ~/bin/status.sh
fi
