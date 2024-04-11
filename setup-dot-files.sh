DOTFILES_REPOSITRY_URL="https://raw.githubusercontent.com/michalpokusa/dot-files/main"

# Download the .tmux.conf, .vimrc and .extended_bashrc files
for file in ".tmux.conf" ".vimrc" ".extended_bashrc"; do
    curl --silent "$DOTFILES_REPOSITRY_URL/$file" > "$HOME/$file"
    echo "Downloaded $file"
done

# Add the line to source .extended_bashrc to .bashrc
BASHRC_PATH="$HOME/.bashrc"
EXTENDED_BASHRC_PATH="$HOME/.extended_bashrc"
LINE_TO_CHECK="source $EXTENDED_BASHRC_PATH"

# Check if the line exists in the file
if ! grep --fixed-strings --line-regexp --silent "$LINE_TO_CHECK" "$BASHRC_PATH"; then
    echo "$LINE_TO_CHECK" >> "$BASHRC_PATH"
    echo "Added line to source .extended_bashrc to .bashrc"
else
    echo "Line to source .extended_bashrc already exists in .bashrc"
fi
