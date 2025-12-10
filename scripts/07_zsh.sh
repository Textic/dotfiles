#!/bin/bash

# Get the directory of the currently running script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Source utilities
if [ -f "$SCRIPT_DIR/00_utils.sh" ]; then
    source "$SCRIPT_DIR/00_utils.sh"
fi

if ask_confirmation "Do you want to install Zsh, Starship and plugins?"; then
    echo_msg "Installing Zsh and plugins..."
    
    # Install zsh and plugins
    if command -v yay &> /dev/null; then
        yay -S --noconfirm zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting starship
    else
        echo_msg "Error: 'yay' is not installed. Please install yay first."
        exit 1
    fi

    # Configure ~/.zshrc
    ZSHRC="$HOME/.zshrc"
    echo_msg "Configuring $ZSHRC..."

    # Create .zshrc if it doesn't exist
    if [ ! -f "$ZSHRC" ]; then
        touch "$ZSHRC"
        echo "# Created by dotfiles installer" > "$ZSHRC"
        echo "autoload -Uz compinit && compinit" >> "$ZSHRC"
    fi

    # Enable History
    if ! grep -q "HISTFILE" "$ZSHRC"; then
        echo "" >> "$ZSHRC"
        echo "# History Configuration" >> "$ZSHRC"
        echo 'HISTFILE="$HOME/.zsh_history"' >> "$ZSHRC"
        echo 'HISTSIZE=10000' >> "$ZSHRC"
        echo 'SAVEHIST=10000' >> "$ZSHRC"
        echo 'setopt EXTENDED_HISTORY' >> "$ZSHRC"
        echo 'setopt SHARE_HISTORY' >> "$ZSHRC"
        echo 'setopt APPEND_HISTORY' >> "$ZSHRC"
        echo_msg "Configured Zsh History"
    fi

    # Enable Autosuggestions
    if ! grep -q "zsh-autosuggestions.zsh" "$ZSHRC"; then
        echo "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> "$ZSHRC"
        echo_msg "Enabled zsh-autosuggestions"
    fi

    # Enable Starship (Add before syntax highlighting if possible)
    if ! grep -q "starship init zsh" "$ZSHRC"; then
        echo 'eval "$(starship init zsh)"' >> "$ZSHRC"
        echo_msg "Enabled Starship prompt"
    fi

    # Enable Syntax Highlighting (Must be at the end of .zshrc)
    if ! grep -q "zsh-syntax-highlighting.zsh" "$ZSHRC"; then
        echo "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "$ZSHRC"
        echo_msg "Enabled zsh-syntax-highlighting"
    fi

    # Add compinit if not present (simple check)
    if ! grep -q "compinit" "$ZSHRC"; then
         # Prepend it? Hard to prepend safely with simple echo.
         # For now, just append it if missing, though it usually needs to be before plugins or just early.
         # Actually, syntax highlighting must be LAST. Autosuggestions can be anywhere.
         # If we are appending syntax highlighting above, we are safe.
         pass # Already handled or risky to edit blindly
    fi
    
    # Change default shell
    if [ "$SHELL" != "$(which zsh)" ]; then
        if ask_confirmation "Do you want to change your default shell to Zsh?"; then
            chsh -s "$(which zsh)"
            echo_msg "Default shell changed to Zsh. Please log out and back in for changes to take effect."
        fi
    fi

    echo_msg "Zsh setup complete!"
else
    echo_msg "Skipping Zsh installation."
fi
