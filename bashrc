# ~/.bashrc: executed by bash(1) for non-login shells.

umask 022
set -o vi
export EDITOR=vim

# Export TERM to have Tmux properly handle Base16 colors
export TERM=xterm-256color

export LC_ALL="en_US.UTF-8"

function __prompt_command {
    local lastExitCode=$?
    local ps1ExitCode=""
    if [ "${lastExitCode}" -ne 0 ]; then
        ps1ExitCode="\[\033[0;31m\](${lastExitCode})\[\033[00m\]"
    fi

    local pyvenv=""
    if [ -n "${VIRTUAL_ENV}" ]; then
        pyvenv=" (\[\033[01;32m\]py\[\033[00m\] $(basename "${VIRTUAL_ENV}"))"
    fi

    local k8s=""
    local k8sContext="$(basename $(kubectl config current-context))"
    if [ -n "${k8sContext}" ]; then
        if [[ "${k8sContext}" == *"pro"* ]]; then
            k8sContext="\[\033[0;41m\]${k8sContext}\[\033[00m\]"
        fi
        k8s=" (\[\033[01;32m\]k8s\[\033[00m\] ${k8sContext})"
    fi

    # See /usr/lib/git-core/git-sh-prompt for details about __git_ps1
    export GIT_PS1_SHOWUPSTREAM=verbose
    export GIT_PS1_SHOWDIRTYSTATE=1
    export GIT_PS1_SHOWSTASHSTATE=1
    export GIT_PS1_SHOWCOLORHINTS=1
    # __git_ps1 "\n\[\033[01;34m\]\w\[\033[00m\]" "\n${ps1ExitCode}\$ "
    __git_ps1 "\n\[\033[01;34m\]\w\[\033[00m\]" "${k8s}${pyvenv}\n${ps1ExitCode}"$' \u03bb '
}
export PROMPT_COMMAND=__prompt_command

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=9999
HISTFILESIZE=9999

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
eval "$(SHELL=/bin/sh lesspipe 2>/dev/null || SHELL=/bin/sh lesspipe.sh)"

# enable color support of ls and also add handy aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# enable programmable completion features
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    elif [ -f /usr/local/etc/bash_completion ]; then
        . /usr/local/etc/bash_completion
    fi
fi

# FZF
if [ -d ~/.fzf ]; then
    export PATH="${PATH}:${HOME}/.fzf/bin"
    . ~/.fzf/shell/completion.bash
    . ~/.fzf/shell/key-bindings.bash
fi

# Base16 Shell
export BASE16_THEME=base16-default
if [ -f ~/.dotfiles/base16-shell/scripts/${BASE16_THEME}-dark.sh ]; then
    . ~/.dotfiles/base16-shell/scripts/${BASE16_THEME}-dark.sh
fi

# if [ -r ${HOME}/.ssh/id_rsa ]; then
if [[ -r ${HOME}/.ssh/id_ed25519 || -r ${HOME}/.ssh/id_rsa ]]; then
    # Start SSH-agent
    export SSH_AUTH_SOCK=/tmp/.ssh-socket

    # ssh-agent automated start
    ssh-add -l &>/dev/null

    if [[ $? = 2 ]]; then

        # Delete the socket file in case the agent was not shutdown correctly
        rm -f ${SSH_AUTH_SOCK}

        # Exit status 2 means couldn't connect to ssh-agent; start one now
        ssh-agent -a ${SSH_AUTH_SOCK} >/tmp/.ssh-script
        . /tmp/.ssh-script
        echo ${SSH_AGENT_PID} >/tmp/.ssh-agent-pid

        # Add my private key
        [ -r ${HOME}/.ssh/id_rsa ]     && ssh-add ${HOME}/.ssh/id_rsa     || /bin/true
        [ -r ${HOME}/.ssh/id_ed25519 ] && ssh-add ${HOME}/.ssh/id_ed25519 || /bin/true
    fi
fi

# launch tmux if not already in
[ -n "$TMUX" ] || exec tmux -u new-session -A -s Tmux

complete -C /usr/bin/terraform terraform
