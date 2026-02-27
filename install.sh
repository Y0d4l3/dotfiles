#!/bin/bash

# --- Helfer-Funktion für Symlinks (verhindert Fehler bei erneutem Ausführen) ---
safe_link() {
    local src=$1
    local dest=$2
    if [ -L "$dest" ]; then
        echo "🔗 Link für $dest existiert bereits. Überspringe..."
    elif [ -f "$dest" ]; then
        echo "⚠️  Datei $dest existiert. Erstelle Backup..."
        mv "$dest" "$dest.backup.$(date +%s)"
        ln -s "$src" "$dest"
    else
        echo "✨ Erstelle Link: $dest -> $src"
        ln -s "$src" "$dest"
    fi
}

# --- 1. OS erkennen & Tools installieren ---
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Mac erkannt. Nutze Homebrew..."
    if ! command -v brew &> /dev/null; then
        echo "Brew nicht gefunden. Bitte installiere Homebrew zuerst!"
        exit 1
    fi
    # Helix hinzugefügt
    brew install zsh starship zoxide atuin eza bat ripgrep lazygit helix font-fira-code-nerd-font

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "🐧 Linux (WSL) erkannt..."
    sudo apt update
    sudo apt install -y zsh unzip fontconfig git curl build-essential

    # Starship
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    # Zoxide & Atuin
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    curl -sS https://setup.atuin.sh | bash

    # HELIX INSTALLATION (Linux via Cargo)
    if ! command -v hx &> /dev/null; then
        echo "🧬 Baue Helix via Cargo (dauert kurz)..."
        cargo install --git https://github.com/helix-editor/helix --force helix-term
    fi

    # YAML Language Server für Kubernetes/YAML Support
    if ! command -v yaml-language-server &> /dev/null; then
        echo "🌐 Installiere YAML Language Server für Helix..."
        sudo apt install -y nodejs npm
        sudo npm install -g yaml-language-server
    fi

    # Bat & Eza via Cargo (da apt Versionen oft uralt sind)
    if ! command -v cargo &> /dev/null; then
        echo "🦀 Installiere Rust/Cargo für moderne Tools..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source $HOME/.cargo/env
    fi
    cargo install eza bat ripgrep
fi

# --- 2. Oh My Zsh (Idempotent) ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installiere Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# --- 3. Plugins ---
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
mkdir -p ${ZSH_CUSTOM}/plugins
[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
[ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting

# --- 4. Symlinks (Jetzt sicher!) ---
mkdir -p ~/.config/helix

safe_link ~/dotfiles/.zshrc ~/.zshrc
safe_link ~/dotfiles/starship.toml ~/.config/starship.toml
# Helix Config verlinken (falls du eine hast)
[ -f ~/dotfiles/helix_config.toml ] && safe_link ~/dotfiles/helix_config.toml ~/.config/helix/config.toml
safe_link ~/dotfiles/languages.toml ~/.config/helix/languages.toml

echo "✅ Upgrade/Setup abgeschlossen! Shell mit 'exec zsh' neu laden."
