# Sudo preserves environment variables
function sudo() {
    command sudo --preserve-env "$@"
}

# Use long iso date format for ls
function ls() {
    command ls --time-style=long-iso "$@"
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

function how-long() {
    local start_time=$(command date +%s%N)

    # Execute the command
    "$@"

    local end_time=$(command date +%s%N)

    local duration_ns=$((end_time - start_time))

    local hours=$((duration_ns / 3600000000000))
    local minutes=$((duration_ns % 3600000000000 / 60000000000))
    local seconds=$((duration_ns % 3600000000000 % 60000000000 / 1000000000))
    local milliseconds=$((duration_ns % 3600000000000 % 60000000000 % 1000000000 / 1000000))

    function wordy_duration() {
        local hours=$1
        local minutes=$2
        local seconds=$3
        local milliseconds=$4
        local output=""

        if [ $hours -gt 0 ]; then
            if [ $hours -eq 1 ]; then
                output="$hours hour"
            else
                output="$hours hours"
            fi
        fi

        if [ $minutes -gt 0 ]; then
            if [[ -n "$output" ]]; then
                output="$output "
            fi

            if [ $minutes -eq 1 ]; then
                output="$output$minutes minute"
            else
                output="$output$minutes minutes"
            fi
        fi

        if [ $seconds -gt 0 ]; then
            if [[ -n $output ]]; then
                output="$output "
            fi

            if [ $seconds -eq 1 ]; then
                output="$output$seconds second"
            else
                output="$output$seconds seconds"
            fi
        fi

        if [ $milliseconds -gt 0 ]; then
            if [[ -n $output ]]; then
                output="$output "
            fi

            if [ $milliseconds -eq 1 ]; then
                output="$output$milliseconds millisecond"
            else
                output="$output$milliseconds milliseconds"
            fi
        fi
        printf "$output"
    }

    function pad-left-with-zero() {
        local value=$1
        local length=$2
        local result=""

        for ((i = 0 ; i < length ; i++)); do
            result="${result}0"
        done

        result="${result}${value}"

        printf ${result: -length}
    }

    function clock_duration() {
        local hours=$1
        local minutes=$2
        local seconds=$3
        local milliseconds=$4
        local outpout=""

        output+="$(pad-left-with-zero $hours 2):"
        output+="$(pad-left-with-zero $minutes 2):"
        output+="$(pad-left-with-zero $seconds 2)."
        output+="$(pad-left-with-zero $milliseconds 3)"

        printf "$output"
    }

    printf "\n$(clock_duration $hours $minutes $seconds $milliseconds) ($(wordy_duration $hours $minutes $seconds $milliseconds))\n"
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
