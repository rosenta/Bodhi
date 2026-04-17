import { readFileSync, readdirSync } from "fs";
import { join } from "path";

export interface Lesson {
  readonly slug: string;
  readonly lesson: number;
  readonly verse: number;
  readonly theme: string;
  readonly title: string;
  readonly tagline: string;
  readonly datePosition: number;
  readonly content: string;
}

const LESSONS_DIR = join(
  process.cwd(),
  "..",
  "content",
  "lessons"
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

function fileToLesson(filename: string): Lesson {
  const raw = readFileSync(join(LESSONS_DIR, filename), "utf-8");
  const { meta, content } = parseFrontmatter(raw);
  const slug = filename.replace(/\.md$/, "");

  return {
    slug,
    lesson: Number(meta.lesson) || 0,
    verse: Number(meta.verse) || 0,
    theme: meta.theme || "",
    title: meta.title || slug,
    tagline: meta.tagline || "",
    datePosition: Number(meta.date_position) || 0,
    content,
  };
}

export function getAllLessons(): readonly Lesson[] {
  try {
    const files = readdirSync(LESSONS_DIR).filter((f) => f.endsWith(".md"));
    return files
      .map(fileToLesson)
      .sort((a, b) => a.lesson - b.lesson);
  } catch {
    return [];
  }
}

export function getLessonBySlug(slug: string): Lesson | undefined {
  try {
    const filename = `${slug}.md`;
    return fileToLesson(filename);
  } catch {
    return undefined;
  }
}
