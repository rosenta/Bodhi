import { readFileSync, readdirSync } from "fs";
import { join } from "path";

export interface Story {
  readonly slug: string;
  readonly story: number;
  readonly title: string;
  readonly setting: string;
  readonly characters: readonly string[];
  readonly versesReferenced: readonly number[];
  readonly theme: string;
  readonly mood: string;
  readonly content: string;
}

const STORIES_DIR = join(process.cwd(), "..", "content", "stories");

function parseArray(value: string): string[] {
  const trimmed = value.trim();
  if (!trimmed.startsWith("[") || !trimmed.endsWith("]")) return [];
  return trimmed
    .slice(1, -1)
    .split(",")
    .map((item) => item.trim().replace(/^["']|["']$/g, ""))
    .filter(Boolean);
}

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

function fileToStory(filename: string): Story {
  const raw = readFileSync(join(STORIES_DIR, filename), "utf-8");
  const { meta, content } = parseFrontmatter(raw);
  const slug = filename.replace(/\.md$/, "");

  const characters = parseArray(meta.characters || "[]");
  const verseRefs = parseArray(meta.verses_referenced || "[]")
    .map((n) => Number(n))
    .filter((n) => !Number.isNaN(n));

  return {
    slug,
    story: Number(meta.story) || 0,
    title: meta.title || slug,
    setting: meta.setting || "",
    characters,
    versesReferenced: verseRefs,
    theme: meta.theme || "",
    mood: meta.mood || "",
    content,
  };
}

export function getAllStories(): readonly Story[] {
  try {
    const files = readdirSync(STORIES_DIR).filter((f) => f.endsWith(".md"));
    return files.map(fileToStory).sort((a, b) => a.story - b.story);
  } catch {
    return [];
  }
}

export function getStoryBySlug(slug: string): Story | undefined {
  try {
    return fileToStory(`${slug}.md`);
  } catch {
    return undefined;
  }
}
