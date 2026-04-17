import Link from "next/link";
import type { Metadata } from "next";
import { getAllSeries } from "@/lib/series";
import { Footer } from "@/components/Footer";

export const metadata: Metadata = {
  title: "Series — Bodhi",
  description:
    "Thematic journeys through ancient wisdom — the Pancha Kosha and Ashtanga Yoga, explained part by part.",
};

export default function SeriesIndexPage() {
  const allSeries = getAllSeries();

  return (
    <>
      {/* Header */}
      <section className="px-6 pt-32 pb-12">
        <div className="mx-auto max-w-3xl text-center">
          <h1 className="animate-fade-up font-serif text-4xl font-semibold text-text-primary md:text-5xl">
            Series
          </h1>
          <p className="animate-fade-up delay-1 mt-4 font-serif text-lg italic text-text-secondary">
            Thematic journeys through ancient wisdom.
          </p>
          <p className="animate-fade-up delay-2 mt-2 text-sm font-light text-text-secondary">
            {allSeries.length} series &middot;{" "}
            {allSeries.reduce((sum, s) => sum + s.partCount, 0)} parts
          </p>
        </div>
      </section>

      {/* Series List */}
      <section className="px-6 pb-24">
        <div className="mx-auto max-w-3xl">
          <div className="flex flex-col gap-4">
            {allSeries.map((series, index) => (
              <Link
                key={series.slug}
                href={`/series/${series.slug}`}
                className={`group block rounded-lg border border-border bg-bg-card p-6 transition-colors hover:border-border-strong hover:bg-bg-card-hover animate-fade-up delay-${Math.min(index + 1, 6)}`}
              >
                <div className="flex items-start gap-5">
                  {/* Part Count */}
                  <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full border border-border text-sm font-light text-accent-gold">
                    {series.partCount}
                  </div>

                  <div className="min-w-0 flex-1">
                    {/* Tag */}
                    <span className="inline-block rounded-full border border-border px-2.5 py-0.5 text-[10px] uppercase tracking-[0.1em] text-accent-gold">
                      Series
                    </span>

                    {/* Title */}
                    <h2 className="mt-2 font-serif text-xl text-text-primary transition-colors group-hover:text-accent-gold">
                      {series.title}
                    </h2>

                    {/* Description */}
                    <p className="mt-1 text-sm font-light leading-relaxed text-text-secondary">
                      {series.description}
                    </p>

                    {/* Parts meta */}
                    <p className="mt-2 text-xs text-text-tertiary">
                      {series.partCount} parts
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
