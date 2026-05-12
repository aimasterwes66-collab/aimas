# AIMAS — AI Machine Automation System

> **A**I-driven **M**achine **A**utomation **S**ystem  
> One command turns a bare Linux machine into a creative AI workstation.

```bash
curl -fsSL https://raw.githubusercontent.com/YOURNAME/aimas/main/aimas-bootstrap.sh | bash
```

---

## What is this?

AIMAS is a declarative bootstrap system for native Linux that installs entire tool ecosystems from a single script. Instead of manually hunting down packages, you run one command and get:

- **AI/ML Stack** — Ollama, PyTorch, Transformers, Jupyter, LocalAI, Open WebUI
- **Creative Tools** — OBS, Kdenlive, Blender, GIMP, Audacity
- **DevOps** — Docker, K8s, Terraform, Ansible, AWS CLI
- **Languages** — Rust, Go, Node, Python (uv), Deno, Bun, JVM (SDKMAN!)
- **Terminal** — Zsh, Starship, Zoxide, modern Rust/Go CLI replacements
- **Scraping** — Playwright, Scrapy, yt-dlp, gallery-dl

---

## Quick Start

### Full Bootstrap

```bash
bash aimas-bootstrap.sh
```

### Selective Install (from JSON manifest)

```bash
cd repo
python3 generator/generate_script.py \
  --platform apt \
  --categories video,ai,dev \
  --format bash \
  --output scripts/my_install.sh

bash scripts/my_install.sh
```

### Ansible

```bash
cd repo
ansible-playbook -i localhost, -c local playbooks/install_stack.yml
```

---

## Repo Layout

```
aimas/
├── aimas-bootstrap.sh          # Master executable script
├── aimas-manifest.json         # Canonical machine-readable manifest
├── scanner-daemon/
│   └── SPEC.md                 # Architecture spec for the self-healing layer
└── repo/
    ├── README.md               # Detailed repo documentation
    ├── tool-list/              # JSON tool definitions
    ├── generator/              # Manifest → script compiler
    ├── playbooks/              # Ansible playbooks
    └── scripts/                # Generated install scripts
```

---

## Design Principles

1. **Declarative** — Describe intent, not commands
2. **Isolated** — Python tools live in `uv` venvs; CLIs in `pipx`
3. **Local-first** — Ollama + llama.cpp run entirely offline
4. **Multi-runtime** — apt, cargo, go, npm, docker, uv, pipx
5. **Self-healing** — Ansible playbooks are idempotent

---

## Requirements

- Ubuntu / Debian-based Linux (amd64)
- systemd
- Internet connection
- ~20GB free disk space (for models and containers)

---

## Security

- Inspect before you run: `curl | bash` is powerful
- All Python packages use isolated virtual environments
- Docker containers run with standard security profiles
- No GPU/CUDA assumed — everything targets CPU inference

---

## License

MIT — see [LICENSE](LICENSE)

---

*Built for humans who'd rather create than configure.*
