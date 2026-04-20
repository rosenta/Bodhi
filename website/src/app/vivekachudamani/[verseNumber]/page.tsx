import Link from "next/link";
import type { Metadata } from "next";
import { getVerseByNumber, getAllVerses } from "@/lib/data";
import {
  getVivekachudamaniSection,
  getVersePositionInSection,
  truncateText,
} from "@/lib/structure";
import { PracticeCard } from "@/components/PracticeCard";
import { Footer } from "@/components/Footer";
import { notFound } from "next/navigation";

interface PageProps {
  params: Promise<{ verseNumber: string }>;
}

export async function generateStaticParams() {
  const verses = getAllVerses();
  return verses.map((verse) => ({
    verseNumber: String(verse.verseNumber),
  }));
}

export async function generateMetadata({
  params,
}: PageProps): Promise<Metadata> {
  const { verseNumber } = await params;
  const verse = getVerseByNumber(Number(verseNumber));

  if (!verse) {
    return { title: "Verse Not Found" };
  }

  const snippet = verse.modernInterpretation.slice(0, 50).trim();
  const title = `Verse ${verse.verseNumber} — ${snippet}`;
  const description =
    verse.modernInterpretation.length > 155
      ? `${verse.modernInterpretation.slice(0, 152).trim()}...`
      : verse.modernInterpretation;
  const canonical = `/vivekachudamani/${verse.verseNumber}`;

  return {
    title,
    description,
    alternates: {
      canonical,
    },
    openGraph: {
      title,
      description,
      type: "article",
      url: canonical,
      images: ["/og-default.png"],
    },
    twitter: {
      card: "summary_large_image",
      title,
      description,
      images: ["/og-default.png"],
    },
  };
}

export default async function VersePage({ params }: PageProps) {
  const { verseNumber } = await params;
  const verse = getVerseByNumber(Number(verseNumber));

  if (!verse) {
    notFound();
  }

  const allVerses = getAllVerses();
  const currentIndex = allVerses.findIndex(
    (v) => v.verseNumber === verse.verseNumber
  );
  const prevVerse = currentIndex > 0 ? allVerses[currentIndex - 1] : null;
  const nextVerse =
    currentIndex < allVerses.length - 1 ? allVerses[currentIndex + 1] : null;
  const totalVerses = allVerses.length;
  const progressPercent = ((currentIndex + 1) / totalVerses) * 100;

  const section = getVivekachudamaniSection(verse.verseNumber);
  const sectionPosition = section
    ? getVersePositionInSection(verse.verseNumber, section)
    : null;

  return (
    <>
      {/* Verse Hero */}
      <section
        className="relative flex min-h-screen items-center justify-center px-6"
        style={{
          background:
            "radial-gradient(ellipse at center, rgba(201, 165, 90, 0.06) 0%, transparent 70%)",
        }}
      >
        <div className="mx-auto max-w-2xl text-center">
          <p className="animate-fade-up delay-1 text-xs font-medium uppercase tracking-[0.25em] text-text-secondary">
            Vivekachudamani — Verse {verse.verseNumber} of 580
          </p>

          <div className="animate-fade-up delay-1 mt-6">
            <span className="inline-flex rounded-full bg-accent-gold-muted px-3 py-1 text-xs font-medium text-accent-gold">
              {verse.theme}
            </span>
          </div>

          <p className="sanskrit animate-fade-up delay-2 mt-8 text-xl leading-relaxed md:text-2xl">
            {verse.sanskrit}
          </p>

          <div className="animate-fade-up delay-3 mx-auto my-8 h-px w-16 bg-border-strong" />

          <p className="animate-fade-up delay-3 font-serif text-lg italic leading-relaxed text-text-primary md:text-xl">
            &ldquo;{verse.englishTranslation}&rdquo;
          </p>
        </div>
      </section>

      {/* Modern Interpretation */}
      <section className="px-6 py-16">
        <div className="mx-auto max-w-[650px]">
          <p className="animate-fade-up text-xs font-medium uppercase tracking-[0.2em] text-accent-gold">
            What This Means for Your Life
          </p>

          <p className="animate-fade-up delay-1 mt-8 text-lg font-light leading-[1.9] text-text-secondary">
            {verse.modernInterpretation}
          </p>
        </div>
      </section>

      {/* Practice Card */}
      <section className="px-6 py-8">
        <div className="mx-auto max-w-[650px]">
          <PracticeCard practice={verse.practicePrompt} />
        </div>
      </section>

      {/* Section Context — "You are HERE in the journey" */}
      {section && (
        <section className="px-6 py-12">
          <div className="mx-auto max-w-[650px]">
            <div className="border-t border-border pt-10">
              <p className="animate-fade-up text-xs font-medium uppercase tracking-[0.2em] text-accent-gold">
                You are here in the journey
              </p>

              <h2 className="animate-fade-up delay-1 mt-6 font-serif text-2xl leading-tight text-text-primary md:text-3xl">
                {section.title}
              </h2>

              <div className="animate-fade-up delay-1 mt-3 flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-text-tertiary">
                {sectionPosition && (
                  <span>
                    Verse {sectionPosition.position} of{" "}
                    {sectionPosition.total} in this section
                  </span>
                )}
                {section.narrativeRole && (
                  <>
                    <span aria-hidden="true">·</span>
                    <span className="italic">
                      {truncateText(section.narrativeRole, 120)}
                    </span>
                  </>
                )}
              </div>

              <p className="animate-fade-up delay-2 mt-6 text-sm font-light leading-[1.8] text-text-secondary">
                {truncateText(section.titleMeaning, 240)}
              </p>
            </div>
          </div>
        </section>
      )}

      {/* Verse Navigation */}
      <section className="px-6 py-16">
        <div className="mx-auto max-w-[650px]">
          <div className="border-t border-border pt-8">
            <div className="flex items-center justify-between">
              {prevVerse ? (
                <Link
                  href={`/vivekachudamani/${prevVerse.verseNumber}`}
                  className="group flex flex-col items-start"
                >
                  <span className="text-xs text-text-tertiary transition-colors group-hover:text-text-secondary">
                    Previous
                  </span>
                  <span className="mt-1 text-sm text-text-secondary transition-colors group-hover:text-text-primary">
                    Verse {prevVerse.verseNumber}
                  </span>
                </Link>
              ) : (
                <div />
              )}

              <Link
                href="/vivekachudamani"
                className="text-xs text-text-tertiary transition-colors hover:text-text-secondary"
              >
                All Verses
              </Link>

              {nextVerse ? (
                <Link
                  href={`/vivekachudamani/${nextVerse.verseNumber}`}
                  className="group flex flex-col items-end"
                >
                  <span className="text-xs text-text-tertiary transition-colors group-hover:text-text-secondary">
                    Next
                  </span>
                  <span className="mt-1 text-sm text-text-secondary transition-colors group-hover:text-text-primary">
                    Verse {nextVerse.verseNumber}
                  </span>
                </Link>
              ) : (
                <div />
              )}
            </div>
          </div>
        </div>
      </section>

      {/* Progress Bar */}
      <div className="fixed bottom-0 left-0 right-0 z-50 h-1 bg-bg-secondary">
        <div
          className="h-full bg-accent-gold transition-all duration-500"
          style={{ width: `${progressPercent}%` }}
        />
      </div>

      <Footer />
    </>
  );
}
