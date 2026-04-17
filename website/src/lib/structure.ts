import { readFileSync } from "fs";
import path from "path";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export interface VivekachudamaniSection {
  sectionNumber: number;
  title: string;
  titleHindi?: string;
  titleMeaning: string;
  verseRange: readonly [number, number];
  verseCount: number;
  summary: string;
  narrativeRole?: string;
  emotionalArc?: string;
  connectionToNext?: string;
  connectionToPrevious?: string;
}

export interface YogaSutraSection {
  sectionNumber: number;
  title: string;
  titleMeaning: string;
  sutraRange: readonly [string, string];
  sutraCount: number;
  summary: string;
  narrativeRole?: string;
  pada: {
    number: number;
    name: string;
    nameDevanagari?: string;
  };
}

// ---------------------------------------------------------------------------
// Raw shapes (only what we actually read)
// ---------------------------------------------------------------------------

interface RawVCSection {
  section_number: number;
  title: string;
  title_hindi?: string;
  title_meaning: string;
  verse_range: [number, number];
  verse_count: number;
  summary: string;
  narrative_role?: string;
  emotional_arc?: string;
  connection_to_next?: string;
  connection_to_previous?: string;
}

interface RawVCStructure {
  sections: readonly RawVCSection[];
}

interface RawYSSection {
  section_number: number;
  title: string;
  title_meaning: string;
  sutra_range: [string, string];
  summary: string;
  narrative_role?: string;
}

interface RawYSPada {
  pada: number;
  name: string;
  name_devanagari?: string;
  sections: readonly RawYSSection[];
}

interface RawYSStructure {
  padas: readonly RawYSPada[];
}

// ---------------------------------------------------------------------------
// Data loading (runs once at module load — build time for static pages)
// ---------------------------------------------------------------------------

function loadJson<T>(relativeFromData: string): T {
  const filePath = path.join(
    process.cwd(),
    "..",
    "data",
    relativeFromData
  );
  const contents = readFileSync(filePath, "utf-8");
  return JSON.parse(contents) as T;
}

const vcStructure: RawVCStructure = loadJson<RawVCStructure>(
  "vivekachudamani-structure.json"
);

const ysStructure: RawYSStructure = loadJson<RawYSStructure>(
  "yoga-sutras-structure.json"
);

// ---------------------------------------------------------------------------
// Sutra ID parsing — "1.10" -> { pada: 1, sutra: 10 }
// ---------------------------------------------------------------------------

function parseSutraId(id: string): { pada: number; sutra: number } | null {
  const parts = id.split(".");
  if (parts.length !== 2) {
    return null;
  }
  const pada = Number(parts[0]);
  const sutra = Number(parts[1]);
  if (!Number.isFinite(pada) || !Number.isFinite(sutra)) {
    return null;
  }
  return { pada, sutra };
}

// ---------------------------------------------------------------------------
// Public API — Vivekachudamani
// ---------------------------------------------------------------------------

export function getVivekachudamaniSection(
  verseNumber: number
): VivekachudamaniSection | null {
  const match = vcStructure.sections.find(
    (s) => s.verse_range[0] <= verseNumber && verseNumber <= s.verse_range[1]
  );
  if (!match) {
    return null;
  }
  return {
    sectionNumber: match.section_number,
    title: match.title,
    titleHindi: match.title_hindi,
    titleMeaning: match.title_meaning,
    verseRange: match.verse_range,
    verseCount: match.verse_count,
    summary: match.summary,
    narrativeRole: match.narrative_role,
    emotionalArc: match.emotional_arc,
    connectionToNext: match.connection_to_next,
    connectionToPrevious: match.connection_to_previous,
  };
}

// ---------------------------------------------------------------------------
// Public API — Yoga Sutras
// ---------------------------------------------------------------------------

export function getYogaSutraSection(
  sutraId: string
): YogaSutraSection | null {
  const parsed = parseSutraId(sutraId);
  if (!parsed) {
    return null;
  }

  const pada = ysStructure.padas.find((p) => p.pada === parsed.pada);
  if (!pada) {
    return null;
  }

  const section = pada.sections.find((s) => {
    const startParsed = parseSutraId(s.sutra_range[0]);
    const endParsed = parseSutraId(s.sutra_range[1]);
    if (!startParsed || !endParsed) {
      return false;
    }
    return (
      parsed.sutra >= startParsed.sutra && parsed.sutra <= endParsed.sutra
    );
  });

  if (!section) {
    return null;
  }

  const startParsed = parseSutraId(section.sutra_range[0]);
  const endParsed = parseSutraId(section.sutra_range[1]);
  const sutraCount =
    startParsed && endParsed ? endParsed.sutra - startParsed.sutra + 1 : 0;

  return {
    sectionNumber: section.section_number,
    title: section.title,
    titleMeaning: section.title_meaning,
    sutraRange: section.sutra_range,
    sutraCount,
    summary: section.summary,
    narrativeRole: section.narrative_role,
    pada: {
      number: pada.pada,
      name: pada.name,
      nameDevanagari: pada.name_devanagari,
    },
  };
}

// ---------------------------------------------------------------------------
// Helpers for positional display
// ---------------------------------------------------------------------------

export function getVersePositionInSection(
  verseNumber: number,
  section: VivekachudamaniSection
): { position: number; total: number } {
  return {
    position: verseNumber - section.verseRange[0] + 1,
    total: section.verseCount,
  };
}

export function getSutraPositionInSection(
  sutraId: string,
  section: YogaSutraSection
): { position: number; total: number } | null {
  const parsed = parseSutraId(sutraId);
  const startParsed = parseSutraId(section.sutraRange[0]);
  if (!parsed || !startParsed) {
    return null;
  }
  return {
    position: parsed.sutra - startParsed.sutra + 1,
    total: section.sutraCount,
  };
}

// ---------------------------------------------------------------------------
// Truncation helper for short-form display
// ---------------------------------------------------------------------------

export function truncateText(text: string, maxChars: number): string {
  if (text.length <= maxChars) {
    return text;
  }
  // Try to cut at sentence boundary first
  const firstSentenceEnd = text.search(/[.!?]\s/);
  if (firstSentenceEnd > 0 && firstSentenceEnd + 1 <= maxChars) {
    return text.slice(0, firstSentenceEnd + 1);
  }
  // Otherwise cut at word boundary
  const sliced = text.slice(0, maxChars);
  const lastSpace = sliced.lastIndexOf(" ");
  return (lastSpace > 0 ? sliced.slice(0, lastSpace) : sliced) + "…";
}
