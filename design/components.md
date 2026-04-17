# Project Bodhi -- Component Library

> Each component is specified with: purpose, layout, states, interactions, responsive behavior, and accessibility notes.

---

## 1. VerseCard (Full Viewport Verse Display)

### Purpose

The centerpiece of the experience. Displays a single verse in its full glory: Sanskrit original, audio trigger, divider, and English translation. Occupies the full viewport on the individual verse page. This is the "gallery wall" -- the verse is the painting.

### Layout

```
[Full viewport, content vertically + horizontally centered]

    VIVEKACHUDAMANI -- VERSE 20 OF 580      (verse-number: Cormorant, gold, uppercase, spaced)

    [ Discrimination ]                       (theme-tag: pill, gold border)

    ब्रह्म सत्यं जगन्मिथ्येत्येवंरूपो      (sanskrit: Noto Devanagari, warm accent)
    विनिश्चयः। सोऽयं नित्यानित्य-           (max-width: 700px, line-height: 2.2)
    वस्तुविवेकः समुदाहृतः॥ २०॥

    [ Listen to Sanskrit Recitation ]        (play-btn: pill button, gold border)

    ───────                                  (gold divider: 60px, centered)

    "Brahman alone is real, the world        (translation: Cormorant italic 300)
    is appearance -- this firm conviction    (max-width: 650px, line-height: 1.8)
    is what is called discrimination
    between the eternal and the transient."
```

### Visual Details

- **Background**: `--bg-primary`, full bleed
- **Vertical gold line**: A 1px line descends from the top of the viewport (below nav) to approximately 100px, using `--gradient-gold-line`. This is a `::before` pseudo-element on the section.
- **Verse number**: Cormorant Garamond 400, 0.9rem, `--accent-gold`, letter-spacing 0.3em, uppercase. Margin-bottom: `--space-8` (48px).
- **Theme tag**: Pill shape (`--radius-xl`), 1px border `--border`, 0.75rem uppercase Inter, `--accent-gold` text. Margin-bottom: `--space-6`.
- **Sanskrit**: Noto Sans Devanagari 400, `--text-3xl` (1.6rem), `--accent-warm`, line-height 2.2. Max-width 700px.
- **Divider**: 60px x 1px, `--accent-gold`. Margin: `--space-6` above and below.
- **Translation**: Cormorant Garamond italic 300, `--text-2xl` (1.4rem), `--text-primary`, line-height 1.8. Max-width 650px.

### Entry Animation

Elements appear via `fadeUp` with staggered delays (200ms apart):
1. Verse number (delay: 200ms)
2. Theme tag (delay: 400ms)
3. Sanskrit text (delay: 600ms)
4. Audio button (delay: 800ms)
5. Divider (delay: 1000ms)
6. Translation (delay: 1200ms)

Total reveal time: ~2 seconds. This slowness is intentional -- it mirrors the pace of contemplative reading.

### States

| State | Behavior |
|---|---|
| Loading | Skeleton with pulsing gold-muted placeholders for each text block |
| Default | Full verse display as described |
| Audio playing | Play button text changes to "Pause Recitation", gold fill on button |
| Scrolled past | Verse fades slightly as user scrolls into depth sections below |

### Responsive Behavior

- **Mobile (< 640px)**: Sanskrit drops to `--text-2xl` (1.2rem). Translation drops to `--text-xl`. Padding reduces to `--space-10` top, `--space-8` sides. Vertical gold line shortens to 60px.
- **Tablet**: Standard scale.
- **Large (>= 1440px)**: Sanskrit scales up to `--text-4xl`. Translation scales up to `--text-3xl`. Max-widths increase proportionally.

### Accessibility

- Sanskrit text wrapped in `<div lang="sa">` for screen reader pronunciation.
- Theme tag uses `<span role="text" aria-label="Theme: Discrimination">`.
- Audio button has `aria-label="Play Sanskrit recitation of verse 20"`.

---

## 2. VerseList (Browsable Index)

### Purpose

Displays all verses for a text (580 for Vivekachudamani, 195 for Yoga Sutras) in a browsable, filterable list. Designed for both scanning and deliberate selection. Not an infinite scroll -- uses paginated or "load more" patterns to preserve intentionality.

### Layout

```
[Header area]
    VIVEKACHUDAMANI                          (page title: Cormorant, --text-4xl)
    580 Verses on Self-Realization           (subtitle: Inter 300, --text-secondary)

[Search + Filter bar]
    [ Search verses... ]     [ Theme ▾ ]    (search input + filter dropdown)

[Verse list: 1 column mobile, 2 columns tablet+]
    ┌──────────────────────────┐  ┌──────────────────────────┐
    │  Verse 2                 │  │  Verse 6                 │
    │  [ Discrimination ]      │  │  [ Discrimination ]      │
    │                          │  │                          │
    │  जन्तूनां नरजन्म दुर्लभ │  │  वदन्तु शास्त्राणि      │
    │  मतः पुंस्त्वं...       │  │  यजन्तु देवान्...       │
    │                          │  │                          │
    │  "Among living beings,   │  │  "Let them recite        │
    │   human birth is rare…"  │  │   scriptures, worship…"  │
    └──────────────────────────┘  └──────────────────────────┘

[Load more / Pagination]
    Showing 1-20 of 580          [ Load More Verses ]
```

### List Item Card

Each card in the list is a compact verse preview:
- **Verse number**: Inter 500, 0.75rem, `--accent-gold`, uppercase.
- **Theme tag**: Smaller pill (0.65rem), next to verse number.
- **Sanskrit preview**: First 1-2 lines of Noto Sans Devanagari, `--accent-warm`, 1.0rem. Truncated with ellipsis at 2 lines.
- **Translation preview**: First 1-2 lines of Cormorant italic 300, `--text-primary`, 1.0rem. Truncated.
- **Card background**: `--bg-card`, border `--border`, `--radius-lg`.
- **Card padding**: `--space-5` (24px).
- **Hover**: Background shifts to `--bg-card-hover`, border shifts to `--border-strong`. Transition: `--duration-fast`.
- **Click**: Navigates to the full VerseCard page for that verse.

### Pagination

Display 20 verses per page. A "Load More Verses" button at the bottom loads the next 20 (with fade-in animation). Alternatively, offer discrete page numbers for users who want to jump to a specific range.

Show a small progress indicator: "Showing 1-20 of 580".

### States

| State | Behavior |
|---|---|
| Loading | 6 skeleton cards (2-column grid) with pulsing placeholders |
| Empty (filter yields no results) | Centered message: "No verses match this filter." with option to clear filters |
| Default | Cards displayed in 2-column grid |
| Filtered | Active filter shown as a pill above the list with an "x" to clear |
| Search active | Results update as user types (300ms debounce) |

### Responsive Behavior

- **Mobile**: 1-column list. Search bar full-width. Filter dropdown below search.
- **Tablet+**: 2-column grid with 16px gap. Search and filter on same row.
- **Large**: 2-column grid with more generous margins (never 3-column -- Devanagari needs horizontal room).

### Accessibility

- List uses `<ul role="list">` with `<li>` for each card.
- Each card is a link (`<a>`) wrapping the card content for keyboard navigation.
- Search input has `aria-label="Search verses"` and announces result count via `aria-live="polite"`.

---

## 3. DailyVerse (Homepage Hero)

### Purpose

The hero component on the homepage. Displays one verse selected for the day, creating a moment of immediate engagement. This is often the first thing a visitor sees -- it must be arresting and immediately communicative of the site's purpose.

### Layout

```
[Full viewport hero, dark background, centered content]

    VERSE OF THE DAY                         (label: Inter 500, gold, uppercase, spaced)

    ───────                                  (gold divider)

    ब्रह्म सत्यं जगन्मिथ्ये...             (Sanskrit, large, warm accent)

    "Brahman alone is real..."               (Translation, Cormorant italic)

    ───────                                  (gold divider)

    Vivekachudamani, Verse 20                (source: Inter 300, --text-secondary)

    [ Read This Verse ]   [ Explore All ]    (two pill buttons, side by side)
```

### Visual Details

- **Full viewport height** (100vh) with content centered vertically and horizontally.
- **Background**: `--bg-primary` with an extremely subtle radial gradient -- a barely visible warm glow behind the verse text: `radial-gradient(ellipse at center, rgba(201, 165, 90, 0.03) 0%, transparent 70%)`.
- **"Verse of the Day" label**: Inter 500, 0.75rem, `--accent-gold`, letter-spacing 0.25em, uppercase.
- **Sanskrit**: Noto Sans Devanagari 400, `--text-4xl` on desktop (larger than the inner verse page -- this is the hero moment), `--accent-warm`.
- **Translation**: Cormorant Garamond italic 300, `--text-2xl`, `--text-primary`.
- **Source line**: Inter 300, 0.85rem, `--text-secondary`.
- **Primary button** ("Read This Verse"): Pill shape, `--accent-gold` border, `--accent-gold` text. On hover: gold fill, dark text.
- **Secondary button** ("Explore All"): Pill shape, `--border` border, `--text-secondary` text. On hover: border strengthens, text lightens.

### Entry Animation

1. The entire hero fades in over `--duration-contemplative` (1200ms) with a very gentle scale (from 0.98 to 1.0). This creates a sense of the verse materializing, as if emerging from silence.
2. Then, individual elements stagger in as per VerseCard (200ms apart).

### Daily Rotation Logic

The verse changes daily at midnight UTC. The selection algorithm should cycle through a curated "featured verses" list (starting with the top 30 from the data file, expanding over time). It should not be purely random -- the curated list ensures quality.

### States

| State | Behavior |
|---|---|
| Loading | Full viewport with centered pulsing gold circle (subtle breathing animation) |
| Default | Verse displayed as described |
| Transitioning (midnight) | Crossfade to new verse (only visible if user has page open) |

### Responsive Behavior

- **Mobile**: Sanskrit drops to `--text-3xl`. Translation to `--text-xl`. Buttons stack vertically with full width. Padding: `--space-8` horizontal.
- **Tablet+**: Standard layout. Buttons remain side by side.

---

## 4. PadaNav (Chapter Navigation for Yoga Sutras)

### Purpose

A navigation component specific to the Yoga Sutras, allowing users to jump between the 4 padas (chapters). Also shows at a glance how many sutras each pada contains and which pada the user is currently in.

### Layout

```
[Horizontal bar, full width of content area]

    ┌─────────────┬─────────────┬─────────────┬─────────────┐
    │   Samadhi   │   Sadhana   │   Vibhuti   │  Kaivalya   │
    │   51 sutras │   55 sutras │   55 sutras │   34 sutras │
    │   [active]  │             │             │             │
    └─────────────┴─────────────┴─────────────┴─────────────┘
```

### Visual Details

- **Container**: Full width of `--container-wide`, with `--bg-card` background, `--radius-lg`, 1px `--border`.
- **Each pada cell**: Equal width (25%), clickable.
  - **Pada name**: Cormorant Garamond 400, 1.0rem, `--text-primary`.
  - **Sutra count**: Inter 300, 0.75rem, `--text-secondary`.
  - **Divider**: 1px `--border` between cells (vertical lines).
- **Active state**: Gold bottom border (2px, `--accent-gold`) on the active pada. Pada name color changes to `--accent-gold`.
- **Hover**: Background shifts to `--bg-card-hover`. Transition: `--duration-fast`.

### States

| State | Behavior |
|---|---|
| Default | All 4 padas shown, one active (highlighted with gold underline) |
| Hover | Background of hovered pada cell lightens |
| Active | Gold underline + gold text for current pada |

### Responsive Behavior

- **Mobile**: 2x2 grid (2 padas per row) instead of 4-column. Active state uses filled background instead of underline for easier visibility.
- **Tablet+**: Full 4-column horizontal bar.

### Accessibility

- Uses `<nav aria-label="Yoga Sutra chapters">` with `<ul role="tablist">` and `<li role="tab">` for each pada.
- `aria-selected="true"` on the active pada.

---

## 5. ThemeFilter (Filter by Theme/Tag)

### Purpose

Allows users to filter the verse list by philosophical theme (discrimination, maya, self-inquiry, guru-disciple, liberation, practical-wisdom). Functions as both a discovery tool and a study aid.

### Layout

```
[Horizontal row of pill-shaped toggles, wrapping if needed]

    [ All ]  [ Discrimination ]  [ Maya ]  [ Self-Inquiry ]
    [ Guru & Disciple ]  [ Liberation ]  [ Practical Wisdom ]
```

### Visual Details

- **Each filter pill**: `--radius-xl` (20px), 1px `--border`, padding `--space-2` (8px) vertical / `--space-4` (16px) horizontal.
  - **Text**: Inter 400, 0.75rem, `--text-secondary`, letter-spacing 0.05em, uppercase.
  - **Inactive hover**: Border shifts to `--border-strong`, text to `--text-primary`.
  - **Active**: `--accent-gold` border, `--accent-gold` text, background `rgba(201, 165, 90, 0.08)`.
- **Gap between pills**: `--space-2` (8px).
- **"All" pill** is the default active state and clears all filters.

### Interaction

- Single-select: clicking a theme selects it and deselects others.
- Clicking the active theme deselects it (returns to "All").
- The verse list below updates immediately (no page reload) with a subtle fade transition.
- The filter state is reflected in the URL query parameter (`?theme=maya`) for shareability and back-button support.

### States

| State | Behavior |
|---|---|
| Default | "All" is active, all other pills are inactive |
| Active filter | One pill is highlighted in gold, "All" is deselected |
| No results | Verse list shows "No verses match this theme" message |

### Responsive Behavior

- **Mobile**: Pills wrap to multiple rows. Horizontal scroll is an option if wrapping feels cluttered (use `overflow-x: auto` with hidden scrollbar).
- **Tablet+**: Single row if all pills fit; wrapping otherwise.

### Accessibility

- Uses `<fieldset>` with `<legend class="sr-only">Filter by theme</legend>`.
- Each pill is a `<button role="radio">` within a `radiogroup`.
- `aria-pressed="true"` on active filter.

---

## 6. PracticeCard (Actionable Practice Prompt)

### Purpose

Attached to each verse, this card provides a concrete, doable practice that brings the verse's teaching into daily life. It is the "bridge" between ancient philosophy and modern experience. Should feel inviting, not prescriptive.

### Layout

```
┌──────────────────────────────────────────────┐
│                                              │
│  TRY THIS TODAY                              │  (label: Inter 500, gold, uppercase)
│                                              │
│  Pick one thing you believe defines you --   │  (body: Inter 300, --text-secondary)
│  your job title, relationship status, or     │  (line-height: 1.8)
│  body. Now notice: who is *aware* of that    │
│  thing? That awareness is what this verse    │
│  points to. Sit with that question for       │
│  just 5 minutes.                             │
│                                              │
└──────────────────────────────────────────────┘
```

### Visual Details

- **Container**: `--bg-card`, 1px `--border`, `--radius-lg` (12px), padding `--space-6` (32px).
- **Label**: Inter 500, 0.75rem, `--accent-gold`, letter-spacing 0.15em, uppercase. Alternatively, "Try This Today" can use Cormorant Garamond 600 at 1.2rem for warmth.
- **Body text**: Inter 300, 1.0rem, `--text-secondary`, line-height 1.8.
- **Emphasis**: `<em>` tags use italic Inter, `<strong>` uses Inter 500 + `--text-primary`.
- **Max-width**: `--container-narrow` (650px), centered.

### States

| State | Behavior |
|---|---|
| Default | Card displayed as described |
| Expanded (future) | Option to reveal a timer component for the suggested practice duration |

### Responsive Behavior

- **Mobile**: Padding reduces to `--space-5`. Full-width within content padding.
- **Desktop**: Centered with max-width, generous margin-top (`--space-8`).

### Accessibility

- Wrapped in `<aside aria-label="Practice suggestion">` to distinguish from primary content.
- Body text is plain HTML with proper `<em>` and `<strong>` tags.

---

## 7. AudioPlayer (Sanskrit Recitation Player)

### Purpose

Plays a Sanskrit recitation of the current verse. Audio is a powerful dimension -- hearing the original Sanskrit creates a visceral connection to the text that reading alone cannot. The player should be unobtrusive but easily accessible.

### Layout -- Compact Mode (Default on Verse Page)

```
    [ ▶  Listen to Sanskrit Recitation ]     (pill button in verse hero area)
```

### Layout -- Expanded Mode (After Play is Triggered)

```
┌─────────────────────────────────────────────┐
│   ▶ ▮▮   0:12 ━━━━━━━━━━━━━━━━━── 0:45    │
│            Verse 20 Recitation       🔊     │
└─────────────────────────────────────────────┘
```

### Visual Details

**Compact (pill button):**
- Pill shape, `--accent-gold` border, `--accent-gold` text, transparent background.
- Text: Inter 400, 0.8rem, letter-spacing 0.1em.
- Play icon (Lucide `play-circle`) at 16px, inline before text.
- Hover: Background fills with `--accent-gold`, text inverts to `--bg-primary`.

**Expanded (after play):**
- Appears as a floating bar, fixed at the bottom of the viewport, above the progress bar.
- Background: `--bg-secondary` with `--blur-nav` backdrop.
- Border-top: 1px `--border`.
- **Play/Pause**: Circle icon, 36px, `--accent-gold`.
- **Progress bar**: Thin line (3px), `--bg-card` track, `--accent-gold` fill. Clickable for seeking.
- **Time**: Inter 300, 0.75rem, `--text-secondary`.
- **Track name**: Inter 400, 0.8rem, `--text-primary`.
- **Volume**: Small icon, toggles mute on click. No slider (minimal UI).

### States

| State | Behavior |
|---|---|
| Idle | Pill button in verse hero area |
| Loading | Pill button shows "Loading..." with subtle pulsing opacity |
| Playing | Expanded player visible at bottom. Pill button text changes to "Pause" |
| Paused | Expanded player stays visible, play icon shown |
| Ended | Player auto-collapses after 2 seconds, returns to pill button |
| Error | Pill button shows "Audio unavailable" in `--text-tertiary` |

### Interaction

- Clicking pill button starts playback and triggers expansion.
- Clicking anywhere on the progress bar seeks to that position.
- Swiping left on mobile dismisses the expanded player.
- Player does not auto-play. Ever. The user initiates.

### Responsive Behavior

- **Mobile**: Expanded player is full-width, slightly taller (44px). Controls larger for touch.
- **Desktop**: Expanded player is centered, max-width `--container-wide`.

### Accessibility

- Play/pause button: `aria-label="Play Sanskrit recitation"` / `"Pause recitation"`.
- Progress bar: `role="slider"`, `aria-valuemin`, `aria-valuemax`, `aria-valuenow`, `aria-label="Recitation progress"`.
- Keyboard: Space toggles play/pause, left/right arrows seek 5 seconds.

---

## 8. ProgressTracker (Journey Progress)

### Purpose

Shows the reader where they are in the complete text. For Vivekachudamani: "Verse 20 of 580." For Yoga Sutras: "Sutra 12 of 195 (Samadhi Pada)." This gives a sense of journey and scale without creating pressure.

### Layout -- Fixed Bar (Always Visible)

```
[Fixed at bottom of viewport, 3px tall]

    ━━━━━░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  (3.4% filled -- verse 20 of 580)
```

### Layout -- Expanded (Hover or Tap on Bar)

```
┌─────────────────────────────────────────────┐
│  Your Journey: Vivekachudamani              │
│  Verse 20 of 580 (3.4%)                    │
│  ━━━━━━━━━━━░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
│                                              │
│  Last read: Verse 19 -- 2 hours ago         │
│  [ Continue Reading ] [ Jump to Verse... ]  │
└─────────────────────────────────────────────┘
```

### Visual Details

**Fixed bar:**
- Position: fixed, bottom: 0, full width, height: 3px.
- Track: `--bg-secondary`.
- Fill: `--gradient-gold` (linear from gold to saffron, left to right).
- Z-index: `--z-progress` (50).
- Transition: fill width uses `--ease-gentle` over `--duration-slow`.

**Expanded tooltip:**
- Appears above the bar on hover (desktop) or tap (mobile).
- Background: `--bg-card`, `--radius-lg`, `--border`, padding `--space-5`.
- Shadow: `--shadow-glow` (dark mode).
- **Title**: Inter 500, 0.85rem, `--text-primary`.
- **Detail**: Inter 300, 0.8rem, `--text-secondary`.
- **Progress bar (in tooltip)**: Same style as fixed bar but 6px tall for better interaction.
- **Buttons**: Small pill buttons.

### States

| State | Behavior |
|---|---|
| Anonymous user | Bar shows progress based on URL (current verse / total) |
| Logged-in user (future) | Bar shows cumulative reading progress across sessions |
| Hover / Tap | Expanded tooltip appears with details |
| Verse page | Bar fill reflects current verse number |
| Index page | Bar hidden (no specific verse context) |

### Responsive Behavior

- **Mobile**: Fixed bar is 4px tall (easier to see). Tap to expand tooltip. Tooltip appears as a bottom sheet (sliding up from bar).
- **Desktop**: 3px bar. Hover to reveal tooltip above the bar.

---

## 9. SearchBar

### Purpose

Allows users to search across all verses in both texts. Searches Sanskrit (transliterated), English translations, and modern interpretations. The search should feel fast and focused -- not a complex query engine, but a quick way to find a remembered phrase or concept.

### Layout

```
┌─────────────────────────────────────────────┐
│  🔍  Search across all verses...            │
└─────────────────────────────────────────────┘

[Results dropdown, appears on typing]
┌─────────────────────────────────────────────┐
│  3 results for "awareness"                  │
│                                              │
│  Verse 20 -- "...the awareness             │
│  witnessing it all..."                      │
│                                              │
│  Verse 136 -- "...that awareness            │
│  has never been born..."                    │
│                                              │
│  Verse 219 -- "...which pulsates            │
│  inwardly as the constant I-I..."           │
│                                              │
│  [ View all results → ]                     │
└─────────────────────────────────────────────┘
```

### Visual Details

**Input:**
- Background: `--bg-surface`, `--radius-md` (8px), 1px `--border`.
- Padding: `--space-3` (12px) vertical, `--space-4` (16px) horizontal.
- Search icon (Lucide `search`): 18px, `--text-tertiary`, positioned left.
- Text input: Inter 400, 0.95rem, `--text-primary`.
- Placeholder: "Search across all verses...", Inter 300, `--text-tertiary`.
- Focus: border changes to `--border-strong`, gold focus ring (2px offset).

**Results dropdown:**
- Background: `--bg-card`, `--radius-lg`, 1px `--border`.
- Shadow: `--shadow-glow` (dark mode), `--shadow-lg` (light mode).
- Max-height: 400px, overflow-y: auto.
- Each result: padding `--space-4`, border-bottom 1px `--border`.
  - **Verse reference**: Inter 500, 0.75rem, `--accent-gold`.
  - **Matched text**: Inter 300, 0.9rem, `--text-secondary`. Matched query text highlighted with `--accent-warm` color and `font-weight: 500`.
- **Result hover**: Background `--bg-card-hover`.
- **"View all results" link**: Inter 400, 0.85rem, `--accent-gold`. Navigates to full search results page.

### Interaction

- Dropdown appears after 2+ characters, with 300ms debounce.
- Results update as the user types.
- Pressing Enter or clicking "View all results" navigates to the full search results page.
- Pressing Escape or clicking outside closes the dropdown.
- Up/Down arrow keys navigate through results; Enter selects.
- Maximum 5 results in the dropdown preview; full page shows all.

### States

| State | Behavior |
|---|---|
| Default | Input with placeholder and search icon |
| Focused | Border highlights, placeholder shifts slightly left |
| Typing (no results yet) | "Searching..." text in dropdown |
| Results found | Dropdown with up to 5 results |
| No results | Dropdown with "No verses match your search" message |
| Error | "Search unavailable. Please try again." message |

### Responsive Behavior

- **Mobile**: Search bar is full-width. On the nav, it is hidden behind a search icon; tapping the icon expands the search bar to full nav width (the nav links slide away).
- **Desktop**: Search bar is always visible in the nav or at the top of index pages.

### Accessibility

- `<input type="search" role="combobox" aria-expanded="true/false" aria-autocomplete="list">`.
- Results list uses `role="listbox"` with `role="option"` for each result.
- Active result indicated with `aria-activedescendant`.
- Clear button has `aria-label="Clear search"`.

---

## 10. QuoteCard (Shareable Verse Image)

### Purpose

Generates a beautifully designed image of a verse that users can share on social media. The image should be immediately recognizable as Bodhi content and look stunning in Instagram Stories, tweets, and WhatsApp messages.

### Layout (Generated Image)

```
┌──────────────────────────────────────────────┐
│                                              │
│  [Dark background with subtle warm glow]     │
│                                              │
│                                              │
│      ब्रह्म सत्यं जगन्मिथ्ये...            │
│                                              │
│      ───────                                 │
│                                              │
│      "Brahman alone is real,                 │
│      the world is appearance..."             │
│                                              │
│                                              │
│      Vivekachudamani, Verse 20               │
│                                              │
│                          BODHI               │
│                                              │
└──────────────────────────────────────────────┘
```

### Trigger

A share icon (Lucide `share-2`) on the verse page. Clicking it opens a modal with:
1. The pre-rendered quote card image.
2. "Download Image" button.
3. "Copy Link" button.
4. Platform share buttons (Twitter/X, WhatsApp, native share on mobile).

### Image Specifications

- **Dimensions**: 1080x1080px (Instagram square), with option for 1080x1920px (Stories/portrait).
- **Background**: `--bg-primary` with a radial gradient glow: `radial-gradient(ellipse at 50% 50%, rgba(201, 165, 90, 0.05), transparent 70%)`.
- **Sanskrit text**: Noto Sans Devanagari 400, ~36px, `--accent-warm`, centered.
- **Divider**: 80px gold line, centered.
- **Translation**: Cormorant Garamond italic 300, ~24px, `--text-primary`, centered.
- **Source**: Inter 300, ~14px, `--text-secondary`.
- **Logo**: "BODHI" in Cormorant Garamond 600, 16px, `--accent-gold`, bottom-right corner.
- **Margins**: At least 80px on all sides.

### Modal Layout

```
┌──────────────────────────────────────────────┐
│                     ✕                        │
│                                              │
│   [Quote card image preview, centered]       │
│                                              │
│   Format:  [ Square ]  [ Story ]             │
│                                              │
│   [ Download Image ]   [ Copy Link ]         │
│                                              │
│   Share:  🐦  📱  💬                         │
│                                              │
└──────────────────────────────────────────────┘
```

### States

| State | Behavior |
|---|---|
| Generating | Skeleton image with pulsing animation |
| Ready | Image displayed with download/share options |
| Downloaded | "Downloaded" confirmation replaces button briefly |
| Link copied | "Copied!" confirmation replaces button briefly |

### Responsive Behavior

- **Mobile**: Modal becomes a full-screen sheet sliding up from bottom. Image fills width. Share uses native Web Share API.
- **Desktop**: Centered modal with overlay. Max-width 500px.

---

## 11. NavigationBar

### Purpose

The persistent top navigation. Fixed at the top of every page. Must be minimal enough to not steal attention from the content, but functional enough for easy wayfinding.

### Layout -- Desktop

```
┌─────────────────────────────────────────────────────────────────┐
│  BODHI          Vivekachudamani   Yoga Sutras   Daily Verse   About   🔍  ☀/🌙  │
└─────────────────────────────────────────────────────────────────┘
```

### Layout -- Mobile

```
┌─────────────────────────────────────────────────────────────────┐
│  BODHI                                               🔍   ☰   │
└─────────────────────────────────────────────────────────────────┘

[Mobile menu (hamburger expanded)]
┌─────────────────────────────────────────────────────────────────┐
│                                                          ✕     │
│                                                                │
│  Vivekachudamani                                               │
│  Yoga Sutras                                                   │
│  Daily Verse                                                   │
│  About                                                         │
│                                                                │
│  [ ☀ Light Mode ]                                              │
└─────────────────────────────────────────────────────────────────┘
```

### Visual Details

- **Position**: Fixed, top: 0, width: 100%, z-index: `--z-nav` (100).
- **Background**: `var(--bg-primary)` at 90% opacity + `--blur-nav` backdrop-filter.
- **Border-bottom**: 1px `--border`.
- **Height**: 60px (desktop), 52px (mobile).
- **Padding**: `--space-4` (16px) vertical, `--space-6` (32px) horizontal.

**Logo:**
- "BODHI" in Cormorant Garamond 600, 1.5rem, `--accent-gold`, letter-spacing 0.1em.
- Clickable, links to home page.

**Nav links:**
- Inter 400, 0.85rem, `--text-secondary`, letter-spacing 0.05em, uppercase.
- Hover: `--accent-gold`. Transition: `--duration-fast`.
- Active page: `--accent-gold` with a subtle bottom border (2px, gold, below the text).

**Search icon:**
- Lucide `search`, 20px, `--text-secondary`. Hover: `--accent-gold`.
- Click opens search bar (replaces nav links on desktop, or opens search sheet on mobile).

**Theme toggle:**
- Lucide `sun` (dark mode showing) / `moon` (light mode showing), 20px, `--text-secondary`.
- Click toggles theme. Icon transitions with a crossfade (`--duration-base`).

**Mobile hamburger:**
- Lucide `menu`, 22px, `--text-secondary`.
- Opens a full-screen overlay menu with `--blur-overlay` backdrop.
- Menu items: Cormorant Garamond 400, 1.8rem, `--text-primary`, stacked vertically, centered.
- Close icon (`x`) in top-right corner.

### States

| State | Behavior |
|---|---|
| Default | Transparent-ish bar with logo + links |
| Scrolled | Background opacity increases slightly (from 90% to 95%) for better contrast |
| Search open | Search bar expands, nav links hide (desktop). Full search sheet (mobile). |
| Mobile menu open | Full-screen overlay with stacked links |

### Responsive Behavior

- **Mobile (< 640px)**: Logo + search icon + hamburger only. Nav links hidden in hamburger menu.
- **Tablet (640-1023px)**: Full nav links visible. Search icon separate.
- **Desktop (1024px+)**: Full layout as described.

---

## 12. Footer

### Purpose

A minimal footer that provides legal information, text source attribution, and secondary navigation. It should feel like a quiet closing -- not a dump of links.

### Layout

```
───────────────────────────────────────────────────  (full-width 1px --border)

    BODHI                                            (logo: Cormorant, gold)
    Ancient verses. Modern clarity.                  (tagline: Inter 300, --text-tertiary)

    Texts                    About                   (two columns of links)
    Vivekachudamani          About This Project
    Yoga Sutras              Source Texts
    Daily Verse              Contact

    ─────────────────────────────────────────────

    Source texts: Gita Press, Gorakhpur               (attribution: Inter 300, 0.75rem)
    Built with reverence, not algorithms.             (small nod to the philosophy)

    © 2026 Project Bodhi                              (copyright)
```

### Visual Details

- **Background**: `--bg-secondary`.
- **Border-top**: 1px `--border`.
- **Padding**: `--space-12` (80px) top, `--space-8` (48px) bottom.
- **Logo**: Same as nav logo.
- **Tagline**: Inter 300, 0.9rem, `--text-tertiary`.
- **Link columns**: Inter 400, 0.85rem, `--text-secondary`. Hover: `--accent-gold`.
- **Column headers**: Inter 500, 0.75rem, `--accent-gold`, uppercase, letter-spacing 0.1em.
- **Attribution**: Inter 300, 0.75rem, `--text-tertiary`.
- **Copyright**: Inter 300, 0.75rem, `--text-tertiary`.

### Responsive Behavior

- **Mobile**: Single column, stacked sections. Logo and tagline centered. Links stacked below.
- **Desktop**: Logo/tagline left-aligned, link columns right-aligned (2-column layout within footer).

### Accessibility

- Footer wrapped in `<footer role="contentinfo">`.
- Links organized in `<nav aria-label="Footer navigation">`.
- Attribution text uses `<small>`.
