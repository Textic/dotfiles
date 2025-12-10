#!/bin/bash

if ask_confirmation "Do you want to install fzf (Command-line fuzzy finder)?"; then
    # Check if fzf is already installed
    if [ -d "$HOME/.fzf" ]; then
        echo_msg "fzf directory already exists at $HOME/.fzf. Pulling latest changes..."
        git -C "$HOME/.fzf" pull
    else
        echo_msg "Cloning fzf repository..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    fi

    echo_msg "Running fzf install script for Bash and Zsh..."
    # --all: Enable all features (key-bindings, completion, update-rc)
    # We specifically want to ensure it touches bash and zsh config if they exist.
    # The install script automatically detects .bashrc and .zshrc
    ~/.fzf/install --all --no-fish

    echo_msg "fzf installed and configured."
else
    echo_msg "Skipping fzf installation."
fi
