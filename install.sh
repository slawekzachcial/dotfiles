#!/bin/bash

set -o errexit -o pipefail
shopt -s failglob nullglob

# readlink on MacOS does not support --canonicalize option.
# MacOS requires greadlink that can be installed with "brew install coreutils."
function __readlink {
    if ! readlink "$@" 2>/dev/null && ! greadlink "$@" 2>/dev/null; then
        echo "ERROR: readlink error (Linux) or greadlink not found or error (MacOS); arguments: $@" 1>&2
        exit 1
    fi
}

export -f __readlink

readonly INSTALL_SCRIPT="$(__readlink --canonicalize "$0")"
readonly DOTFILES="${INSTALL_SCRIPT%/*}"
# Use '-u' instead of '--utc' as it works on both Linux and Macos
readonly NOW="$(date -u +"%Y%m%d%H%M%Sutc")"

# Run 'apt' only on Ubuntu. On other platforms tools need to be installed manually.
if grep --quiet --ignore-case ubuntu /etc/lsb-release 2>/dev/null; then
    APT="apt"
    if [ "$(id -u)" -ne 0 ]; then
        APT="sudo apt"
    fi

    ${APT} update
    ${APT} install --yes git curl tmux vim bash-completion silversearcher-ag
fi

which git   &>/dev/null || { echo "ERROR: git not found!" 1>&2; exit 1; }
which curl  &>/dev/null || { echo "ERROR: curl not found!" 1>&2; exit 1; }
which tmux  &>/dev/null || { echo "ERROR: tmux not found!" 1>&2; exit 1; }
which ag    &>/dev/null || { echo "WARNING: ag not found!" 1>&2; }

# FZF is only present in Ubuntu 19.04 or later, and so not available in 18.04 LTS.
# Installing it 'manually'
echo "Getting FZF..."
if [ -d "${HOME}/.fzf" ]; then
    (cd "${HOME}/.fzf" && git pull --depth 1 && ./install --bin)
else
    git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
    "${HOME}/.fzf/install" --bin
fi

echo "Getting Base16 color theme..."
if [ -d "${DOTFILES}/base16-shell" ]; then
    (cd "${DOTFILES}/base16-shell" && git pull)
else
    git clone https://github.com/chriskempson/base16-shell.git "${DOTFILES}/base16-shell"
fi

for dotfile in bashrc vimrc tmux.conf inputrc; do
    echo "Processing ${DOTFILES}/${dotfile}..."
    if [ -h "${HOME}/.${dotfile}" ]; then
        if [ "${HOME}/.${dotfile}" -ef "${DOTFILES}/${dotfile}" ]; then
            echo "${HOME}/.${dotfile} already symlinked to ${DOTFILES}/${dotfile}"
            continue
        else
            echo "ERROR: ${HOME}/.${dotfile} is a symlink of $(__readlink --canonicalize "${HOME}/.${dotfile}")" 1>&2
            exit 2
        fi
    elif [ -f "${HOME}/.${dotfile}" ]; then
        if diff "${HOME}/.${dotfile}" "${DOTFILES}/${dotfile}" > /dev/null; then
            echo "${HOME}/.${dotfile} already up-to-date"
            continue
        else
            echo "Backing up ${HOME}/.${dotfile} into ${HOME}/.${dotfile}.${NOW}"
            mv "${HOME}/.${dotfile}" "${HOME}/.${dotfile}.${NOW}"
        fi
    fi

    ln --symbolic --relative "${DOTFILES}/${dotfile}" "${HOME}/.${dotfile}"
done
