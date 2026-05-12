---
aimas_version: "0.1.0"
platform: linux
arch: amd64
gpu: false
cuda: false
auto_execute: true
---

# Creative AI Mega-Station

A comprehensive creative workstation for AI-powered content creation,
video production, audio synthesis, image generation, web scraping,
and research automation.

## Requires

- obs-studio
- kdenlive
- ffmpeg
- blender
- gimp
- inkscape
- krita
- darktable
- audacity
- lmms
- ollama
- python >= 3.10
- nodejs >= 18
- docker
- zsh
- starship
- zoxide
- eza
- bat
- fd
- ripgrep
- fzf
- tmux
- lazygit
- yt-dlp
- gallery-dl
- rclone
- nmap
- wireshark

## Capabilities

### AI & Machine Learning
```aimas-capability
{
  "category": "ai-ml",
  "confidence": 0.98,
  "tools": [
    {"name": "ollama", "required": true},
    {"name": "uv", "required": true},
    {"name": "pipx", "required": true}
  ]
}
```

### Video Production
```aimas-capability
{
  "category": "video",
  "confidence": 0.95,
  "tools": [
    {"name": "obs-studio", "required": true},
    {"name": "kdenlive", "required": true},
    {"name": "ffmpeg", "required": true},
    {"name": "blender", "required": false}
  ]
}
```

### Web Scraping & Research
```aimas-capability
{
  "category": "scrape",
  "confidence": 0.92,
  "tools": [
    {"name": "yt-dlp", "required": true},
    {"name": "rclone", "required": false},
    {"name": "gallery-dl", "required": false}
  ]
}
```

## Config
- shell: zsh
- theme: starship
- editor: neovim

## Direct Commands
```aimas-run
# Ensure Ollama models are pulled
ollama pull llama3.1:8b || true
ollama pull qwen2.5-coder:14b || true
```
