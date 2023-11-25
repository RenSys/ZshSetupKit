#!/bin/bash

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

# Update package list
sudo apt-get update 
sudo apt-get install python-openssl grep -y


# Function to check if a command exists and install the package if it doesn't
install_if_missing() {
    local command=$1
    local package=$2
    if ! command -v $command &> /dev/null; then
        sudo apt-get install -y $package
    fi
}

# Function to install Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(wget -O- https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
}

# Install Zsh and make it the default shell
install_if_missing zsh zsh
if [ ! "$SHELL" = "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
fi

install_oh_my_zsh

# Install Alacritty
install_if_missing alacritty alacritty

# Install Fira Code Font
install_if_missing "fc-list | grep -q 'Fira Code'" fonts-firacode

# Create Alacritty config
mkdir -p ~/.config/alacritty
cat << 'EOF' > ~/.config/alacritty/alacritty.yml
# [Alacritty config content]
EOF

# Install Antigen
if [ ! -f "$HOME/antigen.zsh" ]; then
    curl -L git.io/antigen > ~/antigen.zsh
fi

# Configure .zshrc with Antigen and Oh My Zsh theme
cat << 'EOF' > ~/.zshrc
# [Zsh configuration content]
EOF

# Install ripgrep
install_if_missing rg ripgrep

# Install ripgrep-all
if ! cargo install --list | grep -q ripgrep-all; then
    cargo install ripgrep-all
fi

# Install fzf
if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi
echo "source /usr/share/doc/fzf/examples/key-bindings.zsh" >> ~/.zshrc

# Source .zshrc to apply changes
source ~/.zshrc

# Install GitHub CLI
install_if_missing gh gh

# Prompt for GitHub authentication
echo "Authenticating with GitHub. Follow the prompts..."
gh auth login

# Prompt for GitHub username and email
read -p "Enter your GitHub username: " gh_username
read -p "Enter your GitHub email: " gh_email

# Configure Git with the provided username and email
git config --global user.name "$gh_username"
git config --global user.email "$gh_email"

# Optional: Set other global Git configurations
# git config --global [other-config] [value]

# Verify the Git configuration
echo "Git global configuration:"
git config --global --list

# Install pyenv dependencies
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl git

# Install pyenv
curl https://pyenv.run | bash

# Configure shell environment for pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc

# Reload shell configuration
source ~/.zshrc

# List latest Python versions for 3.9, 3.10, etc.
echo "Available Python versions:"
pyenv install --list | grep -E '^  3\.[9-10]+\.[0-9]+$' | tail

# Prompt for Python version
read -p "Enter the desired Python version to install (e.g., 3.10.0): " python_version

# Install selected Python version using pyenv
pyenv install "$python_version"

# Set the selected version as global default
pyenv global "$python_version"

# Verify Python installation
python --version
