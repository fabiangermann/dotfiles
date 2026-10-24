# Copy stdin to the local clipboard via the OSC 52 escape sequence.
# Works over SSH as long as the local terminal supports OSC 52
# (and tmux has `set -g set-clipboard on`, if used).
#
# Usage: cat file | osc52
#        git rev-parse HEAD | osc52
#
# Notes:
# - Reads stdin via `base64 | read` instead of a command substitution,
#   because `(...)` inside a fish function does not receive the
#   function's piped stdin.
# - Buffers the whole payload before emitting the sequence, so stderr
#   output of the producing command (which goes straight to the terminal)
#   cannot end up inside the escape sequence and corrupt it.
function osc52 --description 'Copy stdin to local clipboard via OSC 52'
    base64 -w0 | read -l data
    printf '\e]52;c;%s\a' $data
end
