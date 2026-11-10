# AGENTS.md — Mizuki (biscuit0613.github.io)

Fork of Mizuki (Astro blog template). Personal blog at `biscuit0613.github.io`.

## Quick start

```bash
pnpm install      # pnpm >= 9, Node >= 20 required
pnpm dev          # localhost:4321
pnpm build        # astro build + pagefind --site dist
pnpm preview      # local preview of built site
```

## Key commands

| Command | What it does |
|---|---|
| `pnpm check` | `astro check` — Astro-level diagnostics |
| `pnpm type-check` | `tsc --noEmit --isolatedDeclarations` — separate from `check`, run both |
| `pnpm format` | `biome format --write ./src` |
| `pnpm lint` | `biome check --write ./src` |
| `pnpm new-post <filename>` | Creates a new post in `src/content/posts/` |

**Verification order**: `pnpm check && pnpm type-check && pnpm lint && pnpm build`

## Structure

- **`src/config.ts`** — Central blog config (site info, banner, theme, sidebar, etc.).
- **`src/content/posts/`** — Blog posts (Markdown with frontmatter).
- **`docs/AGENT-writing.md`** — Internal knowledge-map and writing reference; not published as a post.
- **`src/content/spec/`** — Special pages: `friends.md`, `about.md`.
- **`src/pages/`** — Route pages (anime, albums, archive, diary, projects, skills, timeline, 404, RSS).
- **`src/plugins/`** — Custom remark/rehype plugins (Mermaid, admonitions, GitHub cards, excerpt, reading time).
- **`src/components/`** — Svelte 5 + Astro components.
- **`src/layouts/`** — `Layout.astro`, `MainGridLayout.astro`.
- **`public/`** — Static assets (banner images, etc.).

## Post frontmatter

```yaml
---
title: My Post
published: 2024-01-01
description: ''
image: ./cover.jpg
tags: [tag1, tag2]
category: frontend
draft: false
pinned: false
lang: zh-CN   # only if different from site default
---
```

## Deploy

- **Vercel** — auto-deploys from git (config in `vercel.json`).
- **GitHub Pages** — CI in `.github/workflows/deploy.yml`, triggers on **`mizuki`** branch (not `main`).
- Build output: `dist/`.

## Toolchain quirks

- **pnpm enforced** — `preinstall` script blocks npm/yarn. `.npmrc` sets `manage-package-manager-versions = true`.
- **Biome** — tab indent, double quotes, excludes `src/**/*.css`. Astro/Svelte/Vue files have relaxed rules (`noUnusedVariables`, `noUnusedImports`, `useConst`, `useImportType` off by biome overrides).
- **Dark mode** — `class`-based toggling in tailwind config.
- **Swup** — custom `transition-swup-` animation class (not the default `transition-`). Smooth scrolling disabled to avoid anchor nav conflicts.
- **No test framework** installed.
- **No Docker** setup.
- **No environment variables** required for dev.

## Path aliases (tsconfig)

`@components/*`, `@assets/*`, `@constants/*`, `@utils/*`, `@i18n/*`, `@layouts/*`, `@/*` — all resolve under `src/`.

## Dependabot

Daily patch + minor npm updates, grouped. Major updates ignored.
