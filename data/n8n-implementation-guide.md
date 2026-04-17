# n8n Implementation Guide for Project Bodhi

> The definitive guide to building and operating the automated content pipeline.
> Target: Zero n8n experience to full pipeline running in one afternoon.

---

## Table of Contents

1. [What is n8n?](#1-what-is-n8n)
2. [Installation](#2-installation)
3. [Core Concepts](#3-core-concepts)
4. [Credentials Setup](#4-credentials-setup)
5. [Workflow 1: Daily Verse Pipeline](#5-workflow-1-daily-verse-pipeline)
6. [Workflow 2: Lesson to Social Adapter](#6-workflow-2-lesson-to-social-adapter)
7. [Workflow 3: Weekly Analytics](#7-workflow-3-weekly-analytics)
8. [Workflow 4: Content Review Pipeline](#8-workflow-4-content-review-pipeline)
9. [n8n REST API Reference](#9-n8n-rest-api-reference)
10. [n8n CLI Reference](#10-n8n-cli-reference)
11. [n8n Web UI Guide](#11-n8n-web-ui-guide)
12. [MCP Integration](#12-mcp-integration)
13. [Webhook Configuration](#13-webhook-configuration)
14. [Error Handling and Retry Logic](#14-error-handling-and-retry-logic)
15. [Monitoring and Debugging](#15-monitoring-and-debugging)
16. [Environment Variables](#16-environment-variables)
17. [Cost Estimation](#17-cost-estimation)
18. [Integration Reference](#18-integration-reference)
19. [Learning Resources](#19-learning-resources)

---

## 1. What is n8n?

n8n (pronounced "n-eight-n" or "nodemation") is an open-source workflow automation platform. Think Zapier, but self-hostable, code-extensible, and free.

### Key Facts (2026)

| Aspect | Detail |
|--------|--------|
| License | Fair-code (free self-hosted, paid cloud) |
| Built-in integrations | 800+ core nodes, 580+ community nodes |
| AI capabilities | Native AI Agent nodes, Claude/OpenAI/Gemini nodes, RAG with vector stores |
| Data model | JSON items flowing between nodes |
| Languages in Code node | JavaScript, Python |
| Deployment | Docker, npm, Railway, Render, Hetzner, any VPS |
| Community | 9,000+ workflow templates at n8n.io/workflows |

### Self-Hosted vs Cloud

| Feature | Self-Hosted (Community) | n8n Cloud |
|---------|------------------------|-----------|
| Cost | $0 (+ ~$5/mo hosting) | From EUR 24/mo |
| Executions | Unlimited | 2,500-40,000/mo by plan |
| Active workflows | Unlimited | Unlimited (all plans) |
| Setup effort | Docker / VPS config | Zero (managed) |
| Data location | Your server | n8n's servers (EU/US) |
| Support | Community forum | Email support |
| Best for | Project Bodhi | Non-technical teams |

**Recommendation for Project Bodhi**: Self-hosted on Railway ($5/mo) gives unlimited executions at the lowest cost.

---

## 2. Installation

### Option A: Docker (Recommended for Development)

```bash
# Quick start (data persists in Docker volume)
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v n8n_data:/home/node/.n8n \
  docker.n8n.io/n8nio/n8n

# Open browser: http://localhost:5678
```

### Option B: Docker Compose (Recommended for Production)

Create `docker-compose.yml`:

```yaml
version: "3.8"

services:
  n8n:
    image: docker.n8n.io/n8nio/n8n
    restart: always
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=changeme
      - GENERIC_TIMEZONE=Asia/Kolkata
      - TZ=Asia/Kolkata
      - N8N_ENCRYPTION_KEY=your-random-32-char-encryption-key
      - WEBHOOK_URL=https://your-domain.com/
      - N8N_HOST=your-domain.com
      - N8N_PROTOCOL=https
    volumes:
      - n8n_data:/home/node/.n8n

volumes:
  n8n_data:
```

```bash
docker compose up -d
```

### Option C: Railway (Recommended for Production Hosting)

1. Go to https://railway.com/deploy/n8n
2. Click "Deploy Now" (one-click template)
3. Railway provisions n8n + PostgreSQL automatically
4. Set environment variables in Railway dashboard:
   - `N8N_ENCRYPTION_KEY` - random 32-char string
   - `GENERIC_TIMEZONE` - `Asia/Kolkata`
   - `WEBHOOK_URL` - your Railway-assigned domain
5. Click "Generate Domain" under Settings > Networking
6. Access n8n at `https://n8n-production-xxxx.up.railway.app`

**Cost**: ~$5/month on Railway Hobby plan with typical Bodhi usage.

### Option D: npm (Quick Local Testing)

```bash
npm install n8n -g
n8n start
# Or one-shot: npx n8n
```

### Post-Installation Checklist

- [ ] Access UI at http://localhost:5678 (or your domain)
- [ ] Create admin account (first visit)
- [ ] Set timezone to Asia/Kolkata in Settings
- [ ] Generate an API key: Settings > API > Create API Key
- [ ] Note your webhook base URL for later

---

## 3. Core Concepts

### Node Types

| Category | Nodes | Purpose |
|----------|-------|---------|
| **Triggers** | Cron, Webhook, Manual Trigger, Schedule | Start a workflow |
| **Actions** | HTTP Request, Code, Send Email | Do something |
| **AI** | AI Agent, Chat Anthropic, Chat OpenAI, Embeddings | LLM operations |
| **Logic** | IF, Switch, Merge, Split In Batches, Loop Over Items | Control flow |
| **Data** | Set, Function, Spreadsheet File, JSON, XML | Transform data |
| **Storage** | Supabase, PostgreSQL, Google Sheets, S3, Airtable | Read/write data |
| **Communication** | Slack, Discord, Telegram, Email, WhatsApp | Notify |

### Data Model

Every node receives and outputs **items** - arrays of JSON objects:

```json
[
  {
    "json": {
      "verse_id": 42,
      "sanskrit": "ब्रह्म सत्यं जगन्मिथ्या...",
      "translation": "Brahman alone is real..."
    }
  }
]
```

Nodes process each item and pass results downstream. Use **expressions** to reference data from previous nodes:

```
{{ $json.verse_id }}                    // Current node's input
{{ $('Fetch Verse').item.json.sanskrit }} // Data from a specific named node
{{ $now.format('yyyy-MM-dd') }}         // Current date
```

### Workflow Structure

```
[Trigger]
    |
    v
[Transform / Fetch Data]
    |
    v
[Process with AI / Logic]
    |
    +-------+-------+
    |       |       |
    v       v       v
[Action] [Action] [Action]    <-- Parallel branches
    |       |       |
    +-------+-------+
    |
    v
[Final notification / logging]
```

### Credentials System

Credentials are stored **encrypted** in n8n's database. Set them up via:

1. **UI**: Left sidebar > Credentials > Add Credential
2. Search for the service (e.g., "Anthropic")
3. Enter API key / OAuth tokens
4. Test the connection
5. Save - now available in any workflow node

Credentials are NOT exported with workflows by default (security). When importing workflows, you must re-create credentials on the target instance.

### Workflow Lifecycle

```
Draft (inactive)
    |
    v
Active (running on triggers)
    |
    v
Execution (each run)
    |
    +---> Success
    +---> Error --> Error Workflow (optional)
```

- **Inactive**: Workflow exists but triggers do not fire
- **Active**: Published; cron/webhook triggers are live
- **Execution**: A single run of the workflow, stored in execution history

---

## 4. Credentials Setup

Set up these credentials before building workflows. Go to **Credentials** in the n8n left sidebar.

### 4.1 Anthropic (Claude API)

1. Go to https://console.anthropic.com > Settings > API Keys
2. Click "+ Create Key", name it `n8n-bodhi`
3. Copy the key (starts with `sk-ant-`)
4. In n8n: Add Credential > search "Anthropic"
5. Paste the API key
6. Save

**Usage**: Used in Chat Anthropic nodes and AI Agent nodes.

### 4.2 Supabase

1. Go to https://supabase.com > Your project > Settings > API
2. Copy the **Project URL** (e.g., `https://xxx.supabase.co`)
3. Copy the **service_role** key (reveals under "Project API keys")
4. In n8n: Add Credential > search "Supabase"
5. Host = Project URL, Service Role Secret = service_role key
6. Save

**Also set up PostgreSQL credential** (for direct SQL queries):
- Host: `db.xxx.supabase.co`
- Port: `5432`
- Database: `postgres`
- User: `postgres`
- Password: your database password

### 4.3 Cloudflare R2 (via S3 node)

1. Go to Cloudflare Dashboard > R2 > Manage R2 API tokens
2. Create token with "Object Read & Write" permissions
3. Copy Access Key ID + Secret Access Key
4. In n8n: Add Credential > search "S3"
5. Configure:
   - Region: `auto`
   - Access Key ID: your key
   - Secret Access Key: your secret
   - Custom Endpoint: `https://<ACCOUNT_ID>.r2.cloudflarestorage.com`
   - Force Path Style: `true`
6. Save

### 4.4 ElevenLabs

1. Go to https://elevenlabs.io > Profile > API Keys
2. Copy your API key
3. In n8n: Install community node `n8n-nodes-elevenlabs` (Settings > Community Nodes > Install)
4. Add Credential > search "ElevenLabs"
5. Paste API key
6. Save

**Alternative**: Use HTTP Request node with the ElevenLabs REST API directly.

### 4.5 Instagram (via Meta Graph API)

1. Go to https://developers.facebook.com > Create App > Business type
2. Add Instagram Graph API product
3. Generate long-lived access token (60-day, auto-refresh via n8n)
4. Get your Instagram Business Account ID
5. In n8n: Use HTTP Request node with:
   - Header Auth: `Authorization: Bearer <token>`
   - Base URL: `https://graph.facebook.com/v21.0`

### 4.6 YouTube Data API

1. Go to https://console.cloud.google.com > APIs & Services > Enable YouTube Data API v3
2. Create OAuth 2.0 credentials (or API key for read-only)
3. In n8n: Add Credential > search "Google" > OAuth2
4. Paste Client ID + Client Secret
5. Authorize via OAuth flow
6. Save

### 4.7 Publer (Social Scheduling)

1. Go to Publer Settings > Integrations > API
2. Generate API token
3. In n8n: Use HTTP Request node with:
   - Header Auth: `Authorization: Bearer <publer_token>`
   - Base URL: `https://app.publer.io/api/v1`

### 4.8 Canva API

Canva's Connect API (for design generation) requires a Canva Enterprise or Canva for Teams subscription. For programmatic design:

1. Go to https://www.canva.com/developers
2. Create an app, get Client ID and Secret
3. In n8n: Use HTTP Request node with OAuth2
4. Endpoint: `https://api.canva.com/rest/v1/designs`

**Fallback**: If Canva API is not available, use pre-designed templates and swap text via the Canva Bulk Create feature, or generate images directly with Midjourney/Ideogram via their APIs.

### Credential Summary Table

| Service | Credential Type | n8n Node | Required |
|---------|----------------|----------|----------|
| Anthropic (Claude) | API Key | Chat Anthropic / AI Agent | Yes |
| Supabase | Host + Service Key | Supabase / Postgres | Yes |
| Cloudflare R2 | S3-compatible | AWS S3 | Yes |
| ElevenLabs | API Key | Community Node / HTTP | Yes |
| Instagram | OAuth / Token | HTTP Request | Phase 2 |
| YouTube | OAuth2 / API Key | HTTP Request | Phase 2 |
| Publer | API Token | HTTP Request | Phase 2 |
| Canva | OAuth2 | HTTP Request | Optional |
| Discord/Slack | Bot Token / Webhook | Discord / Slack | Optional |

---

## 5. Workflow 1: Daily Verse Pipeline

**File**: `/automation/workflow-daily-verse.json`

### Overview

```
Trigger: Cron (5:00 AM IST daily)
    |
    v
[1] HTTP Request: Fetch today's verse from Supabase
    |
    v
[2] Chat Anthropic: Generate ALL content variants (JSON mode)
    |
    v
[3] Code: Parse Claude's JSON response into separate items
    |
    +--------+--------+--------+--------+--------+
    |        |        |        |        |        |
    v        v        v        v        v        v
[4a]      [4b]     [4c]     [4d]     [4e]     [4f]
Quote    Carousel  Reel    Blog    Email   Podcast
Card     Slides   Script   Post   Snippet  Script
    |        |        |        |        |        |
    +--------+--------+--------+--------+--------+
    |
    v
[5] HTTP Request: Store content_pieces rows in Supabase
    |
    +--------+--------+
    |        |        |
    v        v        v
[6a]      [6b]     [6c]
Canva    Eleven   (optional)
Visuals  Labs     Midjourney
    |      Audio     |
    +--------+--------+
    |
    v
[7] S3: Upload all assets to Cloudflare R2
    |
    v
[8] HTTP Request: Update content_pieces with media_urls
    |
    v
[9] HTTP Request: Publish blog post to Vercel site API
    |
    v
[10] HTTP Request: Queue social posts in Publer
    |
    v
[11] Discord/Slack: Send daily pipeline summary notification
```

### Node-by-Node Configuration

#### Node 1: Schedule Trigger (Cron)

- **Node type**: Schedule Trigger
- **Trigger interval**: Every day
- **Hour**: 5
- **Minute**: 0
- **Timezone**: Asia/Kolkata (set in workflow settings)

#### Node 2: Fetch Today's Verse

- **Node type**: HTTP Request
- **Method**: GET
- **URL**: `{{ $env.SUPABASE_URL }}/rest/v1/daily_verse?select=*,verse:verses(*)&date=eq.{{ $now.format('yyyy-MM-dd') }}`
- **Authentication**: Predefined Credential Type > Supabase
- **Headers**:
  - `apikey`: `{{ $env.SUPABASE_ANON_KEY }}`
  - `Prefer`: `return=representation`

#### Node 3: Chat Anthropic (Generate Content)

- **Node type**: Chat Anthropic (under AI > Language Models)
- **Model**: `claude-sonnet-4-20250514`
- **System prompt**:

```
You are a content strategist for Project Bodhi, a spiritual wisdom brand.
You create content that bridges ancient Sanskrit philosophy with modern life.

Your voice is:
- Direct and punchy (not preachy or flowery)
- Uses modern references (phones, algorithms, Netflix, hustle culture)
- Respects the depth of the original teaching
- Accessible to ages 20-40, spiritual-curious but not necessarily religious

CRITICAL: Output ONLY valid JSON. No markdown code fences. No explanation.
```

- **User message**:

```
Given this verse:
- Number: {{ $json.verse.verse_number }}
- Text: {{ $json.verse.text_id }}
- Sanskrit: {{ $json.verse.sanskrit }}
- Translation: {{ $json.verse.english_translation }}
- Interpretation: {{ $json.verse.modern_interpretation }}
- Hook: {{ $json.verse.reel_hook }}
- Practice: {{ $json.verse.practice_prompt }}
- Theme: {{ $json.verse.theme }}
- Date: {{ $now.format('yyyy-MM-dd') }}
- Day: {{ $now.format('EEEE') }}

Generate ALL of these content types as a single JSON object with keys:
quote_card, carousel, reel_script, blog_post, email_snippet, podcast_script

Follow the Project Bodhi content schema exactly.
```

- **Max tokens**: 8000
- **Temperature**: 0.7

#### Node 4: Code (Parse JSON Response)

- **Node type**: Code
- **Language**: JavaScript
- **Code**:

```javascript
const response = JSON.parse($input.first().json.text);
const verse = $('Fetch Verse').first().json;

const contentTypes = [
  'quote_card', 'carousel', 'reel_script',
  'blog_post', 'email_snippet', 'podcast_script'
];

return contentTypes.map(type => ({
  json: {
    content_type: type,
    verse_id: verse.verse_id,
    content: response[type],
    status: 'draft',
    generated_at: new Date().toISOString()
  }
}));
```

#### Node 5: Insert Content Pieces into Supabase

- **Node type**: Supabase
- **Operation**: Create
- **Table**: `content_pieces`
- **Fields**: Map `content_type`, `verse_id`, `content` (JSON), `status`, `generated_at`

#### Node 6a: Canva API - Generate Visuals

- **Node type**: HTTP Request
- **Method**: POST
- **URL**: `https://api.canva.com/rest/v1/autofills`
- **Body** (JSON):

```json
{
  "brand_template_id": "{{ $env.CANVA_QUOTE_TEMPLATE_ID }}",
  "data": {
    "sanskrit_text": "{{ $json.content.front_text }}",
    "translation": "{{ $json.content.back_text }}"
  }
}
```

**Fallback**: If Canva API is unavailable, use a Code node with a canvas library (e.g., `@napi-rs/canvas`) to generate simple quote card images programmatically.

#### Node 6b: ElevenLabs - Generate Audio

- **Node type**: HTTP Request (or ElevenLabs community node)
- **Method**: POST
- **URL**: `https://api.elevenlabs.io/v1/text-to-speech/{{ $env.ELEVENLABS_VOICE_ID }}`
- **Headers**: `xi-api-key: {{ $env.ELEVENLABS_API_KEY }}`
- **Body** (JSON):

```json
{
  "text": "{{ $json.content.body }}",
  "model_id": "eleven_multilingual_v2",
  "voice_settings": {
    "stability": 0.5,
    "similarity_boost": 0.75
  }
}
```

#### Node 7: Upload to Cloudflare R2

- **Node type**: AWS S3
- **Operation**: Upload
- **Bucket**: `bodhi-assets`
- **File Key**: `{{ $now.format('yyyy/MM/dd') }}/{{ $json.content_type }}.{{ $json.extension }}`
- **Binary Property**: `data`

#### Node 8: Update Media URLs in Supabase

- **Node type**: Supabase
- **Operation**: Update
- **Table**: `content_pieces`
- **Match column**: `id`
- **Update fields**: `media_urls` (array of R2 URLs)

#### Node 9: Publish Blog Post

- **Node type**: HTTP Request
- **Method**: POST
- **URL**: `{{ $env.WEBSITE_API_URL }}/api/publish`
- **Body**: Blog post content from the parsed response

#### Node 10: Queue Social Posts in Publer

- **Node type**: HTTP Request
- **Method**: POST
- **URL**: `https://app.publer.io/api/v1/posts`
- **Body**: Platform-specific posts with scheduled times (8 AM, 12 PM, 6 PM IST)

#### Node 11: Send Notification

- **Node type**: Discord (or Slack)
- **Message**: Daily pipeline summary with links to all generated content

---

## 6. Workflow 2: Lesson to Social Adapter

**File**: `/automation/workflow-lesson-adapter.json`

### Overview

```
Trigger: Webhook (POST /webhook/new-lesson)
    |
    v
[1] HTTP Request: Read the lesson file content (from URL or Supabase)
    |
    v
[2] Chat Anthropic: Extract quote + reel script + Twitter thread
    |
    v
[3] Code: Parse output into separate content items
    |
    +--------+--------+--------+
    |        |        |        |
    v        v        v        v
[4a]      [4b]     [4c]     [4d]
Save     Save     Save     Update
Quote    Reel     Thread   CMO-LOG
Card     Script
    |        |        |        |
    +--------+--------+--------+
    |
    v
[5] Notification: Alert team of new social content
```

### Trigger: Webhook Node

- **Node type**: Webhook
- **HTTP Method**: POST
- **Path**: `/new-lesson`
- **Authentication**: Header Auth (shared secret)
- **Expected body**:

```json
{
  "lesson_file": "content/lessons/lesson-042-verse-58.md",
  "verse_id": 58,
  "title": "The Mirage of Maya"
}
```

### Claude Prompt for Extraction

```
You are a social media content strategist for Project Bodhi.

Given this lesson:
---
{{ $json.lesson_content }}
---

Extract and create:

1. quote_card: The single most powerful sentence from this lesson.
   Format: { "text": "...", "attribution": "Vivekachudamani, Verse X" }

2. reel_script: A 30-45 second reel script.
   Format: { "hook": "...", "segments": [{"text": "...", "duration_s": N, "visual": "..."}], "cta": "..." }

3. twitter_thread: A 4-6 tweet thread.
   Format: { "tweets": ["1/ ...", "2/ ...", ...] }

Output as JSON with keys: quote_card, reel_script, twitter_thread
```

---

## 7. Workflow 3: Weekly Analytics

**File**: `/automation/workflow-analytics.json`

### Overview

```
Trigger: Cron (Monday 9:00 AM IST)
    |
    +--------+--------+
    |        |        |
    v        v        v
[1a]      [1b]     [1c]
Instagram YouTube  Website
Insights  Analytics Plausible
    |        |        |
    +--------+--------+
    |
    v
[2] Merge: Combine all analytics data
    |
    v
[3] Chat Anthropic: Analyze performance + recommend strategy
    |
    v
[4] Code: Format report as Markdown
    |
    v
[5] Supabase: Save report to weekly_reports table
    |
    v
[6] Email/Discord: Send report to team
```

### Node 1a: Instagram Insights

- **Node type**: HTTP Request
- **URL**: `https://graph.facebook.com/v21.0/{{ $env.IG_BUSINESS_ACCOUNT_ID }}/insights`
- **Parameters**:
  - `metric`: `impressions,reach,profile_views`
  - `period`: `day`
  - `since`: 7 days ago (Unix timestamp)
  - `until`: now (Unix timestamp)

### Node 1b: YouTube Analytics

- **Node type**: HTTP Request
- **URL**: `https://youtubeanalytics.googleapis.com/v2/reports`
- **Parameters**:
  - `ids`: `channel==MINE`
  - `startDate`: 7 days ago
  - `endDate`: yesterday
  - `metrics`: `views,estimatedMinutesWatched,averageViewDuration,subscribersGained`
  - `dimensions`: `video`

### Node 1c: Website Analytics (Plausible)

- **Node type**: HTTP Request
- **URL**: `{{ $env.PLAUSIBLE_URL }}/api/v1/stats/aggregate`
- **Parameters**:
  - `site_id`: `projectbodhi.com`
  - `period`: `7d`
  - `metrics`: `visitors,pageviews,bounce_rate,visit_duration`

### Claude Analytics Prompt

```
You are the CMO analyst for Project Bodhi.

Here is this week's performance data:

Instagram:
{{ JSON.stringify($('Instagram').first().json, null, 2) }}

YouTube:
{{ JSON.stringify($('YouTube').first().json, null, 2) }}

Website:
{{ JSON.stringify($('Website').first().json, null, 2) }}

Analyze and provide:
1. Top 3 performing content pieces (by engagement rate) and WHY they worked
2. Bottom 3 performing pieces and what went wrong
3. Which themes resonated most with the audience
4. Which platforms drove the most meaningful engagement
5. Specific recommendations for next week:
   - 3 verse themes to prioritize
   - 2 content formats to double down on
   - 1 experiment to try
6. A/B test results (if any reel hook variants were tested)

Format as a structured JSON report.
```

---

## 8. Workflow 4: Content Review Pipeline

**File**: `/automation/workflow-content-review.json`

### Overview

```
Trigger: Manual Trigger (or Webhook from content generation)
    |
    v
[1] HTTP Request: Fetch content piece from Supabase
    |
    v
[2] Chat Anthropic: Brand voice check
    |
    v
[3] Chat Anthropic: Sanskrit accuracy check
    |
    v
[4] Chat Anthropic: Quality score (1-10)
    |
    v
[5] IF: Score >= 7?
    |
    +--- YES ---> [6a] Update status = 'approved'
    |                   Move to publishing queue
    |
    +--- NO ----> [6b] Update status = 'in_review'
                        Flag for human review
                        Send notification
```

### Brand Voice Check Prompt

```
You are the brand guardian for Project Bodhi.

Review this content piece against our brand voice:
- Direct and punchy (not preachy or flowery)
- Modern references that deepen the teaching
- Respectful of original Sanskrit text depth
- Accessible to ages 20-40, spiritual-curious
- No spiritual jargon unless immediately explained

Content:
{{ $json.content }}

Check for:
1. Does it match our brand voice? (YES/NO + specific issues)
2. Is there any preachy or condescending tone?
3. Are modern references natural or forced?
4. Would someone aged 25 share this? Why or why not?

Output as JSON: { "voice_pass": bool, "issues": [...], "suggestions": [...] }
```

### Sanskrit Accuracy Check Prompt

```
You are a Sanskrit scholar and Vedanta specialist.

Verify the accuracy of this content:
{{ $json.content }}

Original verse:
Sanskrit: {{ $json.sanskrit }}
Standard translation: {{ $json.english_translation }}

Check:
1. Is the Sanskrit quoted correctly (no typos, correct diacritics)?
2. Does the interpretation faithfully represent the original meaning?
3. Are there any misattributions or context errors?
4. Is the philosophical position consistent with Advaita Vedanta?

Output as JSON: { "accuracy_pass": bool, "errors": [...], "notes": [...] }
```

### Quality Scoring Prompt

```
Rate this content piece on a scale of 1-10:

{{ $json.content }}

Criteria:
- Insight depth (does it make you think?) [0-2 points]
- Emotional resonance (does it make you feel?) [0-2 points]
- Shareability (would someone forward this?) [0-2 points]
- Clarity (is it immediately understandable?) [0-2 points]
- Actionability (is there something to DO?) [0-2 points]

Output as JSON:
{
  "total_score": N,
  "breakdown": { "insight": N, "emotion": N, "shareability": N, "clarity": N, "actionability": N },
  "feedback": "...",
  "suggested_improvements": ["..."]
}
```

---

## 9. n8n REST API Reference

### Authentication

Generate an API key in n8n: **Settings** > **API** > **Create API Key**

All requests require the header:
```
X-N8N-API-KEY: <your-api-key>
```

### Base URL

```
http://localhost:5678/api/v1
```

For Railway: `https://your-n8n.up.railway.app/api/v1`

### Endpoints

#### Workflows

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/workflows` | List all workflows (paginated) |
| POST | `/workflows` | Create a new workflow |
| GET | `/workflows/:id` | Get workflow by ID |
| PUT | `/workflows/:id` | Update workflow |
| DELETE | `/workflows/:id` | Delete workflow |
| POST | `/workflows/:id/activate` | Activate workflow |
| POST | `/workflows/:id/deactivate` | Deactivate workflow |
| POST | `/workflows/:id/transfer` | Transfer ownership |

#### Executions

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/executions` | List past executions (filterable) |
| GET | `/executions/:id` | Get single execution details |
| DELETE | `/executions/:id` | Delete execution record |
| POST | `/executions/:id/retry` | Retry a failed execution |

#### Credentials

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/credentials` | List all credentials |
| POST | `/credentials` | Create credential |
| GET | `/credentials/:id` | Get credential (no secrets) |
| DELETE | `/credentials/:id` | Delete credential |

#### Tags, Users, Audit

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/tags` | List tags |
| POST | `/tags` | Create tag |
| GET | `/users` | List users |
| GET | `/audit` | Audit log entries |

### Swagger UI

Self-hosted instances serve an interactive API docs page at:
```
http://localhost:5678/api/v1/docs
```

### Example: Trigger a Workflow via API

```bash
curl -X POST "http://localhost:5678/api/v1/workflows/1/run" \
  -H "X-N8N-API-KEY: your-api-key" \
  -H "Content-Type: application/json"
```

### Example: Create a Workflow Programmatically

```bash
curl -X POST "http://localhost:5678/api/v1/workflows" \
  -H "X-N8N-API-KEY: your-api-key" \
  -H "Content-Type: application/json" \
  -d @workflow-daily-verse.json
```

---

## 10. n8n CLI Reference

The CLI is available on self-hosted instances. If running in Docker, prefix commands with `docker exec -it n8n`.

### Core Commands

```bash
# Start n8n
n8n start

# Start with tunnel (for webhook testing locally)
n8n start --tunnel

# Execute a specific workflow by ID
n8n execute --id <workflow-id>

# Export all workflows to JSON
n8n export:workflow --all --output=./backups/

# Export a single workflow
n8n export:workflow --id=<workflow-id> --output=./workflow.json

# Import a workflow from JSON
n8n import:workflow --input=./workflow.json

# Import all workflows from a directory
n8n import:workflow --input=./backups/ --separate

# Export all credentials (encrypted)
n8n export:credentials --all --output=./creds/

# Import credentials
n8n import:credentials --input=./creds/

# Update n8n
npm update -g n8n

# Check version
n8n --version
```

### Docker-Specific Commands

```bash
# Start n8n in Docker
docker run -it --rm -p 5678:5678 -v n8n_data:/home/node/.n8n docker.n8n.io/n8nio/n8n

# Execute CLI command inside running container
docker exec -it n8n n8n export:workflow --all --output=/home/node/backups/

# Copy workflow files from container
docker cp n8n:/home/node/backups/ ./local-backups/

# Import workflow into running container
docker cp ./workflow.json n8n:/tmp/workflow.json
docker exec -it n8n n8n import:workflow --input=/tmp/workflow.json

# View logs
docker logs -f n8n
```

### Important Notes

- CLI commands operate on the database directly
- If n8n is running, changes may not take effect until restart
- Exported credentials are encrypted; import requires the same `N8N_ENCRYPTION_KEY`
- Use `--separate` flag when exporting to get one file per workflow

---

## 11. n8n Web UI Guide

### Dashboard

The main screen shows all your workflows in a list/grid view:
- **Name**: Workflow title (click to open editor)
- **Status**: Active (green) or Inactive (gray)
- **Last execution**: Timestamp + success/error status
- **Tags**: Organizational labels (e.g., "daily", "analytics", "review")

### Workflow Editor (Canvas)

The visual editor where you build workflows:

1. **Canvas area**: Drag and drop nodes, connect them with wires
2. **Node palette**: Click "+" or drag from left sidebar to add nodes
3. **Node configuration**: Click any node to open its settings panel
4. **Execution controls**:
   - **Execute Workflow** (play button): Run the entire workflow manually
   - **Execute Node** (on individual node): Test just that node
   - **Listen for Test Event**: Activate webhook in test mode
5. **Workflow settings** (gear icon): Name, timezone, error workflow, tags
6. **Save** (Ctrl/Cmd + S): Save current state
7. **Activate/Deactivate** (toggle, top right): Make workflow live

### Execution History

Access via: Left sidebar > Executions

Shows all past workflow runs:
- **Status**: Success (green), Error (red), Running (blue)
- **Started at**: Timestamp
- **Duration**: How long the execution took
- **Mode**: Manual, Trigger, Webhook, Retry
- **Actions**: View details, retry, delete

Click any execution to see the exact data that flowed through each node (invaluable for debugging).

### Credential Management

Access via: Left sidebar > Credentials

- Add, edit, delete API credentials
- Test connections before saving
- See which workflows use each credential
- Credentials are encrypted at rest

### Community Workflow Templates

Access via: Left sidebar > Templates (or https://n8n.io/workflows)

- 9,000+ pre-built workflow templates
- Filter by category: "Social Media", "Content Creation", "AI"
- One-click import into your instance
- Relevant templates for Bodhi:
  - "Schedule & publish all Instagram content types with Facebook Graph API"
  - "Auto-generate & post social media content with GPT-4"
  - "Generate Text-to-Speech Using ElevenLabs via API"

### Settings & Admin

Access via: Left sidebar > Settings

- **General**: Instance name, default timezone
- **Users**: Invite team members, set roles
- **API**: Generate/manage API keys
- **Community nodes**: Install third-party nodes (ElevenLabs, etc.)
- **Log streaming**: Send logs to external services
- **LDAP/SAML**: Enterprise SSO (paid plans)

---

## 12. MCP Integration

### What is MCP?

Model Context Protocol (MCP) allows AI assistants like Claude Code to interact directly with external tools. An n8n MCP server lets Claude Code create, modify, trigger, and monitor n8n workflows programmatically.

### Available n8n MCP Servers

| Project | GitHub | Capabilities |
|---------|--------|-------------|
| n8n-mcp (czlonkowski) | github.com/czlonkowski/n8n-mcp | Full node documentation, 1,396 node definitions, template configs |
| mcp-n8n-server (ahmadsoliman) | github.com/ahmadsoliman/mcp-n8n-server | List workflows, trigger webhooks, get webhook info |
| mcp-n8n-workflow-builder (salacoste) | github.com/salacoste/mcp-n8n-workflow-builder | 17 tools, create/manage/monitor workflows via natural language |
| n8n-claude-MCP-server (zach0028) | github.com/zach0028/n8n-claude-MCP-server | 30+ node documentation, workflow automation via Claude Desktop |

### Installation (mcp-n8n-workflow-builder - Recommended)

```bash
# Clone the repo
git clone https://github.com/salacoste/mcp-n8n-workflow-builder.git
cd mcp-n8n-workflow-builder

# Install dependencies
npm install

# Build
npm run build

# Configure Claude Code
# Add to ~/.claude/settings.json or project .mcp.json:
```

```json
{
  "mcpServers": {
    "n8n": {
      "command": "node",
      "args": ["/path/to/mcp-n8n-workflow-builder/dist/index.js"],
      "env": {
        "N8N_HOST": "http://localhost:5678",
        "N8N_API_KEY": "your-n8n-api-key"
      }
    }
  }
}
```

### What You Can Do with MCP

Once configured, tell Claude Code:
- "Create a new n8n workflow that fetches a verse from Supabase every morning"
- "Trigger the daily-verse workflow now"
- "Show me the last 5 executions of the analytics workflow"
- "Add an error handling node to the content review workflow"

### Alternative: Direct API Access from Scripts

If MCP is not needed, use n8n's REST API directly from shell scripts or Node.js:

```bash
# Trigger workflow from shell script
curl -X POST "https://your-n8n.railway.app/api/v1/workflows/1/run" \
  -H "X-N8N-API-KEY: $N8N_API_KEY"
```

---

## 13. Webhook Configuration

### Test vs Production URLs

Every Webhook node generates two URLs:

| Type | URL Pattern | Active When |
|------|------------|-------------|
| Test | `http://localhost:5678/webhook-test/<path>` | When you click "Listen for Test Event" |
| Production | `http://localhost:5678/webhook/<path>` | When workflow is activated (published) |

- Test webhooks stay active for 120 seconds
- Test mode shows data in the editor UI (useful for debugging)
- Production mode runs silently in the background

### Security for Production Webhooks

Always add authentication to production webhooks:

**Option 1: Header Auth**
- Set Authentication > Header Auth
- Name: `X-Bodhi-Secret`
- Value: a strong random string
- Callers must include this header

**Option 2: Basic Auth**
- Username + Password required on every call
- Encoded as Base64 in Authorization header

**Option 3: JWT**
- Caller signs a token with shared secret
- Best for high-security workflows
- Includes expiry time

### Local Testing with Tunnels

For testing webhooks locally (external services cannot reach localhost):

```bash
# Option 1: n8n built-in tunnel
n8n start --tunnel

# Option 2: ngrok
ngrok http 5678

# Option 3: Cloudflare Tunnel
cloudflared tunnel --url http://localhost:5678
```

---

## 14. Error Handling and Retry Logic

### Node-Level Retry

Every node has retry settings (click node > Settings tab):

| Setting | Default | Recommended |
|---------|---------|-------------|
| Retry On Fail | false | `true` for API calls |
| Max Tries | 3 | 3 (Claude), 5 (file uploads) |
| Wait Between Tries (ms) | 1000 | 2000-5000 for rate-limited APIs |

**Critical note**: If "Continue On Fail" is ON and "Retry On Fail" is also ON, the retry settings are **ignored**. Choose one or the other.

### Exponential Backoff Pattern

For advanced retry with exponential backoff, use a Loop + Wait pattern:

```
[API Call Node] --error--> [Set: retry_count + 1] --> [IF: retry_count < 5?]
                                                          |
                                           YES: [Wait: 2^retry_count seconds]
                                                   --> [Back to API Call]
                                           NO:  [Error notification]
```

### Continue On Fail

When enabled, a failing node passes the error as data to the next node:

```json
{
  "json": {
    "error": {
      "message": "Rate limit exceeded",
      "httpCode": 429
    }
  }
}
```

Use an IF node after to handle the error gracefully.

### Workflow-Level Error Handler

1. Create a separate "Error Handler" workflow
2. In your main workflow: Settings > Error Workflow > select the error handler
3. The error handler receives full context: which node failed, the error message, the input data

**Recommended Error Handler for Bodhi**:

```
[Error Trigger]
    |
    v
[Code: Parse error details]
    |
    +--- [Discord: Alert team with error details]
    +--- [Supabase: Log error to pipeline_errors table]
    +--- [IF: Critical failure?] --- YES --> [Email: Urgent alert to admin]
```

### Error Recovery Strategy per Service

| Service | Failure | Recovery |
|---------|---------|----------|
| Claude API | 429 Rate limit | Retry 3x, 5s/10s/30s backoff |
| Claude API | 500 Server error | Retry 3x, then skip + alert |
| Canva API | Any error | Use fallback plain-text template |
| ElevenLabs | Quota exceeded | Skip audio, publish text-only |
| Cloudflare R2 | Upload fail | Retry 5x, then store locally |
| Supabase | Write fail | CRITICAL: halt pipeline + alert |
| Publer | Schedule fail | Log error, manual scheduling |
| Instagram API | Token expired | Trigger token refresh workflow |

---

## 15. Monitoring and Debugging

### Execution History

- Every workflow run is logged with full input/output data
- Filter by status (success, error), date range, workflow
- Click any execution to replay the data flow visually

### Real-Time Monitoring

During development:
1. Open workflow in editor
2. Click "Execute Workflow" (manual run)
3. Watch data flow through each node in real-time
4. Click any node to inspect input/output data

### Logging Best Practices

Add a "Set" node before critical operations to log state:

```javascript
// In a Code node
console.log('Pipeline state:', JSON.stringify({
  verse_id: $json.verse_id,
  content_types_generated: $json.types.length,
  timestamp: new Date().toISOString()
}));
```

View logs:
- Docker: `docker logs -f n8n`
- Railway: Railway dashboard > Logs tab

### Health Check Workflow

Create a simple workflow that runs every hour:
1. Schedule Trigger (every hour)
2. HTTP Request: Ping Supabase
3. HTTP Request: Ping Claude API (models endpoint)
4. IF: Any failure? > Discord alert

---

## 16. Environment Variables

### Required for All Workflows

```bash
# n8n Configuration
N8N_ENCRYPTION_KEY=random-32-character-string-here
GENERIC_TIMEZONE=Asia/Kolkata
TZ=Asia/Kolkata
WEBHOOK_URL=https://your-n8n-domain.com/
N8N_HOST=your-n8n-domain.com
N8N_PROTOCOL=https

# Supabase
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...

# Anthropic (Claude)
ANTHROPIC_API_KEY=sk-ant-...

# Cloudflare R2
CLOUDFLARE_R2_ACCESS_KEY=...
CLOUDFLARE_R2_SECRET_KEY=...
CLOUDFLARE_R2_ENDPOINT=https://<ACCOUNT_ID>.r2.cloudflarestorage.com
CLOUDFLARE_R2_BUCKET=bodhi-assets

# ElevenLabs
ELEVENLABS_API_KEY=...
ELEVENLABS_VOICE_ID=...

# Social Media Distribution
PUBLER_API_KEY=...
IG_BUSINESS_ACCOUNT_ID=...
IG_ACCESS_TOKEN=...
YOUTUBE_API_KEY=...

# Website
WEBSITE_API_URL=https://projectbodhi.com

# Monitoring
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...
```

### Setting Environment Variables

**Docker Compose**: Add to `environment:` block in `docker-compose.yml`

**Railway**: Dashboard > Variables tab > Add each variable

**Docker run**: Use `-e` flags:
```bash
docker run -e ANTHROPIC_API_KEY=sk-ant-... -e SUPABASE_URL=... n8nio/n8n
```

**In workflows**: Reference with `{{ $env.VARIABLE_NAME }}`

---

## 17. Cost Estimation

### Per Workflow Run

| Workflow | Claude Tokens | ElevenLabs | R2 | Total/Run |
|----------|--------------|------------|-----|-----------|
| Daily Verse | ~10K tokens (~$0.06) | ~2 min audio (~$0.15) | ~50MB (~$0.001) | ~$0.21 |
| Lesson Adapter | ~4K tokens (~$0.025) | None | None | ~$0.03 |
| Weekly Analytics | ~6K tokens (~$0.04) | None | None | ~$0.04 |
| Content Review | ~3K tokens (~$0.02) | None | None | ~$0.02 |

### Monthly Totals

| Item | Monthly Cost |
|------|-------------|
| Claude API (daily + weekly + reviews) | ~$2.50 |
| ElevenLabs (daily audio) | ~$4.50 |
| Cloudflare R2 (1.5 GB/mo storage) | ~$0.02 |
| n8n on Railway | ~$5.00 |
| **Total pipeline cost** | **~$12/month** |

This is ON TOP of the fixed tool subscriptions (Canva Pro, ElevenLabs Creator, etc.) listed in AI-TOOLS-STACK.md.

### Cost Optimization Tips

1. Use `claude-haiku-4-20250514` for content review (cheaper, sufficient quality)
2. Batch multiple verses in a single Claude call when possible
3. Cache generated images - do not regenerate if verse data has not changed
4. Use ElevenLabs only for English; skip Hindi audio initially to save costs
5. R2 has zero egress fees - serve assets directly from R2 URLs

---

## 18. Integration Reference

### AI Integrations

| Service | n8n Node | Auth | Rate Limits | Notes |
|---------|----------|------|-------------|-------|
| Claude (Anthropic) | Chat Anthropic | API Key | Varies by plan (typically 60 RPM) | Use `claude-sonnet-4-20250514` for generation, `claude-haiku-4-20250514` for review |
| OpenAI | Chat OpenAI | API Key | 60-10,000 RPM | Backup LLM if Claude is down |
| Google Gemini | Chat Google Gemini | API Key / OAuth | 15-1000 RPM | Free tier available |

### Social Media

| Platform | API | n8n Approach | Key Gotchas |
|----------|-----|-------------|-------------|
| Instagram | Meta Graph API v21.0 | HTTP Request node | Must use Business/Creator account; video processing is async (poll for completion); 25 posts/day limit |
| YouTube | Data API v3 | HTTP Request + OAuth2 | Upload via resumable upload; 10,000 unit daily quota; shorts via regular upload with `#Shorts` |
| Twitter/X | X API v2 | HTTP Request | Free tier: 1,500 tweets/month; threads require chaining tweet IDs |
| LinkedIn | Marketing API | HTTP Request + OAuth | Requires Company Page admin; UGC Posts API for sharing |
| TikTok | Content Posting API | HTTP Request | Requires TikTok for Developers account |

### Storage & Database

| Service | n8n Node | Key Setup |
|---------|----------|-----------|
| Supabase | Built-in Supabase node | Host + service_role key |
| PostgreSQL | Built-in Postgres node | Standard connection string |
| Google Sheets | Built-in node | OAuth2 |
| Cloudflare R2 | AWS S3 node (compatible) | S3 credentials + custom endpoint |
| Google Drive | Built-in node | OAuth2 |

### Audio/Visual

| Service | n8n Approach | Key Notes |
|---------|-------------|-----------|
| ElevenLabs | Community node or HTTP Request | Install via Settings > Community Nodes; `eleven_multilingual_v2` model for Hindi |
| Canva | HTTP Request + OAuth2 | Requires Canva for Teams; autofill templates via API |
| Midjourney | HTTP Request (via proxy API) | No official API; use third-party proxies or Ideogram instead |

### Communication

| Service | n8n Node | Setup |
|---------|----------|-------|
| Discord | Built-in Discord node | Bot token + channel ID |
| Slack | Built-in Slack node | OAuth2 app |
| Telegram | Built-in Telegram node | Bot token from @BotFather |
| Email (SMTP) | Built-in Send Email node | SMTP credentials |
| Buttondown | HTTP Request | API key |

### Scheduling

| Service | n8n Approach | Notes |
|---------|-------------|-------|
| Publer | HTTP Request | Full API for scheduling + analytics |
| Buffer | HTTP Request | Simpler API, fewer platforms |
| Later | HTTP Request | Good for Instagram-first |

---

## 19. Learning Resources

### Official Documentation

- **n8n Docs**: https://docs.n8n.io/
- **API Reference**: https://docs.n8n.io/api/api-reference/
- **Hosting Guide**: https://docs.n8n.io/hosting/
- **Docker Setup**: https://docs.n8n.io/hosting/installation/docker/
- **CLI Commands**: https://docs.n8n.io/hosting/cli-commands/
- **Error Handling**: https://docs.n8n.io/flow-logic/error-handling/
- **Webhook Node**: https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.webhook/
- **Anthropic Credentials**: https://docs.n8n.io/integrations/builtin/credentials/anthropic/

### Community & Templates

- **Workflow Templates**: https://n8n.io/workflows/ (9,000+ templates)
- **Community Forum**: https://community.n8n.io/
- **GitHub Repo**: https://github.com/n8n-io/n8n
- **Discord**: https://discord.gg/n8n (unofficial)

### Relevant Template URLs

- Instagram content scheduling: https://n8n.io/workflows/4498
- AI social media content generator: https://n8n.io/workflows/3066
- ElevenLabs text-to-speech: https://n8n.io/workflows/2245
- Auto-retry error recovery: https://n8n.io/workflows/3144

### GitHub Resources

- **n8n-mcp** (MCP server for Claude): https://github.com/czlonkowski/n8n-mcp
- **mcp-n8n-workflow-builder**: https://github.com/salacoste/mcp-n8n-workflow-builder
- **n8n-nodes-elevenlabs** (community node): https://github.com/elevenlabs/elevenlabs-n8n
- **n8n-nodes-cloudflare-r2**: https://github.com/jezweb/n8n-nodes-cloudflare-r2
- **awesome-n8n-templates** (280+ templates): https://github.com/enescingoz/awesome-n8n-templates

### Key Blog Posts

- "Claude Code n8n workflows: the era of self-building agents" - https://www.ability.ai/blog/claude-code-n8n-workflows
- "Build AI Agents with n8n + Claude API" - https://n8nlab.io/blog/build-ai-agents-n8n-claude-api
- "n8n AI Automation: Build Smarter Workflows in 2026" - https://www.lowcode.agency/blog/n8n-ai-automation

---

## Appendix: Importing the Bodhi Workflows

### Step-by-Step Import Process

1. Start n8n (Docker, Railway, or npm)
2. Open the web UI at your n8n URL
3. Click "Add workflow" (top right)
4. Click the three-dot menu > "Import from file"
5. Select the workflow JSON file (e.g., `workflow-daily-verse.json`)
6. The workflow loads in the editor with all nodes and connections
7. **Set up credentials**: Click each node that needs credentials (marked with a warning icon) and select/create the appropriate credential
8. **Test step by step**: Click each node individually and run it to verify data flows correctly
9. **Activate**: Toggle the workflow to Active (top right)

### Import via CLI

```bash
# Import all Bodhi workflows at once
n8n import:workflow --input=/path/to/automation/workflow-daily-verse.json
n8n import:workflow --input=/path/to/automation/workflow-lesson-adapter.json
n8n import:workflow --input=/path/to/automation/workflow-analytics.json
n8n import:workflow --input=/path/to/automation/workflow-content-review.json
```

### Import via API

```bash
for file in automation/workflow-*.json; do
  curl -X POST "http://localhost:5678/api/v1/workflows" \
    -H "X-N8N-API-KEY: your-key" \
    -H "Content-Type: application/json" \
    -d @"$file"
done
```

### Post-Import Checklist

- [ ] All 4 workflows imported successfully
- [ ] Credentials created and assigned to each node
- [ ] Timezone set to Asia/Kolkata in each workflow's settings
- [ ] Test Daily Verse workflow manually (execute one run)
- [ ] Test Lesson Adapter webhook with a sample POST
- [ ] Verify Supabase connectivity (run Fetch Verse node)
- [ ] Verify Claude API works (run a content generation node)
- [ ] Activate Daily Verse (cron) and Analytics (cron) workflows
- [ ] Keep Content Review and Lesson Adapter inactive until needed
