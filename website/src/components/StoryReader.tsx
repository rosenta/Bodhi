"use client";

import { useState, useMemo } from "react";

interface HindiContent {
  readonly title: string;
  readonly setting: string;
  readonly content: string;
}

interface StoryReaderProps {
  readonly english: {
    readonly title: string;
    readonly setting: string;
    readonly content: string;
  };
  readonly hindi?: HindiContent;
  readonly storyNumber: number;
  readonly totalStories: number;
}

type Lang = "en" | "hi";

function renderMarkdown(content: string, devanagari: boolean): React.ReactNode[] {
  const lines = content.split("\n");
  const elements: React.ReactNode[] = [];
  const baseP = devanagari
    ? "mb-4 font-devanagari text-base leading-[2] text-text-secondary"
    : "mb-4 text-base font-light leading-[1.9] text-text-secondary";
  const italicP = devanagari
    ? "my-8 text-center font-devanagari text-lg text-accent-gold"
    : "my-8 text-center font-serif text-xl italic text-accent-gold";
  const quoteP = devanagari
    ? "font-devanagari text-lg leading-[2] text-text-primary"
    : "font-serif text-lg italic leading-relaxed text-text-primary";

  let i = 0;
  let key = 0;

  while (i < lines.length) {
    const line = lines[i];

    if (line.startsWith("## ")) {
      elements.push(
        <h2
          key={key++}
          className="mb-4 mt-12 text-xs font-medium uppercase tracking-[0.2em] text-accent-gold"
        >
          {line.slice(3)}
        </h2>
      );
      i++;
      continue;
    }

    if (line.startsWith("# ")) {
      i++;
      continue;
    }

    if (line.trim() === "---") {
      elements.push(<hr key={key++} className="my-10 border-border" />);
      i++;
      continue;
    }

    if (line.startsWith("> ")) {
      const blockLines: string[] = [];
      while (i < lines.length && lines[i].startsWith("> ")) {
        blockLines.push(lines[i].slice(2));
        i++;
      }
      elements.push(
        <blockquote
          key={key++}
          className="my-6 border-l-2 border-accent-gold pl-6"
        >
          {blockLines.map((bl, bi) => (
            <p key={bi} className={quoteP}>
              {bl.replace(/^\*|\*$/g, "")}
            </p>
          ))}
        </blockquote>
      );
      continue;
    }

    if (line.trim() === "") {
      i++;
      continue;
    }

    if (line.startsWith("*") && line.endsWith("*") && !line.startsWith("**")) {
      elements.push(
        <p key={key++} className={italicP}>
          {line.slice(1, -1)}
        </p>
      );
      i++;
      continue;
    }

    const rendered = line
      .replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>")
      .replace(/\*(.+?)\*/g, "<em>$1</em>");

    elements.push(
      <p
        key={key++}
        className={baseP}
        dangerouslySetInnerHTML={{ __html: rendered }}
      />
    );
    i++;
  }

  return elements;
}

export function StoryReader({
  english,
  hindi,
  storyNumber,
  totalStories,
}: StoryReaderProps) {
  const [lang, setLang] = useState<Lang>("en");
  const hasHindi = Boolean(hindi);
  const active = lang === "hi" && hindi ? hindi : english;
  const isHindi = lang === "hi" && hasHindi;

  const body = useMemo(
    () => renderMarkdown(active.content, isHindi),
    [active.content, isHindi]
  );

  return (
    <>
      <section
        className="relative flex min-h-[60vh] items-center justify-center px-6"
        style={{
          background:
            "radial-gradient(ellipse at center, rgba(201, 165, 90, 0.06) 0%, transparent 70%)",
        }}
      >
        <div className="pt-24 pb-12 text-center">
          <p className="animate-fade-up text-xs font-light uppercase tracking-[0.3em] text-accent-gold">
            Story {storyNumber} of {totalStories}
          </p>

          <h1
            className={`mx-auto mt-6 max-w-2xl animate-fade-up delay-2 text-3xl font-semibold leading-snug text-text-primary md:text-4xl ${
              isHindi ? "font-devanagari" : "font-serif"
            }`}
          >
            {active.title}
          </h1>

          {active.setting && (
            <p
              className={`mx-auto mt-4 max-w-lg animate-fade-up delay-3 text-base text-text-secondary ${
                isHindi ? "font-devanagari" : "font-serif italic"
              }`}
            >
              {active.setting}
            </p>
          )}

          {hasHindi && (
            <div
              role="tablist"
              aria-label="Language"
              className="mt-8 inline-flex rounded-full border border-border bg-bg-card p-1"
            >
              <button
                role="tab"
                aria-selected={lang === "en"}
                onClick={() => setLang("en")}
                className={`rounded-full px-4 py-1.5 text-xs font-medium uppercase tracking-[0.15em] transition-colors ${
                  lang === "en"
                    ? "bg-accent-gold text-bg-primary"
                    : "text-text-secondary hover:text-accent-gold"
                }`}
              >
                English
              </button>
              <button
                role="tab"
                aria-selected={lang === "hi"}
                onClick={() => setLang("hi")}
                className={`rounded-full px-4 py-1.5 text-xs font-medium uppercase tracking-[0.15em] transition-colors ${
                  lang === "hi"
                    ? "bg-accent-gold text-bg-primary"
                    : "text-text-secondary hover:text-accent-gold"
                }`}
              >
                हिंदी
              </button>
            </div>
          )}
        </div>
      </section>

      <section className="px-6 pb-16">
        <div className="mx-auto max-w-[650px]">{body}</div>
      </section>
    </>
  );
}
