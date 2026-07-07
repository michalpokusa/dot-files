# Allow executing scripts from home and current directory
export PATH="$PATH:~:."

# Set default editor
export EDITOR="vim"

# Preprent with date and time
export PS1="[\[\033[38;5;239m\]\$(date +%Y-%m-%d\\ %H:%M:%S)\[\033[0m\]] $PS1"

# Fix for tmux
export TERM="xterm-256color"

export HISTFILESIZE=10000           # Number of history commands that will be stored on disk (default: 500).
shopt -s histappend                 # Append to history instead of overwriting
export HISTCONTROL="ignoreboth"     # Ignore duplicates and commands starting with space
export HISTTIMEFORMAT='%F %T - '    # Add date and time to history records

function disable-history() {
    export ORIGINAL_HISTIGNORE="$HISTIGNORE"
    export HISTIGNORE="*"
    history -d $(history 1 | awk '{print $1}')
}
function enable-history() {
    export HISTIGNORE="$ORIGINAL_HISTIGNORE"
    unset ORIGINAL_HISTIGNORE
}

# Default to path completion if no other completions are found
complete -o bashdefault -o default -D

function load-dot-env() {
    local env_files=("$@")
    if [[ ${#env_files[@]} -eq 0 ]]; then
        env_files=(".env")
    fi

    for env_file in "${env_files[@]}"; do
        while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ -z "$line" || "$line" == \#* ]]; then
                continue
            fi

            name=${line%%=*}
            value=${line#*=}

            export "$name=$value"
        done < "$env_file"
    done
}

function cd() {
    builtin cd "$@" && command ls -l --all --time-style=long-iso --human-readable --color=auto
}

alias ...="cd ../.."

alias ls="ls -l --all --time-style=long-iso --human-readable --color=auto"
alias mkdir="mkdir --parents"

function mkcd() {
  command mkdir --parents "$@" && cd "$_";
}

alias home='cd ~'
alias projects='cd ~/projects'

function hard-link() {
    local source_path="$1"
    local target_path="$2"

    command mkdir --parents $(dirname "$target_path")
    command ln --verbose "$source_path" "$target_path"
}

function symbolic-link() {
    local source_path="$1"
    local target_path="$2"

    command mkdir --parents $(dirname "$target_path")
    command ln --symbolic --verbose --relative "$source_path" "$target_path"
}

function backup() {
    local input_paths=()
    local to=""

    while [[ $# -gt 0 ]]; do
      case "$1" in
        -to)
            to="${2%/}"
            shift 2
        ;;
        -*)
            echo "Unknown option: $1"
            return 1
        ;;
        *)
            input_paths+=("$1")
            shift
        ;;
      esac
    done

    if [[ ${#input_paths[@]} -eq 0 ]]; then
        echo "No input paths provided"
        return 1
    fi

    local backup_path_suffix="backup-$(date +%Y-%m-%d_%H-%M-%S).tar.gz"
    local backup_path

    if [[ -n "$to" ]]; then
        backup_path="$to.$backup_path_suffix"
    elif [[ ${#input_paths[@]} -eq 1 ]]; then
        backup_path="$(basename "${input_paths[0]}").$backup_path_suffix"
    else
        backup_path="$backup_path_suffix"
    fi

    command mkdir --parents "$(dirname "$backup_path")"
    command tar --verbose --create --gzip --preserve-permissions --file "$backup_path" "${input_paths[@]}"

    printf "$backup_path\n"
}

function restore-backup() {
    command tar --verbose --extract --gzip --preserve-permissions --file "$@"
}

alias dp='docker ps --all'
alias dr='docker run --rm --interactive --tty'
alias de='docker exec --interactive --tty'
alias da='docker attach --detach-keys "d,e,t,a,c,h"'
alias dsp='docker system prune --all --force --volumes'
alias dcu='docker compose up'
alias dcud='docker compose up --detach'
alias dcd='docker compose down'
alias dcdu='dcd && dcu'
alias dcdud='dcd && dcud'
alias dcr='docker compose restart'
alias dcp='docker compose pull'
alias dcl='docker compose logs'

function gl() {
    GIT_PAGER='less -R' command git log \
        --graph \
        --all \
        --full-history \
        --author-date-order \
        --date=format:'%Y-%m-%d %H:%M:%S' \
        --format=format:'%C(bold blue)%h%C(reset) - %C(auto)%d%C(reset) %C(white)%s%C(reset) %C(dim white)- %an at %ad %C(dim black)(%ar)%C(reset)'
}

alias gwl='git worktree list'
alias gwa='git worktree add'
alias gwr='git worktree remove'
alias gwm='git worktree move'

function gwmb() {
    local current_worktree_path=$(pwd)
    local new_worktree_name=$(git branch --show-current | sed 's/\//-/g')
    local worktrees_folder=$(dirname $(pwd))
    local new_worktree_path="$worktrees_folder/$new_worktree_name"

    printf "old: $current_worktree_path\nnew: $new_worktree_path\nMove [y/N]:"
    read should_move_worktree
    if [[ ! "$should_move_worktree" =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        return 1
    fi

    git worktree move . "$new_worktree_path"
    builtin cd "$new_worktree_path"
}

alias gsl='git stash list'
alias gsa='git stash --all --message'
alias gss='git stash --staged --message'
alias gsu='git stash --include-untracked --message'

alias gsap='git stash apply'
alias gsp='git stash pop'
alias gsd='git stash drop'

alias public-ip="curl https://checkip.amazonaws.com"
alias ports="netstat --tcp --udp --listening --all --numeric-hosts --numeric-ports --extend --program --timers"
alias total-size="du --human-readable --summarize --total"

function sv() {
    local venv_path="${1:-.venv}"

    source $venv_path/bin/activate
}

function update-dot-files() {
    local repository_path="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

    builtin cd "$repository_path" || return 1

    git pull --stat --progress --verbose origin main
}
