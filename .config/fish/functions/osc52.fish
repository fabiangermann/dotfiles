# Copy stdin to the local clipboard via the OSC 52 escape sequence.
# Works over SSH as long as the local terminal supports OSC 52
# (and tmux has `set -g set-clipboard on`, if used).
#
# Usage: cat file | osc52
#        git rev-parse HEAD | osc52
#
# Note: prints the sequence in three parts instead of using a command
# substitution, because `(...)` inside a fish function does not receive
# the function's piped stdin.
function osc52 --description 'Copy stdin to local clipboard via OSC 52'
    printf '\e]52;c;'
    base64 -w0
    printf '\a'
end
