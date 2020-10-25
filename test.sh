#!/bin/bash

set -o errexit -o pipefail
shopt -s failglob nullglob

docker version &>/dev/null || { echo "ERROR: Tests require Docker!" 1>&2; exit 1; }

readonly TEST_SCRIPT_PATH="$(readlink --canonicalize "$0")"
readonly DOTFILES_DIR="${TEST_SCRIPT_PATH%/*}"
readonly TEST_SINGLE_IMAGE="$1"

function test_install_in_image {
    local imageTag="$1"
    local interactive="$2"

    echo
    echo "TESTING dotfiles installation on ${imageTag}..."
    echo

    docker pull "${imageTag}"
    if [ -n "${interactive}" ]; then
        docker run --interactive --tty --rm \
            --volume "${DOTFILES_DIR}":/dotfiles_source:ro \
            "${imageTag}" \
            /bin/bash -c 'mkdir /dotfiles && cp -r /dotfiles_source/* /dotfiles && /dotfiles/install.sh && ls -la $HOME && TMUX=none /bin/bash'
    else
        docker run --rm \
            --volume "${DOTFILES_DIR}":/dotfiles_source:ro \
            "${imageTag}" \
            /bin/bash -c 'mkdir /dotfiles && cp -r /dotfiles_source/* /dotfiles && /dotfiles/install.sh && ls -la $HOME'
    fi
}

# --- MAIN SCRIPT ---

if [ -n "${TEST_SINGLE_IMAGE}" ]; then
    test_install_in_image "${TEST_SINGLE_IMAGE}" interactive
else
    test_install_in_image ubuntu:18.04
    test_install_in_image ubuntu:20.04
    test_install_in_image debian:stretch
    test_install_in_image debian:buster
    test_install_in_image debian:bullseye
fi
