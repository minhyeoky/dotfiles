These are dotfiles i use. 
`.install_ec2.sh` works for Ubuntu. (tested on AWS EC2) It installs minimum things, mainly (neo)vim.

`.install.sh` is for personal usage.

This installation script can override existing configuration so use at your own risk.

## Installation

```sh
git clone https://github.com/minhyeoky/dotfiles
cd dotfiles
./install_ec2.sh
```

## Post Installation

Run command `:PlugInstall` in vim to install plugins. (See [vim-plug](https://github.com/junegunn/vim-plug))

Run command `:CocInstall <lsp-name>` in vim to install langauges server. (See [Language servers](https://github.com/neoclide/coc.nvim/wiki/Language-servers))

## Plugins

- [vim-plug](https://github.com/junegunn/vim-plug): Plugin manager.
- [coc.nvim](https://github.com/neoclide/coc.nvim): Language server in vim.
- [fzf.vim](https://github.com/junegunn/fzf.vim): search in vim.
- [tagbar](https://github.com/preservim/tagbar): side bar for tags.
- [fugitive](https://github.com/tpope/vim-fugitive): git command wrapper in vim.
- [gitgutter](https://github.com/airblade/vim-gitgutter): displays git gutter.
- [nerdtree](https://github.com/preservim/nerdtree): file manager in vim.
- [nerdtree-git-plugin](https://github.com/Xuyuanp/nerdtree-git-plugin): displays git status in nerdtree.
- [vim-startify](https://github.com/Xuyuanp/mhinz/vim-startify): session manager & start screen in vim.
- ...etc.

