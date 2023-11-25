#!/bin/bash

# Update package list
sudo apt-get update

# Install Zsh if not already installed and make it the default shell
if ! command -v zsh &> /dev/null; then
    sudo apt-get install -y zsh
    chsh -s $(which zsh)
fi

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
fi

# Install Alacritty if not already installed
if ! command -v alacritty &> /dev/null; then
    sudo add-apt-repository ppa:mmstick76/alacritty
    sudo apt-get update
    sudo apt-get install -y alacritty
fi

# Install Fira Code Font if not already installed
if ! fc-list | grep -q "Fira Code"; then
    sudo apt-get install -y fonts-firacode
fi

# Create Alacritty config if it doesn't exist
mkdir -p ~/.config/alacritty
cat << 'EOF' > ~/.config/alacritty/alacritty.yml
font:
  normal:
    family: Fira Code
    style: Regular
  bold:
    family: Fira Code
    style: Bold
  italic:
    family: Fira Code
    style: Italic
  size: 12.0
EOF

# Install Antigen if not already installed
if [ ! -f "$HOME/antigen.zsh" ]; then
    curl -L git.io/antigen > ~/antigen.zsh
fi

# Configure .zshrc with Antigen and Oh My Zsh theme
cat << 'EOF' > ~/.zshrc
# Antigen setup
source ~/antigen.zsh

# Load oh-my-zsh library
antigen use oh-my-zsh

# Theme
antigen theme robbyrussell

# Bundles from the default repo (robbyrussell's oh-my-zsh)
antigen bundle git
antigen bundle heroku
antigen bundle pip
antigen bundle lein
antigen bundle command-not-found

# Syntax highlighting bundle
antigen bundle zsh-users/zsh-syntax-highlighting

# Auto-suggestions
antigen bundle zsh-users/zsh-autosuggestions

# Apply antigen changes
antigen apply
EOF

# Install ripgrep if not already installed
if ! command -v rg &> /dev/null; then
    sudo apt-get install -y ripgrep
fi

# Install ripgrep-all if not already installed
if ! cargo install --list | grep -q ripgrep-all; then
    cargo install ripgrep-all
fi

# Install fzf if not already installed
if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi

# Add fzf keybindings to .zshrc
echo "source /usr/share/doc/fzf/examples/key-bindings.zsh" >> ~/.zshrc

# Source .zshrc to apply changes
source ~/.zshrc
