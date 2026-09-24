import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    name: "portafolio-jumi",
    environment: "node",
    globals: true,
    include: ["src/**/*.{test,spec}.{js,jsx,ts,tsx}", "src/**/__tests__/**/*.{js,jsx,ts,tsx}"],
    exclude: ["node_modules/", "dist/"],
  },
});
