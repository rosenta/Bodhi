import { readFileSync, readdirSync } from "fs";
import { join } from "path";

export interface Practice {
  readonly slug: string;
  readonly practice: number;
  readonly title: string;
  readonly duration: string;
  readonly difficulty: string;
  readonly verseReference: number;
  readonly source: string;
  readonly theme: string;
  readonly tagline: string;
  readonly content: string;
}

const PRACTICES_DIR = join(
  process.cwd(),
  "..",
  "content",
  "practices"
);

function parseFrontmatter(raw: string): {
  meta: Record<string, string>;
  content: string;
} {
  const match = raw.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
  if (!match) return { meta: {}, content: raw };

  const meta: Record<string, string> = {};
  for (const line of match[1].split("\n")) {
    const colonIndex = line.indexOf(":");
    if (colonIndex === -1) continue;
    const key = line.slice(0, colonIndex).trim();
    const value = line.slice(colonIndex + 1).trim().replace(/^["']|["']$/g, "");
    meta[key] = value;
  }

  return { meta, content: match[2].trim() };
}

function fileToPractice(filename: string): Practice {
  const raw = readFileSync(join(PRACTICES_DIR, filename), "utf-8");
  const { meta, content } = parseFrontmatter(raw);
  const slug = filename.replace(/\.md$/, "");

  return {
    slug,
    practice: Number(meta.practice) || 0,
    title: meta.title || slug,
    duration: meta.duration || "",
    difficulty: meta.difficulty || "",
    verseReference: Number(meta.verse_reference) || 0,
    source: meta.source || "",
    theme: meta.theme || "",
    tagline: meta.tagline || "",
    content,
  };
}

export function getAllPractices(): readonly Practice[] {
  try {
    const files = readdirSync(PRACTICES_DIR).filter((f) => f.endsWith(".md"));
    return files
      .map(fileToPractice)
      .sort((a, b) => a.practice - b.practice);
  } catch {
    return [];
  }
}

export function getPracticeBySlug(slug: string): Practice | undefined {
  try {
    const filename = `${slug}.md`;
    return fileToPractice(filename);
  } catch {
    return undefined;
  }
}
