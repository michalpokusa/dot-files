# Sudo preserves environment variables
function sudo() {
    command sudo --preserve-env "$@"
}

# Create all intermediate directories if they don't exist
function mkdir() {
    command mkdir --parents "$@"
}

# Create directory and change to it immediately
function mkcd() {
  command mkdir --parents "$@" && cd "$_";
}

# Shortcuts for creating links
function hard-link() {
    command mkdir --parents $(dirname $2)
    command ln --verbose $1 $2
}

function symbolic-link() {
    command mkdir --parents $(dirname $2)
    command ln --symbolic --verbose --relative $1 $2
}

# Changing directory
function home() {
    command cd ~
}
function .() {
    command pwd
}
function ..() {
    # If first argument is a number, change directory by that many levels up
    if [[ $1 =~ ^[0-9]+$ ]]; then
        nr_of_levels=$1
    else
        nr_of_levels=1
    fi

    for ((level = 0 ; level < nr_of_levels ; level++)); do
        command cd ..
    done
}

# Interactive cd command
icd() {

    # Set the trap for Ctrl+C to clear terminal and return from the function
    trap 'clear && return' SIGINT

    current_index=1
    search_term=""

    while true; do
        clear

        # List folders and files in current directory
        files_and_dirs=$(ls --almost-all --classify | grep --extended-regexp --ignore-case "$search_term")
        files_length=$(echo "$files_and_dirs" | wc --lines)

        # Clamp current index
        if [ $current_index -lt 1 ]; then
            current_index=$files_length
        fi
        if [ $current_index -gt $files_length ]; then
            current_index=1
        fi

        # Print current directory
        echo -e "$(pwd)\n"

        # If search term not empty, print it
        if [ -n "$search_term" ]; then
            echo "Search: $search_term"
            echo
        fi


        # If no files or directories found, print message
        # if [ $files_length -eq 0 ]; then
        if [ "$files_and_dirs" = "" ]; then
            echo "No files or directories found"

        # List files and directories
        else
            entry_index=1
            selected_option=""
            for entry in $files_and_dirs; do
                # Selected entry
                if [ $entry_index -eq $current_index ]; then
                    echo -e "\033[1m\033[4m$entry\033[0m"
                    selected_option=$entry
                # Other entries
                else
                    echo -e "$entry"
                fi
                entry_index=$((entry_index + 1))
            done
        fi

        read -s -n1 action
        case "$action" in

            # Enter
            ('')
                # If the selected option is a file, open it
                if [ -f "$selected_option" ]; then
                    vim "$selected_option"
                fi
            ;;

            # Arrow keys
            ($'\033')
                read -t.001 -n2 arrow_key_code
                case "$arrow_key_code" in

                    # Up arrow key
                    ('[A')
                        current_index=$((current_index - 1))
                    ;;

                    # Down arrow key
                    ('[B')
                        current_index=$((current_index + 1))
                    ;;

                    # Right arrow key
                    ('[C')
                        # If the selected option is a directory, cd into it
                        if [ -d "$selected_option" ]; then
                            cd "$selected_option"
                            search_term=""
                        fi
                    ;;

                    # Left arrow key
                    ('[D')
                        cd ..
                        search_term=""
                    ;;
                esac
            ;;

            # Backspace
            ($'\177')
                echo "Backspace"
                search_term="${search_term%?}"
            ;;

            (*)
                search_term="$search_term$action"
            ;;
        esac
    done
}

# Docker shortcuts
function dp() {
    command docker ps --all
}
function dr() {
    command docker run --rm --interactive --tty "$@"
}
function de() {
    command docker exec --interactive --tty "$@"
}
function da() {
    command docker attach --detach-keys ctrl-d "$@"
}
function dl() {
    command docker logs --timestamps --since 1h --follow "$@"
}
function dsp() {
    command docker system prune --all --force --volumes "$@"
}

# Docker compose shortcuts
function dcu() {
    command docker compose --file docker-compose.yml up "$@"
}
function dcud() {
    command docker compose --file docker-compose.yml up --detach "$@"
}
function dcd() {
    command docker compose --file docker-compose.yml down "$@"
}
function dcdu() {
    dcd && dcu "$@"
}
function dcdud() {
    dcd && dcud "$@"
}
function dcr() {
    command docker compose --file docker-compose.yml restart "$@"
}
function dcp() {
    command docker compose --file docker-compose.yml pull "$@"
}
function dcl() {
    command docker compose --file docker-compose.yml logs "$@"
}

# Git stash shortcuts
function gsl() {
    command git stash list "$@"
}
function gsa() {
    command git stash --all --message "$@"
}
function gss() {
    command git stash --staged --message "$@"
}
function gsu() {
    command git stash --include-untracked --message "$@"
}
function gsap() {
    command git stash apply "$@"
}
function gsp() {
    command git stash pop "$@"
}
function gsd() {
    command git stash drop "$@"
}

# Convinience shortcuts
function public-ip() {
    command curl https://ifconfig.me/ip
    command printf "\n"
}

function ports() {
    command netstat --tcp --udp --listening --all --numeric-hosts --numeric-ports --extend --program --timers
}

function total-size() {
    command du --human-readable --summarize --total "$@"
}

vim() {
    # Get last argument and save it as file path
    for ARG in $@; do :; done
    FILE_PATH=$ARG

    ABSOLUTE_FILE_PARENT_DIRECTORY=$(realpath $(dirname $FILE_PATH))

    # If file name was provided, try creating its parent directory if it doesn't exist
    if [[ -n "$FILE_PATH" && ! -d "$ABSOLUTE_FILE_PARENT_DIRECTORY" ]]; then

        UNDERLINE="\033[4m"
        RESET="\033[0m"

        # Ask whether to create parent directory
        read -n1 -p "$(echo -e "Create parent directory $UNDERLINE$ABSOLUTE_FILE_PARENT_DIRECTORY$RESET? [y/N] ")" SHOULD_CREATE_PARENT_DIRECTORY
        if [[ "$SHOULD_CREATE_PARENT_DIRECTORY" =~ y|Y ]]; then
            mkdir --parents $ABSOLUTE_FILE_PARENT_DIRECTORY
        fi
        echo
    fi

    # Open file in vim
    command vim $@
}

function sv() {
    # Set path for venv
    if [[ -n "$1" ]]; then
        local venv_path=$1
    else
        local venv_path=".venv"
    fi

    source $venv_path/bin/activate
}

function recreate-python-venv() {
    # Set path for venv
    if [[ -n "$1" ]]; then
        local venv_path=$1
    else
        local venv_path=".venv"
    fi

    # Remove existing venv if exists
    if [[ -d "$venv_path" ]]; then
    printf "Removing existing $venv_path\n"
        command rm -rf $venv_path
    fi

    # Create new venv
    printf "Creating new $venv_path\n"
    python3 -m venv $venv_path

    # Activate venv
    source $venv_path/bin/activate

    # Install packages from requirements.txt
    if [[ -f "requirements.txt" ]]; then
        printf "Installing packages from requirements.txt\n"
        pip install -r requirements.txt
    fi
}


test-terminal-8-bit-colors() {
    # Read text to use as a placeholder
    read -p "Enter text to use as a placeholder: " placeholderText

    # Foreground colors
    for colorIndex in {0..255} ; do
        printf "\x1b[0m${colorIndex}: "

        # Print placeholder using foreground color
        printf "\x1b[38;5;${colorIndex}m${placeholderText}\x1b[0m"

        # Print a block of background color
        printf "\t\t\x1b[48;5;${colorIndex}m                  \x1b[0m\n"
    done
}

# Updating dot files from the repository
function update-dot-files() {
    curl --silent https://raw.githubusercontent.com/michalpokusa/dot-files/main/update-or-setup-dot-files.sh | bash
}
function udf() {
    update-dot-files
}