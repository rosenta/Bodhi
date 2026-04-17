# n8n Quickstart for Project Bodhi

> Zero to working pipeline in 20 minutes.

---

## Part 1: Install n8n (5 minutes)

### Option A: Docker (recommended)

```bash
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v n8n_data:/home/node/.n8n \
  docker.n8n.io/n8nio/n8n
```

### Option B: npx (quickest)

```bash
npx n8n
```

### Option C: Railway (production)

1. Open https://railway.com/deploy/n8n
2. Click "Deploy Now"
3. Wait 2 minutes for provisioning
4. Click "Generate Domain" under Settings > Networking

**Result**: n8n is running. Open http://localhost:5678 (or your Railway URL).

### First-Time Setup

1. Create your admin account (email + password)
2. Skip the onboarding tour
3. Go to Settings (gear icon, bottom-left) > General > set Timezone to `Asia/Kolkata`
4. Go to Settings > API > click "Create API Key" > copy and save it

---

## Part 2: Create Your First Workflow (10 minutes)

### Step 1: New Workflow

1. Click **"Add workflow"** (top-right corner)
2. Name it: `Test: Hello Bodhi`

### Step 2: Add a Manual Trigger

1. Click the **"+"** button on the canvas (or the big empty area)
2. Search for **"Manual Trigger"**
3. Click it to add it to the canvas

### Step 3: Add an HTTP Request Node

1. Click the **"+"** button that appears to the right of the trigger node
2. Search for **"HTTP Request"**
3. Click it to add it
4. Configure:
   - **Method**: GET
   - **URL**: `https://jsonplaceholder.typicode.com/posts/1`
5. Click **"Execute Node"** (play button on the node)
6. You should see JSON data appear in the output panel

### Step 4: Add a Code Node

1. Click **"+"** after the HTTP Request node
2. Search for **"Code"**
3. Select **JavaScript**
4. Paste this code:

```javascript
const post = $input.first().json;
return [
  {
    json: {
      message: `Bodhi Pipeline works! Fetched: "${post.title}"`,
      timestamp: new Date().toISOString(),
    },
  },
];
```

5. Click **"Execute Node"** - you should see your message

### Step 5: Run the Full Workflow

1. Click **"Execute Workflow"** (play button in the top toolbar)
2. Watch data flow through all three nodes (green checkmarks)
3. Click any node to inspect its input/output data

Congratulations - you just built and ran your first n8n workflow.

---

## Part 3: Connect to Claude API (5 minutes)

### Step 1: Get Your Anthropic API Key

1. Go to https://console.anthropic.com
2. Sign in > Settings > API Keys
3. Click **"+ Create Key"**
4. Name it `n8n-bodhi`
5. Click **"Copy Key"** (starts with `sk-ant-`)

### Step 2: Add Credential in n8n

1. In n8n, click **"Credentials"** (left sidebar, key icon)
2. Click **"Add Credential"**
3. Search for **"Anthropic"**
4. Paste your API key
5. Click **"Save"**
6. You should see a green "Connection tested successfully" message

### Step 3: Build a Claude-Powered Workflow

1. Create a new workflow: `Test: Claude Content Generation`
2. Add nodes in this order:

**Node 1: Manual Trigger**
- (No configuration needed)

**Node 2: Set** (to provide test data)
- Search for "Set" node
- Add a field: Name = `verse`, Type = String
- Value = `The world is unreal. Brahman alone is real. The individual soul is Brahman itself.`

**Node 3: HTTP Request** (Claude API call)
- Method: **POST**
- URL: `https://api.anthropic.com/v1/messages`
- Headers:
  - `x-api-key`: `your-api-key-here` (or use credential)
  - `anthropic-version`: `2023-06-01`
  - `Content-Type`: `application/json`
- Body (JSON):

```json
{
  "model": "claude-sonnet-4-20250514",
  "max_tokens": 1024,
  "messages": [
    {
      "role": "user",
      "content": "You are a content strategist for Project Bodhi. Given this verse: '{{ $json.verse }}' - Write a punchy Instagram quote card text (front text + back text) and 3 hashtags. Output as JSON."
    }
  ]
}
```

3. Click **"Execute Workflow"**
4. Click the Claude node to see the generated content

### Alternate: Use the Anthropic Node Directly

If you prefer the native node (simpler):

1. Add node > search **"Anthropic"** or **"Chat Anthropic"**
2. Select your Anthropic credential
3. Choose model: `claude-sonnet-4-20250514`
4. Enter your prompt directly
5. Execute - no manual header/body configuration needed

---

## Next Steps

### Import the Bodhi Workflows

Now that n8n is running and Claude is connected, import the production workflows:

1. Download the workflow JSON files from `/automation/`:
   - `workflow-daily-verse.json`
   - `workflow-lesson-adapter.json`
   - `workflow-analytics.json`
   - `workflow-content-review.json`

2. For each file:
   - Click **"Add workflow"**
   - Click the three-dot menu (top-right of canvas) > **"Import from file"**
   - Select the JSON file
   - Click each node with a warning icon and assign credentials

3. Read the full implementation guide: `/data/n8n-implementation-guide.md`

### Set Up Remaining Credentials

| Priority | Credential | Why |
|----------|-----------|-----|
| 1 (now) | Anthropic (Claude) | Content generation |
| 2 (now) | Supabase | Verse database |
| 3 (day 2) | Cloudflare R2 | Asset storage |
| 4 (day 2) | ElevenLabs | Audio narration |
| 5 (week 2) | Discord/Slack | Team notifications |
| 6 (week 3) | Publer | Social scheduling |
| 7 (week 4) | Instagram/YouTube | Analytics |

### Useful Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl/Cmd + S` | Save workflow |
| `Ctrl/Cmd + Enter` | Execute workflow |
| `Tab` | Open node search palette |
| `Ctrl/Cmd + Z` | Undo |
| `Space + Drag` | Pan the canvas |
| `Scroll` | Zoom in/out |
| `Delete` | Remove selected node |

### CLI Quick Reference

```bash
# Export all workflows for backup
docker exec n8n n8n export:workflow --all --output=/home/node/backups/

# Import a workflow
docker exec n8n n8n import:workflow --input=/tmp/workflow.json

# Execute a workflow by ID
docker exec n8n n8n execute --id 1

# Check n8n version
docker exec n8n n8n --version
```

### API Quick Reference

```bash
# List all workflows
curl http://localhost:5678/api/v1/workflows \
  -H "X-N8N-API-KEY: your-key"

# Trigger a workflow
curl -X POST http://localhost:5678/api/v1/workflows/1/run \
  -H "X-N8N-API-KEY: your-key"

# Check execution history
curl http://localhost:5678/api/v1/executions \
  -H "X-N8N-API-KEY: your-key"
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Cannot access http://localhost:5678 | Check if Docker is running: `docker ps` |
| "Invalid API key" for Anthropic | Make sure you copied the full key starting with `sk-ant-` |
| Webhook not receiving data | Use test URL (not production) during development |
| Cron not triggering | Workflow must be **Active** (toggle top-right) |
| "Cannot find module" in Code node | Use built-in modules only, or install community nodes |
| Node shows red error | Click the node, check the "Output" tab for error details |
| Railway deployment fails | Check logs in Railway dashboard; ensure env vars are set |

---

## Resources

- Full implementation guide: `/data/n8n-implementation-guide.md`
- Pipeline comparison: `/automation/pipeline-comparison.md`
- Workflow JSONs: `/automation/workflow-*.json`
- n8n Docs: https://docs.n8n.io/
- n8n Templates: https://n8n.io/workflows/
- n8n Community: https://community.n8n.io/
