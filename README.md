# archive-theme

A bilingual Hugo theme for film and video archive exhibitions. Inspired by the layout tradition of [Ananke](https://themes.gohugo.io/themes/gohugo-theme-ananke/) — a bold image-banner header, clean article content, and a minimal card grid for the collection — but purpose-built for archive sites that want locally-hosted video, structured metadata, and EN / 中文 (Chinese) language switching.

**Minimum Hugo version:** `0.128.0` (extended recommended for SCSS but not required).

---

## 目录 · Contents

1. [Quick start · 快速开始](#quick-start--快速开始)
2. [Directory structure · 目录结构](#directory-structure--目录结构)
3. [Configuration · 配置参数](#configuration--配置参数)
4. [Page front matter · 页面前置数据](#page-front-matter--页面前置数据)
5. [Adding a collection item · 添加一部藏品](#adding-a-collection-item--添加一部藏品)
6. [Shortcodes · 正文插件](#shortcodes--正文插件)
7. [Customizing styles · 自定义样式](#customizing-styles--自定义样式)
8. [i18n · 文案字符串](#i18n--文案字符串)
9. [Deployment · 部署](#deployment--部署)
10. [FAQ](#faq)

---

## Quick start · 快速开始

### English

```bash
# 1. Clone or copy this repo somewhere
git clone https://github.com/yourname/archive-theme.git

# 2. Use the exampleSite as the starting point for your own site
cp -r archive-theme/exampleSite my-archive-site
cd my-archive-site

# 3. Link the theme
mkdir -p themes
ln -s ../../archive-theme themes/archive-theme
# (or: cp -r ../archive-theme themes/archive-theme)

# 4. Run the dev server
hugo server
```

Open http://localhost:1313/ — you'll see the site running with the sample content. Edit any `.md` file in `content/` and the page reloads automatically.

### 中文

```bash
# 1. 克隆本主题
git clone https://github.com/yourname/archive-theme.git

# 2. 把 exampleSite 作为你网站的起点
cp -r archive-theme/exampleSite my-archive-site
cd my-archive-site

# 3. 连接主题
mkdir -p themes
ln -s ../../archive-theme themes/archive-theme

# 4. 运行开发服务器
hugo server
```

打开 http://localhost:1313/ ——你会看到带示例内容的站点。编辑 `content/` 下任何 `.md` 文件，页面会自动刷新。

---

## Directory structure · 目录结构

```
my-archive-site/
├── hugo.toml                   # Site config
├── content/
│   ├── _index.en.md            # English home
│   ├── _index.zh.md            # Chinese home
│   ├── about/
│   │   ├── _index.en.md
│   │   └── _index.zh.md
│   ├── history/
│   ├── collection/
│   │   ├── _index.en.md
│   │   ├── _index.zh.md
│   │   └── <film-slug>/
│   │       ├── index.en.md     # English version of this film
│   │       └── index.zh.md     # Chinese version
│   ├── access/
│   └── contact/
├── static/
│   ├── images/                 # All image files go here
│   └── videos/                 # All video files go here
├── assets/                     # Optional overrides
│   └── css/
│       └── custom.css          # Your style overrides (no need to touch the theme)
└── themes/
    └── archive-theme/          # The theme itself — don't edit, configure via hugo.toml
```

**Key rule · 关键规则:** translations are matched by **filename suffix** (`.en.md`, `.zh.md`), not by directory. Do **not** set `contentDir` per language — Hugo will find both languages automatically.

---

## Configuration · 配置参数

All site-level config is in `hugo.toml` at the site root. Every field explained:

### Top-level

| Key | Purpose |
|---|---|
| `baseURL` | Your site's URL. Use `/` during development. |
| `title` | Default site title (fallback if a language doesn't set its own). |
| `theme` | Must be `"archive-theme"`. |
| `defaultContentLanguage` | Which language is default. Usually `"en"`. |
| `defaultContentLanguageInSubdir` | Set `false` so the default language lives at `/`, not `/en/`. |

### `[languages.xx]` blocks

One block per language. Recommended fields:

| Key | Purpose |
|---|---|
| `languageName` | Label on the EN / 中文 toggle (e.g. `"EN"`, `"中文"`). |
| `weight` | Order (smaller = left). |
| `title` | Site title for that language (shown in header + browser tab). |

**Do NOT set `contentDir`** — this theme uses filename-based translations. Setting `contentDir` will break things.

### Menus: `[[languages.xx.menus.main]]`

One block per menu item. Use `pageRef` (not `url`) so Hugo can track active states:

```toml
[[languages.en.menus.main]]
  name = "About"
  pageRef = "/about"
  weight = 10
```

| Key | Purpose |
|---|---|
| `name` | Button label |
| `pageRef` | Path to the content page (`/about`, `/collection`, etc.) |
| `weight` | Sort order (smaller = left) |

### `[params]`

| Key | Default | Purpose |
|---|---|---|
| `banner_image` | — | Default banner background image for every page. Override per-page by setting `banner_image` in that page's front matter. Leave empty for the solid fallback color. |
| `showRecentOnHome` | `false` | If `true`, show up to 6 recent collection items on the home page. |
| `author` | — | Shown next to the copyright in the footer. |

### `[markup.goldmark.renderer]`

Keep `unsafe = true` so you can use raw HTML inside Markdown (e.g. `<em>` in titles).

---

## Page front matter · 页面前置数据

Every page supports these fields in its front matter (the block between `---` lines at the top):

| Field | Purpose |
|---|---|
| `title` | Page title (also used in browser tab). |
| `description` | Meta description + card description on the collection grid. |
| `banner_title` | Big heading shown in the banner. Defaults to `title` if omitted. |
| `banner_subtitle` | Subtitle line under the banner title. Optional. |
| `banner_image` | Background image for **this page's** banner. Overrides the site default. Optional. |
| `draft` | `true` to hide the page during build. |
| `date` | Publication date (used for sorting). |

### How to change the site title or the home page big title

- **Site title** (header brand + browser tab): edit `title` under `[languages.en]` / `[languages.zh]` in `hugo.toml`.
- **Home page big banner title**: edit `banner_title` in `content/_index.en.md` and `content/_index.zh.md`.

Wanting `"A Gauge of the Forgotten Past — Bringing 8.75mm Back To Light"` ? Change `banner_title` in `_index.en.md`. Done. No theme code to touch.

---

## Adding a collection item · 添加一部藏品

### Option 1 — manual

1. Create a folder under `content/collection/`:
   ```
   content/collection/my-new-film/
   ```
2. Inside, create two files: `index.en.md` and `index.zh.md`
3. Use this template:

```yaml
---
title: "My New Film"
banner_title: "My New Film"
banner_subtitle: "Documentary · 1978 · 22 min"
description: "Short card description."

year:      "1978"
genre:     "Documentary"
gauge:     "8.75mm · single perf"
color:     "Color"
sound:     "Sound"
duration:  "22 min"
condition: "Good; minor edge wear."
access:    "Short excerpt available"

thumbnail: "/images/my-film-thumb.jpg"
video:     "/videos/my-film.mp4"
poster:    "/images/my-film-poster.jpg"
---

Description of the film in Markdown...

## Provenance

Where it came from...

{{< figure src="/images/my-film-still.jpg" caption="A still from the film." >}}
```

### Option 2 — using `hugo new`

```bash
hugo new collection/my-new-film/index.en.md
hugo new collection/my-new-film/index.zh.md
```

Then fill in the fields and remove `draft: true`.

### Metadata fields (all optional — empty fields don't render)

| Field | Example |
|---|---|
| `year` | `"1974"` or `"c. 1970s"` |
| `genre` | Documentary / Newsreel / Educational / Narrative Feature |
| `gauge` | `"8.75mm · single perf"` |
| `format` | Alternative to `gauge` |
| `color` | `"Color"`, `"Black & white"`, `"Color (faded to red)"` |
| `sound` | `"Sound"`, `"Silent"`, `"Magnetic sound"` |
| `duration` | `"18 min"` |
| `condition` | Free text |
| `access` | `"Stills only"`, `"Short excerpt available"`, `"Metadata only"` |
| `thumbnail` | Image used on the collection card grid |
| `video` | Path to local video file (usually `/videos/xxx.mp4`) |
| `poster` | Poster image shown before the video plays |
| `video_type` | MIME type, default `video/mp4`. Use `video/webm` for WebM. |

---

## Shortcodes · 正文插件

Three shortcodes are provided for inserting media without breaking page layout. All of them are **centered**, **size-limited**, and **don't break out of the article column** unless you explicitly ask.

### `figure` — centered image

```
{{</* figure src="/images/projector.jpg" caption="A projector from the 1970s." */>}}

{{</* figure src="/images/panorama.jpg" size="wide" */>}}
```

| Param | Default | Purpose |
|---|---|---|
| `src` | (required) | Image path. Put image files in `static/images/` and reference them as `/images/xxx.jpg`. |
| `caption` | — | Caption shown below (supports Markdown). |
| `alt` | `caption` | Alt text for accessibility. |
| `size` | `medium` | `small` (320px) / `medium` (560px) / `large` (prose full width) / `wide` (up to 960px, breaks out of prose column) |
| `link` | — | Wrap the image in a link. |

### `video` — local video player

```
{{</* video src="/videos/excerpt.mp4" poster="/images/poster.jpg" caption="Film excerpt" */>}}
```

| Param | Default | Purpose |
|---|---|---|
| `src` | (required) | Video path. Put videos in `static/videos/`. |
| `poster` | — | Image shown before play. |
| `type` | `video/mp4` | MIME type. Use `video/webm` for WebM. |
| `caption` | — | Caption below the player. |
| `controls` | `true` | Set `"false"` to hide browser controls. |
| `autoplay` | — | `"true"` to autoplay (requires `muted="true"` in modern browsers). |
| `muted` | — | `"true"` to mute audio. |
| `loop` | — | `"true"` to loop. |

### `gallery` — square-grid image set

```
{{</* gallery */>}}
/images/still-1.jpg
/images/still-2.jpg
/images/still-3.jpg|Caption for still 3
{{</* /gallery */>}}
```

Each line is one image path. Append `|alt text` for accessibility.

### Plain Markdown images

You can also just write `![alt](/images/x.jpg)` — the theme auto-centers it and limits its width. No shortcode needed.

---

## Customizing styles · 自定义样式

**Do not edit theme files directly** — updating the theme later will overwrite your changes. Instead, create `assets/css/custom.css` at your **site root**:

```
my-archive-site/
└── assets/
    └── css/
        └── custom.css   ← your overrides live here
```

The theme auto-detects this file and loads it after the main stylesheet, so your rules win.

### Change colors

All colors are CSS variables. Write any of these to override:

```css
:root {
  /* Banner */
  --banner-fallback-bg: #1d4e4f;       /* solid color when no image */
  --banner-overlay:     rgba(20,30,40,0.55);  /* dark layer over banner image */
  --banner-ink:         #ffffff;        /* banner text color */
  --banner-accent:      #e7c000;        /* bottom border color */

  /* Page */
  --bg:        #ffffff;
  --ink:       #222222;
  --ink-2:     #555555;
  --ink-3:     #888888;
  --rule:      #e5e5e5;
  --link:      #1d4e4f;
}
```

### Change fonts

```css
:root {
  --font-sans: 'Inter', sans-serif;
  --font-zh:   'Source Han Sans SC', sans-serif;
}
```

(You'll need to load the font in `head.html` via a custom partial override — or use a `@import url(...)` inside your `custom.css`.)

### Darker overlay on the banner

If your banner image is very bright:

```css
:root {
  --banner-overlay: rgba(0, 0, 0, 0.7);
}
```

### Full dark mode

```css
:root {
  --bg:        #111111;
  --bg-soft:   #1a1a1a;
  --ink:       #f5f5f5;
  --ink-2:     #aaaaaa;
  --ink-3:     #777777;
  --rule:      #2a2a2a;
  --link:      #8ec9ca;
}
```

---

## i18n · 文案字符串

UI labels like "Year", "Duration", "Recent additions" live in `themes/archive-theme/i18n/en.toml` and `zh.toml`.

To override a label in your site without touching the theme, create `i18n/en.toml` (and `zh.toml`) in your site root:

```toml
# my-archive-site/i18n/en.toml
[meta_year]
other = "Date of release"

[footer_tagline]
other = "My Custom Archive — Research only"
```

Site-level `i18n/` takes precedence over the theme's.

---

## Deployment · 部署

### GitHub Pages (auto)

This repo includes `.github/workflows/deploy.yml` — copy it into your site repo's `.github/workflows/` and enable GitHub Pages → "GitHub Actions" as the source. Your site will build + deploy on every push to `main`.

### Netlify / Vercel / Cloudflare Pages

- Build command: `hugo --minify`
- Publish directory: `public`
- Environment: `HUGO_VERSION = 0.128.0` (or newer)

### Your own server

```bash
hugo --minify
rsync -avz --delete public/ user@server:/path/to/web/root/
```

---

## FAQ

**Q: The language toggle takes me to the home page instead of the translated page.**  
A: Hugo couldn't find a translation. Make sure both `index.en.md` and `index.zh.md` exist for that page.

**Q: My banner image isn't showing.**  
A: Make sure it's in `static/images/` and referenced as `/images/filename.ext` (note the leading slash). Also check it exists on the published site at that URL.

**Q: I get `no such function` or template errors.**  
A: Upgrade Hugo. Minimum supported is `0.128.0`. Run `hugo version` to check.

**Q: I want to keep all content in one language folder.**  
A: This theme uses Hugo's **filename-based translations** (`.en.md` / `.zh.md`). You keep all files in the same `content/` tree. If you want separate folders per language, you'd need to set `contentDir` per language — but do not do this with this theme, it'll break the menus.

**Q: Can I add a third language (e.g. French)?**  
A: Yes. Add `[languages.fr]` with `languageName`, `weight`, `title` in `hugo.toml`, add `fr` menu items, create `_index.fr.md` versions of your content, and create `i18n/fr.toml`. The language toggle will auto-render all three.

**Q: I want to remove the banner image entirely and have just a solid color.**  
A: Remove `banner_image` from both `[params]` in `hugo.toml` and the page's front matter. The banner falls back to `--banner-fallback-bg` (a solid color, configurable via CSS variable).

**Q: How do I hide the banner on a specific page?**  
A: This theme always renders the banner. To hide it on one page, create a copy of `themes/archive-theme/layouts/_default/baseof.html` at `layouts/_default/baseof.html` in your site root and conditionally skip the `partial "banner.html"` call.

---

## License

MIT — see [LICENSE](./LICENSE). Free to use, modify, and redistribute.

## Contributing

Issues and pull requests welcome at [github.com/hw4090-create/archive-theme-hugo](https://github.com/hw4090-create/archive-theme-hugo).

## Author contact
Email: haoran020513@gmail.com
