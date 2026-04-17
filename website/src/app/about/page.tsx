import type { Metadata } from "next";
import { Footer } from "@/components/Footer";

export const metadata: Metadata = {
  title: "About — Bodhi",
  description:
    "Ancient verses. Modern clarity. Learn about the mission behind Bodhi and the source texts that power it.",
};

const SOURCE_TEXTS = [
  {
    titleEn: "Vivekachudamani",
    titleSanskrit: "विवेकचूडामणि",
    subtitle: "The Crest-Jewel of Discrimination",
    author: "Adi Shankaracharya (~8th century CE)",
    details: "580 verses, continuous dialogue between Guru and Disciple",
    tradition: "Advaita Vedanta",
    edition: "Gita Press, Gorakhpur",
  },
  {
    titleEn: "Yoga Darshan",
    titleSanskrit: "योग दर्शन",
    subtitle: "Patanjali's Yoga Sutras",
    author: "Maharshi Patanjali (~200 BCE)",
    details: "195 sutras across 4 chapters",
    tradition: "Commentary: Harikrishnadas Goyandka (Gita Press)",
    edition: "Gita Press, Gorakhpur, 26th Edition",
  },
] as const;

export default function AboutPage() {
  return (
    <>
      {/* Header */}
      <section className="px-6 pt-32 pb-16">
        <div className="mx-auto max-w-2xl text-center">
          <h1 className="animate-fade-up font-serif text-4xl font-semibold text-text-primary md:text-5xl">
            About Bodhi
          </h1>
          <p className="animate-fade-up delay-1 mt-4 font-serif text-xl italic font-light text-text-secondary">
            Ancient verses. Modern clarity.
          </p>
        </div>
      </section>

      {/* Mission */}
      <section className="px-6 py-16">
        <div className="mx-auto max-w-[650px]">
          <p className="animate-fade-up text-xs font-medium uppercase tracking-[0.2em] text-accent-gold">
            Why This Exists
          </p>

          <div className="animate-fade-up delay-1 mt-8 space-y-6 text-lg font-light leading-[1.9] text-text-secondary">
            <p>
              The Vivekachudamani and Yoga Sutras are among humanity&apos;s
              deepest inquiries into consciousness. Together they ask the
              question every person eventually faces:{" "}
              <strong className="font-medium text-text-primary">
                Who am I, really?
              </strong>
            </p>
            <p>
              Yet these texts remain locked behind academic jargon, religious
              framing, or simply bad web design. Translations are scattered
              across PDFs with tiny fonts, buried in commentary that obscures
              rather than illuminates.
            </p>
            <p>
              Bodhi is an attempt to present these verses with the{" "}
              <strong className="font-medium text-text-primary">
                reverence they deserve
              </strong>{" "}
              and the{" "}
              <strong className="font-medium text-text-primary">
                clarity they need
              </strong>
              . Each verse is offered in its original Sanskrit, with a faithful
              English translation, a modern interpretation for daily life, and a
              concrete practice you can try today.
            </p>
            <p>
              No login. No paywall. No algorithms deciding what wisdom you
              should see next. Just the texts, presented beautifully, for anyone
              who is ready to look inward.
            </p>
          </div>
        </div>
      </section>

      {/* The Source Texts */}
      <section className="px-6 py-16">
        <div className="mx-auto max-w-[650px]">
          <p className="animate-fade-up text-xs font-medium uppercase tracking-[0.2em] text-accent-gold">
            The Source Texts
          </p>

          <div className="mt-10 space-y-10">
            {SOURCE_TEXTS.map((text, index) => (
              <div
                key={text.titleEn}
                className={`animate-fade-up delay-${index + 1}`}
              >
                <div className="flex items-baseline gap-3">
                  <h3 className="font-serif text-xl text-text-primary">
                    {text.titleEn}
                  </h3>
                  <span className="font-devanagari text-lg text-accent-warm">
                    ({text.titleSanskrit})
                  </span>
                </div>
                <p className="mt-1 font-serif italic text-text-secondary">
                  &ldquo;{text.subtitle}&rdquo;
                </p>
                <div className="mt-3 space-y-1 text-sm font-light text-text-secondary">
                  <p>
                    <span className="text-text-tertiary">Author:</span>{" "}
                    {text.author}
                  </p>
                  <p>{text.details}</p>
                  <p>
                    <span className="text-text-tertiary">Tradition:</span>{" "}
                    {text.tradition}
                  </p>
                  <p>
                    <span className="text-text-tertiary">Edition:</span>{" "}
                    {text.edition}
                  </p>
                </div>

                {index < SOURCE_TEXTS.length - 1 && (
                  <div className="mt-10 h-px w-full bg-border" />
                )}
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Translation Approach */}
      <section className="px-6 py-16">
        <div className="mx-auto max-w-[650px]">
          <p className="animate-fade-up text-xs font-medium uppercase tracking-[0.2em] text-accent-gold">
            Our Approach to Translation
          </p>

          <div className="animate-fade-up delay-1 mt-8 space-y-6 text-lg font-light leading-[1.9] text-text-secondary">
            <p>
              The primary translations come from the{" "}
              <strong className="font-medium text-text-primary">
                Gita Press editions
              </strong>
              , supplemented by cross-referencing with Swami Madhavananda
              (Vivekachudamani) and Swami Vivekananda / I.K. Taimni (Yoga
              Sutras).
            </p>
            <p>
              Modern interpretations are original and aim to bridge ancient
              context with contemporary life without distorting the original
              meaning. Where a verse has multiple valid readings, we prioritize
              the one most actionable for a modern seeker.
            </p>
          </div>
        </div>
      </section>

      {/* How to Use */}
      <section className="px-6 py-16">
        <div className="mx-auto max-w-[650px]">
          <p className="animate-fade-up text-xs font-medium uppercase tracking-[0.2em] text-accent-gold">
            How to Use Bodhi
          </p>

          <div className="mt-8 text-center">
            <p className="animate-fade-up delay-1 font-serif text-2xl leading-relaxed text-text-primary md:text-3xl">
              Read one verse.
              <br />
              Sit with it.
              <br />
              That&apos;s it.
            </p>
          </div>

          <div className="animate-fade-up delay-2 mt-8 space-y-4 text-lg font-light leading-[1.9] text-text-secondary">
            <p>
              You can read sequentially (like the original dialogue), browse by
              theme, or let the daily verse find you. There is no correct path.
              There is only your path.
            </p>
          </div>
        </div>
      </section>

      {/* Attribution */}
      <section className="px-6 py-16">
        <div className="mx-auto max-w-[650px]">
          <p className="animate-fade-up text-xs font-medium uppercase tracking-[0.2em] text-accent-gold">
            Attribution
          </p>

          <div className="animate-fade-up delay-1 mt-8 space-y-3 text-sm font-light leading-relaxed text-text-secondary">
            <p>Source texts published by Gita Press, Gorakhpur.</p>
            <p>
              Sanskrit typography powered by Noto Sans Devanagari (Google Fonts).
            </p>
            <p>Built with Next.js, hosted on Vercel.</p>
            <p className="pt-4 text-text-tertiary">
              Bodhi is an open-source project. Contributions, corrections, and
              suggestions are welcome.
            </p>
          </div>
        </div>
      </section>

      <Footer />
    </>
  );
}
