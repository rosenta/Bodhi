# Project Bodhi: REST API Design

Base URL: `https://bodhi.example.com/api` (Next.js API routes on Vercel)

Authentication: Supabase Auth (JWT in `Authorization: Bearer <token>` header).
Public endpoints require no auth. User endpoints require a valid session.

---

## Verses

### GET /api/verses

List all verses with pagination, filtering, and search.

**Auth:** Public

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | int | 1 | Page number (1-indexed) |
| `limit` | int | 20 | Items per page (max 100) |
| `text` | string | — | Filter by text slug: `vivekachudamani` or `yoga-darshan` |
| `theme` | string | — | Filter by theme slug (e.g. `discrimination`, `samadhi`) |
| `pada` | int | — | Filter Yoga Sutras by pada number (1-4) |
| `tags` | string | — | Comma-separated tag filter (e.g. `liberation,self-inquiry`) |
| `sort` | string | `verse_order` | Sort field: `verse_order`, `created_at`, `verse_number` |
| `order` | string | `asc` | Sort direction: `asc` or `desc` |

**Response: 200 OK**

```json
{
  "data": [
    {
      "id": "uuid",
      "text_id": "uuid",
      "text_slug": "vivekachudamani",
      "verse_number": "2",
      "pada": null,
      "sanskrit": "जन्तूनां नरजन्म...",
      "english_translation": "Among living beings...",
      "reel_hook": "You beat odds of 1 in 400 trillion...",
      "tags": ["human-birth", "discrimination"],
      "themes": [
        { "slug": "discrimination", "name": "Discrimination", "is_primary": true }
      ]
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 225,
    "total_pages": 12
  }
}
```

**Notes:**
- List view returns a compact projection (no `modern_interpretation`, `practice_prompt`, `why_selected`).
- Full data is available on the single-verse endpoint.

---

### GET /api/verses/:id

Get a single verse with all fields, related themes, and generated content.

**Auth:** Public

**Response: 200 OK**

```json
{
  "data": {
    "id": "uuid",
    "text": {
      "id": "uuid",
      "slug": "vivekachudamani",
      "title": "Vivekachudamani",
      "author": "Adi Shankaracharya"
    },
    "verse_number": "2",
    "verse_order": 1,
    "pada": null,
    "pada_number": null,
    "sanskrit": "जन्तूनां नरजन्म...",
    "transliteration": null,
    "hindi_meaning": null,
    "english_translation": "Among living beings...",
    "modern_interpretation": "You have won an impossibly rare cosmic lottery...",
    "practical_application": null,
    "reel_hook": "You beat odds of 1 in 400 trillion...",
    "practice_prompt": "Spend 5 minutes today sitting quietly...",
    "why_selected": "This opening verse creates urgency...",
    "audio_url": null,
    "tags": ["human-birth", "discrimination", "rarity"],
    "themes": [
      { "slug": "discrimination", "name": "Discrimination", "is_primary": true }
    ],
    "content_pieces": [
      {
        "id": "uuid",
        "content_type": "quote_card",
        "title": "The Cosmic Lottery",
        "status": "published",
        "published_at": "2026-04-04T05:00:00Z"
      }
    ],
    "adjacent": {
      "prev": { "id": "uuid", "verse_number": "1" },
      "next": { "id": "uuid", "verse_number": "6" }
    }
  }
}
```

**Error: 404 Not Found**

```json
{
  "error": {
    "code": "VERSE_NOT_FOUND",
    "message": "No verse found with the given ID."
  }
}
```

---

### GET /api/verses/daily

Get today's featured verse.

**Auth:** Public

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `date` | string (YYYY-MM-DD) | today | Fetch a specific date's verse |

**Response: 200 OK**

```json
{
  "data": {
    "featured_date": "2026-04-04",
    "note": "Launch day: The rarity of human birth",
    "verse": {
      "id": "uuid",
      "verse_number": "2",
      "text_slug": "vivekachudamani",
      "sanskrit": "जन्तूनां नरजन्म...",
      "english_translation": "Among living beings...",
      "modern_interpretation": "You have won an impossibly rare cosmic lottery...",
      "reel_hook": "You beat odds of 1 in 400 trillion...",
      "practice_prompt": "Spend 5 minutes today sitting quietly...",
      "themes": [
        { "slug": "discrimination", "name": "Discrimination" }
      ]
    }
  }
}
```

**Error: 404** — no verse scheduled for that date.

---

### GET /api/verses/random

Get a random published verse.

**Auth:** Public

**Response: 200 OK**

Same shape as `GET /api/verses/:id` but randomly selected.

---

## Search

### GET /api/search

Full-text search across verses using trigram similarity.

**Auth:** Public

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `q` | string (required) | — | Search query (min 2 characters) |
| `text` | string | — | Filter by text slug |
| `limit` | int | 20 | Max results (max 50) |
| `offset` | int | 0 | Pagination offset |

**Response: 200 OK**

```json
{
  "data": [
    {
      "id": "uuid",
      "verse_number": "2",
      "text_slug": "vivekachudamani",
      "sanskrit": "जन्तूनां नरजन्म...",
      "english_translation": "Among living beings...",
      "modern_interpretation": "You have won an impossibly rare cosmic lottery...",
      "similarity_score": 0.72,
      "matched_field": "english_translation"
    }
  ],
  "meta": {
    "query": "human birth",
    "total": 5,
    "limit": 20,
    "offset": 0
  }
}
```

**Notes:**
- Searches across `english_translation`, `modern_interpretation`, `sanskrit`, and `tags`.
- Results are ranked by trigram similarity score (descending).
- Returns 400 if `q` is missing or under 2 characters.

---

## Texts

### GET /api/texts

List all source texts.

**Auth:** Public

**Response: 200 OK**

```json
{
  "data": [
    {
      "id": "uuid",
      "slug": "vivekachudamani",
      "title": "Vivekachudamani",
      "title_sanskrit": "विवेकचूडामणि",
      "author": "Adi Shankaracharya",
      "description": "The Crest-Jewel of Discrimination...",
      "total_verses": 580,
      "verse_count_in_db": 30
    },
    {
      "id": "uuid",
      "slug": "yoga-darshan",
      "title": "Yoga Darshan - Patanjali Yoga Sutras",
      "title_sanskrit": "योगदर्शन — पतञ्जलि योगसूत्र",
      "author": "Maharishi Patanjali",
      "description": "The foundational text of Raja Yoga...",
      "total_verses": 195,
      "verse_count_in_db": 195
    }
  ]
}
```

---

## Themes

### GET /api/themes

List all themes with verse counts.

**Auth:** Public

**Response: 200 OK**

```json
{
  "data": [
    {
      "id": "uuid",
      "slug": "discrimination",
      "name": "Discrimination",
      "name_sanskrit": "विवेक",
      "description": "Discerning the real from the unreal...",
      "color_hex": "#8B5CF6",
      "verse_count": 42
    }
  ]
}
```

---

## Reading Progress

### GET /api/texts/:textId/progress

Get the authenticated user's reading progress for a text.

**Auth:** Required (user)

**Response: 200 OK**

```json
{
  "data": {
    "text_id": "uuid",
    "text_slug": "vivekachudamani",
    "total_verses": 30,
    "read_verses": 12,
    "progress_pct": 40.0,
    "last_read": {
      "verse_id": "uuid",
      "verse_number": "78",
      "read_at": "2026-04-03T14:22:00Z"
    },
    "read_verse_ids": ["uuid1", "uuid2", "..."]
  }
}
```

### POST /api/reading-progress

Mark a verse as read.

**Auth:** Required (user)

**Request Body:**

```json
{
  "verse_id": "uuid",
  "time_spent_s": 120
}
```

**Response: 201 Created**

```json
{
  "data": {
    "id": "uuid",
    "verse_id": "uuid",
    "read_at": "2026-04-04T10:00:00Z",
    "completed": true
  }
}
```

**Notes:**
- Upserts on `(user_id, verse_id)` — re-reading updates the timestamp and time_spent.

---

## Bookmarks

### GET /api/bookmarks

List the authenticated user's bookmarked verses.

**Auth:** Required (user)

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | int | 1 | Page number |
| `limit` | int | 20 | Items per page |
| `text` | string | — | Filter by text slug |

**Response: 200 OK**

```json
{
  "data": [
    {
      "id": "uuid",
      "verse": {
        "id": "uuid",
        "verse_number": "20",
        "text_slug": "vivekachudamani",
        "sanskrit": "ब्रह्म सत्यं जगन्मिथ्या...",
        "english_translation": "Brahman alone is real...",
        "reel_hook": "Everything you're chasing is the movie..."
      },
      "note": "This one really hit me today.",
      "created_at": "2026-04-04T10:30:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 5
  }
}
```

### POST /api/bookmarks

Save a verse as a bookmark.

**Auth:** Required (user)

**Request Body:**

```json
{
  "verse_id": "uuid",
  "note": "Optional personal note"
}
```

**Response: 201 Created**

```json
{
  "data": {
    "id": "uuid",
    "verse_id": "uuid",
    "note": "Optional personal note",
    "created_at": "2026-04-04T10:30:00Z"
  }
}
```

**Error: 409 Conflict** — bookmark already exists for this verse.

### DELETE /api/bookmarks/:id

Remove a bookmark.

**Auth:** Required (user, owner)

**Response: 204 No Content**

---

## Reflections

### GET /api/reflections

List the authenticated user's journal reflections.

**Auth:** Required (user)

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | int | 1 | Page number |
| `limit` | int | 20 | Items per page |
| `verse_id` | string | — | Filter by verse |

**Response: 200 OK**

```json
{
  "data": [
    {
      "id": "uuid",
      "verse": {
        "id": "uuid",
        "verse_number": "32",
        "text_slug": "vivekachudamani",
        "reel_hook": "The most sacred prayer..."
      },
      "body": "Today I realized that every time I ask 'Who am I?'...",
      "is_private": true,
      "created_at": "2026-04-04T11:00:00Z",
      "updated_at": "2026-04-04T11:00:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 8
  }
}
```

### POST /api/reflections

Save a journal reflection for a verse.

**Auth:** Required (user)

**Request Body:**

```json
{
  "verse_id": "uuid",
  "body": "This verse made me realize...",
  "is_private": true
}
```

**Response: 201 Created**

```json
{
  "data": {
    "id": "uuid",
    "verse_id": "uuid",
    "body": "This verse made me realize...",
    "is_private": true,
    "created_at": "2026-04-04T11:00:00Z"
  }
}
```

### PATCH /api/reflections/:id

Update an existing reflection.

**Auth:** Required (user, owner)

**Request Body:**

```json
{
  "body": "Updated reflection text...",
  "is_private": false
}
```

**Response: 200 OK**

### DELETE /api/reflections/:id

Delete a reflection.

**Auth:** Required (user, owner)

**Response: 204 No Content**

---

## Analytics (Internal)

### POST /api/analytics/verse-view

Track a verse view (called by the frontend automatically).

**Auth:** Optional (anonymous allowed)

**Request Body:**

```json
{
  "verse_id": "uuid",
  "source": "web",
  "session_id": "anon-session-abc123"
}
```

**Response: 201 Created** (no body)

---

## Content (Admin / Internal)

### GET /api/content

List generated content pieces.

**Auth:** Required (admin)

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `verse_id` | string | — | Filter by verse |
| `type` | string | — | Filter by content type |
| `status` | string | — | Filter by status |
| `platform` | string | — | Filter by platform |
| `page` | int | 1 | Page number |
| `limit` | int | 20 | Items per page |

### POST /api/content/generate

Trigger AI content generation for a verse.

**Auth:** Required (admin)

**Request Body:**

```json
{
  "verse_id": "uuid",
  "content_types": ["quote_card", "carousel", "reel_script", "blog_post"],
  "platform": "instagram"
}
```

**Response: 202 Accepted**

```json
{
  "data": {
    "job_id": "uuid",
    "status": "queued",
    "content_types": ["quote_card", "carousel", "reel_script", "blog_post"]
  }
}
```

**Notes:**
- This queues a background job in n8n.
- Poll `GET /api/content?verse_id=X` for results.

---

## Error Format

All errors follow a consistent envelope:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable description",
    "details": {}
  }
}
```

Common error codes:

| Code | HTTP Status | Meaning |
|------|-------------|---------|
| `VALIDATION_ERROR` | 400 | Invalid request parameters |
| `UNAUTHORIZED` | 401 | Missing or invalid auth token |
| `FORBIDDEN` | 403 | Authenticated but not allowed |
| `NOT_FOUND` | 404 | Resource does not exist |
| `CONFLICT` | 409 | Resource already exists (e.g. duplicate bookmark) |
| `RATE_LIMITED` | 429 | Too many requests |
| `INTERNAL_ERROR` | 500 | Unexpected server error |

---

## Implementation Notes

### Next.js API Routes Structure

```
app/
  api/
    verses/
      route.ts              # GET /api/verses
      [id]/
        route.ts            # GET /api/verses/:id
      daily/
        route.ts            # GET /api/verses/daily
      random/
        route.ts            # GET /api/verses/random
    texts/
      route.ts              # GET /api/texts
      [textId]/
        progress/
          route.ts          # GET /api/texts/:textId/progress
    themes/
      route.ts              # GET /api/themes
    search/
      route.ts              # GET /api/search
    bookmarks/
      route.ts              # GET, POST /api/bookmarks
      [id]/
        route.ts            # DELETE /api/bookmarks/:id
    reflections/
      route.ts              # GET, POST /api/reflections
      [id]/
        route.ts            # PATCH, DELETE /api/reflections/:id
    reading-progress/
      route.ts              # POST /api/reading-progress
    analytics/
      verse-view/
        route.ts            # POST /api/analytics/verse-view
    content/
      route.ts              # GET /api/content (admin)
      generate/
        route.ts            # POST /api/content/generate (admin)
```

### Supabase Client Usage

```typescript
// Public endpoint example (no auth needed)
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!  // server-side only
);

// GET /api/verses with pagination and filtering
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const page = parseInt(searchParams.get('page') ?? '1');
  const limit = Math.min(parseInt(searchParams.get('limit') ?? '20'), 100);
  const text = searchParams.get('text');
  const theme = searchParams.get('theme');

  let query = supabase
    .from('verses')
    .select('*, texts!inner(slug, title), verse_themes(themes(slug, name, is_primary))', { count: 'exact' })
    .eq('is_published', true)
    .range((page - 1) * limit, page * limit - 1)
    .order('verse_order', { ascending: true });

  if (text) query = query.eq('texts.slug', text);
  if (theme) query = query.eq('verse_themes.themes.slug', theme);

  const { data, count, error } = await query;
  // ... return response
}
```

### Rate Limiting

- Public endpoints: 100 requests/minute per IP
- Authenticated endpoints: 200 requests/minute per user
- Content generation: 10 requests/hour per admin
- Analytics: 1000 requests/minute (high volume expected)

### Caching Strategy

| Endpoint | Cache TTL | Strategy |
|----------|-----------|----------|
| GET /api/verses | 5 min | CDN (Vercel Edge) |
| GET /api/verses/:id | 5 min | CDN (Vercel Edge) |
| GET /api/verses/daily | 1 hour | CDN + stale-while-revalidate |
| GET /api/verses/random | no cache | — |
| GET /api/search | 1 min | CDN |
| GET /api/texts | 1 hour | CDN |
| GET /api/themes | 1 hour | CDN |
| User endpoints | no cache | — |
