import Link from "next/link";
import type { Metadata } from "next";
import { getAllPractices } from "@/lib/practices";
import { Footer } from "@/components/Footer";

export const metadata: Metadata = {
  title: "Practices — Bodhi",
  description:
    "Experiential practices distilled from the Vivekachudamani and allied wisdom traditions. Sit, inquire, and discover what has always been present.",
};

export default function PracticesIndexPage() {
  const practices = getAllPractices();

  return (
    <>
      {/* Header */}
      <section className="px-6 pt-32 pb-12">
        <div className="mx-auto max-w-3xl text-center">
          <h1 className="animate-fade-up font-serif text-4xl font-semibold text-text-primary md:text-5xl">
            Practices
          </h1>
          <p className="animate-fade-up delay-1 mt-4 font-serif text-lg italic text-text-secondary">
            Sit. Inquire. Recognize.
          </p>
          <p className="animate-fade-up delay-2 mt-2 text-sm font-light text-text-secondary">
            {practices.length}{" "}
            {practices.length === 1 ? "practice" : "practices"} for direct
            experience
          </p>
        </div>
      </section>

      {/* Practices List */}
      <section className="px-6 pb-24">
        <div className="mx-auto max-w-3xl">
          <div className="flex flex-col gap-4">
            {practices.map((practice, index) => (
              <Link
                key={practice.slug}
                href={`/practices/${practice.slug}`}
                className={`group block rounded-lg border border-border bg-bg-card p-6 transition-colors hover:border-border-strong hover:bg-bg-card-hover animate-fade-up delay-${Math.min(index + 1, 6)}`}
              >
                <div className="flex items-start gap-5">
                  {/* Practice Number */}
                  <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full border border-border text-sm font-light text-accent-gold">
                    {practice.practice}
                  </div>

                  <div className="min-w-0 flex-1">
                    {/* Theme Tag */}
                    <span className="inline-block rounded-full border border-border px-2.5 py-0.5 text-[10px] uppercase tracking-[0.1em] text-accent-gold">
                      {practice.theme}
                    </span>

                    {/* Title */}
                    <h2 className="mt-2 font-serif text-xl text-text-primary transition-colors group-hover:text-accent-gold">
                      {practice.title}
                    </h2>

                    {/* Tagline */}
                    <p className="mt-1 text-sm font-light leading-relaxed text-text-secondary line-clamp-2">
                      {practice.tagline}
                    </p>

                    {/* Meta row: duration / difficulty / verse */}
                    <p className="mt-2 text-xs text-text-tertiary">
                      {practice.duration}
                      {practice.difficulty ? ` · ${practice.difficulty}` : ""}
                      {practice.verseReference
                        ? ` · ${practice.source || "Vivekachudamani"}, Verse ${practice.verseReference}`
                        : ""}
                    </p>
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
