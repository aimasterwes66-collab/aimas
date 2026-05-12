#!/usr/bin/env bash
# =============================================================================
# AIMAS SAMPLE INSTALL SCRIPT (Linux / apt)
# Generated from tool-list/*.json via generator/generate_script.py
# =============================================================================
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[1;34m'; NC='\033[0m'
info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }

echo ""
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║  AIMAS — Self-Assembling Creative AI Workstation                           ║"
echo "║  One-line bootstrap for content creators, video editors, AI researchers    ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""

info "Updating package lists..."
sudo apt-get update || true

info "Installing base packages..."
sudo apt-get install -y \
  build-essential pkg-config make cmake git curl wget ca-certificates \
  gnupg lsb-release software-properties-common unzip zip p7zip-full tar \
  python3 python3-pip python3-venv python3-full pipx zsh fonts-powerline \
  neovim vim nano less jq fzf tmux htop tree ncdu ffmpeg imagemagick \
  bat cmatrix lolcat figlet cowsay nmap netcat-openbsd aircrack-ng \
  ansible obs-studio shotcut kdenlive handbrake audacity gimp inkscape \
  blender krita libreoffice ranger fd-find ripgrep libgl1 libglib2.0-0 \
  libsm6 libxext6 libxrender-dev libgomp1 libvulkan1 linux-headers-generic \
  systemd btop aria2 stow mpv || warn "Some apt packages failed (non-fatal)"

info "Installing Docker Engine..."
if ! command -v docker >/dev/null 2>&1; then
  sudo apt-get remove -y docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc 2>/dev/null || true
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker "$USER" || true
fi
ok "Docker ready"

info "Installing Ollama..."
if ! command -v ollama >/dev/null 2>&1; then
  curl -fsSL https://ollama.com/install.sh | sh
fi
if pidof systemd >/dev/null 2>&1; then
  sudo systemctl enable ollama 2>/dev/null || true
  sudo systemctl start ollama 2>/dev/null || true
fi
ollama pull llama3.1:8b || true
ollama pull qwen2.5-coder:14b || true
ok "Ollama ready"

info "Installing Rust..."
if ! command -v cargo >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
source "${HOME}/.cargo/env" 2>/dev/null || true
ok "Rust ready"

info "Installing Go..."
if ! command -v go >/dev/null 2>&1; then
  GO_VER="1.23.4"
  curl -LO "https://go.dev/dl/go${GO_VER}.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go${GO_VER}.linux-amd64.tar.gz"
  rm -f "go${GO_VER}.linux-amd64.tar.gz"
fi
ok "Go ready"

info "Installing Node.js via NVM..."
export NVM_DIR="${HOME}/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts 2>/dev/null || true
nvm alias default 'lts/*' 2>/dev/null || true
ok "Node ready"

info "Installing Deno..."
if ! command -v deno >/dev/null 2>&1; then
  curl -fsSL https://deno.land/install.sh | sh
fi

info "Installing Bun..."
if ! command -v bun >/dev/null 2>&1; then
  curl -fsSL https://bun.sh/install | bash
fi

info "Installing Shell enhancements..."
if [ "$SHELL" != "$(command -v zsh)" ]; then
  chsh -s "$(command -v zsh)" || warn "Could not change default shell"
fi
if [ ! -d "${HOME}/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true
fi
if ! command -v starship >/dev/null 2>&1; then
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi
if ! command -v zoxide >/dev/null 2>&1; then
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi
ok "Shell stack ready"

echo ""
echo -e "${GREEN}✅ AIMAS base installation complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Log out & back in for Docker permissions."
echo "  2. Run 'exec zsh' to load new shell config."
echo "  3. Run 'aimas-bootstrap.sh' for the FULL creative workstation."
echo ""
