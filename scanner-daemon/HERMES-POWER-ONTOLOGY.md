# Hermes Agent — Power User Ontology
## 9-Part, 12-Point Recursive Self-Improvement Framework

> **Version:** 1.0.0  
> **Target:** Hermes CLI (Nous Research) + local llama.cpp/Ollama backends  
> **Goal:** Transform Hermes from a chat tool into a self-improving autonomous agent system

---

## Part I: Foundation Architecture (The 12 Base Layers)

1. **Provider Topology** — Multi-provider failover (Ollama → llama.cpp server → OpenRouter → Gemini Bridge)
2. **Model Registry** — Local GGUF catalog with auto-selection by task type (code, creative, reasoning)
3. **Context Budgeting** — Dynamic token allocation: 30% system, 50% conversation, 20% tool output
4. **Thread Pool Management** — CPU-optimized thread counts per model size (7B=4 threads, 27B=10 threads)
5. **KV Cache Strategy** — Flash Attention ON, mmap OFF for deterministic performance, cache type f16
6. **Batch Size Calibration** — Prompt batch=512, generation batch=1 for streaming, ubatch matching
7. **Memory Locking** — mlock enabled to prevent swap thrashing on large models
8. **Quantization Ladder** — Auto-downgrade chain: Q8→Q6→Q5→Q4 based on available RAM
9. **System Prompt Engineering** — Multi-layer persona stack: base + roleplay + tool persona + safety
10. **Temperature Scheduling** — High temp (0.9) for ideation, low temp (0.3) for code, adaptive mid-range
11. **Repetition Penalty Tuning** — Scale 1.1–1.2 for creative, 1.05 for technical, disable for poetry
12. **Endpoint Health Monitoring** — Heartbeat checks every 30s, auto-failover on timeout

---

## Part II: Skills Framework (The 12 Upgrades)

1. **Skill Discovery Protocol** — Auto-scan `~/.hermes/skills/` for new YAML definitions on startup
2. **Hot-Reload System** — Watch skills directory with inotify, reload without restarting agent
3. **Skill Dependency Graph** — DAG resolver for interdependent skills (web → scraper → parser)
4. **Skill Sandboxing** — Each skill runs in isolated subprocess with timeout and resource limits
5. **Parameter Injection** — Environment variables + config interpolation into skill templates
6. **Output Schema Enforcement** — JSON Schema validation on all skill returns before passing to LLM
7. **Skill Chaining** — Compositional pipelines: `skill-a | skill-b | skill-c` syntax in prompts
8. **Conditional Execution** — Guard clauses: `if: context.has("url") then: run fetch skill`
9. **Skill Versioning** — Semantic versioning with rollback capability (keep last 3 versions)
10. **Performance Telemetry** — Log latency, token count, success rate per skill invocation
11. **Skill Market** — Git submodule system for community skills (pull from `hermes-skills` org)
12. **Fallback Degradation** — Graceful degradation: if skill fails, fall back to LLM raw reasoning

---

## Part III: MCP Server Integration (The 12 Protocols)

1. **MCP Discovery** — Auto-detect MCP servers via `mcp.json` in project root or `~/.config/mcp/`
2. **Transport Layer** — Support stdio, SSE, and HTTP transports with keepalive heartbeat
3. **Tool Schema Registration** — Parse `tools/list` and register as Hermes native capabilities
4. **Argument Validation** — JSON Schema validation before sending to MCP server (fail fast)
5. **Result Piping** — MCP tool output feeds directly into next LLM prompt as function result
6. **Parallel Tool Calls** — Execute independent MCP tools concurrently, aggregate results
7. **Error Propagation** — MCP errors bubble up as structured `tool_error` messages to LLM
8. **Server Lifecycle** — Auto-start MCP servers on demand, kill after idle timeout (5 min)
9. **Authentication Bridge** — Pass through API keys from Hermes `.env` to MCP servers securely
10. **Capability Negotiation** — Version handshake: Hermes declares v1.0, server responds with supported features
11. **Resource Templating** — Dynamic resource URIs: `file://{workspace}/src/main.py` resolved at runtime
12. **MCP Debugging Mode** — `--mcp-trace` flag logs all MCP requests/responses for troubleshooting

---

## Part IV: Recursive Self-Improvement (The 12 Loops)

1. **Reflection Prompts** — After every 5 turns, inject: "Review your performance. What could improve?"
2. **Context Compression Audit** — When compression triggers, log what was lost and why
3. **Tool Use Optimization** — Track which tools succeeded/failed, weight future tool selection by accuracy
4. **Model Self-Selection** — Meta-prompt chooses between local (fast) and cloud (smart) based on task difficulty
5. **Prompt Evolution** — Store successful prompts, mutate variants, A/B test against baseline
6. **Session Summarization** — End-of-session digest: key decisions, errors, improvements for next time
7. **Knowledge Accumulation** — Write persistent notes to `~/.hermes/memory/` between sessions
8. **Skill Auto-Generation** — If LLM performs same 3-step task 5 times, offer to create skill from pattern
9. **Error Pattern Recognition** — Classify failures: syntax error → code skill, timeout → network skill, hallucination → search skill
10. **Reward Modeling** — Implicit reward: user says "thanks" = positive, user repeats question = negative
11. **Checkpoints** — Save session state every 10 turns, allow `--resume` from any checkpoint
12. **Self-Modification Guardrails** — Agent can suggest config changes but requires user approval via `hermes doctor --apply`

---

## Part V: Deployment Architecture (The 12 Topologies)

1. **Single-User Local** — Default: Hermes + Ollama on localhost, no network exposure
2. **LAN Team Server** — Hermes gateway on 0.0.0.0:5000, shared Ollama backend, auth via API keys
3. **Headless Daemon** — `hermes gateway run --daemon`, systemd-managed, logs to journald
4. **Docker Containerization** — Multi-stage build: Hermes + Ollama in one container, models in volume
5. **Reverse Proxy Integration** — Nginx/Caddy SSL termination, rate limiting, upstream to Hermes
6. **Load Balancing** — Multiple Ollama backends behind HAProxy, round-robin model selection
7. **GitOps Workflow** — Hermes config in Git, CI/CD deploys to server, `hermes config check` on PR
8. **Environment Isolation** — Dev/staging/prod configs via `HERMES_ENV` variable and `.env.{env}` files
9. **Secret Management** — API keys in HashiCorp Vault or Doppler, injected at runtime
10. **Monitoring Stack** — Prometheus metrics endpoint, Grafana dashboard for token throughput/latency
11. **Backup Strategy** — Daily backup: `~/.hermes/` → S3, model cache excluded (too large)
12. **Rollback Procedure** — `hermes checkpoint restore` or systemd `ExecStopPost` cleanup on failure

---

## Part VI: Tooling & Automation (The 12 Automations)

1. **Cron Integration** — `hermes cron add "0 9 * * *" "summarize yesterday's commits"`
2. **File Watchers** — `hermes watch ./src "review diff on file change"`
3. **Webhook Endpoints** — `hermes webhook --port 8082` for GitHub/Slack triggering
4. **Clipboard Integration** — `--clipboard` flag processes current clipboard content as prompt
5. **Screenshot Pipeline** — `--screenshot` captures screen, sends to vision model (via mmproj)
6. **TTS/STT Loop** — `--voice` mode: speech in → text → LLM → speech out (piper + whisper)
7. **Terminal Integration** — Shell completion, `Ctrl+H` hotkey for "explain this command"
8. **IDE Bridge** — LSP mode: `hermes lsp` provides AI completions to Neovim/VS Code
9. **Git Hook Automation** — Pre-commit: lint + review. Post-commit: generate changelog
10. **Database Connectors** — PostgreSQL, SQLite, ChromaDB skills for RAG and structured queries
11. **Browser Automation** — Playwright skill for web scraping, form filling, screenshot comparison
12. **CI/CD Runner** — `.hermes-ci.yml` in repo: auto-review PRs, run tests, deploy on merge

---

## Part VII: Memory & RAG (The 12 Dimensions)

1. **Short-Term Buffer** — Current session context, uncompressed until threshold
2. **Working Memory** — Compressed summary of last 20 messages (20% of threshold preserved)
3. **Episodic Memory** — Past session summaries stored in `~/.hermes/memory/episodes/`
4. **Semantic Memory** — Vector embeddings of key facts in ChromaDB for similarity retrieval
5. **Procedural Memory** — Successful skill patterns stored as reusable templates
6. **Knowledge Graph** — Entities and relations extracted from conversations, queryable via Cypher
7. **Document Ingestion** — `--ingest` flag: PDF → text → chunks → embeddings → ChromaDB
8. **Contextual Retrieval** — RAG: retrieve top-5 relevant chunks based on current prompt embedding
9. **Memory Consolidation** — Nightly job: compress old episodes, update knowledge graph
10. **Memory Forgetting** — LRU eviction for low-salience memories, user can pin important ones
11. **Cross-Session Recall** — `hermes remember "that docker thing"` searches all past sessions
12. **Memory Visualization** — `hermes memory graph` exports knowledge graph to Graphviz DOT

---

## Part VIII: Safety & Alignment (The 12 Guardrails)

1. **Sandboxing** — File system: chroot to workspace. Network: allowlist domains. Execution: timeout + kill
2. **Output Filtering** — PII detection (regex + NER), auto-redact before storing or sending
3. **Rate Limiting** — Per-user token quotas, per-model concurrency limits, cooldown periods
4. **Approval Gates** — `--confirm-dangerous` flag: prompts user before rm, curl | bash, sudo
5. **Audit Logging** — Every action logged to `~/.hermes/audit/` with user, timestamp, command, result
6. **Model Behavior Monitoring** — Detect drift: if model starts refusing safe tasks, alert and reconfigure
7. **Backup Before Mutation** — Auto-git-commit before file modifications, allow `hermes undo`
8. **Network Isolation** — `--offline` mode: no outbound requests, local models and tools only
9. **Data Residency** — `--local-only` flag: no cloud providers, all processing on-device
10. **Secret Scanning** — Pre-commit hook: scan for API keys, passwords, tokens in generated output
11. **Hallucination Detection** — Fact-check citations, verify URLs, cross-reference with search skill
12. **Kill Switch** — `hermes stop` immediately halts all running agents, kills subprocesses, releases locks

---

## Part IX: Meta-System Operations (The 12 Meta-Loops)

1. **Config as Code** — Entire Hermes state declarative in `hermes.yaml` + `skills/` + `memory/`
2. **Self-Healing** — If config corrupted, restore from last known good checkpoint automatically
3. **Auto-Update** — `hermes update --check` weekly, apply patch releases silently, major releases with changelog
4. **Plugin Architecture** — Load custom Python modules from `~/.hermes/plugins/` at runtime
5. **Event Bus** — Internal pub/sub: `model.completed`, `tool.failed`, `session.ended` for reactive automation
6. **State Machine** — Agent states: idle → planning → executing → reviewing → idle, with transitions logged
7. **Metrics Export** — Prometheus-compatible `/metrics` endpoint for external monitoring
8. **A/B Testing** — Run two model configs in parallel, compare outputs, auto-promote winner
9. **Distributed Mode** — Multiple Hermes instances share ChromaDB + Redis for collective memory
10. **Simulation Mode** — `--dry-run --simulate` predicts actions without executing, shows plan
11. **Ontology Versioning** — This document versioned in Git, Hermes can query its own capabilities schema
12. **Recursive Bootstrapping** — Hermes can read this ontology, suggest improvements, and propose PRs

---

## Quick Reference: Hermes + Local LLM Commands

```bash
# Start with local model
hermes config set model.provider ollama-launch
hermes config set model.default gemma4-local
hermes -z "Hello" chat

# Use llama.cpp server directly
hermes config set model.provider openai
hermes config set model.base_url http://127.0.0.1:8081/v1
hermes config set model.default Gemma-4-E4B-Uncensored-HauhauCS-Aggressive-Q4_K_M.gguf

# Enable MCP
hermes mcp add filesystem npx -y @modelcontextprotocol/server-filesystem /home/user
hermes mcp add fetch npx -y @modelcontextprotocol/server-fetch

# Recursive self-improvement mode
hermes -z "Review your last 5 sessions. Suggest 3 config improvements." chat

# Dry-run simulation
hermes --dry-run -z "Delete all files in /tmp/old" chat
```

---

*"The agent that understands its own architecture can improve it."*
