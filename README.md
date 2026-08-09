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
- **macOS Tools**: Configuration for macOS-specific tools like Yabai and SKHD.
- **Utility Scripts**: Collection of useful scripts for development workflow.
- **Claude Code Plugins**: Personal Claude Code plugins for workflow automation (e.g., tmux session status).

## Directory Structure

```
.
├── alacritty/        # Alacritty terminal configuration
├── bash/             # Bash shell configuration
├── claude/           # Claude Code behavioral guidelines + settings template
├── emacs/            # Emacs configuration
├── git/              # Git configuration and aliases
├── hammerspoon/      # Hammerspoon configuration
├── my-plugins/       # Personal Claude Code plugins
├── nvim/             # Neovim configuration
├── scripts/          # Utility scripts
├── skhd/             # Simple Hotkey Daemon configuration
├── tmux/             # Tmux configuration
├── yabai/            # Yabai window manager configuration
└── zsh/              # ZSH shell configuration
```

## Installation

### Prerequisites

- Git
- [GNU Stow](https://www.gnu.org/software/stow/)

### Manual Installation

If you prefer to install manually or want to install only specific configurations:

```bash
# Install GNU Stow
brew install stow  # macOS with Homebrew

# Clone the repository
git clone https://github.com/minhyeoky/dotfiles.git ~/dotfiles

# Navigate to the dotfiles directory
cd ~/dotfiles

# Install specific configurations (e.g., zsh, nvim, tmux)
stow zsh
stow nvim
stow tmux
```

### Claude Code Plugins

The `my-plugins/` directory contains personal Claude Code plugins, registered via a local marketplace (`.claude-plugin/marketplace.json`).

To install, open Claude Code in this repo and run:

```
/plugin marketplace add .
/plugin install my-plugins@my-plugins
```

See [`my-plugins/README.md`](my-plugins/README.md) for available plugins and details.

### Claude Code Settings

`~/.claude/settings.json` is not stowed. Claude Code rewrites it on its own (theme, model, plugin toggles) and parts of it are machine-bound: absolute paths, the statusline's pinned node binary, the local plugin marketplace, per-machine `env` entries. Symlinking it would either fight the tool or carry one machine's paths onto another.

What is tracked instead is [`claude/settings.template.json`](claude/settings.template.json) — the portable keys only, so a preference worth having everywhere is written down somewhere other than one machine's home directory. It is deliberately excluded from stow (`claude/.stow-local-ignore`); nothing reads it from `$HOME`. `spinnerTipsOverride` is absent on purpose — `scripts/claude-spinner-tips.sh` already owns that key, from `claude/.claude/spinner-tips.json`.

Applying it is a judgement call, so Claude Code does it rather than a script. Point a session at the template and `~/.claude/settings.json`: keys missing from the live file get added, keys whose values differ get reported instead of overwritten — a machine that runs a lower effort level on purpose is indistinguishable from drift without knowing why.

Two rules keep the file safe to commit:

- No absolute paths, and nothing machine-bound. The one way secrets leak here is lifting keys out of a live `settings.json` wholesale.
- Adopting a setting worth keeping everywhere means adding it to the template in a PR.

## Available Configurations

The following configurations are available:

- `alacritty`: Configuration for Alacritty terminal emulator
- `bash`: Bash shell configuration
- `claude`: Claude Code behavioral guidelines (CLAUDE.md) and settings template
- `emacs`: Emacs configuration
- `git`: Git configuration and aliases
- `hammerspoon`: Hammerspoon configuration for macOS automation
- `my-plugins`: Personal Claude Code plugins (tmux-status hooks)
- `nvim`: Neovim configuration
- `skhd`: Simple Hotkey Daemon configuration
- `tmux`: Tmux configuration
- `yabai`: Yabai window manager configuration
- `zsh`: ZSH shell configuration

### Environment Secrets

Sensitive information like API keys should be stored in `~/.env_secrets`, which is sourced by Bash but not tracked by Git.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Oh-My-Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- [Neovim](https://neovim.io/)
- [GNU Stow](https://www.gnu.org/software/stow/)
- [Claude Code](https://claude.ai/code)
