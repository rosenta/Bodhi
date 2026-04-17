import Link from "next/link";
import type { Metadata } from "next";
import { getAllStories } from "@/lib/stories";
import { Footer } from "@/components/Footer";

export const metadata: Metadata = {
  title: "Stories — Bodhi",
  description:
    "Narrative retellings of the Guru-Disciple dialogue from the Vivekachudamani. Ancient wisdom as short fiction.",
};

export default function StoriesIndexPage() {
  const stories = getAllStories();

  return (
    <>
      <section className="px-6 pt-32 pb-12">
        <div className="mx-auto max-w-3xl text-center">
          <h1 className="animate-fade-up font-serif text-4xl font-semibold text-text-primary md:text-5xl">
            Stories
          </h1>
          <p className="animate-fade-up delay-1 mt-4 font-serif text-lg italic text-text-secondary">
            The teaching, told as a tale.
          </p>
          <p className="animate-fade-up delay-2 mt-2 text-sm font-light text-text-secondary">
            {stories.length} short stories from the disciple&rsquo;s journey
          </p>
        </div>
      </section>

      <section className="px-6 pb-24">
        <div className="mx-auto max-w-3xl">
          <div className="flex flex-col gap-4">
            {stories.map((story, index) => (
              <Link
                key={story.slug}
                href={`/stories/${story.slug}`}
                className={`group block rounded-lg border border-border bg-bg-card p-6 transition-colors hover:border-border-strong hover:bg-bg-card-hover animate-fade-up delay-${Math.min(index + 1, 6)}`}
              >
                <div className="flex items-start gap-5">
                  <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full border border-border text-sm font-light text-accent-gold">
                    {story.story}
                  </div>

                  <div className="min-w-0 flex-1">
                    {story.mood && (
                      <span className="inline-block rounded-full border border-border px-2.5 py-0.5 text-[10px] uppercase tracking-[0.1em] text-accent-gold">
                        {story.mood.split(",")[0].trim()}
                      </span>
                    )}

                    <h2 className="mt-2 font-serif text-xl text-text-primary transition-colors group-hover:text-accent-gold">
                      {story.title}
                    </h2>

                    {story.theme && (
                      <p className="mt-1 text-sm font-light leading-relaxed text-text-secondary line-clamp-2">
                        {story.theme}
                      </p>
                    )}

                    {story.versesReferenced.length > 0 && (
                      <p className="mt-2 text-xs text-text-tertiary">
                        Verses {story.versesReferenced.join(", ")}
                      </p>
                    )}
                  </div>
                </div>
              </Link>
            ))}
          </div>
        </div>
      </section>

      <Footer />
    </>
  );
}
