#!/usr/bin/env bash
# =============================================================================
# AIMAS GENERATED INSTALL SCRIPT
# Platform: apt
# Generated: $(date -Iseconds)
# =============================================================================
set -e

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m"
info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
die()   { echo -e "${RED}[ERR]${NC}   $*" >&2; exit 1; }

info 'Updating package lists...'
sudo apt-get update || true

# --- FFmpeg ---
# The universal command-line tool for video and audio processing, conversion, and streaming.
# Dependencies: libavcodec-extra
if ! command -v ffmpeg >/dev/null 2>&1; then
  info 'Installing FFmpeg...'
  sudo apt install ffmpeg -y || warn 'FFmpeg installation failed (non-fatal)'
else
  ok 'FFmpeg already present'
fi

# --- OBS Studio ---
# Open-source software for live streaming and screen recording.
if ! command -v obs >/dev/null 2>&1; then
  info 'Installing OBS Studio...'
  sudo apt install obs-studio -y || warn 'OBS Studio installation failed (non-fatal)'
else
  ok 'OBS Studio already present'
fi

# --- Shotcut ---
# Free, open-source, cross-platform video editor.
if ! command -v shotcut >/dev/null 2>&1; then
  info 'Installing Shotcut...'
  sudo apt install shotcut -y || warn 'Shotcut installation failed (non-fatal)'
else
  ok 'Shotcut already present'
fi

# --- Kdenlive ---
# Non-linear video editor based on the MLT framework.
if ! command -v kdenlive >/dev/null 2>&1; then
  info 'Installing Kdenlive...'
  sudo apt install kdenlive -y || warn 'Kdenlive installation failed (non-fatal)'
else
  ok 'Kdenlive already present'
fi

# --- HandBrake ---
# Open-source video transcoder.
if ! command -v handbrake >/dev/null 2>&1; then
  info 'Installing HandBrake...'
  sudo apt install handbrake -y || warn 'HandBrake installation failed (non-fatal)'
else
  ok 'HandBrake already present'
fi

# --- Audacity ---
# Free, open-source, cross-platform audio software for multi-track recording and editing.
if ! command -v audacity >/dev/null 2>&1; then
  info 'Installing Audacity...'
  sudo apt install audacity -y || warn 'Audacity installation failed (non-fatal)'
else
  ok 'Audacity already present'
fi

# --- SuperCollider ---
# Platform for audio synthesis and algorithmic composition.
if ! command -v supercollider >/dev/null 2>&1; then
  info 'Installing SuperCollider...'
  sudo apt install supercollider -y || warn 'SuperCollider installation failed (non-fatal)'
else
  ok 'SuperCollider already present'
fi

# --- LMMS ---
# Free cross-platform digital audio workstation.
if ! command -v lmms >/dev/null 2>&1; then
  info 'Installing LMMS...'
  sudo apt install lmms -y || warn 'LMMS installation failed (non-fatal)'
else
  ok 'LMMS already present'
fi

# --- Blender ---
# Open-source 3D creation suite.
if ! command -v blender >/dev/null 2>&1; then
  info 'Installing Blender...'
  sudo apt install blender -y || warn 'Blender installation failed (non-fatal)'
else
  ok 'Blender already present'
fi

# --- GIMP ---
# GNU Image Manipulation Program.
if ! command -v gimp >/dev/null 2>&1; then
  info 'Installing GIMP...'
  sudo apt install gimp -y || warn 'GIMP installation failed (non-fatal)'
else
  ok 'GIMP already present'
fi

# --- Inkscape ---
# Professional vector graphics editor.
if ! command -v inkscape >/dev/null 2>&1; then
  info 'Installing Inkscape...'
  sudo apt install inkscape -y || warn 'Inkscape installation failed (non-fatal)'
else
  ok 'Inkscape already present'
fi

# --- Krita ---
# Professional digital painting application.
if ! command -v krita >/dev/null 2>&1; then
  info 'Installing Krita...'
  sudo apt install krita -y || warn 'Krita installation failed (non-fatal)'
else
  ok 'Krita already present'
fi

# --- Ollama ---
# Run LLMs locally with a clean CLI and API. CPU-friendly.
if ! command -v ollama >/dev/null 2>&1; then
  info 'Installing Ollama...'
  curl -fsSL https://ollama.com/install.sh | sh || warn 'Ollama installation failed (non-fatal)'
else
  ok 'Ollama already present'
fi

# --- llama.cpp ---
# Bare-metal local LLM inference engine in C/C++.
# Dependencies: docker
if ! command -v llama.cpp >/dev/null 2>&1; then
  info 'Installing llama.cpp...'
  docker run ghcr.io/ggerganov/llama.cpp:latest || warn 'llama.cpp installation failed (non-fatal)'
else
  ok 'llama.cpp already present'
fi

# --- GPT4All ---
# Local chat with quantized models. Lightweight and privacy-friendly.
# Dependencies: pipx
if ! command -v gpt4all >/dev/null 2>&1; then
  info 'Installing GPT4All...'
  pipx install gpt4all || warn 'GPT4All installation failed (non-fatal)'
else
  ok 'GPT4All already present'
fi

# --- shell-gpt ---
# Natural-language shell assistant powered by LLMs.
# Dependencies: pipx
if ! command -v shell-gpt >/dev/null 2>&1; then
  info 'Installing shell-gpt...'
  pipx install shell-gpt || warn 'shell-gpt installation failed (non-fatal)'
else
  ok 'shell-gpt already present'
fi

# --- aider ---
# AI pair programmer that works in your terminal and git repo.
# Dependencies: pipx
if ! command -v aider >/dev/null 2>&1; then
  info 'Installing aider...'
  pipx install aider-chat || warn 'aider installation failed (non-fatal)'
else
  ok 'aider already present'
fi

# --- open-interpreter ---
# Autonomous coding agent that executes code on your machine.
# Dependencies: pipx
if ! command -v open-interpreter >/dev/null 2>&1; then
  info 'Installing open-interpreter...'
  pipx install open-interpreter || warn 'open-interpreter installation failed (non-fatal)'
else
  ok 'open-interpreter already present'
fi

# --- litellm ---
# Unified API gateway for 100+ LLM providers.
# Dependencies: pipx
if ! command -v litellm >/dev/null 2>&1; then
  info 'Installing litellm...'
  pipx install litellm || warn 'litellm installation failed (non-fatal)'
else
  ok 'litellm already present'
fi

# --- LocalAI ---
# OpenAI-compatible local API server for running models.
# Dependencies: docker
if ! command -v localai >/dev/null 2>&1; then
  info 'Installing LocalAI...'
  docker run -p 8080:8080 localai/localai:latest-aio-cpu || warn 'LocalAI installation failed (non-fatal)'
else
  ok 'LocalAI already present'
fi

# --- Open WebUI ---
# Self-hosted web interface for local LLMs.
# Dependencies: docker
if ! command -v open >/dev/null 2>&1; then
  info 'Installing Open WebUI...'
  docker run -d -p 3000:8080 -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main || warn 'Open WebUI installation failed (non-fatal)'
else
  ok 'Open WebUI already present'
fi

# SKIP: TensorFlow (CPU) — no install method for platform apt
# SKIP: PyTorch (CPU) — no install method for platform apt
# SKIP: Transformers — no install method for platform apt
# --- Docker ---
# Platform for developing, shipping, and running applications in containers.
if ! command -v docker >/dev/null 2>&1; then
  info 'Installing Docker...'
  sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y || warn 'Docker installation failed (non-fatal)'
else
  ok 'Docker already present'
fi

# --- kubectl ---
# Kubernetes command-line tool for controlling clusters.
if ! command -v kubectl >/dev/null 2>&1; then
  info 'Installing kubectl...'
  sudo apt install kubectl -y || warn 'kubectl installation failed (non-fatal)'
else
  ok 'kubectl already present'
fi

# --- Terraform ---
# Infrastructure as code tool for building, changing, and versioning infrastructure.
if ! command -v terraform >/dev/null 2>&1; then
  info 'Installing Terraform...'
  sudo apt install terraform -y || warn 'Terraform installation failed (non-fatal)'
else
  ok 'Terraform already present'
fi

# --- Ansible ---
# Agentless automation tool for configuration management and application deployment.
# Dependencies: python3
if ! command -v ansible >/dev/null 2>&1; then
  info 'Installing Ansible...'
  sudo apt install ansible -y || warn 'Ansible installation failed (non-fatal)'
else
  ok 'Ansible already present'
fi

# --- Git ---
# Distributed version control system.
if ! command -v git >/dev/null 2>&1; then
  info 'Installing Git...'
  sudo apt install git -y || warn 'Git installation failed (non-fatal)'
else
  ok 'Git already present'
fi

# --- Neovim ---
# Hyperextensible Vim-based text editor.
if ! command -v neovim >/dev/null 2>&1; then
  info 'Installing Neovim...'
  sudo apt install neovim -y || warn 'Neovim installation failed (non-fatal)'
else
  ok 'Neovim already present'
fi

# --- Zsh ---
# Powerful shell with interactive features.
if ! command -v zsh >/dev/null 2>&1; then
  info 'Installing Zsh...'
  sudo apt install zsh -y || warn 'Zsh installation failed (non-fatal)'
else
  ok 'Zsh already present'
fi

# --- tmux ---
# Terminal multiplexer for managing multiple terminal sessions.
if ! command -v tmux >/dev/null 2>&1; then
  info 'Installing tmux...'
  sudo apt install tmux -y || warn 'tmux installation failed (non-fatal)'
else
  ok 'tmux already present'
fi

# --- fzf ---
# General-purpose command-line fuzzy finder.
if ! command -v fzf >/dev/null 2>&1; then
  info 'Installing fzf...'
  sudo apt install fzf -y || warn 'fzf installation failed (non-fatal)'
else
  ok 'fzf already present'
fi

# --- eza ---
# Modern replacement for ls with colors and git integration.
# Dependencies: rust
if ! command -v eza >/dev/null 2>&1; then
  info 'Installing eza...'
  cargo install eza || warn 'eza installation failed (non-fatal)'
else
  ok 'eza already present'
fi

# --- bat ---
# Cat clone with syntax highlighting and Git integration.
if ! command -v bat >/dev/null 2>&1; then
  info 'Installing bat...'
  sudo apt install bat -y || warn 'bat installation failed (non-fatal)'
else
  ok 'bat already present'
fi

# --- ripgrep ---
# Line-oriented search tool that recursively searches directories.
if ! command -v ripgrep >/dev/null 2>&1; then
  info 'Installing ripgrep...'
  sudo apt install ripgrep -y || warn 'ripgrep installation failed (non-fatal)'
else
  ok 'ripgrep already present'
fi

# --- fd ---
# Simple, fast and user-friendly alternative to find.
if ! command -v fd >/dev/null 2>&1; then
  info 'Installing fd...'
  sudo apt install fd-find -y && sudo ln -sf $(which fdfind) /usr/local/bin/fd || warn 'fd installation failed (non-fatal)'
else
  ok 'fd already present'
fi

# --- Node.js (via nvm) ---
# JavaScript runtime built on Chrome's V8 engine.
if ! command -v node.js >/dev/null 2>&1; then
  info 'Installing Node.js (via nvm)...'
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash || warn 'Node.js (via nvm) installation failed (non-fatal)'
else
  ok 'Node.js (via nvm) already present'
fi

# --- Go ---
# Statically typed, compiled programming language.
if ! command -v go >/dev/null 2>&1; then
  info 'Installing Go...'
  curl -LO https://go.dev/dl/go1.23.4.linux-amd64.tar.gz && sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.23.4.linux-amd64.tar.gz && rm -f go1.23.4.linux-amd64.tar.gz || warn 'Go installation failed (non-fatal)'
else
  ok 'Go already present'
fi

# --- Rust ---
# Systems programming language focused on safety and performance.
if ! command -v rust >/dev/null 2>&1; then
  info 'Installing Rust...'
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh || warn 'Rust installation failed (non-fatal)'
else
  ok 'Rust already present'
fi

# --- Deno ---
# Secure JavaScript and TypeScript runtime built on Rust.
if ! command -v deno >/dev/null 2>&1; then
  info 'Installing Deno...'
  curl -fsSL https://deno.land/install.sh | sh || warn 'Deno installation failed (non-fatal)'
else
  ok 'Deno already present'
fi

# --- Bun ---
# Fast all-in-one JavaScript runtime and toolkit.
if ! command -v bun >/dev/null 2>&1; then
  info 'Installing Bun...'
  curl -fsSL https://bun.sh/install | bash || warn 'Bun installation failed (non-fatal)'
else
  ok 'Bun already present'
fi

# SKIP: Scrapy — no install method for platform apt
# SKIP: Selenium — no install method for platform apt
# SKIP: Playwright — no install method for platform apt
# SKIP: BeautifulSoup4 — no install method for platform apt
# SKIP: httpx — no install method for platform apt
# SKIP: aiohttp — no install method for platform apt
# --- yt-dlp ---
# Feature-rich command-line audio/video downloader.
# Dependencies: pipx
if ! command -v yt-dlp >/dev/null 2>&1; then
  info 'Installing yt-dlp...'
  pipx install yt-dlp || warn 'yt-dlp installation failed (non-fatal)'
else
  ok 'yt-dlp already present'
fi

# --- gallery-dl ---
# Command-line program to download image galleries and collections.
# Dependencies: pipx
if ! command -v gallery-dl >/dev/null 2>&1; then
  info 'Installing gallery-dl...'
  pipx install gallery-dl || warn 'gallery-dl installation failed (non-fatal)'
else
  ok 'gallery-dl already present'
fi

# SKIP: newspaper3k — no install method for platform apt
# SKIP: trafilatura — no install method for platform apt
# SKIP: brozzler — no install method for platform apt
# SKIP: hakrawler — no install method for platform apt
# SKIP: waybackpack — no install method for platform apt
# SKIP: fake-useragent — no install method for platform apt
# --- rclone ---
# rsync for cloud storage — sync files to/from cloud providers.
if ! command -v rclone >/dev/null 2>&1; then
  info 'Installing rclone...'
  curl https://rclone.org/install.sh | sudo bash || warn 'rclone installation failed (non-fatal)'
else
  ok 'rclone already present'
fi

# --- wget ---
# Network utility to retrieve files from the web using HTTP, HTTPS, FTP.
if ! command -v wget >/dev/null 2>&1; then
  info 'Installing wget...'
  sudo apt install wget -y || warn 'wget installation failed (non-fatal)'
else
  ok 'wget already present'
fi

# --- Audacity ---
# Free, open-source, cross-platform audio software for multi-track recording and editing.
if ! command -v audacity >/dev/null 2>&1; then
  info 'Installing Audacity...'
  sudo apt install audacity -y || warn 'Audacity installation failed (non-fatal)'
else
  ok 'Audacity already present'
fi

# --- LMMS ---
# Free cross-platform digital audio workstation for music production.
if ! command -v lmms >/dev/null 2>&1; then
  info 'Installing LMMS...'
  sudo apt install lmms -y || warn 'LMMS installation failed (non-fatal)'
else
  ok 'LMMS already present'
fi

# --- Ardour ---
# Hard disk recorder and digital audio workstation application.
if ! command -v ardour >/dev/null 2>&1; then
  info 'Installing Ardour...'
  sudo apt install ardour -y || warn 'Ardour installation failed (non-fatal)'
else
  ok 'Ardour already present'
fi

# --- SuperCollider ---
# Platform for audio synthesis and algorithmic composition.
if ! command -v supercollider >/dev/null 2>&1; then
  info 'Installing SuperCollider...'
  sudo apt install supercollider supercollider-ide -y || warn 'SuperCollider installation failed (non-fatal)'
else
  ok 'SuperCollider already present'
fi

# --- Sonic Pi ---
# Code-based music creation and performance tool.
if ! command -v sonic >/dev/null 2>&1; then
  info 'Installing Sonic Pi...'
  sudo apt install sonic-pi -y || warn 'Sonic Pi installation failed (non-fatal)'
else
  ok 'Sonic Pi already present'
fi

# --- Hydrogen ---
# Advanced drum machine for GNU/Linux.
if ! command -v hydrogen >/dev/null 2>&1; then
  info 'Installing Hydrogen...'
  sudo apt install hydrogen -y || warn 'Hydrogen installation failed (non-fatal)'
else
  ok 'Hydrogen already present'
fi

# --- MuseScore ---
# Music notation and composition software.
if ! command -v musescore >/dev/null 2>&1; then
  info 'Installing MuseScore...'
  sudo apt install musescore -y || warn 'MuseScore installation failed (non-fatal)'
else
  ok 'MuseScore already present'
fi

# --- Rosegarden ---
# Well-rounded audio and MIDI sequencer, score editor, and music composition tool.
if ! command -v rosegarden >/dev/null 2>&1; then
  info 'Installing Rosegarden...'
  sudo apt install rosegarden -y || warn 'Rosegarden installation failed (non-fatal)'
else
  ok 'Rosegarden already present'
fi

# --- Mixxx ---
# Free DJ software for performing live mixes.
if ! command -v mixxx >/dev/null 2>&1; then
  info 'Installing Mixxx...'
  sudo apt install mixxx -y || warn 'Mixxx installation failed (non-fatal)'
else
  ok 'Mixxx already present'
fi

# --- Helm ---
# Free polyphonic synthesizer with a powerful modulation system.
if ! command -v helm >/dev/null 2>&1; then
  info 'Installing Helm...'
  sudo apt install helm -y || warn 'Helm installation failed (non-fatal)'
else
  ok 'Helm already present'
fi

# --- ZynAddSubFX ---
# Fully featured open source software synthesizer with extensive sound design.
if ! command -v zynaddsubfx >/dev/null 2>&1; then
  info 'Installing ZynAddSubFX...'
  sudo apt install zynaddsubfx -y || warn 'ZynAddSubFX installation failed (non-fatal)'
else
  ok 'ZynAddSubFX already present'
fi

# SKIP: Cecilia — no install method for platform apt
# --- SoX ---
# Swiss Army knife of sound processing utilities.
if ! command -v sox >/dev/null 2>&1; then
  info 'Installing SoX...'
  sudo apt install sox libsox-fmt-all -y || warn 'SoX installation failed (non-fatal)'
else
  ok 'SoX already present'
fi

# --- Spek ---
# Acoustic spectrum analyzer for audio files.
if ! command -v spek >/dev/null 2>&1; then
  info 'Installing Spek...'
  sudo apt install spek -y || warn 'Spek installation failed (non-fatal)'
else
  ok 'Spek already present'
fi

# --- Qtractor ---
# Audio/MIDI multi-track sequencer application written in C++ with Qt framework.
if ! command -v qtractor >/dev/null 2>&1; then
  info 'Installing Qtractor...'
  sudo apt install qtractor -y || warn 'Qtractor installation failed (non-fatal)'
else
  ok 'Qtractor already present'
fi

# --- PipeWire ---
# Server and user space API to handle multimedia pipelines in Linux.
if ! command -v pipewire >/dev/null 2>&1; then
  info 'Installing PipeWire...'
  sudo apt install pipewire pipewire-pulse wireplumber -y || warn 'PipeWire installation failed (non-fatal)'
else
  ok 'PipeWire already present'
fi

# --- Godot ---
# Free and open source 2D and 3D game engine.
if ! command -v godot >/dev/null 2>&1; then
  info 'Installing Godot...'
  sudo apt install godot3 -y || warn 'Godot installation failed (non-fatal)'
else
  ok 'Godot already present'
fi

# --- Blender ---
# Free and open source 3D creation suite for modeling, animation, rendering.
if ! command -v blender >/dev/null 2>&1; then
  info 'Installing Blender...'
  sudo apt install blender -y || warn 'Blender installation failed (non-fatal)'
else
  ok 'Blender already present'
fi

# --- Unity Hub ---
# Management tool for installing and managing Unity Editor versions.
if ! command -v unity >/dev/null 2>&1; then
  info 'Installing Unity Hub...'
  curl -LO https://public-cdn.cloud.unity3d.com/hub/prod/UnityHub.AppImage && chmod +x UnityHub.AppImage && sudo mv UnityHub.AppImage /usr/local/bin/unity-hub || warn 'Unity Hub installation failed (non-fatal)'
else
  ok 'Unity Hub already present'
fi

# --- GDevelop ---
# Open-source, cross-platform game engine designed for everyone.
if ! command -v gdevelop >/dev/null 2>&1; then
  info 'Installing GDevelop...'
  curl -LO https://github.com/4ian/GDevelop/releases/download/v5.4.213/GDevelop-5-Setup-5.4.213.exe || warn 'GDevelop installation failed (non-fatal)'
else
  ok 'GDevelop already present'
fi

# --- Defold ---
# Completely free to use game engine for development of desktop, mobile and web games.
if ! command -v defold >/dev/null 2>&1; then
  info 'Installing Defold...'
  curl -LO https://github.com/defold/defold/releases/download/1.9.2/Defold-x86_64-linux.zip && unzip Defold-x86_64-linux.zip && sudo mv Defold /usr/local/bin/defold || warn 'Defold installation failed (non-fatal)'
else
  ok 'Defold already present'
fi

# --- Bevy ---
# Data-driven game engine built in Rust using the ECS pattern.
# Dependencies: rust
if ! command -v bevy >/dev/null 2>&1; then
  info 'Installing Bevy...'
  cargo install bevy_cli || warn 'Bevy installation failed (non-fatal)'
else
  ok 'Bevy already present'
fi

# --- love2d ---
# Framework for making 2D games in Lua.
if ! command -v love2d >/dev/null 2>&1; then
  info 'Installing love2d...'
  sudo apt install love -y || warn 'love2d installation failed (non-fatal)'
else
  ok 'love2d already present'
fi

# --- Tiled ---
# Flexible level editor for tile-based games.
if ! command -v tiled >/dev/null 2>&1; then
  info 'Installing Tiled...'
  sudo apt install tiled -y || warn 'Tiled installation failed (non-fatal)'
else
  ok 'Tiled already present'
fi

# --- Aseprite ---
# Animated sprite editor and pixel art tool.
if ! command -v aseprite >/dev/null 2>&1; then
  info 'Installing Aseprite...'
  curl -LO https://github.com/aseprite/aseprite/releases/download/v1.3.8.1/Aseprite-v1.3.8.1-Source.zip || warn 'Aseprite installation failed (non-fatal)'
else
  ok 'Aseprite already present'
fi

# --- OBS Studio ---
# Free and open source software for video recording and live streaming.
if ! command -v obs >/dev/null 2>&1; then
  info 'Installing OBS Studio...'
  sudo apt install obs-studio -y || warn 'OBS Studio installation failed (non-fatal)'
else
  ok 'OBS Studio already present'
fi

# --- Wine ---
# Compatibility layer capable of running Windows applications on Linux.
if ! command -v wine >/dev/null 2>&1; then
  info 'Installing Wine...'
  sudo apt install wine -y || warn 'Wine installation failed (non-fatal)'
else
  ok 'Wine already present'
fi

# --- Lutris ---
# Open source gaming platform for GNU/Linux.
# Dependencies: wine
if ! command -v lutris >/dev/null 2>&1; then
  info 'Installing Lutris...'
  sudo apt install lutris -y || warn 'Lutris installation failed (non-fatal)'
else
  ok 'Lutris already present'
fi

# --- RetroArch ---
# Frontend for emulators, game engines and media players.
if ! command -v retroarch >/dev/null 2>&1; then
  info 'Installing RetroArch...'
  sudo apt install retroarch -y || warn 'RetroArch installation failed (non-fatal)'
else
  ok 'RetroArch already present'
fi

# --- Dolphin Emulator ---
# Emulator for Nintendo GameCube and Wii.
if ! command -v dolphin >/dev/null 2>&1; then
  info 'Installing Dolphin Emulator...'
  sudo apt install dolphin-emu -y || warn 'Dolphin Emulator installation failed (non-fatal)'
else
  ok 'Dolphin Emulator already present'
fi

# --- Steam ---
# Digital distribution service for games.
if ! command -v steam >/dev/null 2>&1; then
  info 'Installing Steam...'
  sudo apt install steam -y || warn 'Steam installation failed (non-fatal)'
else
  ok 'Steam already present'
fi

# --- itch.io ---
# Platform for indie game distribution and community.
if ! command -v itch.io >/dev/null 2>&1; then
  info 'Installing itch.io...'
  curl -LO https://itch.io/app/download?platform=linux && tar -xzf itch-setup && sudo mv itch-setup /usr/local/bin/itch || warn 'itch.io installation failed (non-fatal)'
else
  ok 'itch.io already present'
fi

# --- nmap ---
# Network discovery and security auditing utility.
if ! command -v nmap >/dev/null 2>&1; then
  info 'Installing nmap...'
  sudo apt install nmap -y || warn 'nmap installation failed (non-fatal)'
else
  ok 'nmap already present'
fi

# --- Wireshark ---
# World's foremost network protocol analyzer.
if ! command -v wireshark >/dev/null 2>&1; then
  info 'Installing Wireshark...'
  sudo apt install wireshark -y || warn 'Wireshark installation failed (non-fatal)'
else
  ok 'Wireshark already present'
fi

# --- tcpdump ---
# Powerful command-line packet analyzer.
if ! command -v tcpdump >/dev/null 2>&1; then
  info 'Installing tcpdump...'
  sudo apt install tcpdump -y || warn 'tcpdump installation failed (non-fatal)'
else
  ok 'tcpdump already present'
fi

# --- iperf3 ---
# Tool for active measurements of the maximum achievable bandwidth on IP networks.
if ! command -v iperf3 >/dev/null 2>&1; then
  info 'Installing iperf3...'
  sudo apt install iperf3 -y || warn 'iperf3 installation failed (non-fatal)'
else
  ok 'iperf3 already present'
fi

# --- netcat ---
# Networking utility for reading from and writing to network connections.
if ! command -v netcat >/dev/null 2>&1; then
  info 'Installing netcat...'
  sudo apt install netcat-openbsd -y || warn 'netcat installation failed (non-fatal)'
else
  ok 'netcat already present'
fi

# --- mtr ---
# Network diagnostic tool combining ping and traceroute.
if ! command -v mtr >/dev/null 2>&1; then
  info 'Installing mtr...'
  sudo apt install mtr -y || warn 'mtr installation failed (non-fatal)'
else
  ok 'mtr already present'
fi

# --- whois ---
# Client for the whois directory service.
if ! command -v whois >/dev/null 2>&1; then
  info 'Installing whois...'
  sudo apt install whois -y || warn 'whois installation failed (non-fatal)'
else
  ok 'whois already present'
fi

# --- dig ---
# DNS lookup utility for querying DNS name servers.
if ! command -v dig >/dev/null 2>&1; then
  info 'Installing dig...'
  sudo apt install dnsutils -y || warn 'dig installation failed (non-fatal)'
else
  ok 'dig already present'
fi

# --- curl ---
# Command-line tool for transferring data with URLs.
if ! command -v curl >/dev/null 2>&1; then
  info 'Installing curl...'
  sudo apt install curl -y || warn 'curl installation failed (non-fatal)'
else
  ok 'curl already present'
fi

# --- aria2 ---
# Lightweight multi-protocol and multi-source command-line download utility.
if ! command -v aria2 >/dev/null 2>&1; then
  info 'Installing aria2...'
  sudo apt install aria2 -y || warn 'aria2 installation failed (non-fatal)'
else
  ok 'aria2 already present'
fi

# --- bandwhich ---
# Terminal bandwidth utilization tool showing current network usage by process.
# Dependencies: rust
if ! command -v bandwhich >/dev/null 2>&1; then
  info 'Installing bandwhich...'
  cargo install bandwhich || warn 'bandwhich installation failed (non-fatal)'
else
  ok 'bandwhich already present'
fi

# --- bmon ---
# Portable bandwidth monitor and rate estimator.
if ! command -v bmon >/dev/null 2>&1; then
  info 'Installing bmon...'
  sudo apt install bmon -y || warn 'bmon installation failed (non-fatal)'
else
  ok 'bmon already present'
fi

# --- nload ---
# Console application which monitors network traffic and bandwidth usage in real time.
if ! command -v nload >/dev/null 2>&1; then
  info 'Installing nload...'
  sudo apt install nload -y || warn 'nload installation failed (non-fatal)'
else
  ok 'nload already present'
fi

# --- socat ---
# Multipurpose relay for bidirectional data transfer between two independent data channels.
if ! command -v socat >/dev/null 2>&1; then
  info 'Installing socat...'
  sudo apt install socat -y || warn 'socat installation failed (non-fatal)'
else
  ok 'socat already present'
fi

# --- openssh-server ---
# Secure shell server for remote login and command execution.
if ! command -v openssh-server >/dev/null 2>&1; then
  info 'Installing openssh-server...'
  sudo apt install openssh-server -y || warn 'openssh-server installation failed (non-fatal)'
else
  ok 'openssh-server already present'
fi

# --- ufw ---
# Uncomplicated Firewall — user-friendly front-end for managing iptables.
if ! command -v ufw >/dev/null 2>&1; then
  info 'Installing ufw...'
  sudo apt install ufw -y || warn 'ufw installation failed (non-fatal)'
else
  ok 'ufw already present'
fi

# --- Obsidian ---
# Powerful knowledge base on top of a local folder of plain text Markdown files.
if ! command -v obsidian >/dev/null 2>&1; then
  info 'Installing Obsidian...'
  curl -LO https://github.com/obsidianmd/obsidian-releases/releases/download/v1.6.7/Obsidian-1.6.7.AppImage && chmod +x Obsidian-1.6.7.AppImage && sudo mv Obsidian-1.6.7.AppImage /usr/local/bin/obsidian || warn 'Obsidian installation failed (non-fatal)'
else
  ok 'Obsidian already present'
fi

# --- Logseq ---
# Privacy-first, open-source platform for knowledge management and collaboration.
if ! command -v logseq >/dev/null 2>&1; then
  info 'Installing Logseq...'
  curl -LO https://github.com/logseq/logseq/releases/download/0.10.9/Logseq-linux-x64-0.10.9.AppImage && chmod +x Logseq-linux-x64-0.10.9.AppImage && sudo mv Logseq-linux-x64-0.10.9.AppImage /usr/local/bin/logseq || warn 'Logseq installation failed (non-fatal)'
else
  ok 'Logseq already present'
fi

# --- Joplin ---
# Open source note-taking and to-do application with synchronization.
if ! command -v joplin >/dev/null 2>&1; then
  info 'Installing Joplin...'
  wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash || warn 'Joplin installation failed (non-fatal)'
else
  ok 'Joplin already present'
fi

# --- Standard Notes ---
# End-to-end encrypted notes app with focus on privacy and longevity.
if ! command -v standard >/dev/null 2>&1; then
  info 'Installing Standard Notes...'
  curl -LO https://github.com/standardnotes/app/releases/download/%40standardnotes%40desktop%403.195.0/standard-notes-3.195.0-linux-x86_64.AppImage && chmod +x standard-notes-3.195.0-linux-x86_64.AppImage && sudo mv standard-notes-3.195.0-linux-x86_64.AppImage /usr/local/bin/standard-notes || warn 'Standard Notes installation failed (non-fatal)'
else
  ok 'Standard Notes already present'
fi

# --- Zettlr ---
# Markdown editor for the 21st century with Zettelkasten support.
if ! command -v zettlr >/dev/null 2>&1; then
  info 'Installing Zettlr...'
  sudo apt install zettlr -y || warn 'Zettlr installation failed (non-fatal)'
else
  ok 'Zettlr already present'
fi

# --- Taskwarrior ---
# Open source, command-line task management utility.
if ! command -v taskwarrior >/dev/null 2>&1; then
  info 'Installing Taskwarrior...'
  sudo apt install taskwarrior -y || warn 'Taskwarrior installation failed (non-fatal)'
else
  ok 'Taskwarrior already present'
fi

# --- Timewarrior ---
# Command-line time tracking utility that integrates with Taskwarrior.
# Dependencies: taskwarrior
if ! command -v timewarrior >/dev/null 2>&1; then
  info 'Installing Timewarrior...'
  sudo apt install timewarrior -y || warn 'Timewarrior installation failed (non-fatal)'
else
  ok 'Timewarrior already present'
fi

# --- hledger ---
# Plain text accounting software for tracking finances.
if ! command -v hledger >/dev/null 2>&1; then
  info 'Installing hledger...'
  sudo apt install hledger -y || warn 'hledger installation failed (non-fatal)'
else
  ok 'hledger already present'
fi

# --- Calcurse ---
# Text-based calendar and scheduling application.
if ! command -v calcurse >/dev/null 2>&1; then
  info 'Installing Calcurse...'
  sudo apt install calcurse -y || warn 'Calcurse installation failed (non-fatal)'
else
  ok 'Calcurse already present'
fi

# --- Newsboat ---
# Open-source RSS/Atom feed reader for the text console.
if ! command -v newsboat >/dev/null 2>&1; then
  info 'Installing Newsboat...'
  sudo apt install newsboat -y || warn 'Newsboat installation failed (non-fatal)'
else
  ok 'Newsboat already present'
fi

# --- WeeChat ---
# Fast, light and extensible chat client supporting IRC and other protocols.
if ! command -v weechat >/dev/null 2>&1; then
  info 'Installing WeeChat...'
  sudo apt install weechat -y || warn 'WeeChat installation failed (non-fatal)'
else
  ok 'WeeChat already present'
fi

# --- tldr ---
# Simplified and community-driven man pages.
# Dependencies: pipx
if ! command -v tldr >/dev/null 2>&1; then
  info 'Installing tldr...'
  pipx install tldr || warn 'tldr installation failed (non-fatal)'
else
  ok 'tldr already present'
fi

# SKIP: cheat — no install method for platform apt
# --- z ---
# Tracks your most used directories for quick navigation (zoxide superset).
if ! command -v z >/dev/null 2>&1; then
  info 'Installing z...'
  curl -sS https://raw.githubusercontent.com/rupa/z/master/z.sh -o ~/.local/bin/z.sh && chmod +x ~/.local/bin/z.sh || warn 'z installation failed (non-fatal)'
else
  ok 'z already present'
fi

# --- direnv ---
# Environment switcher for the shell that loads/unloads env vars per directory.
if ! command -v direnv >/dev/null 2>&1; then
  info 'Installing direnv...'
  sudo apt install direnv -y || warn 'direnv installation failed (non-fatal)'
else
  ok 'direnv already present'
fi

# --- stow ---
# Symlink farm manager for dotfiles and software package management.
if ! command -v stow >/dev/null 2>&1; then
  info 'Installing stow...'
  sudo apt install stow -y || warn 'stow installation failed (non-fatal)'
else
  ok 'stow already present'
fi

# --- Jellyfin ---
# Free Software Media System for managing and streaming media.
# Dependencies: docker
if ! command -v jellyfin >/dev/null 2>&1; then
  info 'Installing Jellyfin...'
  docker run -d --name jellyfin -p 8096:8096 -v jellyfin-config:/config -v jellyfin-cache:/cache jellyfin/jellyfin:latest || warn 'Jellyfin installation failed (non-fatal)'
else
  ok 'Jellyfin already present'
fi

# --- Plex ---
# Client-server media player system and software suite.
# Dependencies: docker
if ! command -v plex >/dev/null 2>&1; then
  info 'Installing Plex...'
  docker run -d --name plex -p 32400:32400 -v plex-config:/config plexinc/pms-docker:latest || warn 'Plex installation failed (non-fatal)'
else
  ok 'Plex already present'
fi

# --- Nextcloud ---
# Self-hosted cloud storage and collaboration platform.
# Dependencies: docker
if ! command -v nextcloud >/dev/null 2>&1; then
  info 'Installing Nextcloud...'
  docker run -d --name nextcloud -p 8080:80 -v nextcloud:/var/www/html nextcloud:latest || warn 'Nextcloud installation failed (non-fatal)'
else
  ok 'Nextcloud already present'
fi

# --- Immich ---
# Self-hosted photo and video backup solution.
# Dependencies: docker
if ! command -v immich >/dev/null 2>&1; then
  info 'Installing Immich...'
  docker run -d --name immich-server -p 2283:3001 ghcr.io/immich-app/immich-server:release || warn 'Immich installation failed (non-fatal)'
else
  ok 'Immich already present'
fi

# --- Home Assistant ---
# Open source home automation platform for controlling smart devices.
# Dependencies: docker
if ! command -v home >/dev/null 2>&1; then
  info 'Installing Home Assistant...'
  docker run -d --name homeassistant -p 8123:8123 -v hass-config:/config homeassistant/home-assistant:latest || warn 'Home Assistant installation failed (non-fatal)'
else
  ok 'Home Assistant already present'
fi

# --- Pi-hole ---
# Network-wide ad blocking via DNS sinkhole.
# Dependencies: docker
if ! command -v pi-hole >/dev/null 2>&1; then
  info 'Installing Pi-hole...'
  docker run -d --name pihole -p 53:53/tcp -p 53:53/udp -p 80:80 -v pihole:/etc/pihole pihole/pihole:latest || warn 'Pi-hole installation failed (non-fatal)'
else
  ok 'Pi-hole already present'
fi

# --- Portainer ---
# Lightweight management UI for Docker and Kubernetes environments.
# Dependencies: docker
if ! command -v portainer >/dev/null 2>&1; then
  info 'Installing Portainer...'
  docker run -d --name portainer -p 8000:8000 -p 9443:9443 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest || warn 'Portainer installation failed (non-fatal)'
else
  ok 'Portainer already present'
fi

# --- Traefik ---
# Modern HTTP reverse proxy and load balancer for microservices.
# Dependencies: docker
if ! command -v traefik >/dev/null 2>&1; then
  info 'Installing Traefik...'
  docker run -d --name traefik -p 80:80 -p 443:443 -v /var/run/docker.sock:/var/run/docker.sock traefik:v3.0 || warn 'Traefik installation failed (non-fatal)'
else
  ok 'Traefik already present'
fi

# --- Nginx Proxy Manager ---
# Easy-to-use web interface for managing Nginx proxy hosts.
# Dependencies: docker
if ! command -v nginx >/dev/null 2>&1; then
  info 'Installing Nginx Proxy Manager...'
  docker run -d --name npm -p 80:80 -p 81:81 -p 443:443 -v npm-data:/data jc21/nginx-proxy-manager:latest || warn 'Nginx Proxy Manager installation failed (non-fatal)'
else
  ok 'Nginx Proxy Manager already present'
fi

# --- Uptime Kuma ---
# Self-hosted monitoring tool for tracking service uptime and health.
# Dependencies: docker
if ! command -v uptime >/dev/null 2>&1; then
  info 'Installing Uptime Kuma...'
  docker run -d --name uptime-kuma -p 3001:3001 -v uptime-kuma:/app/data louislam/uptime-kuma:1 || warn 'Uptime Kuma installation failed (non-fatal)'
else
  ok 'Uptime Kuma already present'
fi

# --- Grafana ---
# Open source analytics and interactive visualization web application.
# Dependencies: docker
if ! command -v grafana >/dev/null 2>&1; then
  info 'Installing Grafana...'
  docker run -d --name grafana -p 3000:3000 -v grafana-storage:/var/lib/grafana grafana/grafana:latest || warn 'Grafana installation failed (non-fatal)'
else
  ok 'Grafana already present'
fi

# --- Prometheus ---
# Open source monitoring and alerting toolkit for metrics collection.
# Dependencies: docker
if ! command -v prometheus >/dev/null 2>&1; then
  info 'Installing Prometheus...'
  docker run -d --name prometheus -p 9090:9090 -v prometheus-data:/prometheus prom/prometheus:latest || warn 'Prometheus installation failed (non-fatal)'
else
  ok 'Prometheus already present'
fi

# --- Syncthing ---
# Continuous file synchronization program for peer-to-peer file sync.
if ! command -v syncthing >/dev/null 2>&1; then
  info 'Installing Syncthing...'
  sudo apt install syncthing -y || warn 'Syncthing installation failed (non-fatal)'
else
  ok 'Syncthing already present'
fi

# --- MinIO ---
# High-performance, S3 compatible object storage server.
# Dependencies: docker
if ! command -v minio >/dev/null 2>&1; then
  info 'Installing MinIO...'
  docker run -d --name minio -p 9000:9000 -p 9001:9001 -v minio-data:/data minio/minio:latest server /data --console-address ":9001" || warn 'MinIO installation failed (non-fatal)'
else
  ok 'MinIO already present'
fi

# --- Paperless-ngx ---
# Document management system that transforms physical documents into searchable online archive.
# Dependencies: docker
if ! command -v paperless-ngx >/dev/null 2>&1; then
  info 'Installing Paperless-ngx...'
  docker run -d --name paperless -p 8000:8000 -v paperless-data:/usr/src/paperless/media ghcr.io/paperless-ngx/paperless-ngx:latest || warn 'Paperless-ngx installation failed (non-fatal)'
else
  ok 'Paperless-ngx already present'
fi

# --- Vaultwarden ---
# Unofficial Bitwarden compatible server written in Rust for self-hosting passwords.
# Dependencies: docker
if ! command -v vaultwarden >/dev/null 2>&1; then
  info 'Installing Vaultwarden...'
  docker run -d --name vaultwarden -p 80:80 -v vaultwarden-data:/data vaultwarden/server:latest || warn 'Vaultwarden installation failed (non-fatal)'
else
  ok 'Vaultwarden already present'
fi

# --- GIMP ---
# GNU Image Manipulation Program for photo retouching, composition, and authoring.
if ! command -v gimp >/dev/null 2>&1; then
  info 'Installing GIMP...'
  sudo apt install gimp -y || warn 'GIMP installation failed (non-fatal)'
else
  ok 'GIMP already present'
fi

# --- Inkscape ---
# Professional vector graphics editor for creating and editing SVG files.
if ! command -v inkscape >/dev/null 2>&1; then
  info 'Installing Inkscape...'
  sudo apt install inkscape -y || warn 'Inkscape installation failed (non-fatal)'
else
  ok 'Inkscape already present'
fi

# --- Krita ---
# Professional free and open source painting program made by artists.
if ! command -v krita >/dev/null 2>&1; then
  info 'Installing Krita...'
  sudo apt install krita -y || warn 'Krita installation failed (non-fatal)'
else
  ok 'Krita already present'
fi

# --- Darktable ---
# Open source photography workflow application and raw developer.
if ! command -v darktable >/dev/null 2>&1; then
  info 'Installing Darktable...'
  sudo apt install darktable -y || warn 'Darktable installation failed (non-fatal)'
else
  ok 'Darktable already present'
fi

# --- RawTherapee ---
# Free cross-platform raw image processing program.
if ! command -v rawtherapee >/dev/null 2>&1; then
  info 'Installing RawTherapee...'
  sudo apt install rawtherapee -y || warn 'RawTherapee installation failed (non-fatal)'
else
  ok 'RawTherapee already present'
fi

# --- Shotwell ---
# Personal photo manager for GNOME.
if ! command -v shotwell >/dev/null 2>&1; then
  info 'Installing Shotwell...'
  sudo apt install shotwell -y || warn 'Shotwell installation failed (non-fatal)'
else
  ok 'Shotwell already present'
fi

# --- digiKam ---
# Advanced open-source digital photo management application.
if ! command -v digikam >/dev/null 2>&1; then
  info 'Installing digiKam...'
  sudo apt install digikam -y || warn 'digiKam installation failed (non-fatal)'
else
  ok 'digiKam already present'
fi

# --- ImageMagick ---
# Software suite for displaying, converting, and editing raster images.
if ! command -v imagemagick >/dev/null 2>&1; then
  info 'Installing ImageMagick...'
  sudo apt install imagemagick -y || warn 'ImageMagick installation failed (non-fatal)'
else
  ok 'ImageMagick already present'
fi

# SKIP: Pillow — no install method for platform apt
# SKIP: ComfyUI — no install method for platform apt
# SKIP: InvokeAI — no install method for platform apt
# SKIP: Fooocus — no install method for platform apt
# --- ExifTool ---
# Platform-independent Perl library for reading, writing, and editing metadata.
if ! command -v exiftool >/dev/null 2>&1; then
  info 'Installing ExifTool...'
  sudo apt install libimage-exiftool-perl -y || warn 'ExifTool installation failed (non-fatal)'
else
  ok 'ExifTool already present'
fi

# --- pngquant ---
# Command-line utility for lossy compression of PNG images.
if ! command -v pngquant >/dev/null 2>&1; then
  info 'Installing pngquant...'
  sudo apt install pngquant -y || warn 'pngquant installation failed (non-fatal)'
else
  ok 'pngquant already present'
fi

# --- jpegoptim ---
# Utility to optimize and compress JPEG files without losing quality.
if ! command -v jpegoptim >/dev/null 2>&1; then
  info 'Installing jpegoptim...'
  sudo apt install jpegoptim -y || warn 'jpegoptim installation failed (non-fatal)'
else
  ok 'jpegoptim already present'
fi

# --- G'MIC ---
# Full-featured open-source framework for image processing with hundreds of filters.
if ! command -v g'mic >/dev/null 2>&1; then
  info 'Installing G'MIC...'
  sudo apt install gmic -y || warn 'G'MIC installation failed (non-fatal)'
else
  ok 'G'MIC already present'
fi

# --- Metasploit ---
# Penetration testing framework for developing and executing exploit code.
if ! command -v metasploit >/dev/null 2>&1; then
  info 'Installing Metasploit...'
  curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && chmod 755 msfinstall && ./msfinstall || warn 'Metasploit installation failed (non-fatal)'
else
  ok 'Metasploit already present'
fi

# --- Burp Suite Community ---
# Platform for performing security testing of web applications.
if ! command -v burp >/dev/null 2>&1; then
  info 'Installing Burp Suite Community...'
  curl -LO https://portswigger.net/burp/releases/download?product=community&version=2024.12.1&type=Linux && sudo dpkg -i burpsuite_community_linux_v2024_12_1.sh || warn 'Burp Suite Community installation failed (non-fatal)'
else
  ok 'Burp Suite Community already present'
fi

# --- OWASP ZAP ---
# Open source web application security scanner and proxy.
if ! command -v owasp >/dev/null 2>&1; then
  info 'Installing OWASP ZAP...'
  sudo apt install zaproxy -y || warn 'OWASP ZAP installation failed (non-fatal)'
else
  ok 'OWASP ZAP already present'
fi

# SKIP: sqlmap — no install method for platform apt
# --- Nikto ---
# Web server scanner for finding dangerous files, outdated software, and vulnerabilities.
if ! command -v nikto >/dev/null 2>&1; then
  info 'Installing Nikto...'
  sudo apt install nikto -y || warn 'Nikto installation failed (non-fatal)'
else
  ok 'Nikto already present'
fi

# --- dirb ---
# Web Content Scanner that looks for existing and hidden web objects.
if ! command -v dirb >/dev/null 2>&1; then
  info 'Installing dirb...'
  sudo apt install dirb -y || warn 'dirb installation failed (non-fatal)'
else
  ok 'dirb already present'
fi

# SKIP: gobuster — no install method for platform apt
# --- hydra ---
# Very fast network logon cracker supporting numerous protocols.
if ! command -v hydra >/dev/null 2>&1; then
  info 'Installing hydra...'
  sudo apt install hydra -y || warn 'hydra installation failed (non-fatal)'
else
  ok 'hydra already present'
fi

# --- John the Ripper ---
# Password cracking tool supporting hundreds of hash and cipher types.
if ! command -v john >/dev/null 2>&1; then
  info 'Installing John the Ripper...'
  sudo apt install john -y || warn 'John the Ripper installation failed (non-fatal)'
else
  ok 'John the Ripper already present'
fi

# --- Hashcat ---
# World's fastest password recovery utility supporting GPU acceleration.
if ! command -v hashcat >/dev/null 2>&1; then
  info 'Installing Hashcat...'
  sudo apt install hashcat -y || warn 'Hashcat installation failed (non-fatal)'
else
  ok 'Hashcat already present'
fi

# --- aircrack-ng ---
# Complete suite of tools for auditing wireless networks.
if ! command -v aircrack-ng >/dev/null 2>&1; then
  info 'Installing aircrack-ng...'
  sudo apt install aircrack-ng -y || warn 'aircrack-ng installation failed (non-fatal)'
else
  ok 'aircrack-ng already present'
fi

# --- wireshark ---
# Network protocol analyzer for network troubleshooting and analysis.
if ! command -v wireshark >/dev/null 2>&1; then
  info 'Installing wireshark...'
  sudo apt install wireshark -y || warn 'wireshark installation failed (non-fatal)'
else
  ok 'wireshark already present'
fi

# --- tcpdump ---
# Powerful command-line packet analyzer for network debugging.
if ! command -v tcpdump >/dev/null 2>&1; then
  info 'Installing tcpdump...'
  sudo apt install tcpdump -y || warn 'tcpdump installation failed (non-fatal)'
else
  ok 'tcpdump already present'
fi

# --- lynis ---
# Security auditing tool for Unix-based systems.
if ! command -v lynis >/dev/null 2>&1; then
  info 'Installing lynis...'
  sudo apt install lynis -y || warn 'lynis installation failed (non-fatal)'
else
  ok 'lynis already present'
fi

# --- rkhunter ---
# Rootkit and backdoor scanner for Unix-like systems.
if ! command -v rkhunter >/dev/null 2>&1; then
  info 'Installing rkhunter...'
  sudo apt install rkhunter -y || warn 'rkhunter installation failed (non-fatal)'
else
  ok 'rkhunter already present'
fi

# --- chkrootkit ---
# Tool for locally checking for signs of a rootkit infection.
if ! command -v chkrootkit >/dev/null 2>&1; then
  info 'Installing chkrootkit...'
  sudo apt install chkrootkit -y || warn 'chkrootkit installation failed (non-fatal)'
else
  ok 'chkrootkit already present'
fi

echo ''
echo -e "${GREEN}✅ AIMAS generated install complete${NC}"
