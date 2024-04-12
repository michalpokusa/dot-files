REPOSITORY_URL="https://raw.githubusercontent.com/michalpokusa/dot-files/main"

FILES=(
    ".tmux.conf"
    ".vimrc"
    ".extended_bashrc"
)

for FILE in "${FILES[@]}"; do
    FULL_FILE_PATH="$HOME/$FILE"

    # File exists, update it
    if [ -f "$FULL_FILE_PATH" ]; then

        # Compare checksums
        BEFORE_MD5=$(cat $HOME/$FILE | md5sum)
        curl --silent "$REPOSITORY_URL/files/$FILE" > $HOME/$FILE
        AFTER_MD5=$(cat $HOME/$FILE | md5sum)

        if [ "$BEFORE_MD5" != "$AFTER_MD5" ]; then
            echo -e "$FILE has been updated"
        else
            echo -e "$FILE is up to date"
        fi

    # File does not exist, download it
    else
        curl --silent "$REPOSITORY_URL/files/$FILE" > $HOME/$FILE
        echo -e "Downloaded $FILE"
    fi
done


# Sourcing .extended_bashrc by .bashrc
BASHRC_PATH="$HOME/.bashrc"
EXTENDED_BASHRC_PATH="$HOME/.extended_bashrc"

LINE_TO_CHECK="source $EXTENDED_BASHRC_PATH"

# Line for sourcing .extended_bashrc does not exist in .bashrc
if ! grep --fixed-strings --line-regexp --silent "$LINE_TO_CHECK" "$BASHRC_PATH"; then
    echo "$LINE_TO_CHECK" >> "$BASHRC_PATH"
    echo "Added line to source .extended_bashrc to .bashrc"

# Line for sourcing .extended_bashrc already exists in .bashrc
else
    echo "Line to source .extended_bashrc already exists in .bashrc"
fi
