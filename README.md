# lingtai — Claude Code Plugin

Connect Claude Code to a [LingTai](https://lingtai.ai) agent network. Read mail from your agents, send instructions, check liveness, and manage the network — all through the shared human mailbox.

> **Not using Claude Code?** See [lingtai-mailbox-skill](https://github.com/Lingtai-AI/lingtai-mailbox-skill) for OpenCode, Codex CLI, Hermes, and other coding agents.

## Install

```bash
claude plugin add Lingtai-AI/claude-code-plugin
```

## What you get

- **SessionStart hook** — detects `.lingtai/` projects and reports inbox count
- **`lingtai` skill** — full reference for the filesystem mailbox protocol:
  - Read and send mail (with threading via `in_reply_to`)
  - Agent discovery and orchestrator identification
  - Liveness checks (heartbeat)
  - Lifecycle management — sleep, suspend, CPR, refresh, clear
  - Signal files — prompt injection, soul inquiry
  - Reply monitoring with the Monitor tool
  - Read tracking across sessions (`.last_read_cc`)

## Usage

Once installed, Claude Code auto-detects LingTai projects on session start. Ask it to:

- *"Check my inbox"*
- *"Send a message to the orchestrator: research X"*
- *"Are any agents alive?"*
- *"CPR the orchestrator"*
- *"What's the network status?"*

The skill activates on demand — it won't interrupt your coding unless you ask.

## Requirements

- A running LingTai project (`.lingtai/` directory with agents)
- Python 3 (for UUID generation and liveness checks)

## License

MIT
