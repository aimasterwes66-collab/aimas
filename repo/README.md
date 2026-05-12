# AIMAS — Self-Assembling Creative AI Workstation

> **A**I-driven **M**achine **A**utomation **S**ystem  
> Declarative infrastructure for content creators, video editors, AI researchers, and terminal ricers.

---

## Philosophy

Instead of manually installing tools one-by-one, you **describe intent** (via Markdown or JSON) and the system converges reality toward that description. Think of it as Terraform for your desktop — but readable by humans.

---

## Quick Start

### 1. Full Bootstrap (Native Linux)

```bash
# Clone or download, then run
curl -fsSL https://yourdomain.com/aimas-bootstrap.sh | bash
```

Or locally:

```bash
bash aimas-bootstrap.sh
```

### 2. Selective Install via Generator

```bash
cd aimas-repo
python3 generator/generate_script.py \
  --platform apt \
  --categories video,ai,dev \
  --format bash \
  --output scripts/my_install.sh

bash scripts/my_install.sh
```

### 3. Ansible Playbook

```bash
cd aimas-repo
ansible-playbook -i localhost, -c local playbooks/install_stack.yml
```

---

## Repo Structure

```
aimas-repo/
├── tool-list/
│   ├── video-tools.json      # OBS, Kdenlive, FFmpeg, Blender, etc.
│   ├── ai-tools.json         # Ollama, PyTorch, Transformers, Open WebUI
│   └── dev-tools.json        # Docker, K8s, Terraform, Rust, Go, Deno
├── generator/
│   └── generate_script.py    # Reads JSON → outputs bash/ansible
├── playbooks/
│   └── install_stack.yml     # Full Ansible playbook
├── scripts/
│   └── install.sh            # Pre-generated sample script
├── docs/
│   └── manifest-spec.md      # JSON manifest specification
└── README.md                 # You are here
```

---

## JSON Manifest

The canonical manifest (`aimas-manifest.json`) acts as the **genome** of the system. It contains:

- **Categories** — grouped installation steps (system prep, AI/ML, scraping, shell, etc.)
- **All-commands-flat** — a single array for simple loop-based execution
- **God-mode entries** — curated one-liner bootstraps for dotfiles, LLMs, media, networking

---

## Key Principles

| Principle | Implementation |
|-----------|---------------|
| **Declarative** | JSON/YAML/Markdown describes intent, not commands |
| **Isolated** | Python tools live in `uv` venvs; CLIs in `pipx` |
| **Multi-runtime** | Supports apt, cargo, go, npm, docker, nix, brew |
| **Self-healing** | Ansible playbooks can be re-run idempotently |
| **Local-first** | Ollama + llama.cpp run entirely offline |

---

## Tool Categories

### Content Creation
- **Video**: OBS Studio, Kdenlive, Shotcut, HandBrake, FFmpeg
- **Audio**: Audacity, SuperCollider, LMMS
- **Image**: GIMP, Inkscape, Krita, Blender

### AI / ML
- **Local LLMs**: Ollama, llama.cpp, GPT4All, LocalAI
- **Frameworks**: PyTorch (CPU), TensorFlow (CPU), Transformers, Hugging Face
- **Agents**: aider, open-interpreter, shell-gpt, litellm

### Scraping & Research
- **Core**: Scrapy, Selenium, Playwright, BeautifulSoup
- **Media**: yt-dlp, gallery-dl, rclone
- **Analysis**: Pandas, Jupyter, newspaper3k, trafilatura

### Terminal & Shell
- **Shell**: Zsh + Oh-My-Zsh + Starship + Zoxide
- **Modern CLI**: eza, bat, fd, ripgrep, fzf, btm, dust, procs
- **Multiplexer**: tmux

### DevOps
- **Containers**: Docker CE, Docker Compose, kubectl
- **IaC**: Terraform, Ansible
- **Runtimes**: Node (nvm), Go, Rust, Deno, Bun

---

## Security Notes

- The `curl | bash` pattern is powerful. Inspect scripts before running.
- All Python packages are installed into isolated venvs (uv) or pipx sandboxes.
- Docker containers run with standard security profiles.
- No GPU drivers or CUDA are assumed — everything targets CPU inference.

---

## Extending

To add a new tool:

1. Edit `tool-list/<category>-tools.json`
2. Add entry with `name`, `description`, `install_methods`, `platforms`
3. Run `python generator/generate_script.py` to rebuild

---

## License

MIT — do whatever you want, but don’t blame us if your machine gains sentience.
