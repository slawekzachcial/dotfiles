#!/bin/bash

set -o errexit

apt update

# Note: fzf is only present in Ubunut 19.04 or later. On 18.04 (lts) it needs
# to be installed from git as documented in fzf github repository.
apt install --yes git curl tmux vim bash-completion silversearcher-ag fzf
