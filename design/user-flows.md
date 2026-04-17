# Project Bodhi -- User Flows

> Key user journeys through the experience. Each flow describes the user's intent, the path they take, and the emotional state at each step.

---

## 1. First-Time Visitor Discovery Flow

### Persona

Someone who found Bodhi through a Google search ("what is Vivekachudamani"), a social media share, or a link from a friend. They may know nothing about these texts. They are curious but skeptical of "spiritual" websites.

### Intent

"What is this? Is it worth my time?"

### Flow

```
Step 1: Landing
─────────────────────────────────────────────────────
URL:     /
See:     Full-screen Daily Verse hero -- Sanskrit + English
Feel:    Surprise. This looks different from other spiritual sites.
         The dark space and gold typography feel premium, not preachy.
         The verse is immediately readable.
Action:  Read the verse. Pause. Scroll down.

Step 2: Context
─────────────────────────────────────────────────────
See:     "Two ancient texts. 775 verses. One question: Who are
         you, really?"
Feel:    Intrigue. The framing is personal and philosophical,
         not religious. The question resonates.
Action:  Continue scrolling.

Step 3: How It Works
─────────────────────────────────────────────────────
See:     The four-layer explanation (Surface, Depth, Practice,
         Journey). Clean, minimal.
Feel:    Understanding. "Oh, this is a structured reading
         experience, not a wall of scripture."
Action:  Continue scrolling to Featured Verses.

Step 4: Featured Verses
─────────────────────────────────────────────────────
See:     3 verse preview cards with compelling modern
         interpretations visible in the previews.
Feel:    Recognition. One of the hook lines resonates personally
         ("You beat odds of 1 in 400 trillion to be born --
         and you're spending it scrolling?")
Action:  Click into that verse.

Step 5: First Verse Page
─────────────────────────────────────────────────────
URL:     /vivekachudamani/verse/2
See:     Full-screen Sanskrit verse, then scrolling reveals the
         modern interpretation and practice card.
Feel:    Depth. This is not a quick-hit quote page. There is
         substance here. The practice prompt feels actionable.
Action:  Read everything. Possibly try the practice. Then look
         at the verse navigation and notice "Verse 2 of 580."
         Click to the next verse, or go back to explore the index.

Step 6: Decision Point
─────────────────────────────────────────────────────
See:     The Vivekachudamani index page (via nav or back button).
Feel:    Scale. "There are 580 of these, each with this level
         of depth." Either commitment (bookmarks the page) or
         exit (but with a positive impression).
Action:  Bookmark / share / or exit.
```

### Key Design Decisions for This Flow

- The homepage must communicate quality within 3 seconds. The Daily Verse hero does this through typography and space alone -- no explanatory text needed above the fold.
- The "How It Works" section must be scannable in under 10 seconds. Four short rows, not paragraphs.
- The first verse page must have zero friction. No sign-up prompts, no "subscribe to read more," no gate of any kind.
- The 580-verse count should inspire awe, not overwhelm. Frame it as a journey, not an assignment.

### Conversion Goals

- Primary: User clicks into at least one full verse page.
- Secondary: User bookmarks the site or shares a verse.
- Tertiary: User returns the next day (daily verse rotation provides a reason).

---

## 2. Daily Verse Reader Flow

### Persona

A returning visitor who has Bodhi bookmarked or visits the homepage daily. They want a brief, meaningful encounter with one verse -- a morning ritual that takes 3-5 minutes.

### Intent

"What is today's verse? Let me sit with it before my day begins."

### Flow

```
Step 1: Arrival
─────────────────────────────────────────────────────
URL:     / (homepage)
See:     Today's Daily Verse, different from yesterday's.
         The verse materializes slowly (1200ms fade-in).
Feel:    Anticipation. "What will today's teaching be?"
         The slow reveal mirrors the pace of morning stillness.
Action:  Read the Sanskrit (even if not understood, the visual
         presence of the original is meaningful). Read the
         English translation.

Step 2: Click into Verse
─────────────────────────────────────────────────────
URL:     /vivekachudamani/verse/[today's verse]
See:     Full verse page with the same verse, now with depth.
Feel:    Deepening. The transition from homepage hero to verse
         page feels continuous, not jarring.
Action:  Scroll to read the Modern Interpretation.

Step 3: Modern Interpretation
─────────────────────────────────────────────────────
See:     2-3 paragraphs connecting the verse to daily life.
Feel:    Reflection. Something in the interpretation clicks
         with a current life situation.
Action:  Continue to Practice Card.

Step 4: Practice Card
─────────────────────────────────────────────────────
See:     "Try This Today" -- a 5-minute exercise.
Feel:    Intention-setting. "I can actually do this today."
Action:  Mentally commit to the practice. Or close the page
         and carry the verse with them.

Step 5: Optional -- Listen to Recitation
─────────────────────────────────────────────────────
See:     Audio player pill button.
Action:  Play the Sanskrit recitation while sitting quietly.
         The sound of the original language adds a dimension
         that text cannot.
Feel:    Immersion. The recitation is a micro-meditation.

Step 6: Exit
─────────────────────────────────────────────────────
Action:  Close the tab or leave the page.
Feel:    Grounded. The verse echoes through the morning.
Total time: 3-5 minutes.
```

### Key Design Decisions for This Flow

- The Daily Verse must change every day. The same verse on consecutive visits breaks the ritual.
- The homepage-to-verse-page transition should feel seamless. Consider pre-loading the verse page when the user hovers over "Read This Verse."
- The audio player should be one tap away. No navigation required.
- The practice card should be visible without scrolling past a lot of content. The modern interpretation should be concise (3 paragraphs max).
- No distracting elements on the verse page that break the contemplative mood. No "You might also like" carousels. The related verses section is below the fold, available but not attention-seeking.

### Retention Mechanisms

- The daily rotation provides a reason to return.
- The progress bar subtly tracks which verses the user has read over time (if they browse beyond the daily verse), creating a sense of accumulation without gamification.
- Over time, the user builds a personal practice of reading one verse per day -- Bodhi becomes part of their routine, not through notifications or streaks, but through the quality of the experience.

---

## 3. Deep Study Session Flow

### Persona

A serious student of Vedanta or Yoga philosophy who wants to read multiple verses sequentially, studying the text as a continuous dialogue. They may spend 30-60 minutes in a single session.

### Intent

"I want to read through a section of the text deeply, verse by verse, and understand the argument Shankaracharya is building."

### Flow

```
Step 1: Entry via Index
─────────────────────────────────────────────────────
URL:     /vivekachudamani or /yoga-sutras
See:     The full index with all verses.
Action:  Either pick up where they left off (the progress bar
         reminds them of their last position) or browse to a
         specific section.

Step 2: Begin Reading
─────────────────────────────────────────────────────
URL:     /vivekachudamani/verse/44
See:     Full verse page for verse 44.
Action:  Read Sanskrit, listen to audio, read translation.
         Expand the transliteration toggle (they are studying
         the Sanskrit). Expand word-by-word breakdown.

Step 3: Deep Engagement
─────────────────────────────────────────────────────
See:     Word-by-word section, Hindi commentary, modern
         interpretation.
Feel:    Understanding deepening. Cross-referencing the
         traditional commentary with the modern interpretation.
Action:  Read everything. May spend 3-5 minutes on this
         single verse.

Step 4: Navigate to Next Verse
─────────────────────────────────────────────────────
See:     "Verse 45 ->" navigation at the bottom.
Action:  Click next. The page transitions smoothly.
         The progress bar increments.

Step 5: Repeat (Verses 45, 46, 47...)
─────────────────────────────────────────────────────
Action:  Read 5-15 verses in sequence. The rhythm develops:
         Sanskrit -> Translation -> Interpretation -> Next.
         Some verses they linger on; others they move through
         quickly.
Feel:    Flow state. The sequential reading reveals the dialogue
         structure -- the Guru is building an argument, the
         Disciple is asking progressively deeper questions.
         The student feels this arc.

Step 6: Pause and Bookmark
─────────────────────────────────────────────────────
See:     A verse that particularly resonates. The share/save
         buttons.
Action:  Save (bookmark) the verse. Or share it via QuoteCard.
         The progress bar shows their position (e.g., 47/580 = 8.1%).

Step 7: End Session
─────────────────────────────────────────────────────
Action:  Close the tab, or hover over the progress bar to see
         "Last read: Verse 47."
Feel:    Accomplishment. They have moved through a meaningful
         section of the text. The progress bar will remind them
         where to resume.
```

### Key Design Decisions for This Flow

- **Sequential navigation must be effortless.** The "Next verse" link should be prominent and feel satisfying to click. Consider keyboard shortcuts: right arrow for next verse, left for previous.
- **Collapsible depth sections** (transliteration, word-by-word, Hindi) are important for this flow. The deep student opens them; the casual reader skips them. Both are served by the same page.
- **The progress bar is critical for this persona.** It provides a sense of journey and continuity across sessions. Without it, the 580-verse text feels like a formless ocean.
- **Page load speed matters.** When reading sequentially, the next verse should load near-instantly. Pre-fetch the next and previous verse pages.
- **No interruptions between verses.** No interstitial ads, no "Sign up to continue reading," no "Rate your experience." The flow between verses should feel like turning a page in a book.
- **Reading position persistence.** Store the last-read verse in localStorage so the user can resume seamlessly even without an account.

### Navigation Shortcuts (Keyboard)

| Key | Action |
|---|---|
| Right Arrow / `j` | Next verse |
| Left Arrow / `k` | Previous verse |
| Space | Toggle audio play/pause |
| `t` | Toggle transliteration |
| `w` | Toggle word-by-word |
| `h` | Toggle Hindi commentary |
| `Escape` | Close any open modal |

---

## 4. Search and Discovery Flow

### Persona

A user who remembers a concept, a phrase, or a feeling from a verse but does not know the verse number. Or someone who wants to explore a specific theme (e.g., "What does Shankara say about desire?").

### Intent

"I want to find that verse about..." or "Show me everything about Maya."

### Flow

```
Step 1: Trigger Search
─────────────────────────────────────────────────────
Location: Any page (search is in the nav).
Action:   Click the search icon (mobile) or the search bar
          (desktop).
See:      Search input expands / search sheet opens.

Step 2: Type Query
─────────────────────────────────────────────────────
Query:    "awareness" or "who am I" or "maya"
See:      Dropdown with 5 preview results, appearing as they
          type (300ms debounce, after 2+ characters).
          Each result shows: verse reference + matched text
          snippet with query highlighted.
Feel:     Speed. The results are instant and relevant.

Step 3a: Quick Find (Select from Dropdown)
─────────────────────────────────────────────────────
Action:   See the desired verse in the dropdown. Click it.
URL:      Navigated directly to /vivekachudamani/verse/136
Feel:     Efficient. Found what they wanted in under 10 seconds.

Step 3b: Full Search (Press Enter)
─────────────────────────────────────────────────────
URL:      /search?q=awareness
See:      Full search results page with 12 results, each showing
          context and highlights.
Action:   Scan the results. Click into the most relevant one.

Step 4: Alternative -- Theme Browsing
─────────────────────────────────────────────────────
URL:      /vivekachudamani?theme=maya
Action:   From the index page, click the "Maya" theme filter.
See:      The verse list filters to show only Maya-tagged verses.
          The count updates ("Showing 8 verses tagged Maya").
Feel:     Curated. Instead of searching through 580 verses, they
          see a focused collection.

Step 5: Cross-Reference
─────────────────────────────────────────────────────
See:      On a verse page, the "Related Verses" section shows
          2-3 other verses with the same theme.
Action:   Click into a related verse. The theme connection
          deepens understanding.
Feel:     Interconnection. "Shankara returns to this idea of
          Maya in multiple places -- let me trace the thread."
```

### Key Design Decisions for This Flow

- **Search must be fast.** Results should appear in under 200ms after the debounce. Use a pre-built search index (e.g., Fuse.js or Pagefind) rather than server-side search.
- **The dropdown preview should show enough context** (a sentence around the match) so users can identify the right verse without clicking through to the full results page.
- **Theme filtering and text search are complementary paths** to the same goal. The index page offers both.
- **Highlight matched text** in results so the user immediately sees why each result was returned.
- **Search should cover**: English translations, modern interpretations, transliterated Sanskrit, theme tags, and verse numbers (searching "verse 78" should return verse 78).

---

## 5. Mobile Reading Flow

### Persona

Someone reading on their phone -- in bed, on a commute, during a break. The phone is the primary device for most users (especially the target demographic of 25-45 year olds). The mobile experience is not a compromise; it is the primary experience.

### Intent

"Let me read a verse on my phone. Comfortably."

### Flow

```
Step 1: Open Site on Mobile
─────────────────────────────────────────────────────
See:     Full-screen Daily Verse. No hamburger menu visible
         yet (it appears on scroll). Just the BODHI logo, the
         verse, and dark space.
Feel:    The phone screen becomes a window into stillness.
         No visual clutter. The verse fills the screen.
Action:  Read the verse. The Devanagari text is sized for
         mobile (--text-2xl, ~22px) -- large enough to read
         the forms clearly.

Step 2: Tap "Read This Verse"
─────────────────────────────────────────────────────
URL:     /vivekachudamani/verse/[today]
See:     Verse page. The Sanskrit verse centered on screen.
         Below: the gold divider and English translation.
         The entire verse hero fits on one screen (no scrolling
         needed to see both Sanskrit and English).
Feel:    Completeness. The verse is self-contained in the
         first screen.

Step 3: Scroll Down (One-Thumb)
─────────────────────────────────────────────────────
Action:  Scroll with thumb. The modern interpretation section
         enters view.
See:     Text is set at --text-lg (18px) with generous
         line-height (1.9). Comfortable for one-handed phone
         reading. The text container has 16px padding on sides.
Feel:    Ease. The text is not cramped. There is breathing room
         between paragraphs.

Step 4: Practice Card
─────────────────────────────────────────────────────
See:     The practice card. Full-width within the content area.
         Card padding is --space-5 (24px).
Action:  Read the practice. It fits on one screen.

Step 5: Audio (Optional)
─────────────────────────────────────────────────────
Action:  Tap the audio pill button.
See:     The expanded audio player appears as a bottom sheet
         (slides up from the bottom edge), 60px tall. Play/
         pause, progress bar, and close button.
Feel:    The phone becomes a listening device. The user can
         close their eyes.

Step 6: Navigate to Next Verse
─────────────────────────────────────────────────────
Action:  Swipe or tap the "Verse N+1 ->" button at the bottom.
         Large touch target (full width, 48px tall).
See:     Smooth transition to the next verse. The progress
         bar at the very bottom updates.

Step 7: Share (Optional)
─────────────────────────────────────────────────────
Action:  Tap "Share This Verse."
See:     Native Web Share API sheet (on iOS/Android). Or the
         QuoteCard modal as a full-screen bottom sheet.
Action:  Share to WhatsApp, Instagram Stories, or save the
         quote card image to camera roll.
```

### Mobile-Specific Design Decisions

1. **Touch targets**: All interactive elements are minimum 44x44px. The verse navigation buttons are full-width on mobile for easy thumb reach.

2. **Font sizes**: Sanskrit text at --text-2xl (22px) minimum on mobile. English body text at 16px minimum. Never smaller than 15px for any readable text.

3. **Horizontal padding**: 16px on both sides. This gives the text room to breathe without wasting precious screen width.

4. **No horizontal scrolling anywhere.** Every element must fit within the viewport width.

5. **The hamburger menu opens as a full-screen overlay**, not a side drawer. The overlay uses large, centered links (Cormorant Garamond, 1.8rem) that are easy to tap. The dark overlay creates a calm, focused menu experience.

6. **Audio player**: Appears as a bottom sheet, not a floating bar. This is more natural on mobile and does not obscure the progress bar.

7. **Verse hero on mobile**: The verse number, theme tag, Sanskrit, audio button, divider, and translation should all fit within one screen on most phones (without scrolling). This means tighter vertical spacing on mobile -- the verse hero uses --space-6 (32px) instead of --space-8 between elements.

8. **Collapsible sections (transliteration, word-by-word, Hindi)**: These remain collapsed by default, which is especially important on mobile where vertical space is premium. The toggles are clearly labeled and have large touch targets.

9. **No sticky elements besides the nav and progress bar.** On mobile, screen real estate is too precious for sticky sidebars, floating buttons, or persistent CTAs.

10. **Dark mode is especially important on mobile.** Most mobile reading happens in bed or in dim environments. The dark theme reduces eye strain and blue light. The OLED screens on modern phones make true blacks energy-efficient and beautiful.

---

## Flow Interconnections

```
                    ┌─────────────┐
                    │   HOME      │
                    │ Daily Verse │
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
              v            v            v
     ┌────────────┐  ┌──────────┐  ┌──────────┐
     │ Viveka     │  │  Yoga    │  │  Search  │
     │ Index      │  │  Index   │  │  Results │
     └─────┬──────┘  └────┬─────┘  └────┬─────┘
           │               │              │
           └───────┬───────┘              │
                   │                      │
                   v                      │
           ┌──────────────┐               │
           │  Verse Page  │ <─────────────┘
           │  (Deep Dive) │
           │              │
           │  Sanskrit    │
           │  Translation │
           │  Interpret.  │
           │  Practice    │
           │  Related     │
           │  Share       │
           │              │
           │  ← Prev Next →
           └──────────────┘
                   │
                   v
           ┌──────────────┐
           │  Next Verse  │ (sequential reading loop)
           └──────────────┘
```

### The Central Loop

The individual verse page is the gravitational center of the entire experience. Every flow leads to it, and from it, the user can:
- Go to the next or previous verse (sequential study)
- Return to the index (browse)
- Follow a related verse (thematic exploration)
- Share a quote (social distribution, which brings new visitors to Step 1)
- Exit (carrying the verse with them)

The homepage and index pages are entry points. The verse page is the destination. The design of every other component exists to make the verse page experience as deep and uncluttered as possible.
