import Link from "next/link";

const FOOTER_LINKS = [
  { href: "/vivekachudamani", label: "Vivekachudamani" },
  { href: "/yoga-sutras", label: "Yoga Sutras" },
  { href: "/daily", label: "Daily Verse" },
  { href: "/about", label: "About" },
] as const;

export function Footer() {
  return (
    <footer className="border-t border-border bg-bg-secondary">
      <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
        <div className="flex flex-col items-center gap-8">
          {/* Navigation */}
          <nav className="flex flex-wrap justify-center gap-6">
            {FOOTER_LINKS.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className="text-sm text-text-tertiary hover:text-accent-gold transition-colors duration-200"
              >
                {link.label}
              </Link>
            ))}
          </nav>

          {/* Divider */}
          <div className="h-px w-16 bg-border" />

          {/* Attribution */}
          <div className="text-center">
            <p className="text-xs text-text-tertiary leading-relaxed">
              Source texts from Gita Press, Gorakhpur
            </p>
            <p className="mt-1 font-serif text-sm italic text-text-tertiary">
              Built with reverence
            </p>
          </div>
        </div>
      </div>
    </footer>
  );
}
