#!/bin/bash

# --- 1. OS erkennen ---
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Mac erkannt. Nutze Homebrew..."
    # Prüfen ob Brew da ist
    if ! command -v brew &> /dev/null; then
        echo "Brew nicht gefunden. Bitte installiere Homebrew zuerst!"
        exit 1
    fi
    # Tools installieren
    brew install zsh starship zoxide atuin eza bat ripgrep lazygit font-fira-code-nerd-font

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "🐧 Linux (WSL) erkannt..."
    sudo apt update
    sudo apt install -y zsh unzip fontconfig

    # Starship (Universal Installer)
    curl -sS https://starship.rs/install.sh | sh -s -- -y

    # Zoxide
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

    # Atuin
    bash <(curl https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh)

    # Eza (muss oft manuell geholt werden oder via cargo, hier vereinfacht für apt wenn repo da ist, sonst cargo)
    # Wir nehmen hier an, dass user cargo oder apt repositories gepflegt hat.
    # Alternativ: cargo install eza bat
fi

# --- 2. Oh My Zsh installieren (falls nicht da) ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installiere Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# --- 3. Plugins klonen ---
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
echo "Installiere Zsh Plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions 2>/dev/null || echo "Autosuggestions schon da"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting 2>/dev/null || echo "Syntax Highlighting schon da"

# --- 4. Symlinks setzen (Verknüpfungen) ---
echo "Verlinke Config-Dateien..."

# Backup existierender .zshrc
if [ -f ~/.zshrc ]; then
    mv ~/.zshrc ~/.zshrc.backup.$(date +%s)
fi
# Link erstellen
ln -s ~/dotfiles/.zshrc ~/.zshrc

# Starship Config
mkdir -p ~/.config
if [ -f ~/.config/starship.toml ]; then
    mv ~/.config/starship.toml ~/.config/starship.toml.backup.$(date +%s)
fi
ln -s ~/dotfiles/starship.toml ~/.config/starship.toml

echo "✅ Fertig! Starte deine Shell neu mit 'zsh'"
