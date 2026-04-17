# Project Bodhi -- Page Specifications

> Wireframe descriptions for every page in the experience. Each description defines the content hierarchy, section-by-section layout, and the emotional arc the user should feel moving through the page.

---

## 1. Home Page

### Emotional Arc

Arrival. Stillness. Invitation. The homepage is not informational -- it is experiential. The visitor should feel like they have stepped into a quiet room. The Daily Verse greets them. Scrolling reveals context, but the above-the-fold experience is one verse in a vast dark space.

### Sections (Top to Bottom)

**Section 1: Hero -- Daily Verse (100vh)**

Full viewport. Centered content on dark background with the barely perceptible warm radial glow.

```
    VERSE OF THE DAY

    ───────

    [Sanskrit verse in Noto Devanagari, large, warm gold]

    [English translation in Cormorant italic, white]

    ───────

    Vivekachudamani, Verse 20

    [ Read This Verse ]   [ Explore All Verses ]
```

- No other UI elements visible (nav is present but transparent until scroll).
- The verse materializes with the contemplative fade-in animation (1200ms).
- Scrolling down triggers a subtle parallax: the verse fades slightly and the next section enters from below.

**Section 2: Tagline + Context (100vh or auto)**

A brief, centered text block that communicates what Bodhi is.

```
    BODHI

    Two ancient texts. 775 verses.
    One question: Who are you, really?

    Vivekachudamani -- 580 verses on Self-realization
    by Adi Shankaracharya (8th century CE)

    Yoga Darshan -- 195 sutras on mastering the mind
    by Maharshi Patanjali (~200 BCE)

    [ Begin with Vivekachudamani ]
    [ Begin with Yoga Sutras ]
```

- "BODHI" in Cormorant Garamond 600, `--text-4xl`, `--accent-gold`.
- Description in Cormorant Garamond 300, `--text-xl`, `--text-primary`.
- Text names in Cormorant Garamond 400, `--text-lg`, `--text-primary`.
- Author/date in Inter 300, `--text-sm`, `--text-secondary`.
- Two pill buttons, stacked vertically on mobile, side by side on desktop.

**Section 3: How It Works (auto height)**

A minimal explanation of the experience depth -- progressive disclosure at its meta level.

```
    HOW TO READ

    Surface                    Each verse in Sanskrit + English translation
    Depth                      Modern interpretation for daily life
    Practice                   A concrete exercise to embody the teaching
    Journey                    Track your path through all 580 verses

    ───────
```

- Four rows, each with a label (Inter 500, gold, uppercase) and description (Inter 300, secondary).
- Vertically stacked with `--space-5` between rows.
- A thin vertical gold line connects the four rows on the left margin (decorative).

**Section 4: Featured Verses (auto height)**

A curated selection of 3-4 verse preview cards (from the top-30 list) to entice exploration.

```
    EXPLORE

    [VerseCard preview]  [VerseCard preview]  [VerseCard preview]
    Verse 2              Verse 78             Verse 136

    [ See All 580 Verses ]
```

- Uses the compact list-item card variant from VerseList.
- 1-column on mobile, 3-column on desktop.
- Each card links to the full verse page.
- "See All" link below the grid.

**Section 5: Footer**

Standard Footer component.

### URL

`/`

---

## 2. Vivekachudamani Index

### Emotional Arc

Overview. Orientation. Choice. This page says: "Here is the entire journey. Pick a place to begin." It should feel like standing at the entrance to a vast, well-organized library -- not overwhelming, but awe-inspiring in scope.

### Sections

**Section 1: Header**

```
    VIVEKACHUDAMANI
    विवेकचूडामणि

    The Crest-Jewel of Discrimination
    580 verses by Adi Shankaracharya (~8th century CE)

    A dialogue between Guru and Disciple on the path
    from ignorance to Self-realization.
```

- Title in Cormorant Garamond 600, `--text-4xl`, `--text-primary`.
- Sanskrit title below in Noto Sans Devanagari 400, `--text-xl`, `--accent-warm`.
- Subtitle and description in Inter 300, `--text-secondary`.
- Centered, with `--space-12` padding top (accounting for fixed nav), `--space-8` bottom.

**Section 2: Search + Theme Filter**

```
    [ Search verses...                           ]

    [ All ] [ Discrimination ] [ Maya ] [ Self-Inquiry ]
    [ Guru & Disciple ] [ Liberation ] [ Practical Wisdom ]
```

- SearchBar component (without dropdown -- on this page, search filters the list below in real time).
- ThemeFilter component below the search bar.
- `--space-5` gap between search and filters.

**Section 3: Verse List**

```
    Showing 1-20 of 580 verses

    [VerseList component -- 2 column grid on desktop]

    [ Load More Verses ]
```

- VerseList component with 20 items per page.
- The count label ("Showing 1-20 of 580") in Inter 300, `--text-sm`, `--text-tertiary`.
- "Load More" button: pill shape, `--border`, `--text-secondary`. On hover: `--border-strong`, `--text-primary`.

**Section 4: Footer**

Standard Footer.

### URL

`/vivekachudamani`

### Query Parameters

- `?theme=maya` -- pre-filters by theme
- `?search=awareness` -- pre-fills search
- `?page=2` -- pagination (if using page-based)

---

## 3. Yoga Sutras Index

### Emotional Arc

Structure. Clarity. System. The Yoga Sutras have a natural architecture (4 padas) that the page should reflect. The user should immediately see the four-chapter structure and understand the progression: What yoga is, How to practice, What happens, Ultimate freedom.

### Sections

**Section 1: Header**

```
    YOGA DARSHAN
    योग दर्शन

    Patanjali's Yoga Sutras
    195 sutras across 4 chapters by Maharshi Patanjali (~200 BCE)

    "Yoga is the cessation of the fluctuations of the mind."
    -- Sutra 1.2
```

- Same typographic treatment as Vivekachudamani index header.
- The quote from Sutra 1.2 in Cormorant Garamond italic 300, `--text-primary`. This grounds the page immediately in the text's core teaching.

**Section 2: PadaNav**

```
    ┌─────────────┬─────────────┬─────────────┬─────────────┐
    │   Samadhi   │   Sadhana   │   Vibhuti   │  Kaivalya   │
    │   Pada      │   Pada      │   Pada      │   Pada      │
    │   51 sutras │   55 sutras │   55 sutras │   34 sutras │
    │             │             │             │             │
    │  What yoga  │  How to     │  Powers &   │  Ultimate   │
    │  is         │  practice   │  their      │  liberation │
    │             │             │  limits     │             │
    └─────────────┴─────────────┴─────────────┴─────────────┘
```

- PadaNav component, enhanced with a one-line description below each pada name.
- Descriptions in Inter 300, 0.75rem, `--text-tertiary`.
- Clicking a pada scrolls to that pada's section below (smooth scroll) and highlights it in PadaNav.

**Section 3: Search + Filter**

Same as Vivekachudamani index. ThemeFilter may have different tags relevant to Yoga Sutras (e.g., "Samadhi," "Ashtanga," "Kleshas," "Siddhis," "Kaivalya").

**Section 4: Sutra List (by Pada)**

```
    SAMADHI PADA -- SUTRAS 1-51
    What yoga is and the types of samadhi

    [Sutra list -- same VerseList component, filtered to this pada]

    ───────

    SADHANA PADA -- SUTRAS 52-106
    The practice: Ashtanga Yoga (eight limbs)

    [Sutra list]

    ───────

    VIBHUTI PADA -- SUTRAS 107-161
    Powers attained through practice and their transcendence

    [Sutra list]

    ───────

    KAIVALYA PADA -- SUTRAS 162-195
    The nature of ultimate liberation

    [Sutra list]
```

- Each pada is a section with its own header (Cormorant Garamond 400, `--text-xl`, `--text-primary`) and description (Inter 300, `--text-secondary`).
- Sutras within each pada use the same VerseList card format.
- Sections separated by `--space-10` + gold divider.
- PadaNav remains sticky below the main nav while scrolling through sections (on desktop).

**Section 5: Footer**

Standard Footer.

### URL

`/yoga-sutras`

### Query Parameters

- `?pada=sadhana` -- scrolls to and highlights Sadhana Pada
- `?theme=ashtanga` -- pre-filters by theme
- `?search=chitta` -- pre-fills search

---

## 4. Individual Verse Page (Deep-Dive)

### Emotional Arc

Arrival. Absorption. Understanding. Application. Departure. This is the most important page in the experience. The user arrives at a single verse and is guided through progressive layers of depth, from the raw Sanskrit to a practical exercise they can do today. The pace should feel like a slow exhale.

### Sections

**Section 1: Verse Hero (100vh) -- VerseCard Component**

Full viewport display of the verse:

```
    VIVEKACHUDAMANI -- VERSE 20 OF 580

    [ Discrimination ]

    ब्रह्म सत्यं जगन्मिथ्ये...

    [ Listen to Sanskrit Recitation ]

    ───────

    "Brahman alone is real, the world
    is appearance..."
```

- Uses the VerseCard component as specified.
- Scroll indicator (subtle down-arrow or "Scroll to explore" text) appears after initial animation completes.

**Section 2: Transliteration (optional toggle)**

```
    TRANSLITERATION (IAST)

    brahma satyaṁ jaganmithyetyevaṁrūpo viniścayaḥ |
    so'yaṁ nityānityavastuvivekaḥ samudāhṛtaḥ || 20 ||
```

- Collapsed by default. A small "Show transliteration" toggle reveals it.
- Text: Inter 400, 1.0rem, `--text-secondary`, letter-spacing 0.02em.
- This section is for Sanskrit students who want to read the original in Roman script.

**Section 3: Word-by-Word Breakdown (optional toggle)**

```
    WORD BY WORD

    brahma = Brahman (the Absolute Reality)
    satyam = is real, is truth
    jagat = the world, the universe
    mithya = is appearance, is not ultimately real
    ...
```

- Collapsed by default. "Show word-by-word" toggle.
- Each word in a subtle row: Sanskrit word in `--accent-warm`, meaning in `--text-secondary`.
- This is the deepest textual layer, for serious students.

**Section 4: Hindi Commentary (from Gita Press)**

```
    HINDI MEANING (GITA PRESS)

    [Hindi text from the Gita Press commentary]
```

- Collapsed by default. "Show Hindi commentary" toggle.
- Text in Noto Sans Devanagari 400, 1.0rem, `--text-secondary`.
- For Hindi-reading users who want the traditional commentary.

**Section 5: Modern Interpretation**

```
    WHAT THIS MEANS FOR YOUR LIFE

    Everything you can see, touch, measure, and
    post about is constantly changing -- your body,
    your bank balance, your relationships, even
    your thoughts.

    The only thing that never changes is the
    awareness witnessing it all.

    True wisdom is learning to tell the difference
    between the screen and the movie playing on it.
```

- Always visible (not collapsed). This is the bridge between ancient text and modern reader.
- Section label: Inter 500, 0.75rem, `--accent-gold`, uppercase, letter-spacing 0.2em.
- Body: Inter 300, `--text-lg` (1.1rem), `--text-secondary`, line-height 1.9.
- Key sentences in `<strong>` with `--text-primary` and Inter 500.
- Max-width: `--container-narrow` (650px).

**Section 6: Practice -- PracticeCard Component**

```
    ┌──────────────────────────────────────────┐
    │  TRY THIS TODAY                          │
    │                                          │
    │  Pick one thing you believe defines      │
    │  you -- your job title, relationship     │
    │  status, or body. Now notice: who is     │
    │  *aware* of that thing?                  │
    └──────────────────────────────────────────┘
```

- PracticeCard component as specified.
- Margin-top: `--space-8`.

**Section 7: Related Verses (optional)**

```
    RELATED VERSES

    [2-3 compact VerseList cards for thematically linked verses]
```

- Shows 2-3 verses with the same theme tag.
- Uses the compact card format from VerseList.
- 1-column on mobile, 2-column on desktop.
- Helps the reader go deeper into a specific theme.

**Section 8: Share**

```
    [ Share This Verse ]    [ Save ♡ ]
```

- Two pill buttons, centered.
- "Share" opens the QuoteCard modal.
- "Save" bookmarks the verse (persisted to localStorage or user account).

**Section 9: Verse Navigation**

```
    ← Verse 19                              Verse 21 →
```

- Previous/next navigation.
- Left-aligned previous, right-aligned next.
- Border-top 1px `--border` above the nav area.
- Each link includes the verse number and a subtle preview of the first few words.

**Section 10: Progress Bar (Fixed)**

- ProgressTracker fixed at the bottom, showing current position (e.g., 20/580 = 3.4%).

**Section 11: Footer**

Standard Footer.

### URL

`/vivekachudamani/verse/20` (Vivekachudamani)
`/yoga-sutras/sutra/1.2` (Yoga Sutras, using pada.sutra notation)

---

## 5. About Page

### Emotional Arc

Context. Mission. Trust. The About page answers: Why does this exist? Who made it? Can I trust the translations? It should feel personal and sincere, like a letter from the creator.

### Sections

**Section 1: Header**

```
    ABOUT BODHI

    Ancient verses. Modern clarity.
```

- Title in Cormorant Garamond 600, `--text-4xl`.
- Tagline in Cormorant Garamond italic 300, `--text-xl`, `--text-secondary`.
- Centered, generous top padding.

**Section 2: Mission**

```
    WHY THIS EXISTS

    [3-4 paragraphs explaining the motivation: these texts are
    among humanity's deepest inquiries into consciousness, yet
    they remain locked behind academic jargon, religious framing,
    or simply bad web design. Bodhi is an attempt to present them
    with the reverence they deserve and the clarity they need.]
```

- Section label + body text format (same as verse page interpretation).
- Max-width: `--container-narrow`.

**Section 3: The Texts**

```
    THE SOURCE TEXTS

    Vivekachudamani (विवेकचूडामणि)
    "The Crest-Jewel of Discrimination"
    Author: Adi Shankaracharya (~8th century CE)
    580 verses, continuous dialogue between Guru and Disciple
    Tradition: Advaita Vedanta
    Edition: Gita Press, Gorakhpur

    ───────

    Yoga Darshan (योग दर्शन)
    Patanjali's Yoga Sutras
    Author: Maharshi Patanjali (~200 BCE)
    195 sutras across 4 chapters
    Commentary: Harikrishnadas Goyandka (Gita Press)
    Edition: Gita Press, Gorakhpur, 26th Edition
```

- Each text presented as a block with title in Cormorant Garamond, details in Inter.
- Sanskrit title in Noto Sans Devanagari alongside the English.

**Section 4: Translation Approach**

```
    OUR APPROACH TO TRANSLATION

    [Explanation of the translation methodology: the primary
    translations come from the Gita Press editions, supplemented
    by cross-referencing with Swami Madhavananda (Vivekachudamani)
    and Swami Vivekananda / I.K. Taimni (Yoga Sutras). Modern
    interpretations are original and aim to bridge ancient context
    with contemporary life without distorting the original meaning.]
```

- This builds trust with serious students who care about source accuracy.

**Section 5: How to Use This Site**

```
    HOW TO USE BODHI

    Read one verse.
    Sit with it.
    That's it.

    You can read sequentially (like the original dialogue),
    browse by theme, or let the daily verse find you.
    There is no correct path. There is only your path.
```

- Short, poetic. Cormorant Garamond for the first three lines (large, centered), Inter for the rest.

**Section 6: Contact / Attribution**

```
    CONTACT

    [Simple contact information or form]

    Source texts published by Gita Press, Gorakhpur.
    Sanskrit typography powered by Noto Sans Devanagari (Google Fonts).
    Built with Next.js, hosted on Vercel.
```

**Section 7: Footer**

Standard Footer.

### URL

`/about`

---

## 6. Search Results Page

### Emotional Arc

Discovery. Efficiency. The search results page is the most "functional" page in the experience -- it should be clean, fast, and scannable. But even here, the results should have enough breathing room that the user can read a preview before clicking.

### Sections

**Section 1: Search Header**

```
    SEARCH

    [ awareness                              🔍 ]

    12 results for "awareness"
```

- Large SearchBar component at the top.
- Pre-filled with the search query from the URL.
- Result count: Inter 300, `--text-sm`, `--text-secondary`.

**Section 2: Filter (Optional)**

```
    Filter by text:  [ All ]  [ Vivekachudamani ]  [ Yoga Sutras ]
```

- Simple toggle to narrow results to one text.
- Same pill-style as ThemeFilter.

**Section 3: Results List**

```
    ┌──────────────────────────────────────────────┐
    │  Vivekachudamani, Verse 20                   │
    │  [ Discrimination ]                          │
    │                                              │
    │  "...the **awareness** witnessing it all.    │
    │  True wisdom is learning to tell the         │
    │  difference between the screen and the       │
    │  movie playing on it."                       │
    └──────────────────────────────────────────────┘

    ┌──────────────────────────────────────────────┐
    │  Vivekachudamani, Verse 136                  │
    │  [ Self-Inquiry ]                            │
    │                                              │
    │  "...that **awareness** has never been born  │
    │  and will never die..."                      │
    └──────────────────────────────────────────────┘
```

- Each result is a card similar to the VerseList card, but with:
  - The text source (Vivekachudamani or Yoga Sutras) prepended to the verse number.
  - The matched text shown in context (a sentence or two around the match).
  - The matched query highlighted in `--accent-warm` + weight 500.
  - Theme tag shown for quick context.
- Results sorted by relevance (match in Sanskrit transliteration > match in translation > match in interpretation).
- 1-column layout (single column is easier to scan for search results).

**Section 4: No Results State**

```
    No verses found for "xyzabc"

    Try searching for:
    - A concept (e.g., "awareness", "liberation", "mind")
    - A verse number (e.g., "verse 20")
    - A Sanskrit term (e.g., "brahman", "maya", "chitta")
```

- Friendly, helpful suggestions.
- Centered text, Cormorant Garamond for the "No verses found" heading, Inter for the suggestions.

**Section 5: Footer**

Standard Footer.

### URL

`/search?q=awareness`

### Query Parameters

- `?q=awareness` -- the search query
- `?text=vivekachudamani` -- filter by text
- `?text=yoga-sutras` -- filter by text

---

## Page Transitions

All page-to-page navigation uses a simple full-page fade transition:
- Outgoing page fades to `--bg-primary` over `--duration-base` (300ms).
- Incoming page fades in from `--bg-primary` over `--duration-slow` (500ms).
- No sliding, no zooming, no page morphing. The simplicity of the transition mirrors the stillness of the content.

## Scroll Behavior

- All pages use `scroll-behavior: smooth` for internal anchor links.
- No scroll-jacking anywhere. The user owns their scroll.
- The nav bar gains a slightly more opaque background after the user scrolls past the first viewport.
- Verse pages: the VerseCard hero section has a subtle parallax effect -- as the user scrolls down, the verse fades to 0.3 opacity and translates upward slightly (20px). This creates a "leaving the verse behind" feel as they enter the depth sections. Respects `prefers-reduced-motion`.
