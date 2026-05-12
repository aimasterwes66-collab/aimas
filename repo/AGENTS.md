# AIMAS — Agent Guidance

Declarative workstation bootstrapper. JSON tool manifests → generated bash/ansible install scripts.

## Repo Layout

- `tool-list/<category>-tools.json` — canonical tool definitions (video, ai, dev)
- `generator/generate_script.py` — reads JSON manifests, emits install scripts
- `scripts/install.sh` — pre-generated sample bash script (hand-written, not auto-generated)
- `playbooks/install_stack.yml` — comprehensive hand-written Ansible playbook

## Adding or Updating Tools

1. Edit `tool-list/<category>-tools.json`
2. Entry schema: `name`, `description`, `install_methods` (map of platform → `{command, dependencies}`), `platforms`, `category`, `tags`
3. Regenerate:
   ```bash
   python3 generator/generate_script.py \
     --platform apt \
     --categories video,ai,dev \
     --format bash \
     --output scripts/install_generated.sh
   ```
4. Default output path (if `--output` omitted): `scripts/install_generated.{sh,yml}`

## Generator Fallback Order

If the requested platform is missing, `generate_script.py` falls back in this order:
`apt` → `script` → `pipx` → `cargo` → `brew` → `docker` → `binary`

## Running Installers

- **Generated bash**: `bash scripts/install_generated.sh`
- **Ansible playbook** (hand-written, more complete than generated):
  ```bash
  ansible-playbook -i localhost, -c local playbooks/install_stack.yml
  ```
  Use Ansible tags for selective runs: `--tags base,ai,shell,docker`

## Design Constraints

- **CPU-only** — no GPU drivers or CUDA assumed
- **Python 3 stdlib only** — generator has zero external dependencies
- **Isolated Python** — `uv` for venvs, `pipx` for CLI tools; avoid global `pip`
- **Linux/apt primary** — brew/nix/docker methods exist but are secondary
- **Idempotent** — scripts and playbooks use `command -v` checks before installing

## What Not to Touch

- `scripts/install.sh` is a static sample. Editing it directly is fine for quick edits, but prefer updating the JSON source and regenerating so other outputs stay in sync.
- The Ansible playbook is hand-written and much more comprehensive than the generated one. Do not expect `generate_script.py` to reproduce it.
