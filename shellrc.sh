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
    source ${SCRIPT_BASE_DIR}/bashrc.sh
fi

# zsh specific
if [ ! -z "${ZSH_VERSION}" ]; then
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

# Universal utils
source "${SCRIPT_BASE_DIR}/utils/z/z.sh"

# show status if exists
if [ -x ~/bin/status.sh ]; then
	bash ~/bin/status.sh
fi
