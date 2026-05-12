# AIMAS Scanner Daemon — Technical Specification

> **Version:** 0.1.0-alpha  
> **Status:** Design / Pre-Implementation  
> **Author:** aimas  

---

## 1. Executive Summary

The **Scanner Daemon** is the cognitive layer of the AIMAS ecosystem. It converts human-readable Markdown documents into machine-executable system mutations. Instead of the user typing installation commands, they write intent — and the daemon closes the gap between declaration and reality.

**Core premise:** *Markdown is the interface. The machine configures itself.*

---

## 2. Philosophy: Declarative Intent Over Imperative Commands

### Old Model (Imperative)
```bash
sudo apt install ffmpeg
sudo apt install nodejs
git clone https://github.com/...
pip install torch
```

### New Model (Declarative)
```markdown
# My Creative Workstation

Requires:
- Video editing capability
- Local AI inference
- Web scraping pipeline
- Music synthesis
```

The daemon reads this, extracts semantic intent, resolves it against a capability graph, and converges the system state.

---

## 3. System Architecture: The Four-Layer Loop

```
┌─────────────────────────────────────────────────────────────┐
│  LAYER 1: INTENT SOURCE (Markdown Corpus)                   │
│  • .md files in ~/Documents/aimas-intent/                   │
│  • GitHub repos (public or private)                         │
│  • Gist / Pastebin / S3 objects                             │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  LAYER 2: SEMANTIC INTERPRETER (Local LLM + NLP)            │
│  • Reads Markdown as semantic input                         │
│  • Extracts capabilities, not keywords                      │
│  • Runs entirely offline (Ollama/llama.cpp)                 │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  LAYER 3: ENVIRONMENT SCANNER (System State)                │
│  • Detects installed binaries, versions, package managers   │
│  • Identifies missing pieces                                │
│  • Resolves dependency graphs                               │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  LAYER 4: ACTUATOR (Package Managers + Config)              │
│  • Executes install / update / config commands              │
│  • apt, cargo, go, npm, docker, uv, pipx, nix...            │
│  • Writes shell configs, systemd units, cron jobs           │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
              ┌─────────────────┐
              │  CONVERGENCE    │
              │  VERIFY STATE   │
              │  LOOP BACK      │
              └─────────────────┘
```

---

## 4. Layer 1: Intent Source Schema

### 4.1 Markdown File Structure

Every intent document is a Markdown file with **structured blocks**. The daemon ignores free-form prose and only acts on annotated blocks.

#### 4.1.1 Standard Intent Block

```markdown
# Project: AI Video Automation

## Requires
- ffmpeg
- ollama
- python >= 3.10
- comfyui
- nodejs >= 18

## Goals
- Generate videos from text prompts
- Automate rendering pipeline
- Scrape stock footage metadata

## Config
- shell: zsh
- theme: powerlevel10k
- dotfiles: https://github.com/user/dotfiles
```

#### 4.1.2 Machine-Readable YAML Frontmatter

```markdown
---
aimas_version: "0.1.0"
platform: linux
arch: amd64
gpu: false
cuda: false
auto_execute: true
convergence_interval: 300
---

# My Workstation
...
```

#### 4.1.3 Structured Code Blocks (Explicit Commands)

```markdown
## Direct Commands
```aimas-run
sudo apt install ffmpeg
ollama pull llama3.1:8b
```
```

#### 4.1.4 Capability Blocks (Semantic)

```markdown
## Capabilities
```aimas-capability
category: ai-ml
tools:
  - name: ollama
    model: llama3.1:8b
  - name: comfyui
    source: github
    repo: comfyanonymous/ComfyUI
```
```

### 4.2 File Discovery Rules

| Source | Path Pattern | Priority |
|--------|-------------|----------|
| Local intent dir | `~/.config/aimas/intent/**/*.md` | 1 (highest) |
| Project local | `./.aimas/*.md` | 2 |
| GitHub repo | `https://github.com/user/repo/*.md` | 3 |
| Gist | `https://gist.github.com/...` | 4 |
| System default | `/etc/aimas/default.md` | 5 (lowest) |

---

## 5. Layer 2: Semantic Interpreter

### 5.1 Local LLM Backend

The interpreter uses **local models only** — no cloud APIs, no token costs.

**Default stack:**
- **Runtime:** Ollama
- **Model:** `qwen2.5-coder:14b` or `codellama:7b`
- **Context window:** 32k tokens
- **Temperature:** 0.1 (deterministic for system tasks)

### 5.2 Prompt Engineering (System Prompt)

```
You are the AIMAS Semantic Interpreter. Your job is to read Markdown
intent documents and extract structured capability requirements.

Rules:
1. NEVER hallucinate tools. Only use the known capability map.
2. Convert vague descriptions into specific package names.
3. Identify version constraints.
4. Flag conflicting requirements.
5. Output valid JSON only.

Known capabilities include:
- ai-llm: ollama, llama.cpp, gpt4all, localai
- video: ffmpeg, obs-studio, kdenlive, shotcut
- audio: audacity, lmms, supercollider
- image: gimp, inkscape, blender, krita
- dev: docker, kubectl, terraform, ansible
- scrape: scrapy, selenium, playwright, beautifulsoup4
- shell: zsh, tmux, starship, zoxide
```

### 5.3 Output Format: Capability Graph

```json
{
  "intent_id": "sha256_of_markdown",
  "source": "~/.config/aimas/intent/workstation.md",
  "extracted_capabilities": [
    {
      "capability": "local-llm-inference",
      "confidence": 0.98,
      "tools": [
        {"name": "ollama", "required": true, "version": ">=0.3.0"},
        {"name": "llama3.1:8b", "required": true, "type": "model"}
      ]
    },
    {
      "capability": "video-editing",
      "confidence": 0.95,
      "tools": [
        {"name": "ffmpeg", "required": true},
        {"name": "kdenlive", "required": false}
      ]
    }
  ],
  "config_overrides": {
    "shell": "zsh",
    "theme": "powerlevel10k"
  }
}
```

---

## 6. Layer 3: Environment Scanner

### 6.1 State Detection

The scanner builds a **System State Graph** (SSG) by probing:

```python
class SystemState:
    os_type: str           # linux, darwin, windows
    os_version: str
    arch: str              # amd64, arm64
    package_managers: list # apt, brew, nix, cargo, go, npm...
    installed_bins: dict   # { "ffmpeg": "/usr/bin/ffmpeg", ... }
    service_status: dict   # { "ollama": "active", "docker": "inactive" }
    gpu_available: bool
    cuda_version: str | None
    python_envs: list      # detected venvs, conda envs
```

### 6.2 State Probe Commands

| Check | Command |
|-------|---------|
| OS | `cat /etc/os-release` |
| Arch | `uname -m` |
| GPU | `lspci \| grep -i nvidia` |
| Installed bins | `which ffmpeg docker ollama` |
| Service status | `systemctl is-active ollama` |
| Python venvs | `ls ~/.local/share/aimas/venvs/` |
| Docker | `docker version` |

### 6.3 Dependency Resolution

The scanner resolves a **directed dependency graph**:

```
ollama-service
  ├── ollama-binary
  │     └── curl (already present)
  └── systemd (already present)

ai-ml-venv
  ├── uv (install if missing)
  │     └── curl (already present)
  └── python3 (already present)
```

---

## 7. Layer 4: Actuator

### 7.1 Package Manager Router

The actuator selects the correct install method based on platform and tool:

```python
def route_install(tool: str, platform: str) -> InstallMethod:
    if tool in APT_REGISTRY:
        return AptInstall(tool)
    elif tool in CARGO_REGISTRY:
        return CargoInstall(tool)
    elif tool in PIPX_REGISTRY:
        return PipxInstall(tool)
    elif tool in DOCKER_REGISTRY:
        return DockerInstall(tool)
    elif tool in SCRIPT_REGISTRY:
        return ScriptInstall(tool)
    elif tool == "model":
        return OllamaPull(model=tool)
    else:
        raise UnknownToolError(tool)
```

### 7.2 Convergence Strategy

The actuator uses an **idempotent convergence loop**:

1. **Plan:** Generate ordered install steps from dependency graph
2. **Dry-run:** Preview commands (if `auto_execute: false`)
3. **Execute:** Run each step, capturing stdout/stderr
4. **Verify:** Re-run state probes to confirm convergence
5. **Retry:** On failure, retry with backoff (max 3 attempts)
6. **Report:** Write results to `~/.local/share/aimas/log/`

### 7.3 Rollback Capability

Every mutation is logged with a **reverse operation**:

```json
{
  "mutation_id": "uuid",
  "timestamp": "2026-05-11T12:00:00Z",
  "operation": "apt_install",
  "target": "kdenlive",
  "reverse": "sudo apt remove kdenlive -y",
  "state_before": { ... },
  "state_after": { ... }
}
```

---

## 8. Daemon Mode

### 8.1 Continuous Watch

When running as a daemon, the scanner:

1. **Watches** intent directories via `inotify` / `fsevents`
2. **Scans** all `.md` files every `convergence_interval` seconds
3. **Diffs** current intent against previous hash
4. **Converges** only when intent changes

### 8.2 systemd Unit File

```ini
# /etc/systemd/system/aimas-scanner.service
[Unit]
Description=AIMAS Intent Scanner Daemon
After=network.target ollama.service

[Service]
Type=simple
ExecStart=/usr/local/bin/aimas-scanner --daemon --watch ~/.config/aimas/intent
Restart=always
RestartSec=10
User=%I

[Install]
WantedBy=multi-user.target
```

### 8.3 CLI Interface

```bash
# One-shot convergence
aimas-scanner --converge ~/.config/aimas/intent/workstation.md

# Daemon mode
aimas-scanner --daemon --watch ~/.config/aimas/intent

# Dry run (preview only)
aimas-scanner --dry-run ~/.config/aimas/intent/workstation.md

# Check convergence status
aimas-scanner --status

# Force re-convergence
aimas-scanner --force-converge

# Rollback last mutation
aimas-scanner --rollback
```

---

## 9. Configuration

### 9.1 Global Config: `~/.config/aimas/config.yaml`

```yaml
aimas_version: "0.1.0"

interpreter:
  backend: ollama
  model: qwen2.5-coder:14b
  temperature: 0.1
  context_window: 32768

scanner:
  watch_paths:
    - ~/.config/aimas/intent
  poll_interval: 300
  ignore_patterns:
    - "*.tmp"
    - "*.draft.md"

actuator:
  auto_execute: true
  dry_run_first: false
  max_retries: 3
  parallel_limit: 4
  package_managers:
    priority: [apt, uv, pipx, cargo, go, npm, docker]

logging:
  level: info
  path: ~/.local/share/aimas/logs
  max_size: 100MB
  max_files: 10

convergence:
  verify_timeout: 300
  rollback_on_failure: false
```

### 9.2 Local Override: `./.aimas/config.yaml`

Project-specific overrides take precedence over global config.

---

## 10. Example Intent Documents

### 10.1 Minimal Workstation

```markdown
---
aimas_version: "0.1.0"
auto_execute: true
---

# Minimal Dev Workstation

Requires:
- neovim
- git
- docker
- python >= 3.10
```

### 10.2 Creative AI Mega-Station

```markdown
---
aimas_version: "0.1.0"
platform: linux
gpu: true
---

# Creative AI Mega-Station

## Capabilities

### Video Production
- obs-studio
- kdenlive
- ffmpeg
- handbrake

### Audio & Music
- audacity
- lmms
- supercollider

### AI / ML
- ollama
  - models: [llama3.1:8b, qwen2.5-coder:14b, codellama:7b]
- comfyui
- invokeai

### Scraping & Research
- scrapy
- playwright
- yt-dlp

### Print-on-Demand
- gimp
- inkscape
- blender

## Desktop Customization
- shell: zsh
- prompt: starship
- file_manager: ranger

## Automation
```aimas-run
# Custom pipeline scripts
cp ./scripts/render_pipeline.sh ~/.local/bin/
```
```

### 10.3 Content Creator Profile

```markdown
---
aimas_version: "0.1.0"
---

# Content Creator Profile

I need to:
1. Record my screen and stream
2. Edit videos quickly
3. Generate thumbnails with AI
4. Scrape trending topics
5. Automate social media uploads

## Result
The daemon should install:
- OBS Studio + plugins
- Shotcut / Kdenlive
- ComfyUI (for thumbnail gen)
- Scrapy + Selenium
- rclone (for upload automation)
```

---

## 11. Security Model

### 11.1 Threat Surface

| Threat | Mitigation |
|--------|-----------|
| Malicious Markdown | Read-only scanner; manual approval for `auto_execute: false` |
| Supply chain attacks | Checksums for scripts; signed apt repos |
| Privilege escalation | Drop to user context; sudo only for apt |
| Rollback attacks | Immutable mutation log; signed snapshots |

### 11.2 Approval Matrix

| Action | auto_execute=true | auto_execute=false |
|--------|-------------------|--------------------|
| apt install | ✅ Auto | ⏸️ Prompt |
| docker run | ✅ Auto | ⏸️ Prompt |
| curl \| bash | ⏸️ Always prompt | ⏸️ Always prompt |
| rm -rf | ❌ Never | ❌ Never |
| chsh | ⏸️ Prompt | ⏸️ Prompt |

---

## 12. Implementation Roadmap

### Phase 1: Foundation (Week 1-2)
- [ ] Python/Go scanner binary
- [ ] Markdown parser (YAML frontmatter + code blocks)
- [ ] State scanner (bash probes)
- [ ] Basic apt/cargo/pipx actuator

### Phase 2: Intelligence (Week 3-4)
- [ ] Ollama integration for semantic interpretation
- [ ] Capability graph resolver
- [ ] Dependency resolution engine

### Phase 3: Daemon (Week 5-6)
- [ ] inotify file watcher
- [ ] systemd unit generator
- [ ] Continuous convergence loop
- [ ] Mutation logging & rollback

### Phase 4: Polish (Week 7-8)
- [ ] TUI dashboard (using gum / bubbletea)
- [ ] GitHub integration (pull intent from repos)
- [ ] Self-updating capability
- [ ] Comprehensive test suite

---

## 13. Glossary

| Term | Definition |
|------|-----------|
| **Intent** | A human-readable description of desired system state |
| **Capability** | A high-level function (e.g., "video editing") |
| **Convergence** | The process of mutating system state to match intent |
| **SSG** | System State Graph — a snapshot of installed tools and versions |
| **Mutation** | A single change to system state (install, config, removal) |
| **Actuator** | The component that executes shell commands |
| **Interpreter** | The LLM/NLP layer that converts prose to structured requirements |

---

## 14. References

- **AIMAS Bootstrap Script:** `~/Desktop/aimas-bootstrap.sh`
- **Canonical Manifest:** `~/Desktop/aimas-manifest.json`
- **Tool Registry:** `~/Desktop/aimas-repo/tool-list/*.json`
- **Generator:** `~/Desktop/aimas-repo/generator/generate_script.py`
- **Ansible Playbook:** `~/Desktop/aimas-repo/playbooks/install_stack.yml`

---

*"You stop telling the computer how to do things. You tell it what kind of machine it should be."*
