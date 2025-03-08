# Dotfiles

My personal dotfiles for macOS development environment.

## Overview

This repository contains my personal configuration files (dotfiles) for various tools and applications I use in my development workflow. The dotfiles are managed using [GNU Stow](https://www.gnu.org/software/stow/), which creates symbolic links from this repository to your home directory.

## Features

- **Modular Configuration**: Each tool has its own directory, making it easy to add, remove, or modify configurations.
- **ZSH Configuration**: Enhanced ZSH setup with Oh-My-Zsh, Powerlevel10k theme, and useful plugins.
- **Neovim Setup**: Modern Neovim configuration with LSP support, fuzzy finding, and more.
- **Tmux Configuration**: Productive tmux setup with sensible defaults and useful plugins.
- **Git Configuration**: Optimized Git configuration with useful aliases and settings.
- **macOS Tools**: Configuration for macOS-specific tools like Karabiner, Yabai, and SKHD.
- **Utility Scripts**: Collection of useful scripts for development workflow.

## Directory Structure

```
.
├── alacritty/        # Alacritty terminal configuration
├── bash/             # Bash shell configuration
├── emacs/            # Emacs configuration
├── git/              # Git configuration and aliases
├── hammerspoon/      # Hammerspoon configuration
├── install.sh        # Installation script
├── karabiner/        # Karabiner-Elements configuration
├── nvim/             # Neovim configuration
├── scripts/          # Utility scripts
├── skhd/             # Simple Hotkey Daemon configuration
├── tf/               # Terraform configuration
├── tmux/             # Tmux configuration
├── yabai/            # Yabai window manager configuration
└── zsh/              # ZSH shell configuration
```

## Installation

### Prerequisites

- Git
- GNU Stow (will be installed automatically if not present)

### Quick Install

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles

# Navigate to the dotfiles directory
cd ~/dotfiles

# Run the installation script
./install.sh
```

### Manual Installation

If you prefer to install manually or want to install only specific configurations:

```bash
# Install GNU Stow
brew install stow  # macOS with Homebrew
# or
sudo apt-get install stow  # Ubuntu/Debian

# Clone the repository
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles

# Navigate to the dotfiles directory
cd ~/dotfiles

# Install specific configurations (e.g., zsh, nvim, tmux)
stow zsh
stow nvim
stow tmux
```

## Available Configurations

The following configurations are available:

- `alacritty`: Configuration for Alacritty terminal emulator
- `bash`: Bash shell configuration
- `emacs`: Emacs configuration
- `git`: Git configuration and aliases
- `hammerspoon`: Hammerspoon configuration for macOS automation
- `karabiner`: Karabiner-Elements configuration for keyboard customization
- `nvim`: Neovim configuration
- `skhd`: Simple Hotkey Daemon configuration
- `tf`: Terraform configuration
- `tmux`: Tmux configuration
- `yabai`: Yabai window manager configuration
- `zsh`: ZSH shell configuration

## Updating

To update your dotfiles:

```bash
cd ~/dotfiles
./scripts/update-dotfiles.sh
```

## Customization

### Local Customizations

You can add local customizations that won't be tracked by Git:

- ZSH: Create `~/.zshrc.local`
- Bash: Create `~/.bashrc.local`
- Git: Create `~/.gitconfig.local`

### Environment Secrets

Sensitive information like API keys should be stored in `~/.env_secrets`, which is sourced by the shell but not tracked by Git.

## Utility Scripts

The `scripts/` directory contains various utility scripts:

- `update-dotfiles.sh`: Updates dotfiles and installed tools
- `smart-search.sh`: Enhanced search functionality
- `decode-base64.sh`: Utility for decoding base64 strings
- `open-json-from-clipboard.sh`: Opens JSON from clipboard in a viewer
- `swap-tmux-pane.sh`: Utility for swapping tmux panes
- `run-scripts.sh`: Helper for running scripts
- `copy-commit-hash.sh`: Copies the current Git commit hash

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Oh-My-Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- [Neovim](https://neovim.io/)
- [GNU Stow](https://www.gnu.org/software/stow/)
