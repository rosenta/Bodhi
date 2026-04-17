-- =============================================================================
-- Project Bodhi: Complete Supabase/PostgreSQL Schema
-- Multi-platform content system for Vivekachudamani & Yoga Darshan
-- =============================================================================

-- Enable required extensions
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";
create extension if not exists "pg_trgm";    -- trigram index for full-text search


-- =============================================================================
-- ENUM TYPES
-- =============================================================================

create type content_status as enum (
  'draft',
  'in_review',
  'approved',
  'published',
  'archived'
);

create type content_type_enum as enum (
  'quote_card',
  'carousel',
  'reel_script',
  'blog_post',
  'email_snippet',
  'podcast_script',
  'thread',
  'story'
);

create type platform_enum as enum (
  'instagram',
  'youtube',
  'twitter',
  'linkedin',
  'substack',
  'spotify',
  'website',
  'whatsapp'
);


-- =============================================================================
-- CORE TABLES
-- =============================================================================

-- Source texts (Vivekachudamani, Yoga Darshan)
create table texts (
  id            uuid primary key default uuid_generate_v4(),
  slug          text not null unique,
  title         text not null,
  title_sanskrit text,
  author        text not null,
  description   text,
  total_verses  int not null default 0,
  language      text not null default 'sanskrit',
  source_info   text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- Themes (discrimination, maya, self-inquiry, etc.)
create table themes (
  id            uuid primary key default uuid_generate_v4(),
  slug          text not null unique,
  name          text not null,
  name_sanskrit text,
  description   text,
  color_hex     text,               -- for UI badge color
  icon          text,               -- optional icon identifier
  sort_order    int not null default 0,
  created_at    timestamptz not null default now()
);

-- Verses / Sutras
create table verses (
  id                    uuid primary key default uuid_generate_v4(),
  text_id               uuid not null references texts(id) on delete cascade,
  verse_number          text not null,          -- e.g. "2" or "1.1" (pada-qualified)
  verse_order           int not null,           -- global sort order within the text
  pada                  text,                   -- for Yoga Sutras: Samadhi, Sadhana, Vibhuti, Kaivalya
  pada_number           int,                    -- 1-4
  sanskrit              text not null,
  transliteration       text,
  hindi_meaning         text,
  english_translation   text not null,
  modern_interpretation text,
  practical_application text,                   -- practical guidance
  reel_hook             text,                   -- short punchy hook for reels
  practice_prompt       text,                   -- guided practice / journaling prompt
  why_selected          text,                   -- editorial note on why this verse matters
  audio_url             text,                   -- link to audio narration (R2)
  tags                  text[] not null default '{}',
  is_published          boolean not null default true,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),

  constraint uq_text_verse unique (text_id, verse_number)
);

-- Many-to-many: verses <-> themes
create table verse_themes (
  verse_id   uuid not null references verses(id) on delete cascade,
  theme_id   uuid not null references themes(id) on delete cascade,
  is_primary boolean not null default false,    -- one primary theme per verse
  created_at timestamptz not null default now(),

  primary key (verse_id, theme_id)
);


-- =============================================================================
-- CONTENT TABLES
-- =============================================================================

-- Daily featured verse schedule
create table daily_verse (
  id            uuid primary key default uuid_generate_v4(),
  verse_id      uuid not null references verses(id) on delete cascade,
  featured_date date not null unique,
  note          text,                   -- editorial note for the day
  created_at    timestamptz not null default now()
);

-- Generated content pieces linked to verses
create table content_pieces (
  id            uuid primary key default uuid_generate_v4(),
  verse_id      uuid not null references verses(id) on delete cascade,
  content_type  content_type_enum not null,
  title         text,
  body          text not null,                  -- the generated content
  media_urls    text[] not null default '{}',   -- images, videos, audio stored in R2
  platform      platform_enum,                  -- target platform (null = multi-platform)
  status        content_status not null default 'draft',
  scheduled_at  timestamptz,                    -- when to publish
  published_at  timestamptz,
  ai_model      text,                           -- e.g. "claude-sonnet-4-20250514"
  ai_prompt_id  text,                           -- reference to prompt template used
  revision      int not null default 1,
  metadata      jsonb not null default '{}',    -- flexible: slide_count, word_count, etc.
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);


-- =============================================================================
-- USER TABLES (future-ready, behind RLS)
-- =============================================================================

-- Users (synced from Supabase Auth)
create table users (
  id            uuid primary key references auth.users(id) on delete cascade,
  display_name  text,
  avatar_url    text,
  preferred_language text not null default 'en',
  timezone      text not null default 'Asia/Kolkata',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- Reading progress per verse
create table reading_progress (
  id            uuid primary key default uuid_generate_v4(),
  user_id       uuid not null references users(id) on delete cascade,
  verse_id      uuid not null references verses(id) on delete cascade,
  read_at       timestamptz not null default now(),
  time_spent_s  int,                    -- seconds spent reading
  completed     boolean not null default true,

  constraint uq_user_verse_progress unique (user_id, verse_id)
);

-- Bookmarks / favorited verses
create table bookmarks (
  id            uuid primary key default uuid_generate_v4(),
  user_id       uuid not null references users(id) on delete cascade,
  verse_id      uuid not null references verses(id) on delete cascade,
  note          text,
  created_at    timestamptz not null default now(),

  constraint uq_user_verse_bookmark unique (user_id, verse_id)
);

-- User reflections / journal entries
create table reflections (
  id            uuid primary key default uuid_generate_v4(),
  user_id       uuid not null references users(id) on delete cascade,
  verse_id      uuid not null references verses(id) on delete cascade,
  body          text not null,
  is_private    boolean not null default true,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);


-- =============================================================================
-- ANALYTICS TABLES
-- =============================================================================

-- Verse view tracking (append-only, aggregate later)
create table verse_views (
  id            uuid primary key default uuid_generate_v4(),
  verse_id      uuid not null references verses(id) on delete cascade,
  user_id       uuid references users(id) on delete set null,
  session_id    text,                   -- anonymous session tracking
  source        text,                   -- 'web', 'api', 'share_link'
  referrer      text,
  viewed_at     timestamptz not null default now()
);

-- Content performance metrics per piece per platform
create table content_performance (
  id              uuid primary key default uuid_generate_v4(),
  content_piece_id uuid not null references content_pieces(id) on delete cascade,
  platform        platform_enum not null,
  impressions     int not null default 0,
  reach           int not null default 0,
  likes           int not null default 0,
  comments        int not null default 0,
  shares          int not null default 0,
  saves           int not null default 0,
  clicks          int not null default 0,
  watch_time_s    int not null default 0,  -- for video content
  measured_at     timestamptz not null default now(),
  raw_data        jsonb not null default '{}',

  constraint uq_piece_platform_date unique (content_piece_id, platform, measured_at)
);


-- =============================================================================
-- INDEXES
-- =============================================================================

-- Core lookups
create index idx_verses_text_id        on verses (text_id);
create index idx_verses_verse_order    on verses (text_id, verse_order);
create index idx_verses_pada           on verses (pada_number) where pada_number is not null;
create index idx_verses_published      on verses (is_published) where is_published = true;
create index idx_verses_tags           on verses using gin (tags);

-- Full-text search: trigram indexes for fuzzy search across key fields
create index idx_verses_sanskrit_trgm  on verses using gin (sanskrit gin_trgm_ops);
create index idx_verses_english_trgm   on verses using gin (english_translation gin_trgm_ops);
create index idx_verses_modern_trgm    on verses using gin (modern_interpretation gin_trgm_ops)
  where modern_interpretation is not null;

-- Theme lookups
create index idx_verse_themes_theme    on verse_themes (theme_id);
create index idx_verse_themes_primary  on verse_themes (verse_id) where is_primary = true;

-- Content tables
create index idx_daily_verse_date      on daily_verse (featured_date);
create index idx_content_pieces_verse  on content_pieces (verse_id);
create index idx_content_pieces_status on content_pieces (status);
create index idx_content_pieces_sched  on content_pieces (scheduled_at)
  where status = 'approved' and scheduled_at is not null;
create index idx_content_pieces_type   on content_pieces (content_type);

-- User tables
create index idx_reading_progress_user on reading_progress (user_id);
create index idx_bookmarks_user        on bookmarks (user_id);
create index idx_reflections_user      on reflections (user_id);
create index idx_reflections_verse     on reflections (verse_id);

-- Analytics
create index idx_verse_views_verse     on verse_views (verse_id);
create index idx_verse_views_time      on verse_views (viewed_at);
create index idx_content_perf_piece    on content_performance (content_piece_id);
create index idx_content_perf_platform on content_performance (platform);


-- =============================================================================
-- FUNCTIONS
-- =============================================================================

-- Auto-update updated_at on row modification
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Apply updated_at triggers
create trigger trg_texts_updated_at
  before update on texts for each row execute function set_updated_at();

create trigger trg_verses_updated_at
  before update on verses for each row execute function set_updated_at();

create trigger trg_content_pieces_updated_at
  before update on content_pieces for each row execute function set_updated_at();

create trigger trg_users_updated_at
  before update on users for each row execute function set_updated_at();

create trigger trg_reflections_updated_at
  before update on reflections for each row execute function set_updated_at();


-- Full-text search function across verses
create or replace function search_verses(
  search_query text,
  limit_count int default 20,
  offset_count int default 0
)
returns table (
  id uuid,
  text_id uuid,
  verse_number text,
  sanskrit text,
  english_translation text,
  modern_interpretation text,
  similarity_score real
)
language sql stable
as $$
  select
    v.id,
    v.text_id,
    v.verse_number,
    v.sanskrit,
    v.english_translation,
    v.modern_interpretation,
    greatest(
      similarity(v.english_translation, search_query),
      similarity(coalesce(v.modern_interpretation, ''), search_query),
      similarity(v.sanskrit, search_query)
    ) as similarity_score
  from verses v
  where v.is_published = true
    and (
      v.english_translation % search_query
      or coalesce(v.modern_interpretation, '') % search_query
      or v.sanskrit % search_query
      or v.tags @> array[lower(search_query)]
    )
  order by similarity_score desc
  limit limit_count
  offset offset_count;
$$;


-- Get today's featured verse with full data
create or replace function get_daily_verse(target_date date default current_date)
returns table (
  verse_id uuid,
  verse_number text,
  text_title text,
  sanskrit text,
  english_translation text,
  modern_interpretation text,
  reel_hook text,
  practice_prompt text,
  theme_names text[]
)
language sql stable
as $$
  select
    v.id as verse_id,
    v.verse_number,
    t.title as text_title,
    v.sanskrit,
    v.english_translation,
    v.modern_interpretation,
    v.reel_hook,
    v.practice_prompt,
    array_agg(th.name) filter (where th.name is not null) as theme_names
  from daily_verse dv
  join verses v on v.id = dv.verse_id
  join texts t on t.id = v.text_id
  left join verse_themes vt on vt.verse_id = v.id
  left join themes th on th.id = vt.theme_id
  where dv.featured_date = target_date
  group by v.id, v.verse_number, t.title, v.sanskrit,
           v.english_translation, v.modern_interpretation,
           v.reel_hook, v.practice_prompt;
$$;


-- Get a random published verse
create or replace function get_random_verse()
returns table (
  id uuid,
  text_id uuid,
  verse_number text,
  sanskrit text,
  english_translation text,
  modern_interpretation text,
  reel_hook text,
  practice_prompt text
)
language sql volatile
as $$
  select
    v.id, v.text_id, v.verse_number, v.sanskrit,
    v.english_translation, v.modern_interpretation,
    v.reel_hook, v.practice_prompt
  from verses v
  where v.is_published = true
  order by random()
  limit 1;
$$;


-- Get reading progress summary for a user on a given text
create or replace function get_reading_progress(
  p_user_id uuid,
  p_text_id uuid
)
returns table (
  total_verses bigint,
  read_verses bigint,
  progress_pct numeric
)
language sql stable
as $$
  select
    (select count(*) from verses where text_id = p_text_id and is_published = true) as total_verses,
    (select count(distinct rp.verse_id)
     from reading_progress rp
     join verses v on v.id = rp.verse_id
     where rp.user_id = p_user_id
       and v.text_id = p_text_id
       and rp.completed = true) as read_verses,
    round(
      (select count(distinct rp.verse_id)
       from reading_progress rp
       join verses v on v.id = rp.verse_id
       where rp.user_id = p_user_id
         and v.text_id = p_text_id
         and rp.completed = true)::numeric
      /
      nullif((select count(*) from verses where text_id = p_text_id and is_published = true), 0)::numeric
      * 100, 1
    ) as progress_pct;
$$;


-- =============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================================================

-- Enable RLS on all tables
alter table texts              enable row level security;
alter table themes             enable row level security;
alter table verses             enable row level security;
alter table verse_themes       enable row level security;
alter table daily_verse        enable row level security;
alter table content_pieces     enable row level security;
alter table users              enable row level security;
alter table reading_progress   enable row level security;
alter table bookmarks          enable row level security;
alter table reflections        enable row level security;
alter table verse_views        enable row level security;
alter table content_performance enable row level security;

-- PUBLIC READ policies (anyone can read published content)
create policy "Public read texts"
  on texts for select
  using (true);

create policy "Public read themes"
  on themes for select
  using (true);

create policy "Public read published verses"
  on verses for select
  using (is_published = true);

create policy "Public read verse themes"
  on verse_themes for select
  using (true);

create policy "Public read daily verse"
  on daily_verse for select
  using (true);

create policy "Public read published content"
  on content_pieces for select
  using (status = 'published');

-- ADMIN write policies (service_role bypasses RLS; these are for admin users)
-- In practice, Supabase service_role key bypasses RLS entirely.
-- These policies protect against direct client-side mutations.

-- USER-SCOPED policies (authenticated users own their data)
create policy "Users read own profile"
  on users for select
  using (auth.uid() = id);

create policy "Users update own profile"
  on users for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "Users insert own profile"
  on users for insert
  with check (auth.uid() = id);

-- Reading progress: users own their progress
create policy "Users manage own reading progress"
  on reading_progress for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Bookmarks: users own their bookmarks
create policy "Users manage own bookmarks"
  on bookmarks for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Reflections: users see own; public reflections visible to all
create policy "Users manage own reflections"
  on reflections for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Public read shared reflections"
  on reflections for select
  using (is_private = false);

-- Verse views: anyone can insert (anonymous tracking), read is admin-only
create policy "Anyone can log verse views"
  on verse_views for insert
  with check (true);

-- Content performance: read-only for admin (service_role handles writes)
create policy "Authenticated read content performance"
  on content_performance for select
  using (auth.role() = 'authenticated');
