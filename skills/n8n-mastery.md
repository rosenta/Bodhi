---
skill: n8n-mastery
description: Complete n8n workflow automation knowledge -- installation, pipelines, integrations, CLI, REST API, MCP, web UI, and Project Bodhi-specific workflows
version: 2.0
status: complete
---

# n8n Mastery Skill

> Quick-reference cheat sheet for n8n in the context of Project Bodhi.
> Full implementation guide: `/data/n8n-implementation-guide.md`

## Quick Reference

### What is n8n?
- Open-source workflow automation platform (like Zapier but self-hosted)
- Visual node-based editor for building automation pipelines
- 800+ core nodes, 580+ community nodes (1,396 total)
- Self-hostable (Docker, npm, Railway) or cloud (n8n.io)
- Free self-hosted with unlimited executions; Cloud from EUR 24/mo (2,500 executions)
- Native AI Agent nodes with Claude, OpenAI, Gemini support
- Built-in RAG support with vector store nodes (Pinecone, Qdrant, Supabase pgvector)
- MCP (Model Context Protocol) support for Claude Code integration
- 9,000+ community workflow templates at n8n.io/workflows

### Installation (3 ways)
```bash
# 1. Docker (recommended for production)
docker run -it --rm --name n8n -p 5678:5678 -v n8n_data:/home/node/.n8n docker.n8n.io/n8nio/n8n

# 2. npm (global install)
npm install n8n -g
n8n start

# 3. npx (quick test, no install)
npx n8n

# 4. Railway (production hosting, one-click)
# https://railway.com/deploy/n8n -- $5/mo
```
Access UI at: http://localhost:5678

### CLI Commands
```bash
n8n start                              # Start n8n
n8n start --tunnel                     # Start with webhook tunnel (dev)
n8n execute --id=1                     # Execute workflow by ID (headless)
n8n export:workflow --all --output=./  # Export all workflows to JSON
n8n export:workflow --id=1 --output=w.json  # Export single workflow
n8n import:workflow --input=file.json  # Import workflow from JSON
n8n import:workflow --input=./dir/ --separate  # Import from directory
n8n export:credentials --all --output=./creds/  # Export credentials (encrypted)
n8n import:credentials --input=./creds/         # Import credentials
n8n --version                          # Check version
```

**Docker CLI**: Prefix with `docker exec -it n8n`
**Important**: CLI commands operate on the database; restart n8n after import.

### REST API
```
Base URL: http://localhost:5678/api/v1
Auth: Header "X-N8N-API-KEY: <your-key>"
Swagger UI: http://localhost:5678/api/v1/docs
```

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/workflows` | List all workflows (paginated) |
| POST | `/workflows` | Create workflow (JSON body) |
| GET | `/workflows/:id` | Get single workflow |
| PUT | `/workflows/:id` | Update workflow |
| DELETE | `/workflows/:id` | Delete workflow |
| POST | `/workflows/:id/activate` | Activate workflow |
| POST | `/workflows/:id/deactivate` | Deactivate |
| POST | `/workflows/:id/run` | Trigger a run |
| GET | `/executions` | List past runs (filterable) |
| GET | `/executions/:id` | Get execution details |
| POST | `/executions/:id/retry` | Retry failed execution |
| GET | `/credentials` | List credentials |
| POST | `/credentials` | Create credential |

```bash
# Example: trigger workflow
curl -X POST "http://localhost:5678/api/v1/workflows/1/run" \
  -H "X-N8N-API-KEY: your-key"

# Example: import workflow from file
curl -X POST "http://localhost:5678/api/v1/workflows" \
  -H "X-N8N-API-KEY: your-key" \
  -H "Content-Type: application/json" \
  -d @workflow.json
```

---

## Core Concepts

### Node Types
| Category | Nodes | Use |
|----------|-------|-----|
| **Triggers** | Schedule (Cron), Webhook, Manual, Email Trigger | Start workflows |
| **Actions** | HTTP Request, Code (JS/Python), Send Email | Perform operations |
| **AI** | AI Agent, Chat Anthropic, Chat OpenAI, Embeddings, Vector Store | LLM operations |
| **Logic** | IF, Switch, Merge, Split In Batches, Loop Over Items, Wait | Control flow |
| **Data** | Set, Function, Spreadsheet File, JSON, XML, Crypto | Transform data |
| **Storage** | Supabase, PostgreSQL, MySQL, Google Sheets, Airtable, S3 | Read/write |
| **Comms** | Slack, Discord, Telegram, WhatsApp, Email (SMTP) | Notifications |

### Data Model
- Nodes pass **items** (arrays of `{ json: {...}, binary?: {...} }`)
- Reference data: `{{ $json.field }}` (current), `{{ $('NodeName').first().json.field }}` (other)
- Environment vars: `{{ $env.VARIABLE }}`
- Date/time: `{{ $now.format('yyyy-MM-dd') }}`, `{{ $now.minus({ days: 7 }) }}`

### Workflow Structure
```
Trigger --> Transform --> Process --> Output
   |                        |
   +--- Error Workflow -----+
```

### Credentials System
- Stored **encrypted** in n8n database
- Setup: Left sidebar > Credentials > Add Credential > search service
- Supports: API keys, OAuth2, username/password, header auth
- NOT exported with workflows (security) -- must recreate on new instance
- Encryption key: `N8N_ENCRYPTION_KEY` env var (critical for credential portability)

### Webhook URLs
| Type | Pattern | When Active |
|------|---------|-------------|
| Test | `/webhook-test/<path>` | "Listen for Test Event" clicked (120s timeout) |
| Production | `/webhook/<path>` | Workflow is activated |

- Test mode: shows data in editor UI (for debugging)
- Production mode: runs silently
- Always add auth (Header Auth, Basic Auth, or JWT) in production

### Error Handling
- **Retry On Fail**: Per-node setting (max tries, wait between tries)
- **Continue On Fail**: Node passes error as data to next node
- **Error Workflow**: Separate workflow triggered on failure
- **Critical**: Retry + Continue On Fail = retry is IGNORED (pick one)
- Exponential backoff: Loop + Wait + Set nodes for custom retry logic

---

## Project Bodhi Workflows

### Workflow 1: Daily Verse Pipeline
**File**: `/automation/workflow-daily-verse.json`
**Trigger**: Cron `0 5 * * *` (5 AM IST daily)
```
Schedule Trigger (5 AM)
  --> HTTP Request: Fetch verse from Supabase (daily_verse + verses JOIN)
  --> Code: Parse verse data
  --> Chat Anthropic: Generate 6 content variants (quote, carousel, reel, blog, email, podcast)
  --> Code: Parse JSON into separate items
  --> Supabase: Save 6 content_pieces rows (status: draft)
  --> PARALLEL:
      +-- Filter (podcast) --> ElevenLabs TTS --> Upload to R2
      +-- Filter (quote) --> Canva API --> Upload to R2
  --> Filter (blog) --> HTTP Request: Publish to website
  --> HTTP Request: Schedule social posts via Publer
  --> Discord: Pipeline summary notification
```
**Cost per run**: ~$0.21 (Claude: $0.06, ElevenLabs: $0.15, R2: $0.001)

### Workflow 2: Lesson to Social Adapter
**File**: `/automation/workflow-lesson-adapter.json`
**Trigger**: Webhook POST `/new-lesson`
```
Webhook (new lesson notification)
  --> HTTP Request: Fetch verse data from Supabase
  --> Code: Merge lesson content + verse data
  --> Chat Anthropic: Extract quote card + reel script + Twitter thread
  --> Code: Parse into 3 content items
  --> Supabase: Save 3 content_pieces rows
  --> Code: Generate CMO-LOG entry
  --> Discord: Notification
```
**Cost per run**: ~$0.03

### Workflow 3: Weekly Analytics
**File**: `/automation/workflow-analytics.json`
**Trigger**: Cron `0 9 * * 1` (Monday 9 AM IST)
```
Schedule Trigger (Monday 9 AM)
  --> PARALLEL:
      +-- Instagram Insights (Graph API)
      +-- YouTube Analytics (Data API v3)
      +-- Website Analytics (Plausible)
      +-- Content Performance (Supabase)
  --> Code: Merge all analytics data
  --> Chat Anthropic: Analyze performance + recommend strategy
  --> Code: Format as Markdown report
  --> PARALLEL:
      +-- Supabase: Save to weekly_reports table
      +-- Discord: Send report
```
**Cost per run**: ~$0.04

### Workflow 4: Content Review
**File**: `/automation/workflow-content-review.json`
**Trigger**: Manual or Webhook POST `/review-content`
```
Trigger (manual or webhook with content_piece_id)
  --> HTTP Request: Fetch content piece + verse from Supabase
  --> Code: Prepare review payload
  --> PARALLEL (3 Claude calls):
      +-- Brand Voice Check (pass/fail + issues)
      +-- Sanskrit Accuracy Check (pass/fail + errors)
      +-- Quality Score (1-10 with breakdown)
  --> Code: Combine reviews, calculate decision
  --> IF: All pass AND score >= 7?
      +-- YES: Update status = 'approved' --> Discord: Approved
      +-- NO: Update status = 'in_review' --> Discord: Flagged
```
**Cost per run**: ~$0.02

---

## Integrations for Bodhi

### AI
| Service | Node | Auth | Notes |
|---------|------|------|-------|
| Claude (Anthropic) | Chat Anthropic / AI Agent | API Key (`sk-ant-...`) | Primary LLM. Sonnet for generation, Haiku for review. |
| OpenAI | Chat OpenAI | API Key | Backup LLM. |
| Google Gemini | Chat Google Gemini | API Key / OAuth | Free tier available. |

### Social Media
| Platform | Method | Key Setup |
|----------|--------|-----------|
| Instagram | HTTP Request + Meta Graph API v21.0 | Business/Creator account + long-lived token. Async video processing (poll for completion). 25 posts/day limit. |
| YouTube | HTTP Request + Data API v3 | OAuth2 credentials. Resumable upload. 10K daily quota units. |
| Twitter/X | HTTP Request + X API v2 | Free tier: 1,500 tweets/month. Thread = chain tweet IDs. |
| LinkedIn | HTTP Request + Marketing API | Company Page admin + UGC Posts API. |

### Storage & Database
| Service | Node | Key Setup |
|---------|------|-----------|
| Supabase | Built-in Supabase node | Host (project URL) + service_role key |
| PostgreSQL | Built-in Postgres node | Host + port + db + user + password |
| Cloudflare R2 | AWS S3 node | S3-compatible. Access key + secret + custom endpoint (`<ACCOUNT>.r2.cloudflarestorage.com`). Force path style = true. |
| Google Sheets | Built-in node | OAuth2 |

### Audio/Visual
| Service | Node | Notes |
|---------|------|-------|
| ElevenLabs | Community node (`n8n-nodes-elevenlabs`) or HTTP Request | Install: Settings > Community Nodes. Official node from ElevenLabs. `eleven_multilingual_v2` for Hindi. |
| Canva | HTTP Request + OAuth2 | Requires Canva for Teams. Autofill templates via API. Fallback: generate images programmatically. |

### Communication
| Service | Node | Setup |
|---------|------|-------|
| Discord | Built-in or webhook URL | Simplest: create webhook in Discord channel settings, POST JSON. |
| Slack | Built-in Slack node | OAuth2 app |
| Email | Send Email node | SMTP credentials (Gmail, SendGrid, etc.) |

### Scheduling
| Service | Method | Notes |
|---------|--------|-------|
| Publer | HTTP Request | Full API: schedule posts, get analytics. `https://app.publer.io/api/v1` |
| Buffer | HTTP Request | Simpler API. |

---

## MCP Integration

### Available MCP Servers
| Project | GitHub | What It Does |
|---------|--------|-------------|
| n8n-mcp | czlonkowski/n8n-mcp | 1,396 node definitions, template configs. Deep node documentation for Claude. |
| mcp-n8n-workflow-builder | salacoste/mcp-n8n-workflow-builder | 17 tools. Create/manage/monitor workflows via natural language. Multi-instance support. |
| mcp-n8n-server | ahmadsoliman/mcp-n8n-server | List workflows, trigger webhooks, get info. Lightweight. |

### Setup (mcp-n8n-workflow-builder)
```bash
git clone https://github.com/salacoste/mcp-n8n-workflow-builder.git
cd mcp-n8n-workflow-builder && npm install && npm run build
```

Add to `.mcp.json` or `~/.claude/settings.json`:
```json
{
  "mcpServers": {
    "n8n": {
      "command": "node",
      "args": ["/path/to/dist/index.js"],
      "env": {
        "N8N_HOST": "http://localhost:5678",
        "N8N_API_KEY": "your-n8n-api-key"
      }
    }
  }
}
```

### What MCP Enables
- "Create a workflow that fetches a verse from Supabase every morning"
- "Trigger the daily-verse workflow now"
- "Show me the last 5 executions"
- "Add error handling to the content review workflow"

---

## Web UI Guide

### Key Areas
- **Dashboard**: List/grid of all workflows. Status (active/inactive), last execution, tags.
- **Workflow Editor**: Visual canvas. Drag nodes, connect wires. Click node to configure.
- **Execution History**: All past runs. Click to replay data flow visually. Filter by status/date.
- **Credentials**: Add/edit/test API credentials. Encrypted at rest.
- **Settings**: Timezone, API keys, community nodes, user management.
- **Templates**: 9,000+ pre-built workflows. One-click import.

### Editor Controls
| Action | How |
|--------|-----|
| Add node | Click "+" or press Tab |
| Run workflow | Ctrl/Cmd + Enter |
| Run single node | Click play on node |
| Save | Ctrl/Cmd + S |
| Undo | Ctrl/Cmd + Z |
| Pan canvas | Space + drag |
| Zoom | Scroll wheel |
| Activate | Toggle switch (top-right) |
| Test webhook | "Listen for Test Event" button |

---

## Environment Variables

```bash
# n8n Core
N8N_ENCRYPTION_KEY=random-32-char-string    # CRITICAL: needed for credential portability
GENERIC_TIMEZONE=Asia/Kolkata
WEBHOOK_URL=https://your-domain.com/

# Supabase
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...

# Claude
ANTHROPIC_API_KEY=sk-ant-...

# R2
CLOUDFLARE_R2_ACCESS_KEY=...
CLOUDFLARE_R2_SECRET_KEY=...
CLOUDFLARE_R2_ENDPOINT=https://<ACCOUNT_ID>.r2.cloudflarestorage.com

# ElevenLabs
ELEVENLABS_API_KEY=...
ELEVENLABS_VOICE_ID=...

# Distribution
PUBLER_API_KEY=...
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...
```

---

## Cost Summary

| Item | Monthly |
|------|---------|
| n8n on Railway | $5.00 |
| Claude API (all workflows) | ~$2.50 |
| ElevenLabs (daily audio) | ~$4.50 |
| Cloudflare R2 | ~$0.02 |
| **Pipeline total** | **~$12/month** |

(On top of fixed subscriptions: Canva $13, ElevenLabs Creator $22, etc.)

---

## Learning Resources

### Official
- Docs: https://docs.n8n.io/
- API Ref: https://docs.n8n.io/api/api-reference/
- CLI: https://docs.n8n.io/hosting/cli-commands/
- Docker: https://docs.n8n.io/hosting/installation/docker/
- Anthropic Node: https://docs.n8n.io/integrations/builtin/credentials/anthropic/
- Error Handling: https://docs.n8n.io/flow-logic/error-handling/

### Community
- Templates: https://n8n.io/workflows/ (9,000+)
- Forum: https://community.n8n.io/
- GitHub: https://github.com/n8n-io/n8n

### Bodhi-Relevant Templates
- Instagram scheduling: https://n8n.io/workflows/4498
- AI social content: https://n8n.io/workflows/3066
- ElevenLabs TTS: https://n8n.io/workflows/2245
- Error recovery: https://n8n.io/workflows/3144

### MCP Servers
- https://github.com/czlonkowski/n8n-mcp
- https://github.com/salacoste/mcp-n8n-workflow-builder
- https://github.com/ahmadsoliman/mcp-n8n-server

---

## Comparison: n8n vs Native Scripts vs GitHub Actions

| Factor | n8n | Scripts | GitHub Actions |
|--------|-----|---------|----------------|
| Setup | 20 min | 2-4 hours | 1-2 hours |
| Debugging | Visual (best) | Logs only | Run logs |
| Cost | $5/mo | Free | Free (2K min/mo) |
| Maintenance | Low (visual) | High (code) | Medium (YAML) |
| AI integration | Native nodes | SDK calls | Claude Code Action |
| Webhook support | Built-in | Build your own | repository_dispatch |
| Version control | JSON export | Git native | Git native |
| Learning curve | Low | High | Medium |

**Bodhi recommendation**: n8n for complex multi-service pipelines, GitHub Actions for git-integrated tasks, native scripts for local dev/testing.

Full comparison: `/automation/pipeline-comparison.md`

---

*Skill complete. All sections populated from research conducted 2026-04-04.*
*Implementation files: `/automation/workflow-*.json`, `/automation/n8n-quickstart.md`, `/automation/pipeline-comparison.md`*
*Full guide: `/data/n8n-implementation-guide.md`*
