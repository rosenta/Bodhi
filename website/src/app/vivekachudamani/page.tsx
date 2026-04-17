import Link from "next/link";
import type { Metadata } from "next";
import { getAllVerses } from "@/lib/data";
import { Footer } from "@/components/Footer";

export const metadata: Metadata = {
  title: "Vivekachudamani — Bodhi",
  description:
    "Explore all 580 verses of the Vivekachudamani by Adi Shankaracharya — the Crest-Jewel of Discrimination.",
};

const THEMES = [
  { value: "all", label: "All" },
  { value: "discrimination", label: "Discrimination" },
  { value: "maya", label: "Maya" },
  { value: "self-inquiry", label: "Self-Inquiry" },
  { value: "liberation", label: "Liberation" },
  { value: "guru-disciple", label: "Guru & Disciple" },
  { value: "practical-wisdom", label: "Practical Wisdom" },
] as const;

export default function VivekachudamaniIndexPage() {
  const allVerses = getAllVerses();

  return (
    <>
      {/* Header */}
      <section className="px-6 pt-32 pb-12">
        <div className="mx-auto max-w-3xl text-center">
          <h1 className="animate-fade-up font-serif text-4xl font-semibold text-text-primary md:text-5xl">
            Vivekachudamani
          </h1>
          <p className="animate-fade-up delay-1 mt-3 font-devanagari text-xl text-accent-warm">
            विवेकचूडामणि
          </p>
          <p className="animate-fade-up delay-2 mt-4 font-serif italic text-lg text-text-secondary">
            The Crest-Jewel of Discrimination
          </p>
          <p className="animate-fade-up delay-2 mt-2 text-sm font-light text-text-secondary">
            580 verses by Adi Shankaracharya (~8th century CE)
          </p>
          <p className="animate-fade-up delay-3 mt-4 text-sm font-light leading-relaxed text-text-tertiary">
            A dialogue between Guru and Disciple on the path from ignorance to
            Self-realization.
          </p>
        </div>
      </section>

      {/* Theme Filter */}
      <section className="px-6 py-8">
        <div className="mx-auto max-w-4xl">
          <div className="flex flex-wrap justify-center gap-3">
            {THEMES.map((theme) => (
              <span
                key={theme.value}
                className={`inline-flex h-9 items-center rounded-full px-4 text-xs font-medium transition-colors ${
                  theme.value === "all"
                    ? "bg-accent-gold text-bg-primary"
                    : "border border-border text-text-secondary hover:border-border-strong hover:text-text-primary"
                }`}
              >
                {theme.label}
              </span>
            ))}
          </div>
        </div>
      </section>

      {/* Verse List */}
      <section className="px-6 py-8">
        <div className="mx-auto max-w-4xl">
          <p className="mb-6 text-sm text-text-tertiary">
            Showing {allVerses.length} curated verses of 580
          </p>

          <div className="grid gap-4 md:grid-cols-2">
            {allVerses.map((verse, index) => (
              <Link
                key={verse.verseNumber}
                href={`/vivekachudamani/${verse.verseNumber}`}
                className={`group block rounded-lg border border-border bg-bg-card p-5 transition-colors hover:border-border-strong hover:bg-bg-card-hover animate-fade-up delay-${Math.min(index + 1, 6)}`}
              >
                <div className="flex items-start justify-between gap-3">
                  <p className="text-xs font-medium text-accent-gold">
                    Verse {verse.verseNumber}
                  </p>
                  <span className="inline-flex rounded-full bg-accent-gold-muted px-2.5 py-0.5 text-[0.65rem] font-medium text-accent-gold">
                    {verse.theme}
                  </span>
                </div>

                <p className="sanskrit mt-3 line-clamp-2 text-sm leading-relaxed">
                  {verse.sanskrit.split("\n")[0]}
                </p>

                <p className="mt-3 line-clamp-2 font-serif text-sm italic leading-relaxed text-text-secondary">
                  {verse.englishTranslation}
                </p>
              </Link>
            ))}
          </div>
        </div>
      </section>

      <Footer />
    </>
  );
}
