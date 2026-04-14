---
name: lingtai
description: Interact with LingTai agents through the shared human mailbox. Read and send mail, discover agents, check liveness, manage agent lifecycle (sleep/suspend/cpr/refresh), and set up adaptive mail polling. Use this when the user asks about their agents, wants to check mail, or manage the agent network.
version: 0.1.0
---

# LingTai — Claude Code Integration

You are connected to a LingTai agent network. You share the human's identity and mailbox. This skill teaches you how to interact with the network using your native file tools.

## Your Identity

You are the human. Your directory is `.lingtai/human/`. Your mailbox is `.lingtai/human/mailbox/`. You do not have a separate agent identity — you are another interface the human uses to interact with their agents, like checking email from a different device.

When you send mail, add `"via": "claude-code"` to the identity block so messages can be attributed to you vs the TUI.

## Reading Mail

Scan for messages:

```
Glob: .lingtai/human/mailbox/inbox/*/message.json
```

Each `message.json` contains:

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | UUID |
| `from` | string | Sender address (e.g. "orchestrator") |
| `to` | string or array | Recipient address(es) |
| `subject` | string | Subject line |
| `message` | string | Body text |
| `received_at` | string | RFC3339 timestamp |
| `identity` | object | Sender's manifest snapshot |

Sort by `received_at` (RFC3339 strings sort lexicographically). Present a summary to the user: sender, subject, time, and first line of the message.

Sent mail is at `.lingtai/human/mailbox/sent/*/message.json`.

## Sending Mail

To send mail, write `message.json` to **both** the recipient's inbox and your sent folder:

1. Generate a UUID (use `python3 -c "import uuid; print(uuid.uuid4())"`)
2. Create the message JSON
3. Write to `.lingtai/<recipient>/mailbox/inbox/<uuid>/message.json`
4. Write the same file to `.lingtai/human/mailbox/sent/<uuid>/message.json`

Message template:

```json
{
  "id": "<uuid>",
  "_mailbox_id": "<uuid>",
  "from": "human",
  "to": "<recipient-address>",
  "cc": [],
  "subject": "<subject>",
  "message": "<body>",
  "type": "normal",
  "received_at": "<current RFC3339 timestamp>",
  "attachments": [],
  "identity": {
    "agent_name": "human",
    "admin": null,
    "via": "claude-code"
  }
}
```

Generate the timestamp with: `python3 -c "from datetime import datetime, timezone; print(datetime.now(timezone.utc).isoformat())"`

## Agent Discovery

Find all agents:

```
Glob: .lingtai/*/.agent.json
```

Read each `.agent.json` to see: `agent_name`, `state`, `address`, `admin`, `capabilities`, `nickname`.

The **orchestrator** is the agent whose `admin` field is a JSON object with at least one truthy boolean value (e.g. `{"karma": true}`). This is the primary agent the human interacts with.

**IMPORTANT: Always send mail to the orchestrator, not directly to other agents.** The orchestrator manages the network — it delegates work to other agents internally. Sending mail to non-orchestrator agents bypasses the orchestrator's coordination and can cause confusion. Think of it like emailing a team lead, not individual team members.

`admin: null` = human. `admin: {"karma": false, "nirvana": false}` = regular (non-orchestrator) agent.

## Checking Agent Liveness

Read `.lingtai/<agent>/.agent.heartbeat`. It contains a unix timestamp as a float (e.g. `1744567890.123456`).

To check if alive:

```bash
python3 -c "import time; t=float(open('.lingtai/<agent>/.agent.heartbeat').read().strip()); print('ALIVE' if time.time()-t < 3 else 'DEAD', f'({time.time()-t:.1f}s ago)')"
```

- Result < 3 seconds → agent is alive
- Result >= 3 seconds → agent is dead (effectively SUSPENDED)
- File missing → agent is dead

Human is always alive (no heartbeat check needed).

## Agent Lifecycle Management

### Finding the Right Python

Before launching agents, resolve the correct Python interpreter:

1. Read the agent's `init.json` → look for `venv_path` field → use `<venv_path>/bin/python`
2. If not found, try `~/.lingtai-tui/runtime/venv/bin/python`
3. If not found, fall back to `python3` on PATH

Verify it works: `<python> -c "import lingtai; print(lingtai.__version__)"`

### Sleep

Write an empty `.sleep` file to the agent's directory. The agent detects it on next heartbeat cycle and enters sleep mode.

```bash
touch .lingtai/<agent>/.sleep
```

To sleep all agents: iterate over all discovered agents (skip human), write `.sleep` to each alive one.

### Suspend

Write an empty `.suspend` file. The agent terminates gracefully.

```bash
touch .lingtai/<agent>/.suspend
```

To suspend all: same as sleep all, but write `.suspend` instead.

### CPR (Resurrect)

Launch the agent process in the background:

```bash
<python> -m lingtai run .lingtai/<agent>/ >> .lingtai/<agent>/logs/agent.log 2>&1 &
```

Only CPR agents that are not alive (heartbeat stale or missing).

### Refresh (Restart)

A full restart that reloads from init.json:

1. Write `.suspend` to the agent directory
2. Poll `.lingtai/<agent>/.agent.lock` every 500ms — wait for it to disappear (or timeout after 60s)
3. If lock file persists after 60s, remove it manually (process likely died)
4. Remove the `.suspend` file
5. Launch the agent: `<python> -m lingtai run .lingtai/<agent>/ >> .lingtai/<agent>/logs/agent.log 2>&1 &`

### Clear (Wipe History + Restart)

Same as refresh, but also delete `history/chat_history.jsonl` before relaunching. The token ledger (`logs/token_ledger.jsonl`) is preserved.

## Signals

You can send signals to agents by writing files:

| Signal | File | Content | Effect |
|--------|------|---------|--------|
| Sleep | `.sleep` | empty | Agent enters sleep mode |
| Suspend | `.suspend` | empty | Agent terminates gracefully |
| Prompt | `.prompt` | text | Injected as `[system]` message |
| Inquiry | `.inquiry` | `<source>\n<question>` | Triggers soul introspection |

For `.inquiry`, source is `"human"` or `"insight"`. Only one inquiry can be pending at a time — no-op if `.inquiry` or `.inquiry.taken` already exists.

For `.prompt`, write the full text content you want the agent to receive as a system message.

## Adaptive Mail Polling

When you are expecting a reply from an agent (you just sent mail or asked a question):

```
/loop 10s check .lingtai/human/mailbox/inbox/ for new messages and report any new ones
```

For background awareness during normal coding work:

```
/loop 5m check .lingtai/human/mailbox/inbox/ for new messages and report any new ones
```

Stop the polling loop when:
- The expected reply arrives
- The user says to stop
- The user ends the conversation

## Opening the Portal (Viz)

To show the network visualization:

1. Read `.lingtai/.port` to get the portal's port number
2. Open `http://localhost:<port>` in the browser

If `.lingtai/.port` doesn't exist, the portal is not running. Inform the user they can start it with `lingtai-portal` in the project directory.

## Reference Skills

The directory `.lingtai/.skills/` contains detailed reference skills. When you need deeper information about LingTai, read these files — they are authoritative and always up to date:

| Skill | Path | What it covers |
|-------|------|---------------|
| **Tutorial Guide** | `intrinsic/lingtai-tutorial-guide/` | How LingTai works — concepts, philosophy, lessons |
| **Anatomy** | `intrinsic/lingtai-anatomy/` | Full .lingtai/ directory structure, file formats |
| **Portal Guide** | `intrinsic/lingtai-portal-guide/` | Portal API endpoints, topology recording, replay |
| **Recipe** | `intrinsic/lingtai-recipe/` | Behavioral recipes and network cloning |
| **MCP** | `intrinsic/lingtai-mcp/` | MCP server configuration for agents |
| **Export Network** | `intrinsic/lingtai-export-network/` | Network export format |
| **Skills Manual** | `intrinsic/skills-manual/` | How the skills system works |

**If the user asks about LingTai or how anything works, always read the relevant skill first before answering.** These skills contain the complete, current documentation. Do not guess — read the source.
