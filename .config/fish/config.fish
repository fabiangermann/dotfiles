fish_vi_key_bindings

# setxkbmap -layout us -variant altgr-intl -option nodeadkeys

set -x TERM "xterm-256color"
set -gx PATH ~/.local/bin ~/bin $PATH
set -gx EDITOR vim

# Use the local systemd ssh-agent, but keep the forwarded agent in SSH sessions
if not set -q SSH_CONNECTION
    set -x SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"
end

alias ls "ls --color"

alias fh-cleanup-build-images "podman images --filter reference='registry.4bd9c01.registry.nineapis.ch/*' --format '{{.Repository}}:{{.Tag}}' | xargs -r podman rmi"
