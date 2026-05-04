import Link from "next/link";
import type { Metadata } from "next";
import { getAllStories, getStoryBySlug } from "@/lib/stories";
import { Footer } from "@/components/Footer";
import { StoryReader } from "@/components/StoryReader";
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
      <StoryReader
        english={{
          title: story.title,
          setting: story.setting,
          content: story.content,
        }}
        hindi={story.hindi}
        storyNumber={story.story}
        totalStories={allStories.length}
      />

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
