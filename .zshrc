ZSH=/usr/share/oh-my-zsh/
ZSH_CUSTOM=~/.oh-my-zsh/custom/
ZSH_THEME="robbyrussell"
DISABLE_AUTO_UPDATE="true"


# Base16 Shell
[[ $TERM == "xterm" ]] && export TERM=xterm-256color
#BASE16_SHELL="$HOME/.config/base16-shell/base16-default.dark.sh"
#[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

#plugins=(git archlinux django sublime themes python pip node npm history-substring-search zsh-syntax-highlighting)
plugins=(git archlinux fabric pip virtualenvwrapper, django)

source $ZSH/oh-my-zsh.sh

eval "$(fasd --init auto)"
#alias yaourt="yaourt --noconfirm"
alias less="less -R"
alias grep="grep --color=always"
alias dmesg="dmesg -L --reltime -H"

alias lag="sudo tc qdisc add dev lo root netem delay"
alias nolag="sudo tc qdisc delete dev lo root"
alias chromium="chromium --ignore-gpu-blacklist"
alias npb="npm install & bower install"

# fasd aliases
alias v='f -e vim -b viminfo' # quick opening files with vim

alias mt='~/projects/mtracker/venv/bin/python ~/projects/mtracker/mtracker.py'

PATH="$(ruby -e 'puts Gem.user_dir')/bin:~/bin:/home/doppler/personal/bin:$PATH"
EDITOR=vim

export GIT_AUTHOR_NAME="Fabian Germann"
export GIT_AUTHOR_EMAIL="fg@feinheit.ch"
export PYTHONWARNINGS=all # or 'd' for deprecation warnings only

eval $(keychain --eval --agents ssh -Q --quiet ~/.ssh/id_rsa)

mkpkg() {mkdir "$@" && touch "$@/__init__.py"}
rs() {[[ $@ ]] && ./manage.py runserver "0.0.0.0:$@" || ./manage.py runserver "0.0.0.0:8000"}

alias cabal="cabal --force-reinstalls"

# start vi mode
bindkey -v

bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward

function zle-line-init zle-keymap-select {
    VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]%  %{$reset_color%}"
    # working with git_custom_status
    #RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}$(git_custom_status) $EPS1"
    RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/} $EPS1"
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select
export KEYTIMEOUT=1
# end vi mode
