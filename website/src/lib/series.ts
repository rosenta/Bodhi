import { readFileSync, readdirSync, statSync } from "fs";
import { join } from "path";

export interface SeriesPart {
  readonly seriesSlug: string;
  readonly partSlug: string;
  readonly part: number;
  readonly title: string;
  readonly seriesTitle: string;
  readonly subtitle: string;
  readonly englishName: string;
  readonly referencesLabel: string;
  readonly references: readonly string[];
  readonly content: string;
}

export interface Series {
  readonly slug: string;
  readonly title: string;
  readonly description: string;
  readonly partCount: number;
  readonly parts: readonly SeriesPart[];
}

const SERIES_DIR = join(process.cwd(), "..", "content", "series");

const SERIES_META: Record<
  string,
  { readonly description: string; readonly subtitleKey: string; readonly referencesKey: string }
> = {
  "pancha-kosha": {
    description:
      "The five sheaths that veil the true Self — from the physical body to the bliss body — systematically dismantled in the Vivekachudamani.",
    subtitleKey: "kosha",
    referencesKey: "verse_references",
  },
  "ashtanga-yoga": {
    description:
      "Patanjali's eight-limbed path to liberation — from ethical foundations through absorption — as presented in the Yoga Sutras.",
    subtitleKey: "limb",
    referencesKey: "sutra_references",
  },
};

interface Frontmatter {
  readonly values: Record<string, string>;
  readonly arrays: Record<string, readonly string[]>;
}

function parseFrontmatter(raw: string): {
  meta: Frontmatter;
  content: string;
} {
  const match = raw.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
  if (!match) return { meta: { values: {}, arrays: {} }, content: raw };

  const values: Record<string, string> = {};
  const arrays: Record<string, readonly string[]> = {};

  for (const line of match[1].split("\n")) {
    const colonIndex = line.indexOf(":");
    if (colonIndex === -1) continue;
    const key = line.slice(0, colonIndex).trim();
    const rawValue = line.slice(colonIndex + 1).trim();

    // Array form: [a, b, "c"]
    if (rawValue.startsWith("[") && rawValue.endsWith("]")) {
      const inside = rawValue.slice(1, -1).trim();
      if (inside === "") {
        arrays[key] = [];
        continue;
      }
      const items = inside.split(",").map((s) =>
        s.trim().replace(/^["']|["']$/g, "")
      );
      arrays[key] = items;
      continue;
    }

    values[key] = rawValue.replace(/^["']|["']$/g, "");
  }

  return { meta: { values, arrays }, content: match[2].trim() };
}

function fileToSeriesPart(
  seriesSlug: string,
  filename: string
): SeriesPart | undefined {
  const meta = SERIES_META[seriesSlug];
  if (!meta) return undefined;

  const raw = readFileSync(join(SERIES_DIR, seriesSlug, filename), "utf-8");
  const { meta: fm, content } = parseFrontmatter(raw);
  const partSlug = filename.replace(/\.md$/, "");

  // Derive a title: first H1 of the body, else english_name, else partSlug
  const h1Match = content.match(/^#\s+(.+)$/m);
  const title =
    h1Match?.[1]?.trim() ||
    fm.values.english_name ||
    partSlug;

  const references = fm.arrays[meta.referencesKey] ?? [];
  const referencesLabel =
    meta.referencesKey === "verse_references"
      ? "Vivekachudamani"
      : "Yoga Sutras";

  return {
    seriesSlug,
    partSlug,
    part: Number(fm.values.part) || 0,
    title,
    seriesTitle: fm.values.series || "",
    subtitle: fm.values[meta.subtitleKey] || "",
    englishName: fm.values.english_name || "",
    referencesLabel,
    references,
    content,
  };
}

function loadSeries(slug: string): Series | undefined {
  const meta = SERIES_META[slug];
  if (!meta) return undefined;

  try {
    const dir = join(SERIES_DIR, slug);
    const files = readdirSync(dir).filter((f) => f.endsWith(".md"));
    const parts = files
      .map((f) => fileToSeriesPart(slug, f))
      .filter((p): p is SeriesPart => p !== undefined)
      .sort((a, b) => a.part - b.part);

    if (parts.length === 0) return undefined;

    return {
      slug,
      title: parts[0].seriesTitle || slug,
      description: meta.description,
      partCount: parts.length,
      parts,
    };
  } catch {
    return undefined;
  }
}

export function getAllSeries(): readonly Series[] {
  try {
    const entries = readdirSync(SERIES_DIR).filter((name) => {
      try {
        return statSync(join(SERIES_DIR, name)).isDirectory();
      } catch {
        return false;
      }
    });

    return entries
      .map(loadSeries)
      .filter((s): s is Series => s !== undefined)
      .sort((a, b) => a.slug.localeCompare(b.slug));
  } catch {
    return [];
  }
}

export function getSeriesBySlug(slug: string): Series | undefined {
  return loadSeries(slug);
}

export function getSeriesPart(
  seriesSlug: string,
  partSlug: string
): { readonly series: Series; readonly part: SeriesPart } | undefined {
  const series = getSeriesBySlug(seriesSlug);
  if (!series) return undefined;
  const part = series.parts.find((p) => p.partSlug === partSlug);
  if (!part) return undefined;
  return { series, part };
}
