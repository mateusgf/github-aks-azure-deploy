import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Produces a minimal, self-contained server output copied into the Docker image
  output: "standalone",
};

export default nextConfig;
