# Role: Build the Nheb Panha portfolio in Flutter

You are a senior Flutter developer. Recreate the existing **Nuxt 4** portfolio in this repository as a **Flutter app** that looks and behaves the same, runs on the web first (Flutter Web), and can also run on Android/iOS.

The Nuxt app is the **source of truth** for design, content and behaviour. Read the files listed in each section below before building that section. Do not invent content: copy text from the source files.

---

## 1. Project at a glance

| Item | Value |
| --- | --- |
| Owner | Nheb Panha, Flutter & Full-Stack Developer, Phnom Penh, Cambodia (UTC+7) |
| Current stack | Nuxt 4 (SPA, `ssr: false`), Vue 3, Tailwind CSS 3, `@nuxt/icon`, Supabase JS, Gemini API |
| Hosting | Cloudflare Workers with Static Assets (`wrangler.jsonc`, Worker name `panha`) |
| Server API | `server/api/chat.post.ts` (AI chat), `server/api/contact.post.ts` (contact form) |
| Database | Supabase, schema in `supabase_schema.sql` |
| Contact | Email `nhebpanha78@gmail.com` · GitHub `https://github.com/panhanheb` · Telegram `https://t.me/nhebpanha` (`@nhebpanha`) |
| Assets | `public/image/panha_portrait.jpg` (hero photo, 840×840), `public/logo_test.png` (white logo, shown on a dark tile) |

### Source file map

| Flutter piece | Read this Nuxt source |
| --- | --- |
| Design tokens, shared styles | `app/assets/css/main.css`, `tailwind.config.ts` |
| App shell, page order | `app/layouts/default.vue`, `app/pages/index.vue` |
| Header / navigation | `app/components/Header.vue` |
| Hero | `app/components/HeroSection.vue` |
| About | `app/components/About.vue` |
| Experience timeline | `app/components/WorkTimeline.vue` |
| Projects + details dialog | `app/components/Portfolio.vue`, data in `app/composables/useSupabase.ts` (`FALLBACK_PROJECTS`) |
| Skills | `app/components/Skills.vue` |
| Writing + article reader | `app/components/Blog.vue`, data in `useSupabase.ts` (`FALLBACK_BLOG_POSTS`) |
| Contact form | `app/components/ExperienceContact.vue` |
| Footer | `app/components/Footer.vue` |
| AI chat widget | `app/components/FloatingChat.vue` |
| Section heading | `app/components/SectionHeading.vue` |
| Scroll reveal | `app/composables/useScrollAnimate.ts` |
| SEO / head tags | `nuxt.config.ts` (`app.head`) |

---

## 2. Non-negotiable rules

1. **Never put secrets in the Flutter app.** Everything compiled into Flutter (web or mobile) can be read by users. The Gemini key, Telegram bot token and Supabase service-role key stay on the server. The app only calls `POST /api/chat` and `POST /api/contact` (see section 7).
2. **Keep content in one file** (`lib/data.dart`) so updating the site never means touching widgets.
3. **Match the current design** (section 4): one neutral scale plus one indigo accent, light and dark themes, calm and professional. No neon, glow or gradient text.
4. **No self-rated skill percentages and no invented metrics.** The current site removed them on purpose.
5. **No overflow at any width from 320px to 1440px+** (section 9). Every text in a `Row` must be able to shrink or wrap.
6. **Respect "reduce motion"** (`MediaQuery.disableAnimationsOf`): skip entrance animations when it is on.
7. Use **Material 3**, null safety, `const` constructors, and pass `flutter analyze` with zero issues.

---

## 3. Recommended Flutter setup

```
flutter create --platforms web,android,ios --project-name panha_portfolio --org dev.nhebpanha .
flutter pub add http url_launcher google_fonts shared_preferences
```

| Package | Use |
| --- | --- |
| `http` | Call `/api/chat` and `/api/contact` |
| `url_launcher` | GitHub, Telegram, `mailto:` links |
| `google_fonts` | Inter (UI) and JetBrains Mono (dates, small labels) |
| `shared_preferences` | Remember the light/dark choice (key `theme`, values `light`/`dark`) |

Suggested structure:

```
lib/
  main.dart            # MaterialApp, theme mode, ensureSemantics()
  home.dart            # single scrolling page, section keys, scroll-spy
  theme.dart           # Palette (ThemeExtension), buildTheme(), breakpoints
  data.dart            # ALL content: profile, jobs, projects, skills, posts
  api.dart             # /api/chat and /api/contact client
  widgets/common.dart  # PageContainer, Section, SectionHeading, AppCard, AppButton, TagChip, Reveal, ResponsiveGrid
  sections/            # header, hero, about, experience, projects, skills, writing, contact, footer, chat
test/
  overflow_test.dart   # renders every section at many sizes, fails on overflow
```

Gotcha seen with `google_fonts` 9 on Flutter 3.47: `GoogleFonts.interTextTheme(base.textTheme)` raised a `TextTheme` type mismatch. Set `fontFamily: GoogleFonts.inter().fontFamily` on `ThemeData` instead.

---

## 4. Design system (port from `main.css` + `tailwind.config.ts`)

### Colours

Implement as a `ThemeExtension<Palette>` so widgets read `context.pal.accent` etc.

| Token | Light | Dark | Used for |
| --- | --- | --- | --- |
| `bg` | `#FFFFFF` | `#09090B` | Page and card background |
| `surface` | `#F8FAFC` | `#141417` | Alternate sections, chip and icon-tile fill |
| `border` | `#E2E8F0` | `#27272A` | All 1px borders, dividers |
| `text` | `#0F172A` | `#F4F4F5` | Headings, primary text |
| `muted` | `#475569` | `#A1A1AA` | Body copy, labels |
| `accent` | `#4F46E5` (indigo-600) | `#818CF8` (indigo-400) | Buttons, eyebrows, links, active states |
| `accentStrong` | `#4338CA` | `#A5B4FC` | Primary button hover |
| `onAccent` | `#FFFFFF` | `#09090B` | Text/icons on accent (dark text in dark mode) |
| `success` | `#10B981` | `#34D399` | "Available" dot, success messages, checkmarks |

Default theme = the OS setting; the header toggle overrides it and is remembered.

### Typography (Inter)

| Element | Size / weight |
| --- | --- |
| Hero name | 60 (≥640px) / 46, w700, letter-spacing −1.6, height 1.05 |
| Hero role | 24 / 20, w500, muted |
| Section title | 36 (≥640px) / 30, w600, letter-spacing −0.8 |
| Section lead | 18 (≥768px) / 16, muted, height 1.6 |
| Eyebrow | 12, w600, UPPERCASE, letter-spacing ~1.7, accent |
| Card title | 16–18, w600 |
| Body / card text | 14–15, muted, height 1.6 |
| Chips | 12, w500, muted |
| Dates, "UTC+7" | JetBrains Mono 12, muted |

### Layout and components

- **Page container:** max width 1152px (72rem), centred, side padding 32px (≥640px) or 20px.
- **Section:** vertical padding 112px (≥768px) or 80px. "Alt" sections use the `surface` fill with top and bottom `border` lines. Sections alternate: About (alt), Experience, Projects (alt), Skills, Writing (alt), Contact.
- **Section heading:** eyebrow → 12px → title → 16px → lead (max width ~672px).
- **Card:** `bg` fill, 1px `border`, radius 16, padding 24. Interactive cards turn the border to `accent` at 40–45% opacity on hover (200ms).
- **Primary button:** accent fill, `onAccent` text 14 w500, radius 8, padding 20×12, hover to `accentStrong`. Optional trailing arrow that nudges right on hover.
- **Secondary button:** `bg` fill, 1px border, `text` colour, hover fill `surface`.
- **Chip:** `surface` fill, 1px border, radius 6, padding 10×4.
- **Filter pill:** fully rounded, 1px border; selected = `text` fill with `bg` text.
- **Text input:** radius 8, 1px border, focus = accent border plus a soft accent ring.
- **Breakpoints:** `sm` ≥640, `md` ≥768, `lg` ≥1024 (same as Tailwind).

### Motion

- **Reveal on scroll:** fade from 0 → 1 and slide up 12–16px, 600–700ms, ease-out-cubic (`Curves.easeOutCubic`), small stagger (60–90ms) between items. Only opacity and transform.
- **Hero:** animates immediately on load (it is always visible), not on scroll.
- **Portrait:** fades in once decoded (`Image.frameBuilder`), no pop-in.
- **Smooth scroll** to sections on nav click (~700ms, `Curves.easeInOutCubic`), offset by the 64px header.

Reveal pitfall seen before: checking visibility only once after the first frame (and then only on scroll) can leave content invisible if layout is still settling. Re-check on window-size changes (`didChangeMetrics`) and retry on the next frame until the widget has a size.

---

## 5. Page structure and section specs

Single scrolling page. A fixed header sits on top; the chat button floats bottom-right (24px from the edges).

Order: **Header → Hero → About → Experience → Projects → Skills → Writing → Contact → Footer**, plus the floating **Chat**.

### 5.1 Header (`Header.vue`)

- Height 64. Transparent at the top of the page; after scrolling >8px it becomes `bg` at ~94% opacity with a bottom border (animate 250ms). No backdrop blur (it is costly on Flutter Web).
- Left: logo (32×32 dark tile `#18181B`, radius 8, 4px padding, 1px border, `logo_test.png` inside) + "Nheb Panha" (15, w600). Tapping it scrolls to the top.
- Centre (≥1024px): links **About, Experience, Projects, Skills, Writing, Contact**. Active link = `text`, others `muted`. Wrap them in `FittedBox(fit: BoxFit.scaleDown)` inside an `Expanded` so they shrink instead of overflowing.
- Right: theme toggle (36×36 bordered icon button, `light_mode`/`dark_mode`), "Contact me" primary button (compact, 36px tall, hidden below 640px), menu button (below 1024px).
- Mobile menu: slides open under the bar (220ms `AnimatedSize`), lists the links plus a full-width "Contact me" button; active link in accent.
- **Scroll spy:** the active link is the last section whose top is ≤140px from the viewport top; at the very bottom, "Contact" is active. Throttle to once per frame.

### 5.2 Hero (`HeroSection.vue`)

- Padding top 160 / 128, bottom 112 / 80. Two columns at ≥1024px (7/5 split, 40px gap); stacked below that, with the portrait under the text.
- **Backdrop:** soft radial accent wash at top centre (14% opacity) + a faint 56px grid that fades out from the top centre. Draw it once with a `CustomPainter` inside a `RepaintBoundary`. Do **not** use blur filters.
- Pill: green dot + "Available for freelance and full-time roles".
- `h1` "Nheb Panha", role line "Flutter & Full-Stack Developer".
- Intro paragraph (max width ~576): copy from `HeroSection.vue`.
- Buttons: **View my work →** (scroll to Projects), **Get in touch** (scroll to Contact), GitHub icon button (opens `https://github.com/panhanheb`).
- Facts row (top border, 3 columns): Focus = *Mobile & Web*, Building since = *2022*, Core stack = *Flutter · Nuxt*.
- **Portrait card:** max width 384, square photo in a radius-24 frame with a 1px border and soft shadow, an outer ring 12px outside it (radius 28), and a location card hanging 20px below the photo: pin icon + "Phnom Penh, Cambodia" + mono "UTC+7".

### 5.3 About (`About.vue`), alt section

- Left (5/12 at ≥1024px): heading *About* / "Developer with an eye for detail and data", three paragraphs, then chips: Flutter, Dart, Nuxt, Vue, Laravel, Supabase, PostgreSQL, TypeScript.
- Right (7/12): 2×2 grid (1 column below 640px) of service cards. Each card has a 40×40 accent-tinted icon tile, a title and text: **Mobile apps**, **Web applications**, **Backends & APIs**, **Data & databases** (copy text from `About.vue`).

### 5.4 Experience (`WorkTimeline.vue`)

- Heading *Experience* / "Where I've worked" / "Roles across mobile, web and backend development, most recent first."
- Vertical timeline: 1px line, 13px dots (the newest role's dot in accent, the rest in `border`). At ≥768px the period sits in a 144px right-aligned column left of the line; on mobile it sits above the role.
- Each entry: role (18, w600) + type chip, "Company · Location", summary, bullet highlights, tech chips.
- Four entries (2025–Present, 2024–2025, 2023–2024, 2022–2023). **They are placeholders:** keep a `// TODO` and ask the owner for real roles before launch.

### 5.5 Projects (`Portfolio.vue`), alt section

- Heading *Projects* / "Selected work" / lead from `Portfolio.vue`. At ≥768px a search field (288px wide, "Search by name or technology") sits on the right of the heading; below that it sits under the heading.
- Filter pills: **All** + the distinct categories, in data order.
- Grid: 2 columns at ≥768px, otherwise 1. Rows share the tallest card's height.
- Card: top band (`surface`, bottom border) with a 48×48 icon tile, then category eyebrow, title, description (max 3 lines), tag chips, and a "View details →" link pinned to the bottom. The whole card is tappable.
- Search matches title, category, description and tag names (case-insensitive). Empty state: icon + "No projects found" + "Try a different search or category."
- **Details dialog** (max width 576): icon tile, category, title, full description, "Built with" chips, and **Live demo** / **Source code** buttons shown only when a real `http` link exists. Esc and a close button dismiss it.

Projects (from `FALLBACK_PROJECTS`):

| Title | Category | Tech | Suggested icon |
| --- | --- | --- | --- |
| RED ANT Express | E-Commerce | Flutter, Dart | `Icons.shopping_bag_outlined` |
| RED ANT Merchant | Merchant App | Flutter, Dart | `Icons.storefront_outlined` |
| RED ANT Driver | Delivery App | Flutter, Dart | `Icons.delivery_dining_outlined` |
| E-Shop Native | E-Commerce | Kotlin, Swift | `Icons.phone_iphone_outlined` |

Copy descriptions verbatim from `useSupabase.ts`. No store or GitHub links exist yet (TODO).

### 5.6 Skills (`Skills.vue`)

- Heading *Skills* / "Tools and technologies" / "The stack I use day to day, grouped by where it fits in a product."
- Grid: 3 columns at ≥1024px, 2 at ≥640px, else 1. One card per group (icon + title, then items with an optional right-aligned note), plus a **How I work** card with check icons.
- Groups: **Mobile** (Flutter *Primary*, Dart, BLoC & Riverpod, Firebase *Auth, FCM*), **Frontend** (Nuxt *Primary*, Vue 3, TypeScript, Tailwind CSS), **Backend** (Laravel *REST APIs*, Node.js & Express, Supabase *Auth, RLS*, Telegram Bot API), **Data** (PostgreSQL, MySQL, Redis), **Tooling** (Git & GitHub Actions *CI/CD*, Docker, Figma *Design to code*).
- How I work: copy the four statements from `Skills.vue`.

### 5.7 Writing (`Blog.vue`), alt section

- Heading *Writing* / "Notes and articles" / lead from `Blog.vue`.
- 3/2/1-column grid of cards: category eyebrow · date, title, 3-line summary, read time + "Read →".
- **Reader dialog** (max width 672): meta line, title, "By Nheb Panha", divider, body, divider, tag chips. The body is plain text where blocks are separated by a blank line and a line starting with `### ` is a sub-heading (a block can be `### Heading\nParagraph`).
- Three posts: copy title, category, date, read time, summary, content and tags from `FALLBACK_BLOG_POSTS` in `useSupabase.ts`.

### 5.8 Contact (`ExperienceContact.vue`)

- Left: heading *Contact* / "Let's work together" / lead. Three info cards: email with a **Copy** button (shows "Copied" for 2s), Telegram link, location "Phnom Penh, Cambodia (UTC+7)".
- Right: form card with **Name**, **Email** (2 columns at ≥640px), **What can I help with?** dropdown, **Message** (5 lines min). Limits: name 120, email 200, message 5000.
- Dropdown values → labels: `Mobile App Development` → "Mobile app (Flutter)", `Full-Stack Web Development` → "Web application (Nuxt / Vue)", `Backend / API` → "Backend or API", `Full-time Role` → "Full-time role", `General Inquiry` → "Something else".
- Client validation: all fields required, and the email must match `^[^\s@]+@[^\s@]+\.[^\s@]+$`.
- Button "Send message" → "Sending…" with a spinner. Success: "Thanks! Your message has been sent. I'll reply soon." and clear the fields. Error: show the server's `statusMessage`, else "Something went wrong. Please email me at nhebpanha78@gmail.com."
- Status box: green or red tinted, with a matching icon; announce it to screen readers (`Semantics(liveRegion: true)`).

### 5.9 Footer (`Footer.vue`)

- Top border, 32px vertical padding. "© {current year} Nheb Panha. All rights reserved." + links GitHub, Telegram, Email (`mailto:`).
- Use a `Wrap` (space-between) at ≥640px so it wraps instead of overflowing; stacked and centred on mobile.

### 5.10 Floating chat (`FloatingChat.vue`)

- 56px round accent button bottom-right (forum ↔ close icon, rotate/fade swap).
- Panel: width `min(360, screenWidth − 32)`, height `min(500, screenHeight − 120)`, radius 16, border, shadow.
- Header: accent-tinted bot icon, "Ask about Panha", green dot + "AI assistant · usually instant" (**must be `Flexible` with ellipsis**), close button.
- Quick chips: **Skills** → "What are Panha's main skills?", **Projects** → "What projects has Panha built?", **Experience** → "What is Panha's work experience?", **Availability** → "Is Panha available for new work?".
- Messages on a `surface` background; user bubbles in accent (right), assistant bubbles in `bg` with a border (left), labels "You" / "Assistant", typing indicator.
- Greeting: "Hi! I can answer questions about Panha's experience, projects and skills."
- Send on Enter or the send button. On failure show: "The assistant is unavailable right now. You can reach Panha through the contact form."

---

## 6. Data model (`lib/data.dart`)

Keep it plain Dart constants (no network needed to render the site):

```dart
class Job { String period, role, company, location, type, summary; List<String> highlights, tech; }
class Project { String title, category, description; IconData icon; List<String> tags; String? demoUrl, sourceUrl; }
class SkillGroup { IconData icon; String title; List<(String name, String? note)> items; }
class Post { String title, category, date, readTime, summary, content; List<String> tags; }
```

Plus profile constants: `ownerName`, `ownerRole`, `email`, `githubUrl`, `telegramUrl`, `telegramHandle`, `location`, `heroIntro`, `heroFacts`, `aboutParagraphs`, `coreStack`, `services`, `practices`.

Optional later: load projects and posts from Supabase with the **anon key** (public, read-only tables `projects` and `blog_posts` exist in `supabase_schema.sql`), falling back to the constants if the request fails. The Supabase URL in the current `.env` no longer resolves, so the constants are the reliable source today.

---

## 7. Backend API contract (keep server-side)

The Flutter app calls the **same origin** (`Uri.base.resolve('/api/...')`). For local development against another host, allow `--dart-define=API_BASE=http://localhost:3000`. Cross-origin calls need CORS, which the current server does not send.

### `POST /api/chat`

Request:

```json
{ "prompt": "Is Panha available?", "history": [ { "role": "user" | "model", "parts": [ { "text": "..." } ] } ] }
```

Response `200`: `{ "responseText": "..." }`

Server behaviour (see `server/api/chat.post.ts`): trims the prompt to 1000 characters and keeps the last 12 history items; Gemini (`gemini-2.5-flash`, then `gemini-flash-latest`) with the portfolio system prompt; canned keyword answers if Gemini is not configured or fails; logs to the Supabase table `chat_logs`.

### `POST /api/contact`

Request: `{ "name": "...", "email": "...", "type": "Mobile App Development", "message": "..." }`

- `200` → `{ "success": true, "supabaseSaved": bool, "telegramSent": bool }`
- `400` → `{ "statusCode": 400, "statusMessage": "Please provide a valid email address." }` (or the missing-fields message)
- `503` → `{ "statusCode": 503, "statusMessage": "Message could not be delivered right now. Please email me directly." }` when neither Supabase nor Telegram worked

Server behaviour (see `server/api/contact.post.ts`): validates and trims (name 120, email 200, type 80, message 5000), inserts into `contact_submissions`, sends a Telegram message with **HTML escaping**.

### Server secrets (never in Flutter)

`NUXT_GEMINI_API_KEY`, `NUXT_TELEGRAM_BOT_TOKEN`, `NUXT_TELEGRAM_CHAT_ID`, `NUXT_SUPABASE_SERVICE_ROLE_KEY`, plus `NUXT_PUBLIC_SUPABASE_URL` / `NUXT_PUBLIC_SUPABASE_ANON_KEY` (see `.env.example`). Set them in Cloudflare → Worker `panha` → Settings → Variables and Secrets.

If Nuxt is removed, replace these endpoints with a small dependency-free Cloudflare Worker (for example `api/index.ts`) that implements the same contract with `fetch` (Gemini REST `generateContent`, Supabase REST `/rest/v1/<table>`, Telegram `sendMessage`).

---

## 8. Web shell, SEO and accessibility (Flutter Web)

Flutter Web draws on a canvas, so search engines and link previews see little text. Compensate in `web/index.html`:

- Title "Nheb Panha — Flutter & Full-Stack Developer", the meta description, `og:title`, `og:description`, `og:image` (portrait), `twitter:card`, `theme-color`, `lang="en"`, favicon = the logo.
- A **plain-HTML summary** of the profile, projects, skills and contact links in a visually hidden `<main>` (and shown inside `<noscript>`).
- A **loading screen** in the theme colours (name, role, thin progress bar) that is removed on the `flutter-first-frame` event. Pick dark/light the same way the app will (the saved `flutter.theme` value in localStorage, else `prefers-color-scheme`).
- `robots.txt` allowing everything.
- In `main()`, call `SemanticsBinding.instance.ensureSemantics()` so screen readers and in-page search work.
- Use semantic hints: `Semantics(header: true)` on titles, button/link roles, tooltips on icon-only buttons, a `liveRegion` for the form status.

---

## 9. Overflow and responsive rules

- Never put unconstrained `Text` inside a `Row`: wrap it in `Expanded`/`Flexible`, with `maxLines` + `TextOverflow.ellipsis` for single-line labels.
- Prefer `Wrap` for chip lists, button groups, footer links and meta lines.
- Header nav: `Expanded` + `FittedBox(scaleDown)`.
- Card grids: rows wrapped in `IntrinsicHeight` with `CrossAxisAlignment.stretch` so cards align; use `Spacer` to pin "View details" / "Read" to the bottom.
- Dialogs: `maxHeight` = 90% of the screen, scrollable content, inset padding 16.
- Chat panel: clamp its width and height to the screen.

**Required test (`test/overflow_test.dart`):** pump the whole app at 320×568, 360×740, 390×844, 640×900, 768×1024, 1024×768, 1280×800 and 1440×900, in light and dark. Open the mobile menu, every project dialog, every article and the chat panel, and fail on any "overflowed" error, reporting the `lib/...dart:line`. In tests, disable `google_fonts` network fetching with a flag (e.g. `useWebFonts = false`) or the run crashes or hangs. The test font is wider than Inter, so passing it also covers users with larger system text.

---

## 10. Build and deploy (Cloudflare)

- `flutter build web --release` → `build/web`.
- `wrangler.jsonc`: `assets.directory = "./build/web"`, `run_worker_first: ["/api/*"]`, `not_found_handling: "single-page-application"`, and `main` pointing at the API worker.
- Cloudflare's build image (Ubuntu 24.04, x86_64) has `git`, `curl` and `unzip` but **no Flutter**. The build script must install a pinned Flutter (e.g. `git clone --depth 1 --branch 3.47.5 https://github.com/flutter/flutter.git`) before building. Keep the script's line endings LF (`.gitattributes`: `*.sh text eol=lf`).
- Local check: `npx wrangler dev`, then confirm `/` serves the Flutter app and `/api/chat` and `/api/contact` answer.

---

## 11. Acceptance checklist

- [ ] All sections from section 5 present, in order, with content copied from the Nuxt source
- [ ] Light and dark themes match the palette; the toggle is remembered
- [ ] Header scroll-spy, smooth scroll, mobile menu work
- [ ] Project search, filters and details dialog work; link buttons only appear for real links
- [ ] Article reader renders `###` sub-headings
- [ ] Contact form validates, shows server errors, and clears on success
- [ ] Chat works against `/api/chat` and shows a friendly error when it fails
- [ ] No secrets in the Flutter code or `web/` folder
- [ ] `flutter analyze` reports no issues and `flutter test` passes (including the overflow test)
- [ ] Reduced motion disables entrance animations
- [ ] `web/index.html` has the title, meta and OG tags, the HTML summary and the loading screen
- [ ] Deploys on Cloudflare; `/` = Flutter app, `/api/*` = API worker

## 12. Open items for the owner

- Real job history (the Experience entries are placeholders).
- Store, demo or GitHub links for RED ANT Express, Merchant, Driver and E-Shop Native.
- A working Supabase project (the current URL does not resolve), plus the Gemini key in Cloudflare.
