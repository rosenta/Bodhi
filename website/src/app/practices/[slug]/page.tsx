import Link from "next/link";
import type { Metadata } from "next";
import { getAllPractices, getPracticeBySlug } from "@/lib/practices";
import { Footer } from "@/components/Footer";
import { notFound } from "next/navigation";

interface Props {
  params: Promise<{ slug: string }>;
}

export async function generateStaticParams() {
  const practices = getAllPractices();
  return practices.map((p) => ({ slug: p.slug }));
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const practice = getPracticeBySlug(slug);
  if (!practice) return { title: "Practice Not Found — Bodhi" };

  return {
    title: `${practice.title} — Bodhi`,
    description: practice.tagline,
  };
}

/**
 * Minimal markdown to JSX: handles headings, blockquotes, bold, italic, paragraphs.
 * Not a full parser — good enough for practice markdown. Mirrors the lessons renderer
 * and additionally supports H3 (### phase headings) and unordered list items used in
 * the practice content format.
 */
function renderMarkdown(content: string) {
  const lines = content.split("\n");
  const elements: React.ReactNode[] = [];
  let i = 0;
  let key = 0;

  while (i < lines.length) {
    const line = lines[i];

    // H3 (phase heading)
    if (line.startsWith("### ")) {
      elements.push(
        <h3
          key={key++}
          className="mb-3 mt-10 font-serif text-lg font-medium text-text-primary"
        >
          {line.slice(4)}
        </h3>
      );
      i++;
      continue;
    }

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

    // Horizontal rule
    if (line.trim() === "---") {
      elements.push(
        <hr
          key={key++}
          className="my-10 border-0 border-t border-border"
        />
      );
      i++;
      continue;
    }

    // Blockquote block
    if (line.startsWith("> ")) {
      const blockLines: string[] = [];
      while (i < lines.length && lines[i].startsWith(">")) {
        const raw = lines[i];
        blockLines.push(raw.startsWith("> ") ? raw.slice(2) : raw.slice(1));
        i++;
      }
      elements.push(
        <blockquote
          key={key++}
          className="my-6 border-l-2 border-accent-gold pl-6"
        >
          {blockLines.map((bl, bi) => {
            if (bl.trim() === "") {
              return <div key={bi} className="h-2" />;
            }
            if (bl.startsWith("*") && bl.endsWith("*") && !bl.startsWith("**")) {
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

    // Unordered list block
    if (line.startsWith("- ")) {
      const items: string[] = [];
      while (i < lines.length && lines[i].startsWith("- ")) {
        items.push(lines[i].slice(2));
        i++;
      }
      elements.push(
        <ul
          key={key++}
          className="my-4 list-disc space-y-2 pl-6 text-base font-light leading-[1.8] text-text-secondary marker:text-accent-gold"
        >
          {items.map((it, ii) => (
            <li
              key={ii}
              dangerouslySetInnerHTML={{
                __html: it
                  .replace(
                    /\*\*(.+?)\*\*/g,
                    '<strong class="font-medium text-text-primary">$1</strong>'
                  )
                  .replace(
                    /(^|[^*])\*([^*]+)\*/g,
                    '$1<em class="italic">$2</em>'
                  ),
              }}
            />
          ))}
        </ul>
      );
      continue;
    }

    // Empty line
    if (line.trim() === "") {
      i++;
      continue;
    }

    // Bold line (practice step or emphasis)
    if (line.startsWith("**") && line.endsWith("**") && line.length > 4) {
      elements.push(
        <p
          key={key++}
          className="mb-2 mt-6 text-base font-medium text-text-primary"
        >
          {line.slice(2, -2)}
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

    // Regular paragraph (with inline bold/italic support)
    elements.push(
      <p
        key={key++}
        className="mb-4 text-base font-light leading-[1.9] text-text-secondary"
        dangerouslySetInnerHTML={{
          __html: line
            .replace(
              /\*\*(.+?)\*\*/g,
              '<strong class="font-medium text-text-primary">$1</strong>'
            )
            .replace(
              /(^|[^*])\*([^*]+)\*/g,
              '$1<em class="italic">$2</em>'
            ),
        }}
      />
    );
    i++;
  }

  return elements;
}

export default async function PracticePage({ params }: Props) {
  const { slug } = await params;
  const practice = getPracticeBySlug(slug);

  if (!practice) notFound();

  const allPractices = getAllPractices();
  const currentIndex = allPractices.findIndex((p) => p.slug === slug);
  const prev = currentIndex > 0 ? allPractices[currentIndex - 1] : null;
  const next =
    currentIndex < allPractices.length - 1
      ? allPractices[currentIndex + 1]
      : null;

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
            Practice {practice.practice}
            {allPractices.length > 1 ? ` of ${allPractices.length}` : ""}
            {practice.verseReference ? ` — Verse ${practice.verseReference}` : ""}
          </p>

          <span className="mt-4 inline-block animate-fade-up delay-1 rounded-full border border-border px-3 py-1 text-[10px] uppercase tracking-[0.15em] text-accent-gold">
            {practice.theme}
          </span>

          <h1 className="mx-auto mt-6 max-w-2xl animate-fade-up delay-2 font-serif text-3xl font-semibold leading-snug text-text-primary md:text-4xl">
            {practice.title}
          </h1>

          <p className="mx-auto mt-4 max-w-lg animate-fade-up delay-3 font-serif text-lg italic text-text-secondary">
            {practice.tagline}
          </p>

          {(practice.duration || practice.difficulty) && (
            <p className="mx-auto mt-4 animate-fade-up delay-4 text-xs font-light uppercase tracking-[0.2em] text-text-tertiary">
              {practice.duration}
              {practice.duration && practice.difficulty ? " · " : ""}
              {practice.difficulty}
            </p>
          )}
        </div>
      </section>

      {/* Content */}
      <section className="px-6 pb-16">
        <div className="mx-auto max-w-[650px]">
          {renderMarkdown(practice.content)}
        </div>
      </section>

      {/* Navigation */}
      {allPractices.length > 1 && (
        <section className="px-6 py-12">
          <div className="mx-auto flex max-w-[650px] items-center justify-between border-t border-border pt-8">
            {prev ? (
              <Link
                href={`/practices/${prev.slug}`}
                className="text-sm text-text-secondary transition-colors hover:text-accent-gold"
              >
                &larr; Practice {prev.practice}
              </Link>
            ) : (
              <span />
            )}
            <Link
              href="/practices"
              className="text-xs uppercase tracking-[0.15em] text-text-tertiary transition-colors hover:text-accent-gold"
            >
              All Practices
            </Link>
            {next ? (
              <Link
                href={`/practices/${next.slug}`}
                className="text-sm text-text-secondary transition-colors hover:text-accent-gold"
              >
                Practice {next.practice} &rarr;
              </Link>
            ) : (
              <span />
            )}
          </div>
        </section>
      )}

      {allPractices.length <= 1 && (
        <section className="px-6 py-12">
          <div className="mx-auto flex max-w-[650px] items-center justify-center border-t border-border pt-8">
            <Link
              href="/practices"
              className="text-xs uppercase tracking-[0.15em] text-text-tertiary transition-colors hover:text-accent-gold"
            >
              All Practices
            </Link>
          </div>
        </section>
      )}

      <Footer />
    </>
  );
}
