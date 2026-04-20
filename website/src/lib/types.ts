export interface Verse {
  readonly id: string;
  readonly verseNumber: number;
  readonly sanskrit: string;
  readonly transliteration?: string;
  readonly englishTranslation: string;
  readonly hindiMeaning?: string;
  readonly hindiExplanation?: string;
  readonly hindiExample?: string;
  readonly modernInterpretation: string;
  readonly theme: string;
  readonly reelHook: string;
  readonly practicePrompt: string;
  readonly audioUrl?: string;
  readonly tags?: readonly string[];
}

export interface Sutra extends Omit<Verse, "modernInterpretation" | "reelHook"> {
  readonly pada: number;
  readonly padaName: string;
  readonly sutraNumber: string;
  readonly practicalApplication: string;
}

export interface Text {
  readonly id: string;
  readonly title: string;
  readonly slug: string;
  readonly author: string;
  readonly verseCount: number;
  readonly description: string;
}

export interface Theme {
  readonly id: string;
  readonly name: string;
  readonly slug: string;
  readonly count: number;
}

export interface DailyVerse {
  readonly verse: Verse;
  readonly date: string;
}

/** Raw shape of a verse in verses.json */
export interface RawVerse {
  readonly verse_number: number;
  readonly sanskrit: string;
  readonly theme: string;
  readonly why_selected: string;
  readonly english_translation: string;
  readonly modern_interpretation: string;
  readonly reel_hook: string;
  readonly practice_prompt: string;
  readonly hindi_meaning?: string;
  readonly hindi_explanation?: string;
  readonly hindi_example?: string;
}

/** Raw shape of a sutra inside the padas array in sutras.json */
export interface RawSutra {
  readonly pada: number;
  readonly pada_name: string;
  readonly sutra_number: string;
  readonly sanskrit: string;
  readonly transliteration: string;
  readonly english_translation: string;
  readonly hindi_meaning: string;
  readonly hindi_explanation?: string;
  readonly hindi_example?: string;
  readonly theme: string;
  readonly practical_application: string;
  readonly tags: readonly string[];
}

/** Raw shape of a pada in sutras.json */
export interface RawPada {
  readonly number: number;
  readonly name: string;
  readonly name_devanagari: string;
  readonly sutra_count: number;
  readonly theme: string;
  readonly sutras: readonly RawSutra[];
}

/** Raw root shape of sutras.json */
export interface RawSutrasFile {
  readonly title: string;
  readonly source: string;
  readonly total_sutras: number;
  readonly padas: readonly RawPada[];
}
