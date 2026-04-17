import Link from "next/link";
import type { Metadata } from "next";
import { getAllSeries, getSeriesBySlug } from "@/lib/series";
import { Footer } from "@/components/Footer";
import { notFound } from "next/navigation";

interface Props {
  params: Promise<{ series: string }>;
}

export async function generateStaticParams() {
  const allSeries = getAllSeries();
  return allSeries.map((s) => ({ series: s.slug }));
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { series: seriesSlug } = await params;
  const series = getSeriesBySlug(seriesSlug);
  if (!series) return { title: "Series Not Found — Bodhi" };

  return {
    title: `${series.title} — Bodhi`,
    description: series.description,
  };
}

export default async function SeriesDetailPage({ params }: Props) {
  const { series: seriesSlug } = await params;
  const series = getSeriesBySlug(seriesSlug);

  if (!series) notFound();

  return (
    <>
      {/* Header */}
      <section
        className="relative flex min-h-[50vh] items-center justify-center px-6"
        style={{
          background:
            "radial-gradient(ellipse at center, rgba(201, 165, 90, 0.06) 0%, transparent 70%)",
        }}
      >
        <div className="pt-24 pb-12 text-center">
          <p className="animate-fade-up text-xs font-light uppercase tracking-[0.3em] text-accent-gold">
            Series &mdash; {series.partCount} parts
          </p>

          <h1 className="mx-auto mt-6 max-w-2xl animate-fade-up delay-1 font-serif text-3xl font-semibold leading-snug text-text-primary md:text-4xl">
            {series.title}
          </h1>

          <p className="mx-auto mt-4 max-w-xl animate-fade-up delay-2 font-serif text-lg italic text-text-secondary">
            {series.description}
          </p>
        </div>
      </section>

      {/* Parts List */}
      <section className="px-6 pb-24">
        <div className="mx-auto max-w-3xl">
          <div className="flex flex-col gap-4">
            {series.parts.map((part, index) => (
              <Link
                key={part.partSlug}
                href={`/series/${series.slug}/${part.partSlug}`}
                className={`group block rounded-lg border border-border bg-bg-card p-6 transition-colors hover:border-border-strong hover:bg-bg-card-hover animate-fade-up delay-${Math.min(index + 1, 6)}`}
              >
                <div className="flex items-start gap-5">
                  {/* Part Number */}
                  <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full border border-border text-sm font-light text-accent-gold">
                    {part.part}
                  </div>

                  <div className="min-w-0 flex-1">
                    {/* Subtitle tag (kosha / limb) */}
                    {part.subtitle ? (
                      <span className="inline-block rounded-full border border-border px-2.5 py-0.5 text-[10px] uppercase tracking-[0.1em] text-accent-gold">
                        {part.subtitle}
                      </span>
                    ) : null}

                    {/* Title */}
                    <h2 className="mt-2 font-serif text-xl text-text-primary transition-colors group-hover:text-accent-gold">
                      {part.title}
                    </h2>

                    {/* English name */}
                    {part.englishName ? (
                      <p className="mt-1 text-sm font-light leading-relaxed text-text-secondary">
                        {part.englishName}
                      </p>
                    ) : null}

                    {/* References */}
                    {part.references.length > 0 ? (
                      <p className="mt-2 text-xs text-text-tertiary">
                        {part.referencesLabel} &middot;{" "}
                        {part.references.join(", ")}
                      </p>
                    ) : null}
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
