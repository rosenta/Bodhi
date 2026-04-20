import type {
  Verse,
  Sutra,
  DailyVerse,
  RawVerse,
  RawSutrasFile,
  RawSutra,
} from "./types";
import rawVerses from "@/data/verses.json";
import rawSutrasFile from "@/data/sutras.json";

// ---------------------------------------------------------------------------
// Verse transformations (Vivekachudamani)
// ---------------------------------------------------------------------------

function toVerse(raw: RawVerse): Verse {
  return {
    id: `vc-${raw.verse_number}`,
    verseNumber: raw.verse_number,
    sanskrit: raw.sanskrit,
    englishTranslation: raw.english_translation,
    modernInterpretation: raw.modern_interpretation,
    theme: raw.theme,
    reelHook: raw.reel_hook,
    practicePrompt: raw.practice_prompt,
    hindiMeaning: raw.hindi_meaning,
    hindiExplanation: raw.hindi_explanation,
    hindiExample: raw.hindi_example,
  };
}

const verses: readonly Verse[] = (rawVerses as readonly RawVerse[]).map(toVerse);

// ---------------------------------------------------------------------------
// Sutra transformations (Yoga Sutras)
// ---------------------------------------------------------------------------

function toSutra(raw: RawSutra): Sutra {
  return {
    id: `ys-${raw.sutra_number}`,
    verseNumber: raw.pada,
    sutraNumber: raw.sutra_number,
    pada: raw.pada,
    padaName: raw.pada_name,
    sanskrit: raw.sanskrit,
    transliteration: raw.transliteration,
    englishTranslation: raw.english_translation,
    hindiMeaning: raw.hindi_meaning,
    hindiExplanation: raw.hindi_explanation,
    hindiExample: raw.hindi_example,
    theme: raw.theme,
    practicalApplication: raw.practical_application,
    practicePrompt: raw.practical_application,
    tags: raw.tags,
  };
}

const sutrasFile = rawSutrasFile as unknown as RawSutrasFile;

const sutras: readonly Sutra[] = sutrasFile.padas.flatMap((pada) =>
  pada.sutras.map(toSutra),
);

// ---------------------------------------------------------------------------
// Public API — Vivekachudamani Verses
// ---------------------------------------------------------------------------

export function getAllVerses(): readonly Verse[] {
  return verses;
}

export function getVerseByNumber(num: number): Verse | undefined {
  return verses.find((v) => v.verseNumber === num);
}

export function getVersesByTheme(theme: string): readonly Verse[] {
  const lower = theme.toLowerCase();
  return verses.filter((v) => v.theme.toLowerCase() === lower);
}

export function searchVerses(query: string): readonly Verse[] {
  const lower = query.toLowerCase();
  return verses.filter(
    (v) =>
      v.englishTranslation.toLowerCase().includes(lower) ||
      v.modernInterpretation.toLowerCase().includes(lower) ||
      v.sanskrit.toLowerCase().includes(lower) ||
      v.theme.toLowerCase().includes(lower) ||
      v.reelHook.toLowerCase().includes(lower),
  );
}

// ---------------------------------------------------------------------------
// Public API — Yoga Sutras
// ---------------------------------------------------------------------------

export function getAllSutras(): readonly Sutra[] {
  return sutras;
}

export function getSutraByNumber(num: string): Sutra | undefined {
  return sutras.find((s) => s.sutraNumber === num);
}

export function getSutrasByPada(padaNum: number): readonly Sutra[] {
  return sutras.filter((s) => s.pada === padaNum);
}

// ---------------------------------------------------------------------------
// Public API — Daily Verse
// ---------------------------------------------------------------------------

export function getDailyVerse(): DailyVerse {
  const today = new Date();
  const dayOfYear = Math.floor(
    (today.getTime() - new Date(today.getFullYear(), 0, 0).getTime()) /
      (1000 * 60 * 60 * 24),
  );
  const index = dayOfYear % verses.length;
  const verse = verses[index];

  return {
    verse,
    date: today.toISOString().slice(0, 10),
  };
}
