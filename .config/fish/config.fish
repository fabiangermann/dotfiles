fish_vi_key_bindings

# setxkbmap -layout us -variant altgr-intl -option nodeadkeys

set -x TERM "xterm-256color"
set -gx PATH ~/.local/bin ~/bin $PATH
set -gx EDITOR vim

alias ls "ls --color"
