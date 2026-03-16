import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  /**
   * Serve /.well-known/ files with the correct Content-Type so that:
   *  - Android verifies App Links via assetlinks.json
   *  - iOS verifies Universal Links via apple-app-site-association
   */
  async headers() {
    return [
      {
        source: '/.well-known/:file*',
        headers: [
          { key: 'Content-Type', value: 'application/json' },
          { key: 'Cache-Control', value: 'no-cache, no-store, must-revalidate' },
        ],
      },
    ];
  },
};

export default nextConfig;
