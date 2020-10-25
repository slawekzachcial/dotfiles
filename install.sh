#!/bin/bash

set -o errexit -o pipefail
shopt -s failglob nullglob

NOW="$(date --utc +"%Y%m%d%H%M%Sutc")"
OS_FLAVOR="Debian"
DOTFILES_DIR="TO_BE_INITIALIZED"

function determine_os_flavor {
    if [ "$(uname)" == "Darwin" ]; then
        OS_FLAVOR="MacOS"
    elif [ -e /etc/debian_version ]; then
        OS_FLAVOR="Debian"
    else
        OS_FLAVOR="unsupported"
    fi
}

function install_macos_packages {
    brew install bash coreutils git curl tmux vim bash-completion the_silver_searcher
    export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH" 
}

function install_debian_packages {
    APT="apt"
    LOCALE_GEN="locale-gen"
    if [ "$(id -u)" -ne 0 ]; then
        APT="sudo apt"
        LOCALE_GEN="sudo locale-gen"
    fi

    ${APT} update
    ${APT} install --yes locales git curl tmux vim bash-completion silversearcher-ag
    ${LOCALE_GEN} "en_US.UTF-8"
}

function initialize_dotfiles_dir {
    # This can only be done after OS packages are installed as on MacOS it
    # depends on GNU readlink.
    local installScriptPath="$(readlink --canonicalize "$0")"

    DOTFILES_DIR="${installScriptPath%/*}"
}

function install_fzf {
    # FZF is only present in Ubuntu 19.04 or later, and so not available in 18.04 LTS.
    # Installing it 'manually'
    echo "Getting FZF..."
    if [ -d "${HOME}/.fzf" ]; then
        (cd "${HOME}/.fzf" && git fetch --depth 1 && git checkout FETCH_HEAD && ./install --bin)
    else
        git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
        "${HOME}/.fzf/install" --bin
    fi
}

function install_base16_colors {
    echo "Getting Base16 color theme..."
    if [ -d "${DOTFILES_DIR}/base16-shell" ]; then
        (cd "${DOTFILES_DIR}/base16-shell" && git pull)
    else
        git clone https://github.com/chriskempson/base16-shell.git "${DOTFILES_DIR}/base16-shell"
    fi
}

function create_home_symlink {
    local sourceFilePath="$1"
    local symlinkPath="${HOME}/.$(basename "${sourceFilePath}")"

    echo "Processing ${sourceFilePath}..."

    if [ ! -e "${sourceFilePath}" ]; then
        echo "ERROR: File not found: ${sourceFilePath}" 1>&2
        exit 2
    fi

    if [ -h "${symlinkPath}" ]; then
        if [ "${symlinkPath}" -ef "${sourceFilePath}" ]; then
            echo "${symlinkPath} already symlinked to ${sourceFilePath}"
            continue
        else
            echo "ERROR: ${symlinkPath} is a symlink of $(readlink --canonicalize "${symlinkPath}")" 1>&2
            exit 2
        fi
    elif [ -f "${symlinkPath}" ]; then
        if diff "${symlinkPath}" "${sourceFilePath}" > /dev/null; then
            echo "${symlinkPath} already up-to-date"
            continue
        else
            echo "Backing up ${symlinkPath} into ${symlinkPath}.${NOW}"
            mv "${symlinkPath}" "${symlinkPath}.${NOW}"
        fi
    fi

    ln --symbolic --relative "${sourceFilePath}" "${symlinkPath}"
}

# --- MAIN SCRIPT ---

determine_os_flavor

if [ "${OS_FLAVOR}" == "MacOS" ]; then
    install_macos_packages
elif [ "${OS_FLAVOR}" == "Debian" ]; then
    install_debian_packages
else
    echo "ERROR: Operating system not supported: $(uname -a)" 1>&2
    exit 1
fi

initialize_dotfiles_dir
install_fzf
install_base16_colors

for dotfile in ${DOTFILES_DIR}/{bashrc,vimrc,tmux.conf,inputrc,gitconfig}; do
    create_home_symlink "${dotfile}"
done
