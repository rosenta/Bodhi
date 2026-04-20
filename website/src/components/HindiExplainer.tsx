interface HindiExplainerProps {
  readonly meaning?: string;
  readonly explanation?: string;
  readonly example?: string;
  readonly audioSrc?: string;
}

/**
 * Renders the Hindi explainer section — plain meaning, conversational walk-through,
 * and one concrete modern example. Optionally surfaces a native audio player
 * next to the "समझ" sub-heading when `audioSrc` is provided.
 *
 * Returns null when no Hindi content is available so the host page stays clean.
 */
export function HindiExplainer({
  meaning,
  explanation,
  example,
  audioSrc,
}: HindiExplainerProps) {
  if (!meaning && !explanation && !example) {
    return null;
  }

  return (
    <section className="px-6 py-12">
      <div className="mx-auto max-w-[650px]">
        <div className="rounded-xl border border-border bg-bg-card p-6 sm:p-8">
          <h2 className="font-devanagari text-xl font-semibold leading-tight text-accent-gold sm:text-2xl">
            हिंदी में समझें
          </h2>

          {meaning && (
            <div className="mt-6">
              <p className="text-xs font-semibold uppercase tracking-[0.2em] text-accent-gold">
                अर्थ
              </p>
              <p className="font-devanagari mt-3 text-base leading-[2] text-text-secondary">
                {meaning}
              </p>
            </div>
          )}

          {explanation && (
            <div className="mt-8">
              <div className="flex items-center gap-3">
                <p className="text-xs font-semibold uppercase tracking-[0.2em] text-accent-gold">
                  समझ
                </p>
                {audioSrc && (
                  <audio
                    controls
                    preload="none"
                    src={audioSrc}
                    className="h-8 max-w-[240px] flex-1"
                    aria-label="Hindi explanation audio"
                  >
                    Your browser does not support the audio element.
                  </audio>
                )}
              </div>
              <p className="font-devanagari mt-3 text-base leading-[2] text-text-secondary">
                {explanation}
              </p>
            </div>
          )}

          {example && (
            <div className="mt-8">
              <p className="text-xs font-semibold uppercase tracking-[0.2em] text-accent-gold">
                उदाहरण
              </p>
              <p className="font-devanagari mt-3 text-base leading-[2] text-text-secondary">
                {example}
              </p>
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
