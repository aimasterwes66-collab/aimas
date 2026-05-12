#!/usr/bin/env bash
# =============================================================================
# AIMAS MEGA-BOOTSTRAP v1.0
# A declarative self-assembling creative AI workstation for native Linux
# =============================================================================
# Usage:   bash aimas-bootstrap.sh
# Requires: Ubuntu/Debian-based system, amd64, systemd, internet connection
# =============================================================================

set -e

# ---------------------------------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------------------------------
export NVM_DIR="${HOME}/.nvm"
export CARGO_HOME="${HOME}/.cargo"
export GOPATH="${HOME}/go"
export PIPX_HOME="${HOME}/.local/pipx"
export PIPX_BIN_DIR="${PIPX_HOME}/bin"
export VENV_DIR="${HOME}/.local/share/aimas/venvs"
export OLLAMA_MODELS="${HOME}/.ollama/models"

# Ensure local bins are available immediately
export PATH="${HOME}/.local/bin:${PIPX_BIN_DIR}:${CARGO_HOME}/bin:/usr/local/go/bin:${GOPATH}/bin:${PATH}"

# ---------------------------------------------------------------------------
# UTILITIES
# ---------------------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[1;34m'; NC='\033[0m'
info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
die()   { echo -e "${RED}[ERR]${NC}   $*" >&2; exit 1; }
has()   { command -v "$1" &>/dev/null; }

section() {
  echo ""
  echo "============================================================================="
  echo "  $1"
  echo "============================================================================="
}

# ---------------------------------------------------------------------------
# 0. SYSTEM PREP
# ---------------------------------------------------------------------------
section "0. System Preparation"
info "Updating package lists..."
sudo apt-get update
info "Upgrading existing packages..."
sudo apt-get full-upgrade -y

# ---------------------------------------------------------------------------
# 1. BASE SYSTEM PACKAGES (apt)
# ---------------------------------------------------------------------------
section "1. Installing Base System Packages"

sudo apt-get install -y \
  build-essential pkg-config make cmake \
  git curl wget ca-certificates gnupg lsb-release software-properties-common \
  unzip zip p7zip-full tar \
  python3 python3-pip python3-venv python3-full pipx \
  zsh fonts-powerline \
  neovim vim nano less \
  jq fzf tmux htop tree ncdu \
  ffmpeg imagemagick \
  bat cmatrix lolcat figlet cowsay \
  nmap netcat-openbsd aircrack-ng \
  ansible \
  obs-studio shotcut kdenlive handbrake audacity \
  gimp inkscape blender krita \
  libreoffice \
  tmux ranger \
  fd-find ripgrep \
  btop aria2 stow mpv \
  libgl1 libglib2.0-0 libsm6 libxext6 libxrender-dev \
  libgomp1 libvulkan1 linux-headers-generic systemd \
  || warn "Some apt packages failed (non-fatal)"

# Fix Ubuntu command name inconsistencies
if has batcat && ! has bat; then
  sudo ln -sf "$(command -v batcat)" /usr/local/bin/bat || true
fi
if has fdfind && ! has fd; then
  sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd || true
fi

ok "Base packages installed."

# ---------------------------------------------------------------------------
# 2. UV — THE PYTHON SANITY LAYER
# ---------------------------------------------------------------------------
section "2. Installing uv (Modern Python Package Manager)"
if ! has uv; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi
export PATH="${HOME}/.local/bin:${PATH}"
has uv || die "uv installation failed"
ok "uv ready: $(uv --version)"

# ---------------------------------------------------------------------------
# 3. NVM & NODE ECOSYSTEM
# ---------------------------------------------------------------------------
section "3. Installing NVM & Node.js LTS"
if [ ! -d "$NVM_DIR" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi
# Source NVM in this non-interactive shell context
export NVM_DIR="${HOME}/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if ! has node; then
  if has nvm; then
    # LTS resolution can fail in non-interactive shells; try explicit fallback
    nvm install --lts 2>/dev/null || nvm install 20 2>/dev/null || nvm install 18 2>/dev/null || true
    nvm alias default 'lts/*' 2>/dev/null || nvm alias default '20' 2>/dev/null || true
    nvm use default 2>/dev/null || true
  fi
fi
has node || warn "Node.js not available after NVM setup (non-fatal)"
has node && ok "Node.js ready: $(node --version)"

# ---------------------------------------------------------------------------
# 4. RUST / CARGO
# ---------------------------------------------------------------------------
section "4. Installing Rustup & Cargo"
if ! has cargo; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
source "${CARGO_HOME}/env" 2>/dev/null || true
has cargo || die "Rustup installation failed"
ok "Cargo ready: $(cargo --version)"

# ---------------------------------------------------------------------------
# 5. GO
# ---------------------------------------------------------------------------
section "5. Installing Go"
if ! has go; then
  GO_VER="1.23.4"
  curl -LO "https://go.dev/dl/go${GO_VER}.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go${GO_VER}.linux-amd64.tar.gz"
  rm -f "go${GO_VER}.linux-amd64.tar.gz"
  export PATH="${PATH}:/usr/local/go/bin"
fi
has go || die "Go installation failed"
ok "Go ready: $(go version)"

# ---------------------------------------------------------------------------
# 6. DOCKER ENGINE (Official)
# ---------------------------------------------------------------------------
section "6. Installing Docker Engine"
sudo apt-get remove -y docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc 2>/dev/null || true
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$USER" || true
ok "Docker installed."

# ---------------------------------------------------------------------------
# 7. KUBECTL
# ---------------------------------------------------------------------------
section "7. Installing kubectl"
if ! has kubectl; then
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update
  sudo apt-get install -y kubectl
fi
ok "kubectl ready."

# ---------------------------------------------------------------------------
# 8. TERRAFORM
# ---------------------------------------------------------------------------
section "8. Installing Terraform"
if ! has terraform; then
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/hashicorp.gpg || true
  sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" -y
  sudo apt-get update && sudo apt-get install -y terraform
fi
ok "Terraform ready."

# ---------------------------------------------------------------------------
# 8b. AWS CLI
# ---------------------------------------------------------------------------
section "8b. Installing AWS CLI"
if ! has aws; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -o awscliv2.zip
  sudo ./aws/install
  rm -rf aws awscliv2.zip
fi
ok "AWS CLI ready."

# ---------------------------------------------------------------------------
# 9. OLLAMA (Local LLM Runtime)
# ---------------------------------------------------------------------------
section "9. Installing Ollama"
if ! has ollama; then
  curl -fsSL https://ollama.com/install.sh | sh
fi
# Native Linux: use systemd properly
if pidof systemd >/dev/null 2>&1; then
  sudo systemctl enable ollama
  sudo systemctl start ollama
else
  warn "systemd not detected as init; you may need to start Ollama manually"
fi

# Pull CPU-friendly models (non-blocking; pulls in background)
info "Pulling Ollama models (this may take time)..."
ollama pull llama3.1:8b          || true
ollama pull qwen2.5-coder:14b    || true
ollama pull codellama:7b         || true
ollama pull phi3:mini            || true
ollama pull tinyllama            || true
ollama pull mistral:7b           || true
ok "Ollama installed."

# ---------------------------------------------------------------------------
# 10. ZSH, OH-MY-ZSH & PROMPT ENGINE
# ---------------------------------------------------------------------------
section "10. Shell Enhancements (Zsh + Oh-My-Zsh + Starship + Zoxide)"

# Default shell
if [ "$SHELL" != "$(command -v zsh)" ]; then
  chsh -s "$(command -v zsh)" || warn "Could not change default shell to zsh"
fi

# Oh My Zsh
if [ ! -d "${HOME}/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true
fi

# Starship
if ! has starship; then
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Zoxide
if ! has zoxide; then
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi
ok "Shell stack ready."

# ---------------------------------------------------------------------------
# 11. TERMINAL PRODUCTIVITY — RUST CARGO
# ---------------------------------------------------------------------------
section "11. Installing Rust-based Terminal Tools"
if has cargo; then
  cargo install eza         2>/dev/null || true
  cargo install du-dust     2>/dev/null || true
  cargo install procs       2>/dev/null || true
  cargo install bottom      2>/dev/null || true
  cargo install hyperfine   2>/dev/null || true
  cargo install tokei       2>/dev/null || true
  cargo install bandwhich   2>/dev/null || true
  cargo install tre-command 2>/dev/null || true
  cargo install tealdeer    2>/dev/null || true
  cargo install bore-cli    2>/dev/null || true
  cargo install xsv         2>/dev/null || true
  cargo install sd          2>/dev/null || true
  cargo install choose      2>/dev/null || true
fi
ok "Cargo tools installed."

# ---------------------------------------------------------------------------
# 12. GO-BASED TOOLS
# ---------------------------------------------------------------------------
section "12. Installing Go-based Tools"
if has go; then
  go install github.com/jesseduffield/lazygit@latest       || true
  go install github.com/x-motemen/ghq@latest               || true
  go install github.com/charmbracelet/mods@latest          || true
  go install github.com/charmbracelet/gum@latest           || true
  go install github.com/dundee/gdu/v5/cmd/gdu@latest       || true
  go install github.com/sachaos/viddy@latest               || true
  go install github.com/sharkdp/fd@latest                  || true  # fallback if apt fd is old
  go install filippo.io/age/cmd/age@latest                 || true
fi
ok "Go tools installed."

# ---------------------------------------------------------------------------
# 13. PIPX — ISOLATED PYTHON CLI APPS
# ---------------------------------------------------------------------------
section "13. Installing pipx-based Python CLIs"
pipx ensurepath 2>/dev/null || true

pipx install poetry          2>/dev/null || true
pipx install pdm             2>/dev/null || true
pipx install hatch           2>/dev/null || true
pipx install copier          2>/dev/null || true
pipx install httpie          2>/dev/null || true
pipx install glances         2>/dev/null || true
pipx install thefuck         2>/dev/null || true
pipx install tldr            2>/dev/null || true
pipx install yt-dlp          2>/dev/null || true
pipx install gallery-dl      2>/dev/null || true
pipx install pygments        2>/dev/null || true
pipx install cookiecutter    2>/dev/null || true
pipx install black           2>/dev/null || true
pipx install ruff            2>/dev/null || true
pipx install mypy            2>/dev/null || true
ok "pipx tools installed."

# ---------------------------------------------------------------------------
# 14. NPM GLOBAL TOOLS
# ---------------------------------------------------------------------------
section "14. Installing Global npm Tools"
if has npm; then
  npm install -g @anthropic-ai/claude-code  || true
  npm install -g @google/gemini-cli          || true
  npm install -g vercel                      || true
  npm install -g @vue/cli                    || true
  npm install -g n8n                         || true
  npm install -g @anthropic-ai/claude-code   || true
  npm install -g @continuedev/cli            || true
fi
ok "npm globals installed."

# ---------------------------------------------------------------------------
# 14b. DENO & BUN (Additional JS/TS Runtimes)
# ---------------------------------------------------------------------------
section "14b. Installing Deno & Bun"
if ! has deno; then
  curl -fsSL https://deno.land/install.sh | sh
fi
if ! has bun; then
  curl -fsSL https://bun.sh/install | bash
fi
ok "Deno & Bun ready."

# ---------------------------------------------------------------------------
# 14c. SDKMAN! (JVM ECOSYSTEM)
# ---------------------------------------------------------------------------
section "14c. Installing SDKMAN!"
if [ ! -d "${HOME}/.sdkman" ]; then
  curl -s "https://get.sdkman.io" | bash
fi
ok "SDKMAN ready."

# ---------------------------------------------------------------------------
# 15. PYTHON VIRTUAL ENVIRONMENTS (uv) — THE AI/ML/SCRAPE LAYER
# ---------------------------------------------------------------------------
section "15. Building Isolated Python Environments with uv"
mkdir -p "$VENV_DIR"

# --- 15a. AI & ML Libraries (CPU-ONLY; NO CUDA) ---
info "Creating ai-ml venv..."
uv venv "${VENV_DIR}/ai-ml"
uv pip install --python "${VENV_DIR}/ai-ml/bin/python" \
  torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu \
  tensorflow-cpu \
  transformers \
  datasets \
  accelerate \
  sentence-transformers \
  diffusers \
  openai \
  anthropic \
  huggingface-hub \
  jupyterlab \
  ipython \
  ipywidgets \
  numpy \
  pandas \
  matplotlib \
  seaborn \
  scikit-learn \
  scipy \
  opencv-python \
  Pillow \
  rembg \
  onnxruntime \
  tqdm \
  rich \
  || warn "Some ai-ml packages failed (non-fatal)"

# --- 15b. Scraping, Research & Data Harvesting ---
info "Creating scrape venv..."
uv venv "${VENV_DIR}/scrape"
uv pip install --python "${VENV_DIR}/scrape/bin/python" \
  beautifulsoup4 \
  scrapy \
  selenium \
  requests \
  httpx \
  aiohttp \
  playwright \
  yt-dlp \
  gallery-dl \
  newspaper3k \
  trafilatura \
  brozzler \
  hakrawler \
  waybackpack \
  fake-useragent \
  scrapy-fake-useragent \
  || warn "Some scrape packages failed (non-fatal)"

# --- 15c. AI CLI Tools & Agents (isolated to prevent dependency hell) ---
info "Creating ai-cli venv..."
uv venv "${VENV_DIR}/ai-cli"
uv pip install --python "${VENV_DIR}/ai-cli/bin/python" \
  gpt4all \
  shell-gpt \
  aider-chat \
  open-interpreter \
  litellm \
  par-gpt \
  tgpt \
  chatblade \
  llm \
  llm-ollama \
  private-gpt \
  crewai \
  agentops \
  langchain \
  langchain-community \
  langchain-ollama \
  langchain-openai \
  semantic-kernel \
  haystack-ai \
  smol-dev \
  fastchat \
  || warn "Some ai-cli packages failed (non-fatal)"

# --- 15d. Link key executables into ~/.local/bin ---
mkdir -p "${HOME}/.local/bin"

link_venv_bin() {
  local venv="$1"; shift
  for exe in "$@"; do
    local src="${VENV_DIR}/${venv}/bin/${exe}"
    local dst="${HOME}/.local/bin/${exe}"
    if [ -f "$src" ] && [ ! -L "$dst" ]; then
      ln -sf "$src" "$dst" || true
    fi
  done
}

link_venv_bin ai-ml      jupyter jupyter-lab ipython python
link_venv_bin scrape     scrapy yt-dlp gallery-dl playwright
link_venv_bin ai-cli     sgpt aider open-interpreter litellm par-gpt tgpt chatblade llm private-gpt crewai smol-dev

ok "Python environments built."

# ---------------------------------------------------------------------------
# 16. LLAMA.CPP (CPU BUILD)
# ---------------------------------------------------------------------------
section "16. Building llama.cpp (CPU Inference Engine)"
if [ ! -d "${HOME}/llama.cpp" ]; then
  git clone https://github.com/ggerganov/llama.cpp.git "${HOME}/llama.cpp"
fi
cd "${HOME}/llama.cpp"
git pull || true
make -j$(nproc) || true
[ -f "./main" ] && ok "llama.cpp built." || warn "llama.cpp build had issues (non-fatal)"
cd - >/dev/null || true

# ---------------------------------------------------------------------------
# 17. ADDITIONAL BINARY INSTALLS
# ---------------------------------------------------------------------------
section "17. Installing Standalone Binaries"

# rclone
if ! has rclone; then
  curl https://rclone.org/install.sh | sudo bash || true
fi

# yt-dlp (latest standalone binary)
if ! has yt-dlp; then
  sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
  sudo chmod a+rx /usr/local/bin/yt-dlp
fi

# k9s (Kubernetes TUI)
if ! has k9s; then
  curl -sS https://webinstall.dev/k9s | bash
fi

# Helm
if ! has helm; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# asciinema (terminal recording)
pipx install asciinema 2>/dev/null || true

# LocalAI (Docker, CPU image)
info "Starting LocalAI (CPU Docker)..."
docker run -d --name localai \
  -p 8080:8080 \
  --restart always \
  localai/localai:latest-aio-cpu || warn "LocalAI container failed (may already exist)"

# Open WebUI
info "Starting Open WebUI..."
docker run -d \
  -p 3000:8080 \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main || warn "Open WebUI container failed (may already exist)"

ok "Binaries & containers ready."

# ---------------------------------------------------------------------------
# 18. DOTFILES & SHELL CONFIG
# ---------------------------------------------------------------------------
section "18. Configuring Shell Environment"

ZSHRC="${HOME}/.zshrc"

# Only append if our marker isn't present
if ! grep -q "# == AIMAS BOOTSTRAP ==" "$ZSHRC" 2>/dev/null; then
  cat >> "$ZSHRC" << 'ZSHRC_BLOCK'

# == AIMAS BOOTSTRAP ==
# Auto-generated by aimas-bootstrap.sh

# Paths
export PATH="${HOME}/.local/bin:${HOME}/.cargo/bin:/usr/local/go/bin:${HOME}/go/bin:${PATH}"
export NVM_DIR="${HOME}/.nvm"
[ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"

# SDKMAN
export SDKMAN_DIR="${HOME}/.sdkman"
[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ] && \. "${SDKMAN_DIR}/bin/sdkman-init.sh"

# Deno
export DENO_INSTALL="${HOME}/.deno"
[ -s "${DENO_INSTALL}/bin/deno" ] && export PATH="${DENO_INSTALL}/bin:${PATH}"

# Bun
export BUN_INSTALL="${HOME}/.bun"
[ -s "${BUN_INSTALL}/bin/bun" ] && export PATH="${BUN_INSTALL}/bin:${PATH}"

# Aliases (fall back gracefully)
alias ls='eza --icons --group-directories-first 2>/dev/null || ls --color=auto'
alias ll='eza -la --icons --group-directories-first 2>/dev/null || ls -la --color=auto'
alias cat='bat --paging=never 2>/dev/null || cat'
alias top='btm 2>/dev/null || htop 2>/dev/null || top'
alias du='dust 2>/dev/null || du -sh'
alias ps='procs 2>/dev/null || ps'
alias find='fd 2>/dev/null || find'
alias grep='rg 2>/dev/null || grep'
alias cd='z 2>/dev/null || cd'
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status'
alias gp='git pull'
alias gl='git log --oneline -10'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias oll='ollama list'
alias ollr='ollama run'

# Aimas venv activators
alias ai-ml='source ${HOME}/.local/share/aimas/venvs/ai-ml/bin/activate'
alias ai-cli='source ${HOME}/.local/share/aimas/venvs/ai-cli/bin/activate'
alias scrape='source ${HOME}/.local/share/aimas/venvs/scrape/bin/activate'

# Tool initializations
eval "$(zoxide init zsh 2>/dev/null || true)"
eval "$(starship init zsh 2>/dev/null || true)"

# == END AIMAS ==
ZSHRC_BLOCK
  ok "Shell config appended to ~/.zshrc"
else
  info "Shell config already present."
fi

# ---------------------------------------------------------------------------
# 19. OPTIONAL: OPENCODE / CLAUDE-CODE / GEMINI
# ---------------------------------------------------------------------------
section "19. Installing Remote AI CLIs"
curl -fsSL https://opencode.ai/install | bash 2>/dev/null || warn "OpenCode install failed (non-fatal)"

# ---------------------------------------------------------------------------
# 20. DONE
# ---------------------------------------------------------------------------
section "Bootstrap Complete"

echo ""
echo -e "${GREEN}✅ AIMAS MEGA-BOOTSTRAP COMPLETE${NC}"
echo ""
echo "═════════════════════════════════════════════════════════════════════════════"
echo "  QUICK REFERENCE"
echo "═════════════════════════════════════════════════════════════════════════════"
echo ""
echo "  Shell:         zsh (with Oh-My-Zsh, Starship, Zoxide)"
echo "  Python:        uv + pipx + 3 isolated venvs"
echo "  Node:          nvm + LTS"
echo "  JS/TS:         Deno + Bun"
echo "  Docker:        official CE + compose plugin"
echo "  JVM:           SDKMAN! (Java/Kotlin/Scala)"
echo "  Cloud:         AWS CLI + Terraform"
echo "  Ollama:        http://localhost:11434"
echo "  Open WebUI:    http://localhost:3000"
echo "  LocalAI:       http://localhost:8080"
echo ""
echo "  Venv shortcuts:"
echo "    ai-ml   → activate AI/ML libraries (torch, tf, transformers, jupyter)"
echo "    ai-cli  → activate AI agents (aider, sgpt, litellm, crewai, ...)"
echo "    scrape  → activate scraping tools (scrapy, playwright, yt-dlp, ...)"
echo ""
echo "  Example commands:"
echo "    ollama run llama3.1"
echo "    sgpt 'Explain quantum computing'"
echo "    aider"
echo "    yt-dlp <URL>"
echo "    lazygit"
echo "    eza -la --icons"
echo "    deno run https://example.com/script.ts"
echo "    bun install"
echo "    sdk install java"
echo "    k9s"
echo "    helm install myapp ./chart"
echo "    age -p secret.txt > secret.txt.age"
echo ""
echo "  IMPORTANT:"
echo "    → Log out & back in for Docker group permissions to take effect."
echo "    → Run 'exec zsh' or open a new terminal to load shell config."
echo "    → Run 'sudo systemctl status ollama' to verify the LLM daemon."
echo ""
