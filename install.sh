#!/bin/bash

set -o errexit -o pipefail
shopt -s failglob nullglob

readonly INSTALL_SCRIPT="$(readlink --canonicalize "$0")"
readonly DOTFILES="${INSTALL_SCRIPT%/*}"
readonly NOW="$(date --utc +"%Y%m%d%H%M%Sutc")"


apt update

# Note: fzf is only present in Ubunut 19.04 or later. On 18.04 (lts) it needs
# to be installed from git as documented in fzf github repository.
apt install --yes git curl tmux vim bash-completion silversearcher-ag fzf

# which git &>/dev/null || { echo "ERROR: git command not found" 1>&2; exit 1; }
# which tmux &>/dev/null || { echo "ERROR: tmux command not found" 1>&2; exit 1; }
# which curl &>/dev/null || { echo "ERROR: curl command not found" 1>&2; exit 1; }

# [ -f /usr/share/bash-completion/bash_completion ] \
#     || [ -f /etc/bash_completion ] \
#     || echo "WARNING: bash-completion not installed" 1>&2
# which ag &>/dev/null || echo "WARNING: the silver searcher (ag) command not found" 1>&2
# which fzf &>/dev/null || echo "WARNING: fzf command not found" 1>&2

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
