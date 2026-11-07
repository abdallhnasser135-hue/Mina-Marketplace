# RTL / LTR and localization specification

Arabic is a first-class language, not a mirrored English layout. Locales: `en` (LTR) and `ar` (RTL). Everything here is a requirement for Phase 4 and a test target for Phase 6.

## 1. Principles

1. **Write directions logically, once.** No `left`/`right` anywhere in app CSS or Tailwind classes. The same markup serves both locales.
2. **Mirror layout, not content.** Page structure, navigation, icons that imply direction, and progress flow mirror. Code, hashes, versions, license keys, emails, URLs, file paths and numbers stay left-to-right.
3. **Arabic has its own typography.** Larger size, taller lines, no negative tracking, no all-caps equivalents (see tokens: `:lang(ar)` block).
4. **No hidden fallbacks.** If an Arabic translation is missing for product text, show the English text marked `lang="en"` with a small notice, never blank or machine-translated text.

## 2. Document setup

- URL prefix `/en/...` and `/ar/...`; `<html lang="ar" dir="rtl">` or `lang="en" dir="ltr"`; `hreflang` alternates and `x-default`; canonical per locale.
- Locale detection order: URL prefix, saved choice (signed-in: `users.locale`; guest: cookie, strictly functional), `Accept-Language`, default `en`. The visitor can always switch.
- LocaleSwitch label is the *other* language in its own script ("العربية" / "English") and carries its own `lang` attribute.
- Inline foreign-language text gets its own `lang` (English product names inside Arabic pages, Arabic reviews inside English pages).

## 3. Layout and CSS rules

| topic | rule |
| --- | --- |
| margins, padding, position | `ms-/me-/ps-/pe-/start-/end-`, `margin-inline`, `inset-inline`; lint rule forbids `ml- mr- pl- pr- left- right- text-left text-right rounded-l rounded-r border-l border-r` |
| alignment | `text-start` / `text-end`; never `text-left` |
| flex and grid | row direction follows `dir` automatically; never reverse with `row-reverse` to fake RTL |
| border radius | logical radii (`rounded-s`, `rounded-e`, `border-start-start-radius`); segmented controls use them |
| shadows and gradients | no directional shadows; no gradients, so nothing to flip |
| transforms and animation | slide-ins use `translateX` with a `--dir` multiplier (1 / -1); sheets from the bottom need none |
| background and object position | logical or centred; no `background-position: left` |
| scrollbars and horizontal scrollers | start at inline-start; the library tab strip scrolls the current tab into view |
| sticky columns | sticky panel stays at inline-end of the content (right in LTR, left in RTL) |
| z-order and overlays | toasts at bottom-end; drawers and popovers open toward inline-end and flip when clipped |
| aspect ratios and images | never mirrored (screenshots, logos, photos) |

## 4. What mirrors and what does not

| mirrors | does not mirror |
| --- | --- |
| header order (logo at inline-start), sidebars, filter rail position, breadcrumbs, tabs, pagination | product screenshots, GIFs, video, logo tower glyph |
| chevrons and arrows (back, next, breadcrumb separators, accordion carets pointing sideways), list/grid toggle order, progress bar fill direction, slider thumb order | magnifier, cart, heart, download, copy, check, close, plus, play/pause (media controls keep LTR order), clock |
| gallery thumbnail order and lightbox arrows, step order in OrderStatusStepper, timeline rule side | code, file trees, SHA-256, versions, license keys, URLs, emails, order numbers |
| table column order and header alignment | numeric columns' digits (tabular, LTR), chart time axis (see §9) |
| swipe and keyboard arrow semantics (ArrowRight moves backward in RTL for tabs and carousels) | brand wordmark in Latin, product names in Latin |

Icon rule: every icon in the set is classified `mirror` or `keep` in a single map in code (Phase 4) and tested; new icons must be classified before use.

## 5. Bidirectional text

- **LTR islands:** `.ltr-island` (`direction: ltr; unicode-bidi: isolate; text-align: start`) wraps code blocks, file trees, hashes, keys, emails, URLs, versions, order numbers, and file names inside RTL text. In inline use prefer `<bdi dir="ltr">`.
- **User-generated text** (reviews, tickets, names): `dir="auto"` on the element, and in lists each item is its own element so one item never reorders another.
- **Punctuation and quotes:** use locale quotation marks (EN “ ”, AR « » or “ ”) and the Arabic comma and semicolon (، ؛ ؟) in Arabic copy. Do not put a trailing Latin full stop after an LTR island at the end of an Arabic sentence; move the island or restructure the sentence.
- **Mixed strings with variables:** translators receive full sentences with named placeholders (`{product}`, `{version}`), never concatenated fragments. Placeholders that insert Latin text are wrapped in `<bdi>` by the formatter.
- **Lists of tags with Latin names inside Arabic UI:** each tag its own bdi.

## 6. Numerals, dates, currency

**Decision:** Western digits (0 to 9) in both locales for prices, versions, dates, counts, order numbers and codes. Reasons: unambiguous next to USD amounts, code and hashes; matches how Egyptian e-commerce and developer tools are usually read; avoids bidi surprises in mixed strings. A per-user "Arabic-Indic digits" setting is V2.

Formatting uses `Intl` with the `latn` numbering system forced:

```
Intl.NumberFormat('ar-EG-u-nu-latn', { style: 'currency', currency: 'USD' })   // 149 ... US$ in Arabic style
Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' })              // $149.00
Intl.DateTimeFormat('ar-EG-u-nu-latn', { dateStyle: 'medium', timeZone: user })  // 12 أكتوبر 2026
Intl.DateTimeFormat('en-GB', { dateStyle: 'medium' })                            // 12 Oct 2026
```

Currency display rule: `$149` in both locales in UI components (the symbol is part of an LTR island so it never swaps sides); formal documents (receipts, legal pages) use the locale's currency formatting. Dates use the visitor's time zone; times show the zone on first use.

## 7. Typography in Arabic

Sizes and line heights come from `tokens.json` `type.*.ar`: body 17/30, small 15/24, headings with tall lines (h1 44/64, mobile 32/48). Never negative letter-spacing, never `text-transform`, never justified text. Bold is limited to weights 600; avoid italic (use weight or colour-free emphasis). Line length 55 to 68 characters. Latin text inside Arabic paragraphs uses IBM Plex Sans via the font stack; baselines align because the families are designed together.

## 8. Forms and components

- Labels, hints and errors sit at inline-start; input text aligns to start; **email, URL, password, code and phone fields use `dir="ltr"`** (placeholder still aligns to start).
- Validation messages and required markers mirror; error icon at inline-start.
- Price range: Min then Max in reading order (right-to-left in Arabic), digits LTR.
- Sliders (if used) and progress bars fill from inline-start.
- Segmented controls, tabs, pagination and carousels mirror their order and arrow semantics.
- Tables mirror column order; numeric and money columns are `text-end` with tabular LTR digits; sort indicators are reordered consistently.
- Tooltips and popovers place themselves with logical placement (`start`, `end`).
- Search field icon at inline-start; keyboard shortcut hint is shown in an LTR island.

## 9. Charts

Layout, legend, panel order and card order mirror. **Time axes run left to right in both locales** (numbers and dates are read LTR and mixed-direction axes are confusing), with axis labels in the page language. Bar charts of categories list categories in reading order (right-to-left in Arabic). Every chart has a table view (which mirrors) and a text summary.

## 10. Content and data

- Content model: `*_translations` tables with `en` required and `ar` optional; admin shows completeness per product. Missing AR → English with notice (see principle 4).
- Sorting and search: sort names with `Intl.Collator(locale)`; Arabic search normalises diacritics (tashkeel), tatweel, alef forms (أ إ آ → ا), ya/alef maqsura and ta marbuta variants before indexing and querying; Postgres `simple` config with trigram, an upgrade path to Meilisearch/Typesense in V2.
- Email templates (receipts, reset, verification, support): each exists in both languages, are chosen by `users.locale`, set `dir`, and keep codes and links in LTR islands.
- Legal pages and license texts exist in both languages; the English text governs unless a lawyer decides otherwise.
- Slugs stay Latin; Arabic titles are never transliterated automatically.

## 11. Tests required (Phase 6)

1. Every screen renders in `ar` with no overflow at 360, 390, 768, 1024, 1440 px.
2. Pseudo-localisation: strings expanded 130% (EN) and Arabic with long words do not clip or overlap.
3. Bidi cases: product names in Latin inside Arabic sentences; a hash at the end of an Arabic sentence; a review mixing Arabic and English; an email address in a ticket.
4. Icon map: every icon is classified; directional icons mirror.
5. Keyboard: arrow keys in tabs, carousels and gallery follow RTL; focus order matches visual order.
6. Screen reader (NVDA/VoiceOver) reads Arabic pages in Arabic voice, and LTR islands in the correct language.
7. Forms accept Arabic names, show correct error placement, and email fields remain LTR.
8. Lint: no physical-direction classes or CSS in the codebase.
