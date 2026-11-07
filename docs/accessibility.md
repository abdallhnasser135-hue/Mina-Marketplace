# Accessibility validation (WCAG 2.2 AA)

Target: WCAG 2.2 level AA for every MVP screen, in English and Arabic. This report separates what was **verified by tools today**, what is **specified in the design** and must be tested once it is built, and what **needs manual testing**. Nothing here claims a built product passes; there is no built product yet.

Status key: **V** verified by a tool in this phase · **S** specified in the design, to be tested in Phase 4/6 · **M** needs manual testing with people or assistive technology.

## 1. What was actually run

| check | tool | scope | result |
| --- | --- | --- | --- |
| Colour contrast | `contrast.py` (WCAG 2 formula) | 39 pairs from `tokens.json`: 30 text, 9 UI/focus | **0 failures.** Text: 18 pairs at AAA (7:1+), lowest 5.95:1. UI/focus: lowest 3.84:1 (needs 3:1). `validation/contrast.json` |
| Contrast defects found and fixed | same | dividers on the dark panel (2.22:1), placeholder text on the tinted ground | tokens corrected; placeholder colour rule added to `tokens.css` (the default grey fails 4.5:1 on `bg`) |
| Structural accessibility of the 6 boards | axe-core 4 on jsdom | landmarks, labels, names, roles, heading order, duplicate ids, language, table headers, aria validity | **0 violations** on all 6 boards. `validation/boards-lint.log` |
| RTL safety of the boards | custom lint | physical left/right CSS, 4-value radii, undefined tokens, raw hex | found and fixed 2 defects (physical corner radii on the List/Grid toggle; a physical `left:` offset); now **0 issues** |
| Token enforcement | Tailwind 3 build of `tailwind.config.ts` | token classes generate; off-scale spacing cannot be written | verified (`p-7` is not generated); physical utilities such as `ml-4` still exist in Tailwind, so Phase 4 needs the lint rule in `rtl-i18n.md` |
| Design vs architecture | `validate-design.py` | 48 screens vs `api.md`, `schema.sql`, `traceability.csv` | **PASS** with 6 documented API gaps |

**Limits of the automated checks:** jsdom has no layout engine, so axe's colour-contrast rule was not run on rendered pages (contrast was verified from tokens instead, and every colour combination used on the boards comes from a checked pair); I did not render, zoom or screenshot the boards in a real browser; no screen reader was used; no keyboard walkthrough has been performed because nothing interactive is built. Control sizes on the boards: 32 and 36 px appear on desktop-width rows (WCAG 2.2 minimum is 24 px; our touch rule of 44 px applies below 900 px and is specified in `components.md`).

## 2. Success criteria

### Perceivable

| SC | requirement | how the design meets it | status |
| --- | --- | --- | --- |
| 1.1.1 Non-text content | text alternatives | screenshots require `alt_i18n` per locale (admin cannot publish without it); decorative cover tiles `alt=""`; icons aria-hidden or labelled; charts have a text summary and table view | S |
| 1.2.1 to 1.2.5 Time-based media | captions, descriptions | product videos must have no audio or captions (admin publish check); GIFs get a still + play button; no autoplay with sound | S |
| 1.3.1 Info and relationships | structure in markup | landmarks, one h1, ordered headings, `<dl>` for facts, real tables with captions and scoped headers, fieldset/legend groups, lists for navigation | V (boards) / S |
| 1.3.2 Meaningful sequence | reading order | DOM order equals visual order; RTL by `dir`, never `row-reverse` | S |
| 1.3.3 Sensory characteristics | no "the red button" | instructions use names ("Buy now"), not colour or position | S |
| 1.3.4 Orientation | no lock | portrait and landscape supported | S |
| 1.3.5 Identify input purpose | autocomplete | `autocomplete` on name, email, current/new password, one-time code | S |
| 1.4.1 Use of colour | not colour alone | status = icon + word; links underlined in prose; selected = border + weight, not hue alone; charts labelled directly | S |
| 1.4.2 Audio control | none | no audio | S |
| 1.4.3 Contrast (minimum) | 4.5:1 / 3:1 | all token pairs pass (see §1) | **V** |
| 1.4.4 Resize text | 200% | rem-based type; layouts reflow; no fixed heights on text containers | M |
| 1.4.5 Images of text | none | text is live text; logo is an SVG with text alternative | S |
| 1.4.10 Reflow | 320 px / 400% zoom | mobile-first from 360 (design target 320 must also work); tables stack as description lists; code and file trees scroll in labelled containers | M |
| 1.4.11 Non-text contrast | 3:1 | input borders 3.84 to 4.61:1, focus ring 6.26 to 7.51:1, beacon on ink 7.95:1 | **V** |
| 1.4.12 Text spacing | user overrides | no fixed-height text boxes; line heights in rem | M |
| 1.4.13 Content on hover or focus | dismissible, hoverable, persistent | tooltips and popovers close with Esc, stay while hovered, appear on focus | S |

### Operable

| SC | requirement | how the design meets it | status |
| --- | --- | --- | --- |
| 2.1.1 Keyboard | everything operable | native elements first; ARIA patterns for tabs, dialogs, combobox, menus, tree; no drag-only action (media reorder has buttons) | S / M |
| 2.1.2 No keyboard trap | | dialogs trap focus legitimately and release on close; no other traps | M |
| 2.1.4 Character key shortcuts | | "/" focuses search only when no field is focused and is documented; can be disabled | S |
| 2.2.1 Timing adjustable | | order status polling stops with an explanation, never loses the order number; download links expire (security) and can be re-requested | S |
| 2.2.2 Pause, stop, hide | | no auto-playing motion except the one-time hero pass, which respects reduced motion | S |
| 2.3.1 Three flashes | | none | S |
| 2.4.1 Bypass blocks | | skip link first in every shell; landmarks | S |
| 2.4.2 Page titled | | unique `<title>` per route and locale | S |
| 2.4.3 Focus order | | matches visual order in LTR and RTL; focus moves to h1 after client navigation | S / M |
| 2.4.4 Link purpose | | link text meaningful out of context; product title is the link in rows | V (boards) / S |
| 2.4.5 Multiple ways | | navigation, search, category index, breadcrumbs, sitemap | S |
| 2.4.6 Headings and labels | | descriptive headings; visible labels on every field | V (boards) / S |
| 2.4.7 Focus visible | | 2px accent ring with 2px offset and halo; accent-on-ink on dark | S |
| 2.4.11 Focus not obscured (minimum) | | sticky header and mobile buy bar use `scroll-padding`; focused element never fully hidden | M |
| 2.5.1 Pointer gestures | | no path-based gestures; swipe has button equivalents | S |
| 2.5.2 Pointer cancellation | | actions fire on up-event (native behaviour) | S |
| 2.5.3 Label in name | | visible label text is contained in the accessible name (icon buttons with visible text keep it) | S |
| 2.5.4 Motion actuation | | none | S |
| 2.5.7 Dragging movements | | every drag has a single-pointer alternative (move up/down buttons) | S |
| 2.5.8 Target size (minimum) | 24 px | controls are 32 px minimum on desktop and 44 px on touch widths | V (boards sizes) / S |

### Understandable

| SC | requirement | how the design meets it | status |
| --- | --- | --- | --- |
| 3.1.1 Language of page | | `lang` and `dir` per locale on `<html>` | V (boards) / S |
| 3.1.2 Language of parts | | `lang` on mixed-language content, locale switch, user reviews | S |
| 3.2.1 / 3.2.2 On focus / on input | | filters apply on change only on desktop where the result count is announced; on mobile they apply via "Show results"; no unexpected navigation | S |
| 3.2.3 Consistent navigation | | one header, footer and shell per template | S |
| 3.2.4 Consistent identification | | one name per action across button, dialog and toast (vocabulary table) | S |
| 3.2.6 Consistent help | | Support and FAQ links in the same place in header and footer on every page | S |
| 3.3.1 Error identification | | errors in text next to the field and in a summary; `aria-live` | S |
| 3.3.2 Labels or instructions | | labels always visible; format hints and required states in text | V (boards) / S |
| 3.3.3 Error suggestion | | messages say how to fix ("Use at least 12 characters") | S |
| 3.3.4 Error prevention (legal, financial) | | cart shows total and terms before payment; refund request and key reveal confirm; order review before redirect | S |
| 3.3.7 Redundant entry | | checkout reuses account email; contact and ticket forms pre-fill for signed-in users | S |
| 3.3.8 Accessible authentication (minimum) | | no cognitive tests; paste allowed in password fields; password managers supported; email-link and one-time code options via the auth provider; Turnstile used for bots must be tested with assistive tech | S / M |

### Robust

| SC | requirement | how the design meets it | status |
| --- | --- | --- | --- |
| 4.1.2 Name, role, value | | native controls; ARIA only where no native element exists; states exposed (`aria-pressed`, `aria-current`, `aria-expanded`, `aria-selected`) | V (boards) / S |
| 4.1.3 Status messages | | live regions for result counts, price changes, copy confirmations, order status, toasts | S / M |

(4.1.1 Parsing was removed in WCAG 2.2.)

## 3. Phase 6 accessibility test plan

1. **Automated in a real browser:** axe-core through Playwright on every screen × {en, ar} × {360, 768, 1440} (this adds rendered colour-contrast and focus checks that jsdom could not run). Gate: zero serious or critical.
2. **Keyboard walkthroughs** (scripted): browse and filter, buy flow to the provider redirect, sign up, log in with MFA, library and download, reveal key (re-auth dialog), refund request, admin product editor, admin refund decision. In both directions of text.
3. **Screen readers:** NVDA + Firefox and VoiceOver + Safari (macOS and iOS), TalkBack on Android; Arabic pages must be read with an Arabic voice and Latin islands with an English voice.
4. **Zoom and spacing:** 200% and 400% zoom, WCAG text-spacing overrides, 320 px width.
5. **Preferences:** `prefers-reduced-motion`, Windows forced-colors mode (focus ring and borders must remain visible), 130% string expansion.
6. **People:** at least one round with users who rely on a screen reader or keyboard only, before launch.

## 4. Known risks to watch

- **Third-party widgets:** Turnstile and the payment provider's hosted page are outside our control; test them and provide a support path.
- **Markdown content** written by admins: headings and alt text discipline is enforced by the editor checks, not by the layout alone.
- **Arabic accessibility** depends on correct `lang`, `dir`, and `bdi` islands; the bidi test cases in `rtl-i18n.md` are part of this plan.
- **Colour roles will change in Phase 9:** re-run `contrast.py` after any palette change.
