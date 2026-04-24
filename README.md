# lingtai — Claude Code Plugin

Connect Claude Code to a [LingTai](https://lingtai.ai) agent network. Read mail from your agents, send instructions, check liveness, and manage the network — all through the shared human mailbox.

> **Not using Claude Code?** See [lingtai-mailbox-skill](https://github.com/Lingtai-AI/lingtai-mailbox-skill) for OpenCode, Codex CLI, Hermes, and other coding agents.

## Install

```bash
claude plugin add Lingtai-AI/claude-code-plugin
```

## What you get

- **SessionStart hook** — detects `.lingtai/` projects, reports inbox count and any mail awaiting pickup
- **`lingtai` skill** — full reference for the filesystem mailbox protocol:
  - Send mail via the human's outbox (pseudo-agent model — agents poll and claim)
  - Read incoming mail with threading via `in_reply_to`
  - Agent discovery and orchestrator identification
  - Liveness checks (heartbeat)
  - Lifecycle management — sleep, suspend, CPR, refresh, clear
  - Signal files — prompt injection, soul inquiry
  - Delivery + reply monitoring with the Monitor tool
  - Read tracking across sessions (`.last_read_cc`)
  - **Remote networks via SSH** — read/send mail, discover agents, check liveness, manage lifecycle, and monitor remote `.lingtai/` directories over SSH

## Usage

Once installed, Claude Code auto-detects LingTai projects on session start. Ask it to:

- *"Check my inbox"*
- *"Send a message to the orchestrator: research X"*
- *"Are any agents alive?"*
- *"CPR the orchestrator"*
- *"What's the network status?"*
- *"Connect to my remote at zesen@lab:/home/zesen/project/.lingtai"*
- *"Check inbox on the lab server"*
- *"Send 'hello' to the orchestrator on my remote"*

The skill activates on demand — it won't interrupt your coding unless you ask. In projects without `.lingtai/`, the plugin does nothing.

## Related skills

The `lingtai` skill in this plugin is the **integration protocol** — how Claude talks to the mailbox. For deeper reference about the agent runtime itself, Claude should load the skills that ship with the LingTai TUI. When the TUI (`lingtai-tui`) is installed, these live at `~/.lingtai-tui/bundled-skills/`:

| Skill | Location | What it covers |
|-------|----------|---------------|
| **lingtai-anatomy** | `~/.lingtai-tui/bundled-skills/lingtai-anatomy/SKILL.md` | Memory system, filesystem layout, runtime anatomy (turn loop, state machine, signals, molt, mail atomicity) |
| **lingtai-tutorial-guide** | `~/.lingtai-tui/bundled-skills/lingtai-tutorial-guide/SKILL.md` | How LingTai works — concepts, philosophy, lessons |
| **lingtai-portal-guide** | `~/.lingtai-tui/bundled-skills/lingtai-portal-guide/SKILL.md` | Portal API endpoints, topology recording, replay |
| **lingtai-recipe** | `~/.lingtai-tui/bundled-skills/lingtai-recipe/SKILL.md` | Behavioral recipes, network cloning, export/import |
| **lingtai-mcp** | `~/.lingtai-tui/bundled-skills/lingtai-mcp/SKILL.md` | MCP server configuration for agents |
| **lingtai-changelog** | `~/.lingtai-tui/bundled-skills/lingtai-changelog/SKILL.md` | Breaking changes, renames, migrations |

The plugin doesn't bundle these skills — they're maintained in the [main LingTai repo](https://github.com/Lingtai-AI/lingtai) under `tui/internal/preset/skills/` and populated to `~/.lingtai-tui/bundled-skills/` on TUI install. If you use this plugin, the TUI is installed, so this path exists. When deeper information about LingTai internals is needed, Claude should `Read` the relevant file from that location — the plugin's own `lingtai` skill references this path as its authoritative fallback.

**For plugin developers**: the source of the integration skill is `skills/lingtai/SKILL.md` in this repo. The anatomy and other reference skills live upstream — edit them in the main lingtai repo, not here.

## Requirements

- A running LingTai project (`.lingtai/` directory with agents)
- Python 3 (for UUID generation and liveness checks)
- SSH keys configured for remote networks (`ssh-copy-id user@host`)
- `lingtai-tui` installed (populates `~/.lingtai-tui/bundled-skills/` with the reference skills above)

## License

MIT
