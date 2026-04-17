interface PracticeCardProps {
  readonly practice: string;
}

export function PracticeCard({ practice }: PracticeCardProps) {
  return (
    <div className="rounded-xl border border-border bg-bg-card p-6 sm:p-8">
      <h3 className="mb-3 text-xs font-semibold uppercase tracking-[0.2em] text-accent-gold">
        Try This Today
      </h3>
      <p className="text-sm sm:text-base leading-relaxed text-text-secondary">
        {practice}
      </p>
    </div>
  );
}
