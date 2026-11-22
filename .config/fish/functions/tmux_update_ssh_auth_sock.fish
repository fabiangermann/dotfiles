function tmux_update_ssh_auth_sock --description "Refresh SSH_AUTH_SOCK from tmux after reattaching over a new SSH connection"
    if set -q TMUX
        set -gx (tmux show-environment SSH_AUTH_SOCK | string split =)
    end
end
