## Installing dot files

For the first time, copy and paste the following code into the terminal. It will download the `.tmux.conf`, `.vimrc` and `.extended_bashrc` files and add the line to source `.extended_bashrc` to `.bashrc` (if it does not exist already).

Later, dot files can be updated by running `dot-files-update`.

```bash
curl https://raw.githubusercontent.com/michalpokusa/dot-files/main/setup-dot-files.sh | bash
```
