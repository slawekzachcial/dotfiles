#!/bin/bash

set -o errexit -o pipefail
shopt -s failglob nullglob

readonly INSTALL_SCRIPT="$(readlink --canonicalize "$0")"
readonly DOTFILES="${INSTALL_SCRIPT%/*}"
readonly NOW="$(date --utc +"%Y%m%d%H%M%Sutc")"


apt update

apt install --yes git curl tmux vim bash-completion silversearcher-ag

# FZF is only present in Ubuntu 19.04 or later, and so not available in 18.04 LTS.
# Installing it 'manually'
echo "Getting FZF..."
if [ -d "${HOME}/.fzf" ]; then
    (cd "${HOME}/.fzf" && git pull && ./install --bin)
else
    git clone https://github.com/junegunn/fzf.git "${HOME}/.fzf"
    "${HOME}/.fzf/install" --bin
fi

echo "Getting Base16 color theme..."
if [ -d "${DOTFILES}/base16-shell" ]; then
    (cd "${DOTFILES}/base16-shell" && git pull)
else
    git clone https://github.com/chriskempson/base16-shell.git "${DOTFILES}/base16-shell"
fi

for dotfile in bashrc vimrc tmux.conf; do
    echo "Processing ${DOTFILES}/${dotfile}..."
    if [ -h "${HOME}/.${dotfile}" ]; then
        if [ "${HOME}/.${dotfile}" -ef "${DOTFILES}/${dotfile}" ]; then
            echo "${HOME}/.${dotfile} already symlinked to ${DOTFILES}/${dotfile}"
            continue
        else
            echo "ERROR: ${HOME}/.${dotfile} is a symlink of $(readline --canonicalize "${HOME}/.${dotfile}")" 1>&2
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
