import type { Metadata } from "next";
import { Cormorant_Garamond, Inter, Noto_Sans_Devanagari } from "next/font/google";
import "./globals.css";
import { Navbar } from "@/components/Navbar";

const inter = Inter({
  variable: "--font-sans",
  subsets: ["latin"],
  display: "swap",
});

const cormorant = Cormorant_Garamond({
  variable: "--font-serif",
  subsets: ["latin"],
  weight: ["300", "400", "600"],
  style: ["normal", "italic"],
  display: "swap",
});

const notoDevanagari = Noto_Sans_Devanagari({
  variable: "--font-devanagari",
  subsets: ["devanagari"],
  weight: ["300", "400", "600"],
  display: "swap",
});

const SITE_URL = process.env.NEXT_PUBLIC_SITE_URL ?? "https://bodhi.app";

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: "Bodhi — Ancient Verses, Modern Clarity",
    template: "%s | Bodhi",
  },
  description:
    "Ancient wisdom from the Vivekachudamani and Yoga Darshan — lessons, stories, and practices for modern life.",
  keywords: [
    "Vivekachudamani",
    "Yoga Sutras",
    "Advaita Vedanta",
    "Shankaracharya",
    "Patanjali",
    "Indian philosophy",
    "self-inquiry",
  ],
  openGraph: {
    type: "website",
    siteName: "Bodhi",
    locale: "en_US",
    url: SITE_URL,
    title: "Bodhi — Ancient Verses, Modern Clarity",
    description:
      "Ancient wisdom from the Vivekachudamani and Yoga Darshan — lessons, stories, and practices for modern life.",
    images: ["/og-default.png"],
  },
  twitter: {
    card: "summary_large_image",
    title: "Bodhi — Ancient Verses, Modern Clarity",
    description:
      "Ancient wisdom from the Vivekachudamani and Yoga Darshan — lessons, stories, and practices for modern life.",
    images: ["/og-default.png"],
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className={`${inter.variable} ${cormorant.variable} ${notoDevanagari.variable} h-full antialiased`}
    >
      <body className="min-h-full flex flex-col bg-bg-primary text-text-primary">
        <Navbar />
        <main className="flex-1">{children}</main>
      </body>
    </html>
  );
}
