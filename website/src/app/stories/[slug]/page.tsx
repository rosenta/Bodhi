import Link from "next/link";
import type { Metadata } from "next";
import { getAllStories, getStoryBySlug } from "@/lib/stories";
import { Footer } from "@/components/Footer";
import { notFound } from "next/navigation";

interface Props {
  params: Promise<{ slug: string }>;
}

export async function generateStaticParams() {
  const stories = getAllStories();
  return stories.map((s) => ({ slug: s.slug }));
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const story = getStoryBySlug(slug);
  if (!story) return { title: "Story Not Found — Bodhi" };

  return {
    title: `${story.title} — Bodhi Stories`,
    description: story.theme || `A short story from the Vivekachudamani.`,
  };
}

function renderMarkdown(content: string) {
  const lines = content.split("\n");
  const elements: React.ReactNode[] = [];
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
      elements.push(
        <hr key={key++} className="my-10 border-border" />
      );
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
            <p
              key={bi}
              className="font-serif text-lg italic leading-relaxed text-text-primary"
            >
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

    const rendered = line
      .replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>")
      .replace(/\*(.+?)\*/g, "<em>$1</em>");

    elements.push(
      <p
        key={key++}
        className="mb-4 text-base font-light leading-[1.9] text-text-secondary"
        dangerouslySetInnerHTML={{ __html: rendered }}
      />
    );
    i++;
  }

  return elements;
}

export default async function StoryPage({ params }: Props) {
  const { slug } = await params;
  const story = getStoryBySlug(slug);

  if (!story) notFound();

  const allStories = getAllStories();
  const currentIndex = allStories.findIndex((s) => s.slug === slug);
  const prev = currentIndex > 0 ? allStories[currentIndex - 1] : null;
  const next =
    currentIndex < allStories.length - 1 ? allStories[currentIndex + 1] : null;

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
            Story {story.story} of {allStories.length}
          </p>

          <h1 className="mx-auto mt-6 max-w-2xl animate-fade-up delay-2 font-serif text-3xl font-semibold leading-snug text-text-primary md:text-4xl">
            {story.title}
          </h1>

          {story.setting && (
            <p className="mx-auto mt-4 max-w-lg animate-fade-up delay-3 font-serif text-base italic text-text-secondary">
              {story.setting}
            </p>
          )}
        </div>
      </section>

      <section className="px-6 pb-16">
        <div className="mx-auto max-w-[650px]">{renderMarkdown(story.content)}</div>
      </section>

      <section className="px-6 py-12">
        <div className="mx-auto flex max-w-[650px] items-center justify-between border-t border-border pt-8">
          {prev ? (
            <Link
              href={`/stories/${prev.slug}`}
              className="text-sm text-text-secondary transition-colors hover:text-accent-gold"
            >
              &larr; {prev.title}
            </Link>
          ) : (
            <span />
          )}
          <Link
            href="/stories"
            className="text-xs uppercase tracking-[0.15em] text-text-tertiary transition-colors hover:text-accent-gold"
          >
            All Stories
          </Link>
          {next ? (
            <Link
              href={`/stories/${next.slug}`}
              className="text-sm text-text-secondary transition-colors hover:text-accent-gold"
            >
              {next.title} &rarr;
            </Link>
          ) : (
            <span />
          )}
        </div>
      </section>

      <Footer />
    </>
  );
}
