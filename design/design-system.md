# Design system: working codename "Mina" (مينا)

Phase 3 output. "Mina" is a **placeholder** (Arabic for "harbour"), not a name recommendation; Phase 9 chooses and checks the real name. All colour *values* are provisional until Phase 9; role names are fixed (see `tokens.json`). Companion files: `components.md`, `screens.md`, `rtl-i18n.md`, `accessibility.md`, `tokens.json`, `tokens.css`, `tailwind.config.ts`, live boards (link in `design-report.md`).

## 1. Who and what

**Audience:** developers, technical founders, agencies and students buying source code, AI projects, security tools and SaaS templates, often $40–$500, often from a seller they have never heard of. Many read Arabic first, many read English first, some switch.

**The core job:** let a technical buyer decide in a couple of minutes, with confidence, that a download is what it claims to be.

**The trust problem is specific.** Buyers cannot try code before paying. They worry about: what exactly is inside, whether it is safe, whether it is maintained, what they may legally do with it, and whether they can get their money back. The design answers those five questions on the listing itself, in plain view.

## 2. Concept: the inspected listing

Visual language borrowed from sea charts and technical drawings: a pale sea-glass ground, deep harbour ink, hairline structure, and a single light. On charts, lights and aids to navigation are marked in magenta. We use that one colour, sparingly, for **action** and for **verification**.

The memorable thing is the **manifest**: a compact ink panel that shows a listing's contents tree, license, scan status, version and checksum. It is the hero of the home page and the purchase panel of every product page. Everything around it stays quiet.

### Principles

1. **Show the contents.** No buy button without the manifest nearby.
2. **One lit mark.** Magenta means "act" or "verified" and nothing else. If everything is magenta, nothing is.
3. **Structure carries meaning.** Rules, tone steps and alignment replace cards and shadows. Results are rows you can compare, not a wall of identical tiles.
4. **Calm and exact.** No gradients, no ambient shadows, no motion that does not answer an action.
5. **Two languages, one logic.** Every layout is written in logical directions. Arabic gets its own sizes, line heights and tracking, not a mirrored English design.
6. **Say only what the system does.** Interface claims map to real features: scan status, checksum, versions, license text, refunds, verified purchases. No claim is made that the platform does not implement.

### Review against the generic defaults (done before building)

| first instinct | why it was rejected | what replaced it |
| --- | --- | --- |
| Teal with an amber accent | the default "tech with a warm highlight" palette | chart-light magenta on harbour ink and sea-glass; magenta rarely seen in developer marketplaces and tied to the lighthouse/harbour story |
| Inter everywhere | the reflex choice, weak Arabic pairing | IBM Plex Sans + IBM Plex Sans Arabic (designed as a family) + Plex Mono for code |
| A grid of rounded product cards | the SaaS card kit; hides comparison | **list rows with a spec column** as the default view; tiles only for featured items and the optional grid view |
| A dark hero with a big stat | fake-authority default; there are no real stats yet | a light hero with a real **inspection** manifest |
| Soft grey shadow under everything | the second tell | borders and tone steps; shadow only on floating layers |
| Eyebrow labels, numbered markers, all caps | template chrome | sentence-case headings; numbering only in the order-status stepper, which is a real sequence |

What we deliberately avoid: gradient washes, identical card grids, shadows under static surfaces, all-caps labels, middle-dot meta strings, arrows appended to every link, decorative icons, stock photos, and invented statistics.

## 3. Colour

All values live in `tokens.json`; `build-tokens.py` generates `tokens.css`. Use roles, never hex.

| role | value | job |
| --- | --- | --- |
| bg | #F1F5F4 | page ground (sea-glass) |
| surface | #FFFFFF | panels, forms, headers |
| surface-sunken | #E5ECEA | wells, tags, table headers |
| border | #D0DBD8 | decorative dividers and panel edges |
| border-input | #66787F | control edges (meets 3:1) |
| text | #0F2430 | body and headings |
| text-muted | #43565F | secondary text, placeholders |
| accent | #A3105F | the beacon: primary action, links, selected state, focus ring |
| accent-hover | #830D4C | pressed/hover for accent |
| on-accent | #FFFFFF | text on accent |
| accent-subtle / on-accent-subtle | #F8E4EE / #7A0B46 | quiet highlight (selected row, notice) |
| ink / ink-raised | #0B2230 / #12303F | inspection surfaces: manifest, file tree, code, admin sidebar |
| on-ink / on-ink-muted | #FFFFFF / #B4C7CF | text on ink |
| accent-on-ink | #FF93C4 | beacon on ink (verified mark, focus on ink) |
| border-on-ink | #648596 | dividers on ink (meets 3:1) |
| focus-ring | #A3105F | keyboard focus |
| success, warning, danger, info (+ subtle and on-subtle) | see tokens | status; never colour alone |

**Accent budget:** at most one filled accent button per screen region, accent links in running text, and the beacon glyph. Status colours are always paired with an icon and a word.

**Surface hierarchy:** bg → surface (a panel sits on the ground and is separated by a 1px border) → surface-sunken (wells inside panels). Ink is reserved for things that are being *inspected* (manifest, code, file tree) and for the admin sidebar.

**Contrast:** 39 pairs checked with `contrast.py`, 0 failures: 30 text pairs (18 reach AAA 7:1; lowest 5.95:1) and 9 UI/focus pairs (lowest 3.84:1, minimum 3:1). See `contrast-report.txt` and `accessibility.md`. Dark mode is out of MVP (roles are ready for it).

## 4. Typography

Families (all SIL Open Font License, self-hosted, latin + arabic subsets): **IBM Plex Sans**, **IBM Plex Sans Arabic**, **IBM Plex Mono** (code, file trees, hashes, versions, license keys, order numbers). One superfamily keeps both scripts in the same voice; hierarchy comes from size, weight and spacing rather than a second display face.

| step | EN px/line | AR px/line | weight | use |
| --- | --- | --- | --- | --- |
| display | 64/68 (mobile 38/44) | 62/88 (mobile 38/57) | 600, -0.025em | home hero only |
| h1 | 44/50 (mobile 32/38) | 44/64 (mobile 32/48) | 600, -0.02em | page titles |
| h2 | 32/40 (mobile 26/34) | 33/50 (mobile 26/39) | 600 | section titles |
| h3 | 24/32 | 25/38 | 600 | subsections |
| h4 | 20/28 | 21/32 | 600 | panel titles, row titles |
| body-lg | 18/28 | 19/32 | 400 | lead paragraphs |
| body | 16/26 | 17/30 | 400 | default |
| small | 14/20 | 15/24 | 400 | meta, helper text |
| caption | 12/16 | 13/20 | 500 | tags, table headers (never all caps) |
| code | 14/22 | 14/22 | 400 mono | code, hashes |

Rules: sentence case everywhere; Arabic never uses negative tracking and never `text-transform`; line length 60 to 72 characters (`max-width: 68ch`); weight 700 only for numerals in KPI tiles; tabular numerals (`.num`) for prices, versions and table columns; text never below 12px (13px Arabic).

## 5. Spacing, grid and layout

Scale (Tailwind numbering, key × 4 = px): 1=4, 2=8, 3=12, 4=16, 5=20, 6=24, 8=32, 10=40, 12=48, 16=64, 20=80, 24=96, 32=128. Tailwind's default scale is replaced so off-scale values cannot be written.

| breakpoint | width | columns / gap | gutter |
| --- | --- | --- | --- |
| base (mobile) | 360+ | 4 / 16 | 16 |
| sm | 600+ | 8 / 24 | 24 |
| md | 900+ | 12 / 24 | 32 |
| lg | 1200+ | 12 / 24 | 32 |
| xl | 1440+ | 12 / 24 | 40 |

Container 1280. Header 56 (mobile) / 64. Filter rail 280. Manifest panel 392. Customer sidebar 240. Admin sidebar 248 (collapsed 64). Mobile buy bar 72 to 88 plus safe-area inset. Controls: sm 32, md 40, lg 48; **44 minimum touch target** on touch widths.

### Page templates (all screens use one of these)

1. **Storefront**: header, full-width bands, 12-col content, footer (W01, W08 to W17).
2. **List + rail**: left filter rail (280), results column; below 900 the rail becomes a bottom sheet (W02 to W04, C07, C09, M02 and other admin lists use a variant without rail).
3. **Product**: 8-col content + sticky manifest purchase panel (392); below 900 the panel becomes an in-flow section plus a sticky bottom buy bar (W05).
4. **Account shell**: 240 sidebar + content; below 900 the sidebar becomes a horizontally scrolling tab strip (C06 to C14).
5. **Admin shell**: 248 ink sidebar + fluid content with a top bar; below 900 the sidebar becomes a drawer (M01 to M17).
6. **Focused form**: single 440 column on a plain ground, no site navigation (C01 to C05).
7. **Prose**: 68ch column with in-page contents (W08, W09, W11 to W14, W16).

## 6. Shape, elevation, borders, motion

Radius encodes role: tags 4, controls 8, media 8, panels 12; never one radius for everything; full-bleed bands are square. Separation uses 1px `border` and tone, not shadow. Shadow exists only on layers that float: popover and dialog (`overlay`), bottom sheet (`sheet`), toast.

Motion: 120/200/320 ms, one easing curve, only in response to a user action (open, expand, confirm, copy). One permitted ambient moment: a single-pass "inspection" highlight over the manifest rows on the home hero, once, 600 ms. `prefers-reduced-motion` removes all transitions and that pass.

## 7. Iconography

Lucide (ISC licence), 20px, 1.5px stroke, `currentColor`. Two custom glyphs drawn for the brand: the **tower mark** (placeholder logo) and the **beacon** (a point with two arcs), which means "checked by us": malware scan clean, license valid, verified purchase. Never use the beacon as decoration. Directional icons mirror in RTL (see `rtl-i18n.md`). Icon-only buttons always carry an accessible name.

## 8. Imagery and covers

Real screenshots and short GIF/video previews only, framed with a 1px border and 8px radius, 16:10, with required `alt` text in each locale (`product_media.alt_i18n`). No stock photography, no generated illustrations. Products without a strong cover use the **cover tile**: ink tile, 2 to 3 letter stack mark in 600 weight, 4:3. A cover tile is a fallback, not a design flourish.

## 9. Content and voice

Plain verbs, active voice, sentence case, no filler. A button names the exact result: "Buy now", "Add to cart", "Download 2.5.0", "Reveal key". The same action keeps its name across button, dialog and toast ("Reveal key" → "Key revealed").

| thing | EN | AR |
| --- | --- | --- |
| buy | Buy now | اشترِ الآن |
| cart | Add to cart | أضِف إلى السلة |
| download | Download 2.5.0 | تنزيل 2.5.0 |
| key | Reveal key | إظهار المفتاح |
| refund | Request a refund | طلب استرداد |
| scan | Malware scan: clean | فحص البرمجيات الخبيثة: نظيف |
| verified | Verified buyer | مشترٍ موثّق |

Errors say what happened and what to do, without apologizing ("The download link expired. Request a new one."). Empty states invite the next action ("You have not bought anything yet. Browse projects."). Arabic is Modern Standard Arabic in a plain, direct register. **All Arabic strings in this package are drafts and need review by a native Arabic speaker before launch.**

## 10. Data patterns

- **Price:** `$149`, USD, tabular numerals, always with "One-time payment in USD" near the buy button.
- **Dates:** `12 Oct 2026` (EN), `12 أكتوبر 2026` (AR). Western digits in both locales (see `rtl-i18n.md`).
- **Versions** in mono with the release date in the facts list; the current version is labelled, yanked versions are struck through with a reason.
- **Checksums:** SHA-256, middle-truncated (`9f3a8c…c41e`) with a copy button that copies the full value; always inside an LTR island.
- **File sizes:** binary units (KB, MB) with one decimal.
- **Rating:** number first ("4.8 from 31 verified buyers"); stars are an ink glyph, never the only signal.
- **Status:** icon + word + subtle fill, e.g. Paid, Refund requested, Flagged, Pending review.

## 11. Trust patterns (where each claim appears)

| claim | shown as | backed by |
| --- | --- | --- |
| Contents known | file tree in manifest | `product_versions.contents` (addendum G1) |
| Scanned | beacon "Clean" | `product_files.scan_status = clean`; downloads blocked otherwise |
| Not tampered | SHA-256 with copy | `product_files.sha256` |
| Maintained | version, date, changelog | `product_versions` |
| Legal use is clear | license summary + full text before purchase | `license_templates`, `product_editions` |
| Real buyers | "Verified buyer" label | `reviews.entitlement_id` NOT NULL |
| Money back | refund policy link next to Buy | refund policy page + `refunds` |

## 12. Governance

`tokens.json` is the single source of truth. Phase 9 may change **values** only, then re-run `python3 contrast.py tokens.json` and `python3 build-tokens.py`. New colour roles require a contrast pair. Components never use raw hex or off-scale spacing. Adding a component means adding its block to `components.md` first.
