import Link from "next/link";
import type { Metadata } from "next";
import { getAllSutras, getSutrasByPada } from "@/lib/data";
import { Footer } from "@/components/Footer";

export const metadata: Metadata = {
  title: "Yoga Darshan — Bodhi",
  description:
    "Explore Patanjali's Yoga Sutras — 195 sutras across 4 chapters on mastering the mind and achieving liberation.",
};

const PADAS = [
  {
    id: "samadhi",
    padaNum: 1,
    name: "Samadhi Pada",
    sutraRange: "Sutras 1.1–1.51",
    count: 51,
    description: "What yoga is",
    longDescription: "What yoga is and the types of samadhi",
  },
  {
    id: "sadhana",
    padaNum: 2,
    name: "Sadhana Pada",
    sutraRange: "Sutras 2.1–2.55",
    count: 55,
    description: "How to practice",
    longDescription: "The practice: Ashtanga Yoga (eight limbs)",
  },
  {
    id: "vibhuti",
    padaNum: 3,
    name: "Vibhuti Pada",
    sutraRange: "Sutras 3.1–3.55",
    count: 55,
    description: "Powers & their limits",
    longDescription: "Powers attained through practice and their transcendence",
  },
  {
    id: "kaivalya",
    padaNum: 4,
    name: "Kaivalya Pada",
    sutraRange: "Sutras 4.1–4.34",
    count: 34,
    description: "Ultimate liberation",
    longDescription: "The nature of ultimate liberation",
  },
] as const;

export default function YogaSutrasIndexPage() {
  const allSutras = getAllSutras();

  return (
    <>
      {/* Header */}
      <section className="px-6 pt-32 pb-12">
        <div className="mx-auto max-w-3xl text-center">
          <h1 className="animate-fade-up font-serif text-4xl font-semibold text-text-primary md:text-5xl">
            Yoga Darshan
          </h1>
          <p className="animate-fade-up delay-1 mt-3 font-devanagari text-xl text-accent-warm">
            योग दर्शन
          </p>
          <p className="animate-fade-up delay-2 mt-4 font-serif italic text-lg text-text-secondary">
            Patanjali&apos;s Yoga Sutras
          </p>
          <p className="animate-fade-up delay-2 mt-2 text-sm font-light text-text-secondary">
            195 sutras across 4 chapters by Maharshi Patanjali (~200 BCE)
          </p>
          <p className="animate-fade-up delay-3 mt-6 mx-auto max-w-lg font-serif italic text-text-primary leading-relaxed">
            &ldquo;Yoga is the cessation of the fluctuations of the
            mind.&rdquo;
          </p>
          <p className="animate-fade-up delay-3 mt-2 text-sm text-text-tertiary">
            — Sutra 1.2
          </p>
        </div>
      </section>

      {/* Pada Navigation Cards */}
      <section className="px-6 py-8">
        <div className="mx-auto max-w-4xl">
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
            {PADAS.map((pada, index) => (
              <a
                key={pada.id}
                href={`#${pada.id}`}
                className={`group block rounded-lg border border-border bg-bg-card p-5 text-center transition-colors hover:border-border-strong hover:bg-bg-card-hover animate-fade-up delay-${index + 1}`}
              >
                <p className="font-serif text-lg text-text-primary group-hover:text-accent-gold transition-colors">
                  {pada.name}
                </p>
                <p className="mt-1 text-xs text-text-tertiary">
                  {pada.count} sutras
                </p>
                <p className="mt-3 text-xs font-light leading-relaxed text-text-secondary">
                  {pada.description}
                </p>
              </a>
            ))}
          </div>
        </div>
      </section>

      {/* Sutra Lists by Pada */}
      {PADAS.map((pada, padaIndex) => {
        const padaSutras = getSutrasByPada(pada.padaNum);

        return (
          <section key={pada.id} id={pada.id} className="px-6 py-12">
            <div className="mx-auto max-w-4xl">
              {padaIndex > 0 && <div className="mb-12 h-px bg-border" />}

              <div className="mb-8">
                <h2 className="font-serif text-xl text-text-primary">
                  {pada.name}
                </h2>
                <p className="mt-1 text-xs uppercase tracking-wider text-accent-gold">
                  {pada.sutraRange}
                </p>
                <p className="mt-2 text-sm font-light text-text-secondary">
                  {pada.longDescription}
                </p>
              </div>

              <div className="grid gap-4 md:grid-cols-2">
                {padaSutras.map((sutra) => (
                  <Link
                    key={sutra.sutraNumber}
                    href={`/yoga-sutras/${sutra.sutraNumber}`}
                    className="group block rounded-lg border border-border bg-bg-card p-5 transition-colors hover:border-border-strong hover:bg-bg-card-hover"
                  >
                    <div className="flex items-start justify-between gap-3">
                      <p className="text-xs font-medium text-accent-gold">
                        Sutra {sutra.sutraNumber}
                      </p>
                      {sutra.theme && (
                        <span className="inline-flex rounded-full bg-accent-gold-muted px-2.5 py-0.5 text-[0.65rem] font-medium text-accent-gold">
                          {sutra.theme}
                        </span>
                      )}
                    </div>

                    <p className="sanskrit mt-3 line-clamp-2 text-sm leading-relaxed">
                      {sutra.sanskrit}
                    </p>

                    <p className="mt-3 line-clamp-2 font-serif text-sm italic leading-relaxed text-text-secondary">
                      {sutra.englishTranslation}
                    </p>
                  </Link>
                ))}
              </div>

              {padaSutras.length === 0 && (
                <p className="py-8 text-center text-sm text-text-tertiary">
                  Sutras for {pada.name} are being prepared. Check back soon.
                </p>
              )}
            </div>
          </section>
        );
      })}

      <Footer />
    </>
  );
}
