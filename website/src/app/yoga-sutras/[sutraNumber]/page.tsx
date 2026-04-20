import Link from "next/link";
import type { Metadata } from "next";
import { getSutraByNumber, getAllSutras, getSutrasByPada } from "@/lib/data";
import {
  getYogaSutraSection,
  getSutraPositionInSection,
  truncateText,
} from "@/lib/structure";
import { PracticeCard } from "@/components/PracticeCard";
import { Footer } from "@/components/Footer";
import { notFound } from "next/navigation";

interface PageProps {
  params: Promise<{ sutraNumber: string }>;
}

export async function generateStaticParams() {
  const sutras = getAllSutras();
  return sutras.map((sutra) => ({
    sutraNumber: String(sutra.sutraNumber),
  }));
}

export async function generateMetadata({
  params,
}: PageProps): Promise<Metadata> {
  const { sutraNumber } = await params;
  const sutra = getSutraByNumber(sutraNumber);

  if (!sutra) {
    return { title: "Sutra Not Found" };
  }

  const snippet = (sutra.practicalApplication ?? sutra.englishTranslation)
    .slice(0, 50)
    .trim();
  const title = `Sutra ${sutra.sutraNumber} — ${snippet}`;
  const descSource = `${sutra.englishTranslation} — ${
    sutra.practicalApplication ?? ""
  }`.trim();
  const description =
    descSource.length > 155
      ? `${descSource.slice(0, 152).trim()}...`
      : descSource;
  const canonical = `/yoga-sutras/${sutra.sutraNumber}`;

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

export default async function SutraPage({ params }: PageProps) {
  const { sutraNumber } = await params;
  const sutra = getSutraByNumber(sutraNumber);

  if (!sutra) {
    notFound();
  }

  const padaSutras = sutra.pada ? getSutrasByPada(sutra.pada) : getAllSutras();
  const currentIndex = padaSutras.findIndex(
    (s) => s.sutraNumber === sutra.sutraNumber
  );
  const prevSutra = currentIndex > 0 ? padaSutras[currentIndex - 1] : null;
  const nextSutra =
    currentIndex < padaSutras.length - 1
      ? padaSutras[currentIndex + 1]
      : null;

  const allSutras = getAllSutras();
  const globalIndex = allSutras.findIndex(
    (s) => s.sutraNumber === sutra.sutraNumber
  );
  const totalSutras = allSutras.length;
  const progressPercent =
    totalSutras > 0 ? ((globalIndex + 1) / totalSutras) * 100 : 0;

  const padaNames: Record<number, string> = {
    1: "Samadhi Pada",
    2: "Sadhana Pada",
    3: "Vibhuti Pada",
    4: "Kaivalya Pada",
  };
  const padaDisplayName = padaNames[sutra.pada] ?? "Yoga Sutras";

  const section = getYogaSutraSection(sutra.sutraNumber);
  const sectionPosition = section
    ? getSutraPositionInSection(sutra.sutraNumber, section)
    : null;

  return (
    <>
      {/* Sutra Hero */}
      <section
        className="relative flex min-h-screen items-center justify-center px-6"
        style={{
          background:
            "radial-gradient(ellipse at center, rgba(201, 165, 90, 0.06) 0%, transparent 70%)",
        }}
      >
        <div className="mx-auto max-w-2xl text-center">
          <p className="animate-fade-up delay-1 text-xs font-medium uppercase tracking-[0.25em] text-text-secondary">
            Yoga Darshan — {padaDisplayName} — Sutra {sutra.sutraNumber}
          </p>

          {sutra.theme && (
            <div className="animate-fade-up delay-1 mt-6">
              <span className="inline-flex rounded-full bg-accent-gold-muted px-3 py-1 text-xs font-medium text-accent-gold">
                {sutra.theme}
              </span>
            </div>
          )}

          <p className="sanskrit animate-fade-up delay-2 mt-8 text-xl leading-relaxed md:text-2xl">
            {sutra.sanskrit}
          </p>

          {sutra.transliteration && (
            <p className="animate-fade-up delay-2 mt-4 text-sm tracking-wide text-text-secondary">
              {sutra.transliteration}
            </p>
          )}

          <div className="animate-fade-up delay-3 mx-auto my-8 h-px w-16 bg-border-strong" />

          <p className="animate-fade-up delay-3 font-serif text-lg italic leading-relaxed text-text-primary md:text-xl">
            &ldquo;{sutra.englishTranslation}&rdquo;
          </p>
        </div>
      </section>

      {/* Hindi Meaning */}
      {sutra.hindiMeaning && (
        <section className="px-6 py-12">
          <div className="mx-auto max-w-[650px]">
            <p className="animate-fade-up text-xs font-medium uppercase tracking-[0.2em] text-accent-gold">
              Hindi Meaning
            </p>
            <p className="animate-fade-up delay-1 mt-6 font-devanagari text-base leading-[2] text-text-secondary">
              {sutra.hindiMeaning}
            </p>
          </div>
        </section>
      )}

      {/* Practical Application */}
      {sutra.practicalApplication && (
        <section className="px-6 py-12">
          <div className="mx-auto max-w-[650px]">
            <p className="animate-fade-up text-xs font-medium uppercase tracking-[0.2em] text-accent-gold">
              What This Means for Your Life
            </p>
            <p className="animate-fade-up delay-1 mt-8 text-lg font-light leading-[1.9] text-text-secondary">
              {sutra.practicalApplication}
            </p>
          </div>
        </section>
      )}

      {/* Practice Card */}
      {sutra.practicalApplication && (
        <section className="px-6 py-8">
          <div className="mx-auto max-w-[650px]">
            <PracticeCard practice={sutra.practicalApplication} />
          </div>
        </section>
      )}

      {/* Section Context — "You are HERE in the journey" */}
      {section && (
        <section className="px-6 py-12">
          <div className="mx-auto max-w-[650px]">
            <div className="border-t border-border pt-10">
              <p className="animate-fade-up text-xs font-medium uppercase tracking-[0.2em] text-accent-gold">
                You are here in the journey
              </p>

              <p className="animate-fade-up delay-1 mt-4 text-xs tracking-[0.15em] text-text-tertiary">
                Pada {section.pada.number}: {section.pada.name}
              </p>

              <h2 className="animate-fade-up delay-1 mt-2 font-serif text-2xl leading-tight text-text-primary md:text-3xl">
                {section.title}
              </h2>

              <div className="animate-fade-up delay-1 mt-3 flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-text-tertiary">
                {sectionPosition && (
                  <span>
                    Sutra {sectionPosition.position} of{" "}
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

      {/* Sutra Navigation */}
      <section className="px-6 py-16">
        <div className="mx-auto max-w-[650px]">
          <div className="border-t border-border pt-8">
            <div className="flex items-center justify-between">
              {prevSutra ? (
                <Link
                  href={`/yoga-sutras/${prevSutra.sutraNumber}`}
                  className="group flex flex-col items-start"
                >
                  <span className="text-xs text-text-tertiary transition-colors group-hover:text-text-secondary">
                    Previous
                  </span>
                  <span className="mt-1 text-sm text-text-secondary transition-colors group-hover:text-text-primary">
                    Sutra {prevSutra.sutraNumber}
                  </span>
                </Link>
              ) : (
                <div />
              )}

              <Link
                href="/yoga-sutras"
                className="text-xs text-text-tertiary transition-colors hover:text-text-secondary"
              >
                All Sutras
              </Link>

              {nextSutra ? (
                <Link
                  href={`/yoga-sutras/${nextSutra.sutraNumber}`}
                  className="group flex flex-col items-end"
                >
                  <span className="text-xs text-text-tertiary transition-colors group-hover:text-text-secondary">
                    Next
                  </span>
                  <span className="mt-1 text-sm text-text-secondary transition-colors group-hover:text-text-primary">
                    Sutra {nextSutra.sutraNumber}
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
