
function update-or-setup-dot-files() {
    local repository_url="https://raw.githubusercontent.com/michalpokusa/dot-files/main"

    local files=(
        ".bash_functions"
        ".extended_bashrc"
        ".tmux.conf"
        ".vimrc"
    )

    for file in "${files[@]}"; do
        local absolute_file_path="$HOME/$file"

        # File exists, update it
        if [[ -f "$absolute_file_path" ]]; then

            # Compare checksums
            local before_md5=$(cat $HOME/$file | md5sum)
            curl --silent "$repository_url/files/$file" > $HOME/$file
            local after_md5=$(cat $HOME/$file | md5sum)

            if [[ "$before_md5" != "$after_md5" ]]; then
                printf "$file has been updated\n"
            else
                printf "$file is up to date\n"
            fi

        # File does not exist, download it
        else
            curl --silent "$repository_url/files/$file" > $HOME/$file
            printf "Downloaded $file\n"
        fi
    done


    # Sourcing .extended_bashrc in .bashrc
    local bashrc_path="$HOME/.bashrc"
    local extended_bashrc_path="$HOME/.extended_bashrc"
    local line_to_check="source $extended_bashrc_path"

    # Line for sourcing .extended_bashrc does not exist in .bashrc
    if ! grep --fixed-strings --line-regexp --silent "$line_to_check" "$bashrc_path"; then
        printf "$line_to_check\n" >> "$bashrc_path"
        printf "Added line to source .extended_bashrc to .bashrc\n"

    # Line for sourcing .extended_bashrc already exists in .bashrc
    else
        printf "Line to source .extended_bashrc already exists in .bashrc\n"
    fi
}

update-or-setup-dot-files
