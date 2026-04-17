"use client";

import { useState, useCallback } from "react";
import Link from "next/link";
import { Menu, X, Search } from "lucide-react";

const NAV_LINKS = [
  { href: "/vivekachudamani", label: "Vivekachudamani" },
  { href: "/yoga-sutras", label: "Yoga Sutras" },
  { href: "/lessons", label: "Lessons" },
  { href: "/stories", label: "Stories" },
  { href: "/series", label: "Series" },
  { href: "/practices", label: "Practices" },
  { href: "/about", label: "About" },
] as const;

export function Navbar() {
  const [isOpen, setIsOpen] = useState(false);

  const toggleMenu = useCallback(() => {
    setIsOpen((prev) => !prev);
  }, []);

  const closeMenu = useCallback(() => {
    setIsOpen(false);
  }, []);

  return (
    <nav className="fixed top-0 left-0 right-0 z-50 bg-bg-primary/80 backdrop-blur-lg border-b border-border">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="flex h-16 items-center justify-between">
          {/* Logo */}
          <Link
            href="/"
            className="font-serif text-2xl font-semibold tracking-wide text-accent-gold"
          >
            BODHI
          </Link>

          {/* Desktop links */}
          <div className="hidden md:flex items-center gap-8">
            {NAV_LINKS.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className="text-sm tracking-wide text-text-secondary hover:text-accent-gold transition-colors duration-200"
              >
                {link.label}
              </Link>
            ))}
            <button
              type="button"
              aria-label="Search"
              className="text-text-secondary hover:text-accent-gold transition-colors duration-200"
            >
              <Search size={18} />
            </button>
          </div>

          {/* Mobile hamburger */}
          <button
            type="button"
            aria-label={isOpen ? "Close menu" : "Open menu"}
            className="md:hidden text-text-secondary hover:text-accent-gold transition-colors duration-200"
            onClick={toggleMenu}
          >
            {isOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>
      </div>

      {/* Mobile overlay */}
      {isOpen && (
        <div className="fixed inset-0 top-16 z-40 bg-bg-primary/95 backdrop-blur-xl md:hidden animate-fade-in">
          <div className="flex flex-col items-center justify-center gap-10 pt-20">
            {NAV_LINKS.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                onClick={closeMenu}
                className="font-serif text-2xl text-text-secondary hover:text-accent-gold transition-colors duration-200"
              >
                {link.label}
              </Link>
            ))}
            <button
              type="button"
              aria-label="Search"
              onClick={closeMenu}
              className="flex items-center gap-2 text-text-secondary hover:text-accent-gold transition-colors duration-200"
            >
              <Search size={20} />
              <span className="font-serif text-lg">Search</span>
            </button>
          </div>
        </div>
      )}
    </nav>
  );
}
