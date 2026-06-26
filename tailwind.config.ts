import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./hooks/**/*.{js,ts,jsx,tsx,mdx}",
    "./lib/**/*.{js,ts,jsx,tsx,mdx}"
  ],
  theme: {
    extend: {
      colors: {
        calm: {
          50: "#f2fbfa",
          100: "#d9f4f0",
          500: "#16a6a0",
          700: "#0d7474"
        },
        skycare: {
          50: "#f3f8ff",
          100: "#dcecff",
          500: "#2f80ed",
          700: "#1d5fb8"
        }
      },
      boxShadow: {
        soft: "0 14px 38px rgba(31, 56, 88, 0.08)"
      }
    }
  },
  plugins: []
};

export default config;
