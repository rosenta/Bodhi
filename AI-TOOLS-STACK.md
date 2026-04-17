# Project Bodhi: AI Tools & Automation Stack

## The $101/month Content Machine

A solo creator can maintain **daily multi-platform publishing** with ~30 minutes of daily effort after initial setup.

---

## Recommended Stack

### Core Infrastructure (Free/Near-Free)
| Component | Tool | Cost |
|-----------|------|------|
| Verse database & CMS | Supabase (free tier) | $0 |
| Website | Next.js on Vercel (free tier) | $0 |
| Workflow automation | n8n self-hosted on Railway | $5/mo |
| Vector search for chatbot | Supabase pgvector | $0 |
| File storage (audio, images) | Cloudflare R2 | ~$1/mo |

### Content Creation
| Component | Tool | Cost |
|-----------|------|------|
| AI writing & translation | Claude API (Sonnet) | ~$20/mo |
| Design & templates | Canva Pro | $13/mo |
| AI voiceover (Hindi/English) | ElevenLabs Creator | $22/mo |
| Video editing | CapCut Pro | $8/mo |
| AI video generation | Kling AI | $10/mo |
| Image generation | Midjourney Basic | $10/mo |

### Distribution
| Component | Tool | Cost |
|-----------|------|------|
| Scheduling | Publer Professional | $12/mo |
| Podcast hosting | Spotify for Podcasters | $0 |
| Email newsletter | Buttondown / Substack | $0 |

### **Total: ~$101/month**

---

## The Automated Daily Pipeline

```
5:00 AM — n8n triggers automatically:

  [1] Fetch next verse from Supabase queue
       |
  [2] Claude API → generates ALL content variants:
       ├── Quote card text
       ├── Instagram carousel (10 slides)
       ├── Reel script (30-60 sec)
       ├── Blog post (500-800 words)
       ├── Email newsletter snippet
       └── Podcast script
       |
  [3] Canva API → generates visuals from templates:
       ├── Quote card image
       ├── Carousel slides
       └── Reel thumbnail
       |
  [4] ElevenLabs API → generates narration:
       ├── English voiceover
       └── Hindi voiceover
       |
  [5] Assets stored in Cloudflare R2
       |
  [6] Blog post published to website (Vercel API)
       |
  [7] Social posts queued in Publer for optimal times
```

### Human Review: 15-30 min/day
1. Review generated content in dashboard
2. Approve, tweak, or regenerate
3. Create 1-2 reels/week using CapCut with AI-generated scripts

### Weekly: 30 min
1. Review analytics (n8n pulls from Instagram/YouTube APIs)
2. Adjust content calendar based on performance
3. Batch-generate podcast episodes via Google NotebookLM

---

## Tool-by-Tool Recommendations

### Text Extraction & Translation
| Need | Best Tool | Budget Alternative |
|------|-----------|-------------------|
| Sanskrit/Devanagari OCR | Google Cloud Vision API ($1.50/1000 pages) | Tesseract OCR (free, lower accuracy) |
| Translation pipeline | Claude API with few-shot prompts | Google Gemini 1.5 Pro (free tier) |
| Existing digital corpora | sanskritdocuments.org, GRETIL archive | Use before OCR-ing from scratch |

### Content Generation
| Need | Best Tool | Budget Alternative |
|------|-----------|-------------------|
| Quote cards & carousels | Canva Pro ($13/mo) batch create | Figma + Google Sheets (free) |
| AI video for reels | Kling AI ($10/mo) | Pika Labs (free tier) |
| Voiceover | ElevenLabs ($22/mo) | Google Cloud TTS (free tier) |
| Podcast generation | Google NotebookLM (free) | Already free |
| Sanskrit recitation | **Human recording** (AI can't do Sanskrit prosody well) | -- |

### Visual Design
| Need | Best Tool | Budget Alternative |
|------|-----------|-------------------|
| Spiritual imagery | Midjourney v6/v7 ($10/mo) | Ideogram 2.0 (free, great for text) |
| Logo & brand | Looka ($20-65 one-time) | Midjourney + Figma (free) |
| Templates | Canva Pro (included above) | -- |

### Video Production
| Need | Best Tool | Budget Alternative |
|------|-----------|-------------------|
| Video editing | Descript ($24/mo) | CapCut (free desktop) |
| Animation (Guru-Disciple stories) | Animaker ($20/mo) | Canva animation (free) |
| Subtitles/captions | Descript or CapCut | Whisper (free, local) |
| Cross-platform repurposing | Opus Clip ($19/mo) | CapCut auto-reframe (free) |

### Agentic Workflows
| Need | Best Tool | Budget Alternative |
|------|-----------|-------------------|
| Pipeline orchestration | n8n self-hosted (free) | Make.com (1000 ops/mo free) |
| Complex agent logic | Claude Agent SDK / LangGraph | CrewAI (open source) |
| Code-free agents | CrewAI | -- |

### Community & Engagement
| Need | Best Tool | Budget Alternative |
|------|-----------|-------------------|
| AI chatbot (verse Q&A) | Claude API + Supabase pgvector (RAG) | Vercel AI SDK + Ollama (free) |
| Community platform | Circle.so ($89/mo) | Discord or WhatsApp Community (free) |
| Verse recommendations | Simple tag-based system in Supabase | -- |

---

## Useful MCP Servers for Claude Code Workflow
1. **Filesystem** — read/write verse files and generated content
2. **PostgreSQL/Supabase** — query verse database
3. **Brave Search** — research trending spiritual topics
4. **Google Drive** — shared content assets
5. **Slack/Discord** — post to community channels
6. **Custom Verse API** — `get_verse(id)`, `get_verses_by_theme(theme)`, `get_todays_verse()`

---

## Key Insight: 775 Verses = 2+ Years of Daily Content

Map it out in advance:
- Organize by theme, aligned with Hindu calendar events
- Maha Shivaratri → verses about the Self
- Guru Purnima → Guru-Disciple verses
- Navratri → verses about Maya/Shakti
- Regular days → systematic progression through the text

---

## Risks & Mitigations
1. **Sanskrit OCR accuracy** → Use existing digital corpora first, OCR only for Hindi commentary
2. **AI translation quality** → Scholar reviews first 50 verses as benchmarks, use as few-shot examples
3. **Spiritual content feeling hollow** → Ground in original text, be transparent about AI use, human editorial oversight
4. **Platform formatting** → Design templates natively sized for each platform from day 1
5. **Burnout** → The finite 775-verse library IS the advantage — plan the whole thing upfront
