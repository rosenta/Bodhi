import type { MetadataRoute } from "next";
import { getAllVerses, getAllSutras } from "@/lib/data";
import { getAllLessons } from "@/lib/lessons";
import { getAllStories } from "@/lib/stories";
import { getAllPractices } from "@/lib/practices";
import { getAllSeries } from "@/lib/series";

const SITE_URL = process.env.NEXT_PUBLIC_SITE_URL ?? "https://bodhi.app";

type ChangeFrequency = NonNullable<
  MetadataRoute.Sitemap[number]["changeFrequency"]
>;

function entry(
  path: string,
  priority: number,
  changeFrequency: ChangeFrequency,
  lastModified: Date = new Date()
): MetadataRoute.Sitemap[number] {
  return {
    url: `${SITE_URL}${path}`,
    lastModified,
    changeFrequency,
    priority,
  };
}

export default function sitemap(): MetadataRoute.Sitemap {
  const now = new Date();

  const staticRoutes: MetadataRoute.Sitemap = [
    entry("/", 1.0, "monthly", now),
    entry("/about", 0.6, "monthly", now),
    entry("/lessons", 0.8, "monthly", now),
    entry("/stories", 0.8, "monthly", now),
    entry("/series", 0.7, "monthly", now),
    entry("/practices", 0.7, "monthly", now),
    entry("/vivekachudamani", 0.9, "monthly", now),
    entry("/yoga-sutras", 0.9, "monthly", now),
  ];

  const verseRoutes: MetadataRoute.Sitemap = getAllVerses().map((v) =>
    entry(`/vivekachudamani/${v.verseNumber}`, 0.8, "yearly", now)
  );

  const sutraRoutes: MetadataRoute.Sitemap = getAllSutras().map((s) =>
    entry(`/yoga-sutras/${s.sutraNumber}`, 0.8, "yearly", now)
  );

  const lessonRoutes: MetadataRoute.Sitemap = getAllLessons().map((l) =>
    entry(`/lessons/${l.slug}`, 0.5, "monthly", now)
  );

  const storyRoutes: MetadataRoute.Sitemap = getAllStories().map((s) =>
    entry(`/stories/${s.slug}`, 0.5, "monthly", now)
  );

  const practiceRoutes: MetadataRoute.Sitemap = getAllPractices().map((p) =>
    entry(`/practices/${p.slug}`, 0.5, "monthly", now)
  );

  const seriesRoutes: MetadataRoute.Sitemap = getAllSeries().flatMap((s) => [
    entry(`/series/${s.slug}`, 0.6, "monthly", now),
    ...s.parts.map((p) =>
      entry(`/series/${s.slug}/${p.partSlug}`, 0.5, "monthly", now)
    ),
  ]);

  return [
    ...staticRoutes,
    ...verseRoutes,
    ...sutraRoutes,
    ...lessonRoutes,
    ...storyRoutes,
    ...practiceRoutes,
    ...seriesRoutes,
  ];
}
