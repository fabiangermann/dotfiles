if status is-interactive
    # Commands to run in interactive sessions can go here
end

fish_vi_key_bindings

# setxkbmap -layout us -variant altgr-intl -option nodeadkeys

set -x TERM "xterm-256color"
set -gx PATH ~/.local/bin ~/bin $PATH
set -gx EDITOR vim

alias ls "ls --color"

if not set -q SSH_CONNECTION
    # Local machine: use the systemd ssh-agent (SSH sessions keep the forwarded agent)
    set -x SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"
    alias wayssh "waypipe --no-gpu ssh"
    alias undone "ssh -t pnwork undone"
else
    # Server
    alias fh-cleanup-build-images "podman images --filter reference='registry.4bd9c01.registry.nineapis.ch/*' --format '{{.Repository}}:{{.Tag}}' | xargs -r podman rmi"
end
