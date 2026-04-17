import Link from "next/link";
import type { Metadata } from "next";
import { getDailyVerse, getAllVerses } from "@/lib/data";
import { VerseCard } from "@/components/VerseCard";
import { Footer } from "@/components/Footer";

export const metadata: Metadata = {
  title: "Bodhi — Ancient Verses, Modern Clarity",
  description:
    "Explore the Vivekachudamani and Yoga Sutras — 775 verses of transformative wisdom, beautifully presented for the modern seeker.",
};

const FEATURED_VERSE_NUMBERS = [20, 78, 136] as const;

const HOW_IT_WORKS_STEPS = [
  {
    label: "Surface",
    description: "Each verse in Sanskrit + English translation",
  },
  {
    label: "Depth",
    description: "Modern interpretation for daily life",
  },
  {
    label: "Practice",
    description: "A concrete exercise to embody the teaching",
  },
  {
    label: "Journey",
    description: "Track your path through all 580 verses",
  },
] as const;

export default function HomePage() {
  const dailyVerse = getDailyVerse();
  const allVerses = getAllVerses();
  const featuredVerses = allVerses.filter((v) =>
    FEATURED_VERSE_NUMBERS.includes(
      v.verseNumber as (typeof FEATURED_VERSE_NUMBERS)[number]
    )
  );

  return (
    <>
      {/* Hero — Daily Verse (100vh) */}
      <section
        className="relative flex min-h-screen items-center justify-center px-6"
        style={{
          background:
            "radial-gradient(ellipse at center, rgba(201, 165, 90, 0.06) 0%, transparent 70%)",
        }}
      >
        <div className="mx-auto max-w-2xl text-center">
          <p className="animate-fade-up delay-1 text-xs font-medium uppercase tracking-[0.25em] text-accent-gold">
            Verse of the Day
          </p>

          <div className="animate-fade-up delay-2 mx-auto my-6 h-px w-16 bg-border-strong" />

          <p className="sanskrit animate-fade-up delay-2 text-xl leading-relaxed md:text-2xl">
            {dailyVerse.verse.sanskrit}
          </p>

          <div className="animate-fade-up delay-3 mx-auto my-6 h-px w-16 bg-border-strong" />

          <p className="animate-fade-up delay-3 font-serif text-lg italic leading-relaxed text-text-primary md:text-xl">
            &ldquo;{dailyVerse.verse.englishTranslation}&rdquo;
          </p>

          <p className="animate-fade-up delay-4 mt-6 text-sm text-text-secondary">
            Vivekachudamani, Verse {dailyVerse.verse.verseNumber}
          </p>

          <div className="animate-fade-up delay-5 mt-8 flex flex-col items-center gap-4 sm:flex-row sm:justify-center">
            <Link
              href={`/vivekachudamani/${dailyVerse.verse.verseNumber}`}
              className="inline-flex h-12 items-center justify-center rounded-full bg-accent-gold px-8 text-sm font-medium text-bg-primary transition-opacity hover:opacity-90"
            >
              Read This Verse
            </Link>
            <Link
              href="/vivekachudamani"
              className="inline-flex h-12 items-center justify-center rounded-full border border-border-strong px-8 text-sm font-medium text-text-secondary transition-colors hover:border-accent-gold hover:text-text-primary"
            >
              Explore All Verses
            </Link>
          </div>
        </div>
      </section>

      {/* Context Section */}
      <section className="flex min-h-screen items-center justify-center px-6 py-24">
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="animate-fade-up font-serif text-4xl font-semibold text-accent-gold md:text-5xl">
            BODHI
          </h2>

          <p className="animate-fade-up delay-1 mt-8 font-serif text-xl font-light leading-relaxed text-text-primary md:text-2xl">
            Two ancient texts. 775 verses.
            <br />
            One question: Who are you, really?
          </p>

          <div className="mt-12 space-y-8">
            <div className="animate-fade-up delay-2">
              <p className="font-serif text-lg text-text-primary">
                Vivekachudamani
              </p>
              <p className="mt-1 text-sm font-light text-text-secondary">
                580 verses on Self-realization by Adi Shankaracharya (8th
                century CE)
              </p>
            </div>

            <div className="animate-fade-up delay-3">
              <p className="font-serif text-lg text-text-primary">
                Yoga Darshan
              </p>
              <p className="mt-1 text-sm font-light text-text-secondary">
                195 sutras on mastering the mind by Maharshi Patanjali (~200
                BCE)
              </p>
            </div>
          </div>

          <div className="animate-fade-up delay-4 mt-12 flex flex-col items-center gap-4 sm:flex-row sm:justify-center">
            <Link
              href="/vivekachudamani"
              className="inline-flex h-12 items-center justify-center rounded-full border border-border-strong px-8 text-sm font-medium text-text-secondary transition-colors hover:border-accent-gold hover:text-text-primary"
            >
              Begin with Vivekachudamani
            </Link>
            <Link
              href="/yoga-sutras"
              className="inline-flex h-12 items-center justify-center rounded-full border border-border-strong px-8 text-sm font-medium text-text-secondary transition-colors hover:border-accent-gold hover:text-text-primary"
            >
              Begin with Yoga Sutras
            </Link>
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section className="px-6 py-24">
        <div className="mx-auto max-w-xl">
          <h2 className="animate-fade-up text-xs font-medium uppercase tracking-[0.25em] text-accent-gold">
            How to Read
          </h2>

          <div className="relative mt-10">
            {/* Decorative vertical gold line */}
            <div className="absolute left-0 top-0 h-full w-px bg-accent-gold/25" />

            <div className="space-y-8 pl-8">
              {HOW_IT_WORKS_STEPS.map((step, index) => (
                <div
                  key={step.label}
                  className={`animate-fade-up delay-${index + 1}`}
                >
                  <p className="text-sm font-medium uppercase tracking-wider text-accent-gold">
                    {step.label}
                  </p>
                  <p className="mt-1 text-sm font-light leading-relaxed text-text-secondary">
                    {step.description}
                  </p>
                </div>
              ))}
            </div>
          </div>

          <div className="mt-12 h-px w-full bg-border" />
        </div>
      </section>

      {/* Featured Verses */}
      <section className="px-6 py-24">
        <div className="mx-auto max-w-5xl">
          <h2 className="animate-fade-up text-center text-xs font-medium uppercase tracking-[0.25em] text-accent-gold">
            Explore
          </h2>

          <div className="mt-12 grid gap-6 md:grid-cols-3">
            {featuredVerses.map((verse, index) => (
              <Link
                key={verse.verseNumber}
                href={`/vivekachudamani/${verse.verseNumber}`}
                className={`animate-fade-up delay-${index + 1}`}
              >
                <VerseCard verse={verse} variant="compact" />
              </Link>
            ))}
          </div>

          <div className="animate-fade-up delay-4 mt-12 text-center">
            <Link
              href="/vivekachudamani"
              className="inline-flex h-12 items-center justify-center rounded-full border border-border px-8 text-sm font-medium text-text-secondary transition-colors hover:border-border-strong hover:text-text-primary"
            >
              See All 580 Verses
            </Link>
          </div>
        </div>
      </section>

      <Footer />
    </>
  );
}
