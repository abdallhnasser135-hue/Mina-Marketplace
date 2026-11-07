// replica/design/tailwind.config.ts: token mapping only (no components). Phase 4 copies this into the app.
// Regenerate tailwind.theme.json with: python3 build-tokens.py
import type { Config } from 'tailwindcss'
import theme from './tailwind.theme.json'

export default {
  content: ['./app/**/*.{ts,tsx,mdx}', './components/**/*.{ts,tsx}'],
  theme: {
    // REPLACED, not extended: only token colours and the token spacing scale can be used.
    colors: { transparent: 'transparent', current: 'currentColor', ...theme.colors },
    spacing: theme.spacing,
    screens: theme.screens,
    borderRadius: { none: '0', ...theme.borderRadius },
    boxShadow: theme.boxShadow,
    extend: {
      fontFamily: theme.fontFamily,
      fontSize: theme.fontSize as any,
      zIndex: theme.zIndex,
      maxWidth: { container: 'var(--container)', prose: 'var(--prose)' },
      transitionDuration: { fast: 'var(--motion-fast)', base: 'var(--motion-base)', slow: 'var(--motion-slow)' },
      transitionTimingFunction: { DEFAULT: 'var(--motion-ease)' },
    },
  },
  // Logical utilities (ms-*, me-*, ps-*, pe-*, start-*, end-*, text-start, text-end, border-s, rounded-s) are built in.
  // Lint rule for Phase 4: forbid ml-*, mr-*, pl-*, pr-*, left-*, right-*, text-left, text-right, rounded-l, rounded-r.
  plugins: [],
} satisfies Config
