import Link from "next/link";
import type { Metadata } from "next";
import { getAllLessons, getLessonBySlug } from "@/lib/lessons";
import { Footer } from "@/components/Footer";
import { notFound } from "next/navigation";

interface Props {
  params: Promise<{ slug: string }>;
}

export async function generateStaticParams() {
  const lessons = getAllLessons();
  return lessons.map((l) => ({ slug: l.slug }));
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const lesson = getLessonBySlug(slug);
  if (!lesson) return { title: "Lesson Not Found — Bodhi" };

  return {
    title: `${lesson.title} — Bodhi`,
    description: lesson.tagline,
  };
}

/**
 * Minimal markdown to JSX: handles headings, blockquotes, bold, italic, paragraphs.
 * Not a full parser — good enough for lesson markdown.
 */
function renderMarkdown(content: string) {
  const lines = content.split("\n");
  const elements: React.ReactNode[] = [];
  let i = 0;
  let key = 0;

  while (i < lines.length) {
    const line = lines[i];

    // H2
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

    // H1 (skip — already shown as page title)
    if (line.startsWith("# ")) {
      i++;
      continue;
    }

    // Blockquote block
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
          {blockLines.map((bl, bi) => {
            if (bl.startsWith("*") && bl.endsWith("*")) {
              return (
                <p
                  key={bi}
                  className="font-serif text-lg italic leading-relaxed text-text-primary"
                >
                  {bl.slice(1, -1)}
                </p>
              );
            }
            return (
              <p
                key={bi}
                className="font-devanagari text-base leading-[2] text-accent-warm"
              >
                {bl}
              </p>
            );
          })}
        </blockquote>
      );
      continue;
    }

    // Empty line
    if (line.trim() === "") {
      i++;
      continue;
    }

    // Bold line (practice step or emphasis)
    if (line.startsWith("**") && line.includes("**")) {
      elements.push(
        <p
          key={key++}
          className="mb-2 mt-6 text-base font-medium text-text-primary"
        >
          {line.replace(/\*\*/g, "")}
        </p>
      );
      i++;
      continue;
    }

    // Italic line (reflection question)
    if (line.startsWith("*") && line.endsWith("*") && !line.startsWith("**")) {
      elements.push(
        <p
          key={key++}
          className="my-8 text-center font-serif text-xl italic text-accent-gold"
        >
          {line.slice(1, -1)}
        </p>
      );
      i++;
      continue;
    }

    // Regular paragraph
    elements.push(
      <p
        key={key++}
        className="mb-4 text-base font-light leading-[1.9] text-text-secondary"
      >
        {line}
      </p>
    );
    i++;
  }

  return elements;
}

export default async function LessonPage({ params }: Props) {
  const { slug } = await params;
  const lesson = getLessonBySlug(slug);

  if (!lesson) notFound();

  const allLessons = getAllLessons();
  const currentIndex = allLessons.findIndex((l) => l.slug === slug);
  const prev = currentIndex > 0 ? allLessons[currentIndex - 1] : null;
  const next =
    currentIndex < allLessons.length - 1 ? allLessons[currentIndex + 1] : null;

  return (
    <>
      {/* Header */}
      <section
        className="relative flex min-h-[60vh] items-center justify-center px-6"
        style={{
          background:
            "radial-gradient(ellipse at center, rgba(201, 165, 90, 0.06) 0%, transparent 70%)",
        }}
      >
        <div className="pt-24 pb-12 text-center">
          <p className="animate-fade-up text-xs font-light uppercase tracking-[0.3em] text-accent-gold">
            Lesson {lesson.lesson} of {allLessons.length} &mdash; Verse{" "}
            {lesson.verse}
          </p>

          <span className="mt-4 inline-block animate-fade-up delay-1 rounded-full border border-border px-3 py-1 text-[10px] uppercase tracking-[0.15em] text-accent-gold">
            {lesson.theme}
          </span>

          <h1 className="mx-auto mt-6 max-w-2xl animate-fade-up delay-2 font-serif text-3xl font-semibold leading-snug text-text-primary md:text-4xl">
            {lesson.title}
          </h1>

          <p className="mx-auto mt-4 max-w-lg animate-fade-up delay-3 font-serif text-lg italic text-text-secondary">
            {lesson.tagline}
          </p>
        </div>
      </section>

      {/* Content */}
      <section className="px-6 pb-16">
        <div className="mx-auto max-w-[650px]">{renderMarkdown(lesson.content)}</div>
      </section>

      {/* Navigation */}
      <section className="px-6 py-12">
        <div className="mx-auto flex max-w-[650px] items-center justify-between border-t border-border pt-8">
          {prev ? (
            <Link
              href={`/lessons/${prev.slug}`}
              className="text-sm text-text-secondary transition-colors hover:text-accent-gold"
            >
              &larr; Lesson {prev.lesson}
            </Link>
          ) : (
            <span />
          )}
          <Link
            href="/lessons"
            className="text-xs uppercase tracking-[0.15em] text-text-tertiary transition-colors hover:text-accent-gold"
          >
            All Lessons
          </Link>
          {next ? (
            <Link
              href={`/lessons/${next.slug}`}
              className="text-sm text-text-secondary transition-colors hover:text-accent-gold"
            >
              Lesson {next.lesson} &rarr;
            </Link>
          ) : (
            <span />
          )}
        </div>
      </section>

      {/* Progress Bar */}
      <div className="fixed bottom-0 left-0 h-[3px] w-full bg-bg-secondary">
        <div
          className="h-full bg-gradient-to-r from-accent-gold to-accent-saffron transition-all"
          style={{
            width: `${((currentIndex + 1) / allLessons.length) * 100}%`,
          }}
        />
      </div>

      <Footer />
    </>
  );
}
