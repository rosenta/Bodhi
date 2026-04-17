# Pipeline Comparison: n8n vs Native Scripts vs GitHub Actions

> Which automation approach fits Project Bodhi at each stage of growth.

---

## The Three Approaches

### 1. n8n (Visual Workflow Automation)

Self-hosted workflow engine with a visual drag-and-drop editor, 800+ integrations, and built-in AI agent nodes.

### 2. Native Scripts (Shell + Cron + Node.js)

Traditional approach: write scripts in JavaScript/Python/Bash, schedule with cron, store in the project repository.

### 3. GitHub Actions (CI/CD Pipelines)

GitHub-hosted runners that execute workflows on cron schedules, webhooks, or repository events. Claude Code has an official GitHub Action.

---

## Head-to-Head Comparison

| Criteria | n8n | Native Scripts | GitHub Actions |
|----------|-----|---------------|----------------|
| **Setup time** | 20 min (Railway deploy) | 2-4 hours (write scripts) | 1-2 hours (write YAML) |
| **Maintenance** | Low (visual updates) | High (code changes) | Medium (YAML edits) |
| **Debugging** | Excellent (visual execution history, per-node data inspection) | Manual (logs, print statements) | Good (run logs, step outputs) |
| **Error handling** | Built-in retry, fallback, error workflows | Must code from scratch | Built-in retry, `continue-on-error` |
| **Cost** | ~$5/mo (Railway) | Free (runs on existing server) | Free (2,000 min/mo) then $0.008/min |
| **AI integration** | Native Claude/OpenAI nodes | SDK calls in code | Claude Code Action |
| **Visual editing** | Yes (drag-and-drop canvas) | No (code only) | No (YAML only) |
| **Webhook support** | Built-in, test + production URLs | Must set up Express/Fastify server | repository_dispatch or webhook |
| **Secret management** | Encrypted credential store | .env files, server env vars | GitHub Secrets (encrypted) |
| **Version control** | Export JSON (manual) | Git native | Git native (YAML in repo) |
| **Scalability** | Queue mode + workers (Railway Pro) | Scale with infrastructure | Parallel jobs, matrix builds |
| **Learning curve** | Low (visual, no-code) | High (coding required) | Medium (YAML syntax) |
| **Community templates** | 9,000+ workflow templates | None | GitHub Marketplace Actions |
| **MCP integration** | Yes (multiple MCP servers) | N/A | Via Claude Code Action |

---

## Approach 1: n8n Implementation

### When to Use n8n

- Daily recurring pipelines (Daily Verse, Weekly Analytics)
- Workflows that connect 4+ services (Supabase -> Claude -> Canva -> R2 -> Publer)
- When a non-developer needs to modify workflows
- When visual debugging and execution history matter
- When you want to iterate quickly on pipeline logic

### n8n Architecture for Bodhi

```
Railway (n8n instance, $5/mo)
    |
    +-- Workflow 1: Daily Verse Pipeline (Cron 5 AM)
    +-- Workflow 2: Lesson Adapter (Webhook)
    +-- Workflow 3: Weekly Analytics (Cron Monday 9 AM)
    +-- Workflow 4: Content Review (Manual / Webhook)
    +-- Workflow 5: Health Check (Cron hourly)
    +-- Workflow 6: Error Handler (triggered by other workflows)
```

### Pros

- No code for most changes (drag a node, connect a wire)
- Execution history lets you debug any past run (click through each node's data)
- Built-in retry/error handling without writing try/catch blocks
- Claude/Anthropic node is first-class (no SDK wrangling)
- Can be operated by a non-technical team member

### Cons

- Another service to maintain (Railway instance)
- JSON workflow format is not diff-friendly in git
- Complex JavaScript logic in Code nodes can be harder to test than standalone scripts
- Rate limiting across multiple workflows is not centralized

---

## Approach 2: Native Scripts Implementation

### When to Use Native Scripts

- Simple, single-purpose tasks (one API call, one output)
- When you need fine-grained control over every line of execution
- When the team is developer-only and prefers code to GUIs
- For tasks that need to interact with the local filesystem directly
- When you want everything version-controlled in git natively

### Native Script Architecture for Bodhi

```
Server (VPS or local machine)
    |
    +-- crontab
    |     +-- 0 5 * * * /scripts/daily-verse.sh
    |     +-- 0 9 * * 1 /scripts/weekly-analytics.sh
    |
    +-- scripts/
    |     +-- daily-verse.sh        (orchestrator)
    |     +-- fetch-verse.js        (Supabase query)
    |     +-- generate-content.js   (Claude API call)
    |     +-- generate-audio.js     (ElevenLabs API)
    |     +-- upload-r2.js          (Cloudflare R2)
    |     +-- publish-blog.js       (Website API)
    |     +-- schedule-social.js    (Publer API)
    |     +-- weekly-analytics.js   (Pull + analyze)
    |     +-- content-review.js     (Claude review)
    |
    +-- .env                        (secrets)
    +-- package.json                (dependencies)
```

### Example: Daily Verse Script (Node.js)

```javascript
// scripts/daily-verse.js
import Anthropic from "@anthropic-ai/sdk";
import { createClient } from "@supabase/supabase-js";

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

const anthropic = new Anthropic();

async function main() {
  // 1. Fetch today's verse
  const today = new Date().toISOString().split("T")[0];
  const { data: dailyVerse, error } = await supabase
    .from("daily_verse")
    .select("*, verse:verses(*)")
    .eq("date", today)
    .single();

  if (error) throw new Error(`Failed to fetch verse: ${error.message}`);

  // 2. Generate content with Claude
  const response = await anthropic.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 8000,
    system:
      "You are a content strategist for Project Bodhi... (system prompt)",
    messages: [
      {
        role: "user",
        content: `Given this verse:\n${JSON.stringify(dailyVerse.verse)}\n\nGenerate all content types as JSON...`,
      },
    ],
  });

  const content = JSON.parse(response.content[0].text);

  // 3. Save to Supabase
  const contentTypes = Object.keys(content);
  for (const type of contentTypes) {
    await supabase.from("content_pieces").insert({
      content_type: type,
      verse_id: dailyVerse.verse_id,
      content: content[type],
      status: "draft",
      generated_at: new Date().toISOString(),
    });
  }

  // 4. Generate audio (podcast script only)
  if (content.podcast_script) {
    const audioResponse = await fetch(
      `https://api.elevenlabs.io/v1/text-to-speech/${process.env.ELEVENLABS_VOICE_ID}`,
      {
        method: "POST",
        headers: {
          "xi-api-key": process.env.ELEVENLABS_API_KEY,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          text:
            content.podcast_script.intro +
            " " +
            content.podcast_script.body +
            " " +
            content.podcast_script.outro,
          model_id: "eleven_multilingual_v2",
        }),
      }
    );
    // ... upload to R2, update Supabase
  }

  console.log(`Daily pipeline complete for ${today}`);
}

main().catch((err) => {
  console.error("Pipeline failed:", err);
  // Send Discord notification about failure
  process.exit(1);
});
```

### Example: Crontab Setup

```bash
# Edit crontab
crontab -e

# Add these lines (times in IST if server is configured for IST):
# Daily verse pipeline at 5:00 AM
0 5 * * * cd /path/to/project && node scripts/daily-verse.js >> logs/daily.log 2>&1

# Weekly analytics at 9:00 AM Monday
0 9 * * 1 cd /path/to/project && node scripts/weekly-analytics.js >> logs/weekly.log 2>&1
```

### Pros

- Full control over every line of logic
- Native git versioning (real diffs, real PRs)
- No external service dependency (runs anywhere Node.js runs)
- Easier to unit test (standard test frameworks)
- Free (runs on any machine)

### Cons

- Must write all error handling, retry logic, and logging from scratch
- No visual debugging (just logs)
- No execution history browser
- Adding a new API integration requires writing code, not dragging a node
- Secrets management is your responsibility (.env files, process.env)

---

## Approach 3: GitHub Actions Implementation

### When to Use GitHub Actions

- Cron-scheduled tasks that run infrequently (weekly analytics)
- Tasks that benefit from git integration (content that lives in the repo)
- When you want infrastructure-free automation (no server to maintain)
- When using Claude Code Action for AI-powered tasks

### GitHub Actions Architecture for Bodhi

```yaml
# .github/workflows/daily-verse.yml
name: Daily Verse Pipeline

on:
  schedule:
    - cron: "30 23 * * *" # 5:00 AM IST = 23:30 UTC previous day
  workflow_dispatch: # Manual trigger

jobs:
  generate-content:
    runs-on: ubuntu-latest
    timeout-minutes: 15

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: "20"

      - name: Install dependencies
        run: npm ci

      - name: Fetch today's verse
        id: fetch-verse
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_SERVICE_ROLE_KEY: ${{ secrets.SUPABASE_SERVICE_ROLE_KEY }}
        run: node scripts/fetch-verse.js >> $GITHUB_OUTPUT

      - name: Generate content with Claude
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: node scripts/generate-content.js

      - name: Generate audio
        env:
          ELEVENLABS_API_KEY: ${{ secrets.ELEVENLABS_API_KEY }}
        run: node scripts/generate-audio.js
        continue-on-error: true

      - name: Upload assets to R2
        env:
          CLOUDFLARE_R2_ACCESS_KEY: ${{ secrets.CLOUDFLARE_R2_ACCESS_KEY }}
          CLOUDFLARE_R2_SECRET_KEY: ${{ secrets.CLOUDFLARE_R2_SECRET_KEY }}
        run: node scripts/upload-r2.js

      - name: Publish and schedule
        env:
          PUBLER_API_KEY: ${{ secrets.PUBLER_API_KEY }}
          WEBSITE_API_URL: ${{ secrets.WEBSITE_API_URL }}
        run: |
          node scripts/publish-blog.js
          node scripts/schedule-social.js

      - name: Notify team
        if: always()
        env:
          DISCORD_WEBHOOK_URL: ${{ secrets.DISCORD_WEBHOOK_URL }}
        run: node scripts/notify.js ${{ job.status }}
```

### Using Claude Code Action (Alternative)

```yaml
# .github/workflows/content-review.yml
name: Content Review with Claude Code

on:
  workflow_dispatch:
    inputs:
      content_piece_id:
        description: "Content piece ID to review"
        required: true

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Review content piece ${{ github.event.inputs.content_piece_id }}
            from our Supabase database. Check brand voice, Sanskrit accuracy,
            and quality score. Update the status in Supabase.
```

### Pros

- Zero infrastructure (GitHub hosts the runners)
- Native git integration (triggered by commits, PRs, issues)
- Built-in secret management (GitHub Secrets)
- Parallel job execution (matrix strategy)
- 2,000 free minutes/month (sufficient for Bodhi)
- Claude Code Action provides direct AI integration
- Audit trail via GitHub Actions run logs

### Cons

- Cron scheduling has ~10-15 min variance (not precise)
- No visual workflow editor
- YAML syntax can be verbose for complex logic
- 6-hour max job timeout
- Cannot receive external webhooks natively (need repository_dispatch + intermediary)
- Cold start time adds 30-60s to each run
- No persistent state between runs (must use external storage)

---

## Recommendation for Project Bodhi

### Phase 1: Launch (Weeks 1-4) -- Use n8n

**Why**: Fastest path from zero to working pipeline. Visual debugging is invaluable when you are still iterating on prompts and data flows.

| Workflow | Approach | Reason |
|----------|----------|--------|
| Daily Verse Pipeline | n8n | Complex multi-service orchestration, needs visual debugging |
| Lesson Adapter | n8n | Webhook trigger, real-time processing |
| Content Review | n8n | Manual trigger, interactive review flow |
| Weekly Analytics | n8n | Multi-source data aggregation |

**Setup**: Deploy n8n on Railway ($5/mo), import the 4 workflow JSON files, configure credentials, activate.

### Phase 2: Optimization (Months 2-3) -- Add Native Scripts

Once pipeline logic is stable and prompts are finalized, extract performance-critical or frequently-modified parts into standalone scripts:

| Task | Move to | Reason |
|------|---------|--------|
| Claude prompt testing | Node.js script | Faster iteration, unit testable |
| Bulk content generation | Node.js script | Can run locally, no n8n overhead |
| Content migration/import | Shell scripts | One-time operations |

### Phase 3: Scale (Months 4+) -- Add GitHub Actions

Add GitHub Actions for repository-integrated tasks:

| Task | Approach | Reason |
|------|----------|--------|
| Daily content backup | GitHub Actions cron | Auto-commit generated content to repo |
| Content review via Claude Code | Claude Code Action | Direct AI review in PR workflow |
| Weekly dependency updates | GitHub Actions | Dependabot + Claude Code |
| Documentation sync | GitHub Actions | Keep docs current with codebase |

### The Hybrid Sweet Spot

```
n8n (Railway)                    GitHub Actions
+-------------------------------+  +----------------------------+
| Daily Verse Pipeline          |  | Content backup (cron)      |
| Lesson Adapter (webhook)      |  | Claude Code review (PR)    |
| Content Review (manual)       |  | Weekly dep updates         |
| Weekly Analytics              |  | Doc sync                   |
| Health Check (hourly)         |  |                            |
+-------------------------------+  +----------------------------+
         |                                    |
         v                                    v
+----------------------------------------------------------+
| Supabase (shared state, content DB, analytics)           |
| Cloudflare R2 (shared asset storage)                     |
+----------------------------------------------------------+
```

n8n handles the complex, multi-service, real-time orchestration.
GitHub Actions handles the scheduled, git-integrated, maintenance tasks.
Native scripts handle local development, testing, and one-off operations.

---

## Decision Matrix

Use this to decide which approach for any new automation task:

| Question | If YES | If NO |
|----------|--------|-------|
| Does it connect 3+ external APIs? | n8n | Script or GH Action |
| Does it need a webhook trigger? | n8n | Any |
| Does it need visual debugging? | n8n | Script or GH Action |
| Is it a one-time batch operation? | Script | n8n or GH Action |
| Does it modify files in the git repo? | GH Action | n8n or Script |
| Does it run on PR/commit events? | GH Action | n8n or Script |
| Does a non-developer need to modify it? | n8n | Script or GH Action |
| Is it performance-critical (sub-second)? | Script | n8n or GH Action |
| Does it need precise cron timing (<1 min)? | n8n or Script | GH Action works |
