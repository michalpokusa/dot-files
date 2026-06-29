PROMPT='%n@%m %~ %# '
RPROMPT='%*'


setopt extended_glob
setopt glob_dots


HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt append_history
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt inc_append_history


# Ctrl+← / Ctrl+→ word jumps
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word


# Ctrl+Shift+← / Ctrl+Shift+→ start begin of command and end of command
bindkey '^[[1;6C' end-of-line
bindkey '^[[1;6D' beginning-of-line

# Ctrl+Shift+Backspace delete to the beginning of the line
bindkey '^[[1;6H' backward-kill-line

# Ctrl+Shift+Delete delete to the end of the line
bindkey '^[[3;6~' kill-line

# Ctrl+X, E edit command line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^Xe' edit-command-line
