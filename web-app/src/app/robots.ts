import type { MetadataRoute } from "next";

const siteUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://step-forward.app";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: "*",
      allow: "/",
      disallow: ["/main/", "/complete-profile"],
    },
    sitemap: `${siteUrl}/sitemap.xml`,
  };
}
