# lingtai — Claude Code Plugin

Connect Claude Code to a [LingTai](https://lingtai.ai) agent network. Read mail from your agents, send instructions, check liveness, and manage the network — all through the shared human mailbox.

> **Other coding agents:** Codex CLI users → [`Lingtai-AI/codex-plugin`](https://github.com/Lingtai-AI/codex-plugin). Anything else → [`Lingtai-AI/lingtai-skill`](https://github.com/Lingtai-AI/lingtai-skill) (the canonical skill — copy into your tool's skill dir).

## Install

```bash
claude plugin marketplace add Lingtai-AI/claude-code-plugin
claude plugin install lingtai@lingtai
```

To upgrade an existing install: `claude plugin marketplace update lingtai && claude plugin update lingtai@lingtai`.

## What you get

- **SessionStart hook** — detects `.lingtai/` projects, reports inbox count and any mail awaiting pickup
- **`lingtai` skill** — tells Claude how to find and follow the network's own entrance:
  - `.lingtai/human/README.md` — the protocol, written by the LingTai kernel (mail, liveness, signals, restarts)
  - `.lingtai/<agent>/SKILL.md` — each agent's description of itself, written by the agent
  - host rules: `via: claude-code` attribution, per-host read tracking, reply monitoring, verifying "done" claims
  - a minimal, tested fallback recipe for projects whose kernel does not write the entrance yet

Because the protocol is read from the project rather than copied into the plugin, the plugin does not go stale when the kernel changes.

## Usage

Once installed, Claude Code auto-detects LingTai projects on session start. Ask it to:

- *"Check my inbox"*
- *"Send a message to the orchestrator: research X"*
- *"Are any agents alive?"*
- *"CPR the orchestrator"*
- *"What's the network status?"*

The skill activates on demand — it won't interrupt your coding unless you ask. In projects without `.lingtai/`, the plugin does nothing.

## Deeper reference

Each agent carries the kernel's manuals at `.lingtai/<agent>/.library/intrinsic/capabilities/<skill>/SKILL.md` (for example `lingtai-kernel-anatomy`, `email`, `system-manual`), and the LingTai TUI installs guides at `~/.lingtai-tui/utilities/` (for example `lingtai-tutorial-guide`, `lingtai-portal-guide`, `lingtai-tui-anatomy`). The skill points Claude at these when you ask how LingTai works.

**For plugin developers**: `skills/lingtai/SKILL.md` is **vendored from the canonical [`Lingtai-AI/lingtai-skill`](https://github.com/Lingtai-AI/lingtai-skill) repo**. Do not edit it here — edit it upstream and run `scripts/sync-from-canonical.sh` to pull the latest.

## Requirements

- A LingTai project (`.lingtai/` directory with agents)
- Python 3 (for message ids and timestamps in the fallback recipe)

## License

Apache-2.0
