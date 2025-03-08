#!/bin/bash

# Install Homebrew
# https://docs.brew.sh/Installation#unattended-installation
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install --cask font-jetbrains-mono-nerd-font
brew install --cask google-chrome
