import type { Verse } from "@/lib/types";

interface VerseCardProps {
  readonly verse: Verse;
  readonly showFull?: boolean;
  readonly variant?: "default" | "compact";
}

export function VerseCard({
  verse,
  showFull = false,
  variant = "default",
}: VerseCardProps) {
  const isCompact = variant === "compact";

  return (
    <article
      className={`rounded-2xl border border-border bg-bg-card transition-colors hover:bg-bg-card-hover ${
        isCompact ? "p-5" : "p-6 sm:p-8"
      } animate-fade-up`}
    >
      {/* Header: verse number + theme */}
      <div className="flex items-center justify-between mb-4 delay-1 animate-fade-up">
        <span className="text-xs font-semibold uppercase tracking-[0.2em] text-accent-gold">
          Verse {verse.verseNumber}
        </span>
        <span className="rounded-full border border-border-strong px-3 py-1 text-xs text-text-tertiary">
          {verse.theme}
        </span>
      </div>

      {/* Sanskrit */}
      <div className={`${isCompact ? "mb-4" : "mb-6"} delay-2 animate-fade-up`}>
        <p
          className={`sanskrit leading-relaxed whitespace-pre-line ${
            isCompact ? "text-base line-clamp-3" : "text-lg sm:text-xl"
          }`}
        >
          {verse.sanskrit}
        </p>
      </div>

      {/* Divider */}
      <div
        className={`${isCompact ? "my-4" : "my-6"} h-px bg-border delay-3 animate-fade-up`}
      />

      {/* English translation */}
      <div className="delay-3 animate-fade-up">
        <p
          className={`serif italic leading-relaxed text-text-secondary ${
            isCompact ? "text-sm line-clamp-3" : "text-base sm:text-lg"
          }`}
        >
          {verse.englishTranslation}
        </p>
      </div>

      {/* Extended content (only in default variant) */}
      {showFull && !isCompact && (
        <>
          {/* Modern interpretation */}
          <div className="mt-6 delay-4 animate-fade-up">
            <h3 className="mb-2 text-xs font-semibold uppercase tracking-[0.2em] text-accent-gold">
              Modern Interpretation
            </h3>
            <p className="text-sm leading-relaxed text-text-secondary">
              {verse.modernInterpretation}
            </p>
          </div>

          {/* Practice prompt */}
          <div className="mt-6 delay-5 animate-fade-up">
            <div className="rounded-xl border border-border bg-bg-surface p-5">
              <h3 className="mb-2 text-xs font-semibold uppercase tracking-[0.2em] text-accent-gold">
                Try This Today
              </h3>
              <p className="text-sm leading-relaxed text-text-secondary">
                {verse.practicePrompt}
              </p>
            </div>
          </div>
        </>
      )}
    </article>
  );
}
