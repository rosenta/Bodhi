# Project Bodhi -- Design System

> Ancient verses. Modern clarity.

This design system governs the visual language of Project Bodhi, a contemplative digital experience presenting Vivekachudamani (580 verses) and Yoga Darshan (195 sutras). Every decision serves one principle: **slow the reader down so the wisdom can land**.

---

## 1. Design Philosophy

### Core Principles

1. **Breath over bandwidth.** Every element should have space to breathe. If a screen feels "full," remove something.
2. **Stillness as interaction.** The best interaction is the user pausing to absorb a verse. Design for dwell time, not click-through rate.
3. **Reverence without religion.** The aesthetic should feel sacred and elevated without being devotional or sectarian. Think museum gallery, not temple.
4. **Progressive depth.** Surface is simple; depth is available. Never show everything at once. Let the user choose to go deeper.
5. **Typography is the hero.** Sanskrit Devanagari and English serif are the primary visual elements. Photography and illustration are secondary.

### Anti-Patterns (What We Never Do)

- No flashy animations, parallax overload, or motion for motion's sake
- No cluttered layouts, sidebars dense with links, or "wall of text" presentations
- No pop-ups, newsletter nags, cookie banners (use minimal footer consent)
- No gamification, streak counters, or dopamine loops
- No stock photography of "meditating person on mountain"
- No infinite scroll on verse lists (use deliberate pagination)

---

## 2. Color System

### Dark Mode (Primary)

The default and recommended experience. Dark environments reduce visual noise, evoke night-time contemplation, and let gold accents feel luminous.

| Token | Hex | Usage |
|---|---|---|
| `--bg-primary` | `#0A0A0F` | Page background, full-bleed sections |
| `--bg-secondary` | `#12121A` | Slightly elevated surfaces, nav background |
| `--bg-card` | `#1A1A25` | Cards, practice prompts, elevated containers |
| `--bg-card-hover` | `#22222F` | Card hover state |
| `--bg-surface` | `#141420` | Input fields, search bar, subtle containers |
| `--text-primary` | `#E8E6E0` | Headings, English translations, primary body text |
| `--text-secondary` | `#9A9690` | Captions, metadata, secondary body text |
| `--text-tertiary` | `#6A6660` | Disabled text, placeholders, timestamps |
| `--accent-gold` | `#C9A55A` | Logo, labels, section headers, interactive highlights |
| `--accent-gold-muted` | `rgba(201, 165, 90, 0.15)` | Borders, dividers, subtle gold tints |
| `--accent-saffron` | `#E67E22` | Active states, progress indicators, emphasis |
| `--accent-warm` | `#D4A574` | Sanskrit text, warm highlights |
| `--accent-cream` | `#F5E6C8` | Hover states for Sanskrit, high-contrast moments |
| `--border` | `rgba(201, 165, 90, 0.12)` | Card borders, dividers, nav bottom border |
| `--border-strong` | `rgba(201, 165, 90, 0.25)` | Focused input borders, active card borders |
| `--overlay` | `rgba(10, 10, 15, 0.85)` | Modal overlays, backdrop layers |

### Light Mode (Variant)

For daytime reading or user preference. The palette inverts while preserving warmth and quietness. Not a simple inversion -- the light mode has its own character: parchment-warm, like a well-lit reading room.

| Token | Hex (Light) | Usage |
|---|---|---|
| `--bg-primary` | `#FAF7F2` | Page background (warm parchment white) |
| `--bg-secondary` | `#F0EDE6` | Slightly recessed surfaces |
| `--bg-card` | `#FFFFFF` | Cards (true white for contrast) |
| `--bg-card-hover` | `#F8F5EF` | Card hover state |
| `--bg-surface` | `#F5F2EC` | Input fields, search bar |
| `--text-primary` | `#1A1A1F` | Headings, body text |
| `--text-secondary` | `#5A5650` | Captions, metadata |
| `--text-tertiary` | `#9A9690` | Disabled text, placeholders |
| `--accent-gold` | `#8B6914` | Logo, labels (darkened for contrast on light) |
| `--accent-gold-muted` | `rgba(139, 105, 20, 0.10)` | Borders, subtle tints |
| `--accent-saffron` | `#C96A10` | Active states (darkened for accessibility) |
| `--accent-warm` | `#7A5A30` | Sanskrit text (darkened for legibility) |
| `--border` | `rgba(0, 0, 0, 0.08)` | Card borders, dividers |
| `--border-strong` | `rgba(0, 0, 0, 0.15)` | Focused inputs |
| `--overlay` | `rgba(250, 247, 242, 0.90)` | Modal overlays |

### Gradients

```
--gradient-gold:    linear-gradient(135deg, #C9A55A, #E67E22)
--gradient-verse:   linear-gradient(180deg, transparent, var(--bg-primary))
--gradient-fade-up: linear-gradient(to top, var(--bg-primary), transparent)
--gradient-fade-down: linear-gradient(to bottom, var(--bg-primary), transparent)
--gradient-gold-line: linear-gradient(to bottom, transparent, var(--accent-gold), transparent)
```

### Semantic Colors

| Token | Dark | Light | Usage |
|---|---|---|---|
| `--success` | `#4A9B6E` | `#2D7A4A` | Completed state, confirmation |
| `--info` | `#5A8AB5` | `#3A6A95` | Informational notices |
| `--warning` | `#C9A55A` | `#8B6914` | Caution (reuses gold) |
| `--error` | `#B54A4A` | `#953A3A` | Error states |

---

## 3. Typography

### Font Stack

| Role | Family | Weight Range | Fallback |
|---|---|---|---|
| **Devanagari** | Noto Sans Devanagari | 300, 400, 600 | Mangal, sans-serif |
| **Latin Serif** | Cormorant Garamond | 300, 400, 600 (+ italics) | Georgia, serif |
| **Latin Sans** | Inter | 300, 400, 500 | system-ui, sans-serif |

### Why These Fonts

- **Noto Sans Devanagari**: Best-in-class open-source Devanagari with excellent weight range and screen legibility. The rounded forms complement the gold palette.
- **Cormorant Garamond**: An elegant, high-contrast serif with a literary quality. Its light weight (300) creates the airy, meditative feel needed for translations. Its italic has genuine calligraphic character.
- **Inter**: A neutral, highly legible sans-serif for UI elements, metadata, and modern interpretations. It recedes, letting the serif and Devanagari carry emotional weight.

### Type Scale (rem-based, 16px root)

| Token | Size (rem) | Size (px) | Line Height | Usage |
|---|---|---|---|---|
| `--text-xs` | 0.75 | 12 | 1.5 | Metadata, timestamps, fine print |
| `--text-sm` | 0.85 | ~14 | 1.5 | Captions, nav links, tags |
| `--text-base` | 1.0 | 16 | 1.7 | Body text (Inter) |
| `--text-lg` | 1.1 | ~18 | 1.8 | Modern interpretation body |
| `--text-xl` | 1.25 | 20 | 1.7 | Subheadings |
| `--text-2xl` | 1.4 | ~22 | 1.8 | English translation (Cormorant) |
| `--text-3xl` | 1.6 | ~26 | 2.2 | Sanskrit verse (Noto Devanagari) |
| `--text-4xl` | 2.0 | 32 | 1.5 | Page titles (Cormorant) |
| `--text-5xl` | 2.8 | ~45 | 1.3 | Hero verse display |
| `--text-6xl` | 3.5 | 56 | 1.2 | Landing page hero |

### Typography Rules

1. **Sanskrit text** always uses `Noto Sans Devanagari` in `--accent-warm` color. Line height is generous (2.0-2.2) to allow each line of verse to stand alone.
2. **English translations** use `Cormorant Garamond` in italic weight 300. The lightness and italic slant signal "interpreted meaning" versus the solidity of the Sanskrit original.
3. **Section labels** use `Inter` weight 500, uppercase, with `0.15-0.25em` letter-spacing, in `--accent-gold`. These are small, functional markers that orient the reader.
4. **Body text** (modern interpretations, about pages) uses `Inter` weight 300-400 at `--text-lg` with generous line-height (1.8-1.9). The lightness keeps the tone conversational, not authoritative.
5. **Verse numbers** use `Cormorant Garamond` weight 400, uppercase, with `0.3em` letter-spacing in `--accent-gold`.
6. **Maximum line length**: 65-70 characters for Latin text, 40-45 characters for Devanagari. Use `max-width` on text containers accordingly (650px for Latin, 700px for Devanagari at standard sizes).

### Responsive Typography Scaling

```
Mobile  (< 640px):  root = 15px, Sanskrit --text-2xl, Translation --text-xl
Tablet  (640-1024):  root = 16px, standard scale
Desktop (> 1024):    root = 16px, Sanskrit --text-3xl, Translation --text-2xl
Large   (> 1440):    root = 17px, Sanskrit --text-4xl, Translation --text-3xl
```

---

## 4. Spacing System

Based on an **8px grid** with a deliberate bias toward generous spacing. When in doubt, add more space.

| Token | Value | Usage |
|---|---|---|
| `--space-1` | 4px | Tight internal padding (icon gaps) |
| `--space-2` | 8px | Inline element spacing |
| `--space-3` | 12px | Small component padding |
| `--space-4` | 16px | Standard component padding |
| `--space-5` | 24px | Card padding, section gaps |
| `--space-6` | 32px | Section separation |
| `--space-7` | 40px | Between major content blocks |
| `--space-8` | 48px | Major section breaks |
| `--space-10` | 64px | Between page sections |
| `--space-12` | 80px | Hero section padding |
| `--space-16` | 128px | Full viewport section spacing |
| `--space-20` | 160px | Landing page hero top padding |

### Spacing Principles

1. **Verse breathing room**: A verse displayed at full viewport must have at least `--space-12` (80px) of padding on all sides. The verse should feel like a single object in a gallery, not a paragraph in a document.
2. **Section transitions**: Between major content sections (e.g., Sanskrit verse to modern interpretation), use at least `--space-10` (64px). Consider a visual divider (gold line, 60px wide, 1px).
3. **Card padding**: All cards use `--space-5` (24px) minimum internal padding, `--space-6` (32px) preferred.
4. **List item spacing**: Verse list items have `--space-4` (16px) vertical gap between them. They should not feel crowded.
5. **Mobile reduction**: On screens below 640px, reduce section spacing by one tier (e.g., `--space-10` becomes `--space-8`). Never reduce below `--space-5` for verse-related spacing.

---

## 5. Layout & Grid

### Container Widths

| Token | Value | Usage |
|---|---|---|
| `--container-narrow` | 650px | Verse text, translations, interpretations |
| `--container-medium` | 800px | Verse page depth sections |
| `--container-wide` | 1080px | Verse list, search results |
| `--container-full` | 1280px | Navigation, footer, max page width |

### Grid System

- **Verse pages**: Single column, centered. No sidebar. The content is the only thing on screen.
- **Index pages**: 1-column list (mobile), 2-column grid (tablet+) for verse cards.
- **Home page**: Full-bleed sections stacked vertically. No grid -- each section is its own world.
- **Yoga Sutras index**: 4-column pada navigation at top (1 per pada), verse list below.

### Centering

All primary content is horizontally centered. The center axis is sacred -- it mirrors the vertical gold line motif (the thread of awareness running through the page). Left-alignment is used only within cards and for secondary body text.

---

## 6. Borders, Shadows & Effects

### Border Radius

| Token | Value | Usage |
|---|---|---|
| `--radius-sm` | 4px | Tags, small badges |
| `--radius-md` | 8px | Buttons, input fields |
| `--radius-lg` | 12px | Cards, practice prompts |
| `--radius-xl` | 20px | Pill buttons, tag chips |
| `--radius-full` | 9999px | Audio player controls, circular avatars |

### Shadows

Shadows are used sparingly. The dark theme does not rely on shadows for elevation -- borders and background color shifts do the work. In light mode, subtle shadows appear.

| Token | Value (Dark) | Value (Light) |
|---|---|---|
| `--shadow-sm` | none | `0 1px 3px rgba(0, 0, 0, 0.06)` |
| `--shadow-md` | none | `0 4px 12px rgba(0, 0, 0, 0.08)` |
| `--shadow-lg` | none | `0 8px 30px rgba(0, 0, 0, 0.10)` |
| `--shadow-glow` | `0 0 40px rgba(201, 165, 90, 0.06)` | none |

### Blur Effects

| Token | Value | Usage |
|---|---|---|
| `--blur-nav` | `blur(20px)` | Navigation bar backdrop |
| `--blur-overlay` | `blur(10px)` | Modal/sheet overlays |
| `--blur-subtle` | `blur(4px)` | Depth-of-field effects on background elements |

### Dividers

The primary divider is a short gold line, centered:
- Width: 60px
- Height: 1px
- Color: `--accent-gold`
- Margin: `--space-6` above and below

A secondary divider is a full-width 1px line using `--border`:
- Used between list items and sections where a subtle break is needed.

---

## 7. Animation Principles

### Philosophy

Animation in Bodhi is like breathing: present, rhythmic, barely noticed. It should never draw attention to itself. The purpose of animation is to ease transitions and create a sense of organic, living stillness -- not to entertain.

### Timing Functions

| Token | Value | Usage |
|---|---|---|
| `--ease-default` | `cubic-bezier(0.4, 0, 0.2, 1)` | Standard transitions |
| `--ease-in` | `cubic-bezier(0.4, 0, 1, 1)` | Elements leaving the screen |
| `--ease-out` | `cubic-bezier(0, 0, 0.2, 1)` | Elements entering the screen |
| `--ease-gentle` | `cubic-bezier(0.25, 0.1, 0.25, 1)` | Slow, contemplative reveals |

### Duration Scale

| Token | Value | Usage |
|---|---|---|
| `--duration-fast` | 150ms | Hover states, micro-interactions |
| `--duration-base` | 300ms | Standard transitions (color, opacity) |
| `--duration-slow` | 500ms | Element reveals, section transitions |
| `--duration-slower` | 800ms | Page entry animations, verse reveals |
| `--duration-contemplative` | 1200ms | Hero verse fade-in, landing page elements |

### Core Animations

1. **Fade Up**: Elements enter with a gentle vertical movement (20px) and opacity transition. Stagger child elements by 200ms each. This is the primary entry animation.
   ```
   @keyframes fadeUp {
     from { opacity: 0; transform: translateY(20px); }
     to   { opacity: 1; transform: translateY(0); }
   }
   ```

2. **Fade In**: Simple opacity transition for elements that should appear without movement (e.g., background changes, overlay appearances).

3. **Gold Line Grow**: The vertical gold line at the top of verse pages grows downward from 0 to its full height (100px) over `--duration-contemplative`.

4. **Progress Fill**: The bottom progress bar fills smoothly using `--ease-gentle` over `--duration-slow`.

5. **Scroll Reveal**: Sections below the fold enter via Intersection Observer with `fadeUp` when 20% visible. Each section triggers independently. No scroll-jacking -- the user controls the pace.

### Animation Rules

- **Respect `prefers-reduced-motion`.** When enabled, replace all animations with instant transitions (0ms duration, no transforms).
- **No looping animations.** Nothing should pulse, rotate, or bounce indefinitely. The page should feel still when the user is still.
- **No scroll-jacking.** The user controls scroll position and speed at all times.
- **Stagger, don't synchronize.** When multiple elements appear, stagger them by 200ms. Synchronized animations feel mechanical; staggered ones feel organic.
- **Maximum 3 animated elements per viewport.** If more elements need to animate, group them.

---

## 8. Iconography

### Direction

Icons are minimal, line-based, and used sparingly. The design relies on typography and space, not icons, for communication.

### Style

- **Stroke weight**: 1.5px (matches the thin, elegant feel of Cormorant Garamond)
- **Size**: 20px standard, 16px compact, 24px prominent
- **Color**: `--text-secondary` default, `--accent-gold` on hover/active
- **Source**: Lucide Icons (open-source, consistent with the thin-line aesthetic)

### Icon Inventory

| Icon | Usage |
|---|---|
| `chevron-left` / `chevron-right` | Verse navigation (previous/next) |
| `search` | Search bar |
| `play-circle` | Audio player (play) |
| `pause-circle` | Audio player (pause) |
| `volume-2` | Audio player (volume) |
| `bookmark` / `bookmark-check` | Save verse |
| `share-2` | Share verse |
| `sun` / `moon` | Theme toggle |
| `menu` | Mobile hamburger |
| `x` | Close modal/menu |
| `arrow-up` | Back to top |
| `filter` | Theme filter |
| `hash` | Verse number reference |
| `book-open` | Text/scripture indicator |
| `compass` | Explore/discover |

### Icon Rules

- Never use icons as decoration. Every icon must have a functional purpose.
- Always pair icons with text labels on desktop. Icons-only are acceptable on mobile for common actions (search, menu, share).
- Icon transitions: color only, `--duration-fast`. No scaling or rotation on hover.

---

## 9. Responsive Breakpoints

| Token | Value | Columns | Behavior |
|---|---|---|---|
| `--bp-mobile` | < 640px | 1 | Single column, stacked layout, hamburger nav |
| `--bp-tablet` | 640px - 1023px | 1-2 | Two-column verse list, expanded nav |
| `--bp-desktop` | 1024px - 1439px | 2-3 | Full navigation, optimal reading width |
| `--bp-large` | >= 1440px | 2-3 | Maximum container widths, generous margins |

### Responsive Principles

1. **Mobile is the primary reading device.** Design every component mobile-first. The mobile verse experience must be as contemplative as desktop.
2. **Navigation collapses at `--bp-mobile`** to a hamburger menu. The logo remains visible.
3. **Verse display** is always single-column and centered, regardless of breakpoint. Only the font size and spacing scale change.
4. **Verse lists** shift from 1-column (mobile) to 2-column (tablet+). Never 3-column for verses -- they need horizontal space for the Devanagari text.
5. **Touch targets** are minimum 44x44px on mobile.
6. **Horizontal padding**: 16px (mobile), 24px (tablet), 32px (desktop). Verse pages use extra generous padding.

---

## 10. Accessibility

### Color Contrast

- All text meets WCAG AA (4.5:1 for normal text, 3:1 for large text).
- `--text-primary` on `--bg-primary`: 13.2:1 (dark mode), 14.5:1 (light mode) -- exceeds AAA.
- `--accent-gold` on `--bg-primary`: 6.8:1 -- meets AA for large text. For small text, use `--accent-cream` (#F5E6C8) which achieves 10.1:1.
- `--text-secondary` on `--bg-primary`: 4.7:1 -- meets AA.

### Focus States

- All interactive elements show a visible focus ring: `2px solid var(--accent-gold)` with `2px offset`.
- Focus ring is visible in both dark and light modes.
- Tab order follows logical reading flow: nav, verse, interpretation, practice, navigation arrows.

### Screen Readers

- Sanskrit text includes `lang="sa"` attribute for correct pronunciation by screen readers.
- All decorative elements (gold lines, ornamental dividers) are `aria-hidden="true"`.
- Verse navigation uses `aria-label` (e.g., "Go to verse 21").
- Progress bar uses `role="progressbar"` with `aria-valuenow`, `aria-valuemin`, `aria-valuemax`.

### Motion

- All animations respect `prefers-reduced-motion: reduce`.
- No content is hidden behind required animations -- everything is accessible without motion.

### Font Sizing

- All font sizes are in `rem` units, respecting user browser settings.
- Minimum font size on any element: 12px (0.75rem).
- Body text never goes below 15px on any breakpoint.

---

## 11. Z-Index Scale

| Token | Value | Usage |
|---|---|---|
| `--z-base` | 0 | Default content |
| `--z-card` | 10 | Elevated cards (on hover) |
| `--z-nav` | 100 | Fixed navigation bar |
| `--z-overlay` | 200 | Modal overlays, drawers |
| `--z-modal` | 300 | Modal content |
| `--z-toast` | 400 | Toast notifications |
| `--z-progress` | 50 | Fixed progress bar |

---

## 12. Component Token Naming Convention

All CSS custom properties follow this pattern:

```
--{category}-{element}-{modifier}

Examples:
  --bg-primary
  --text-secondary
  --accent-gold-muted
  --space-8
  --radius-lg
  --duration-slow
  --shadow-glow
```

For component-specific tokens:

```
--{component}-{property}-{state}

Examples:
  --card-bg-hover
  --nav-height
  --verse-line-height
  --audio-progress-fill
```

---

## 13. Asset Guidelines

### Photography

If images are ever used (about page, editorial features), they should be:
- High contrast, desaturated, with warm tones
- Subjects: natural textures (stone, water, sky, flame, leaves), architectural details of ancient structures, close-up calligraphy
- Never: people in stereotypical meditation poses, stock "spiritual" imagery, busy compositions
- Treatment: slight grain, reduced saturation, warm color grade matching the gold palette

### Ornamental Elements

The only ornamental element is the **vertical gold line** -- a recurring motif representing the thread of awareness (sutra literally means "thread"). It appears:
- At the top of verse pages (growing downward from the nav)
- Between major sections as a short horizontal divider
- As the progress bar at the page bottom

No other ornamental elements (no mandala backgrounds, no lotus motifs, no Om symbols). The restraint itself communicates sophistication.

### Favicon & App Icon

- Favicon: A minimal gold mark on dark background -- either a stylized "B" in Cormorant Garamond or a single Devanagari character (OM or the first syllable of Bodhi: बो)
- App icon: Same mark, centered, with generous padding

---

## 14. Dark Mode Implementation Notes

Dark mode is the default. The system respects `prefers-color-scheme` on first visit, but defaults to dark if no preference is set. Users can toggle manually via a sun/moon icon in the navigation.

Theme preference is stored in `localStorage` under key `bodhi-theme` with values `"dark"` or `"light"`.

The toggle should apply `data-theme="light"` on `<html>`, with CSS custom properties overridden in:

```css
[data-theme="light"] {
  --bg-primary: #FAF7F2;
  --bg-secondary: #F0EDE6;
  /* ... all light-mode overrides ... */
}
```

The transition between themes uses `--duration-slow` (500ms) on `background-color` and `color` properties only. No flash of unstyled content -- the theme is applied before first paint via a blocking inline script that reads `localStorage`.
