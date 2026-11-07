# Phase 3 completion report: design

Date: 2026-11-06 · Inputs: `architecture.md`, `api.md`, `schema.sql`, `traceability.csv` · Live visual boards: https://claude.ai/artifact/VQRGvsXdsPA6DMEbeqvobo (private to you until you share it)

## 1. What was delivered

| deliverable | file | status |
| --- | --- | --- |
| Design system (concept, principles, colour, type, layout, shape, motion, icons, imagery, voice, trust patterns) | `design-system.md` | complete |
| Design tokens (source of truth) | `tokens.json`, generated `tokens.css`, `tailwind.theme.json`, `tailwind.config.ts`, generator `build-tokens.py` | complete, verified |
| Colour palette and contrast | `tokens.json`, `contrast-report.txt` | 39 pairs, 0 failures |
| Typography system (EN + AR) | `design-system.md` §4, `tokens.json` | complete |
| Spacing and layout rules, templates, breakpoints | `design-system.md` §5 | complete |
| Component specifications | `components.md`: 60+ components with variants, sizes, states, a11y, RTL, used-on | complete (specified, not built) |
| MVP screens | `screens.md`: all 48 screens specified (layout, mobile behaviour, states, notes) | complete as specification |
| Visual screen designs | live canvas: **6 boards** (Home, Catalog, Product desktop EN, Product mobile AR RTL, Customer library, Admin overview) | **partial: 6 of 48 drawn** |
| Responsive behaviour | `design-system.md` §5, per-screen mobile notes in `screens.md` | complete |
| RTL/LTR specification | `rtl-i18n.md` | complete |
| Accessibility validation | `accessibility.md` + `validation/` logs | tools run; manual testing planned |
| Validation against Phase 2 | `validate-design.py`, `design-gaps.md`, `design-traceability.csv`, `schema_addendum_phase3.sql` | complete |

## 2. The design in one paragraph

The identity is an **inspected listing**. A pale sea-glass ground and deep harbour ink, hairline structure instead of cards and shadows, IBM Plex Sans / Plex Sans Arabic / Plex Mono, and one colour, a deep magenta used the way sea charts mark lights, reserved for action and verification. The signature element is the **manifest**: a compact panel that shows a listing's contents tree, license, scan result, version and checksum, so the buyer can inspect before paying. Catalog results are comparable rows rather than a wall of identical tiles. Every claim the interface makes maps to something the platform actually does.

## 3. Validation results

| check | result |
| --- | --- |
| Screens vs `api.md` | all 48 screens resolve to existing routes except **6 routes that must be added** (G7 to G12), all documented |
| Screens vs `schema.sql` | all referenced tables exist; **6 schema additions** needed (G1 to G6, plus a settings key), applied in `schema_addendum_phase3.sql` and tested on a real Postgres engine (14 behaviour checks, all pass) |
| Features vs `traceability.csv` | all **38 MVP features** map to at least one screen; non-MVP rows correctly have none |
| Routes with no screen | only webhooks, machine licence API, V2 export and future multi-vendor routes (all expected) |
| Contrast | 0 failures in 39 pairs; 2 real defects found and fixed during the work |
| Boards, structural accessibility (axe-core) | 0 violations on 6 boards |
| Boards, RTL lint | 2 real defects found and fixed; 0 remaining |
| Tailwind mapping | compiles; token classes generate; off-scale spacing cannot be written |

Defects I introduced and fixed along the way: Arabic headings would have used desktop sizes on phones (generator bug), a List/Grid toggle with physical corner radii that would round the wrong corners in RTL, dark-panel dividers below 3:1, and default placeholder colour below 4.5:1 on the page ground.

## 4. Honest limits and deviations

1. **Only 6 of 48 screens are drawn.** The other 42 are fully specified in `screens.md` (layout, mobile, states, components) but have no visual board yet. I can draw more boards in the same canvas, starting with the ones that carry the most trust or money: cart, order status, library item, product editor, refund decision.
2. **I have not seen the boards rendered.** I checked their source (structure, tokens, RTL, accessibility rules) but did not screenshot or open them in a browser. Please open the link and tell me what looks wrong; expect some visual polish issues.
3. **Components are specified, not built.** The replica-design skill's step 4 builds the primitives in code on a `/design` route. You told me not to write application code yet, so that moves to the start of Phase 4.
4. **Nothing is derived from the reference's visuals.** I fetched the reference as text and captured no screenshots, so the design is original by construction. The only things taken from the reference are functional patterns (product page, cart, library, purchase-gated reviews).
5. **Sample content.** Product names, prices, ratings, counts and dates on the boards are placeholders for layout review. Real listings, screenshots, About text, FAQ answers, legal texts and the refund window must come from you.
6. **Arabic copy is a draft** and needs a native review before launch (the target audience reads it critically).
7. **Brand is provisional.** "Mina", the tower mark and the exact colours are placeholders until Phase 9; roles are fixed, values may change.
8. **Fonts on the boards load from Google Fonts**; production self-hosts them.
9. **Dark mode and Arabic-Indic digits are out of MVP** (roles are ready for both).
10. **Accessibility is verified only as far as tools go** (token contrast, structure). Keyboard, screen reader, zoom and forced-colours testing are planned for Phase 6 and not yet done.

## 5. Decisions made that you may want to change

| decision | alternative |
| --- | --- |
| Harbour ink + sea-glass + magenta beacon | a quieter blue/neutral scheme (safer, less distinctive) |
| IBM Plex family for both scripts | a more expressive Arabic display face for headlines |
| Catalog default is **list rows**, grid is optional | grid first (more familiar, less comparable) |
| Western digits in Arabic UI | Arabic-Indic digits (needs bidi care next to USD prices and code) |
| Light-only MVP | add dark mode earlier |
| Cart page, not a drawer; hosted payment page, no card fields in our UI | cart drawer for fewer clicks |
| Hero headline "Software you can inspect before you pay for it" | any claim you prefer; it must stay true to what the platform does |
| No global admin search in MVP | add it (needs one more API) |

## 6. Approvals needed

1. **Apply `schema_addendum_phase3.sql`** (contents tree, includes facet, updated and price denormalisation, terms-acceptance evidence, receipt link, featured-product setting). It is additive and tested.
2. **Accept the 6 API additions** (G7 to G12) and the changes to `GET /api/products` and suggestions (G13) listed in `design-gaps.md`.
3. **Confirm the visual direction** above, or tell me what to change before Phase 4 builds on it.

## 7. Phase 4 handoff (`/replica-build`)

**Before screens:**
1. Create the app foundation (M0 in `architecture.md`): migrations from `schema.sql` + `schema_addendum_phase3.sql` + `seed.sql`, RLS, i18n shell with `/en` and `/ar`, fonts self-hosted.
2. Copy `tokens.css` and `tailwind.config.ts` into the app; run `python3 contrast.py tokens.json` in CI so a palette change cannot ship a contrast failure.
3. Add the lint rules from `rtl-i18n.md`: no `ml- mr- pl- pr- left- right- text-left text-right rounded-l rounded-r`, no raw hex, no off-scale spacing.
4. Build the primitives on an accessible base (Radix or React Aria) on a `/design` route, one block of `components.md` at a time, each with its states, in EN and AR. Screenshot it. This is the design-system check the skill requires.

**Build order for components:** Button, IconButton, Link, TextField family, Checkbox/Radio, Select, Tag, StatusBadge, Beacon, Dialog, Sheet, Toast, Banner, Table, DescriptionList, Skeleton, EmptyState, CopyField; then CoverTile, ProductRow, PriceBlock, Rating, FilterRail/Sheet, Gallery, FileTree, ManifestPanel, EditionPicker, VersionTimeline, LicenseCard, DownloadButton, CartLine/OrderSummary, OrderStatusStepper; then shells (SiteHeader/Footer, AccountShell, AdminShell) and admin components.

**Build order for screens** follows the roadmap: M1 vertical slice (W05, W06, W07, C02, C09, C10 with the test payment adapter), M2 catalog (W01 to W04), M3 accounts (C-series), M5 admin (M-series), M6 content and reviews.

**Definition of done for each screen:** matches `screens.md` including states; works at 360, 768, 1440 px in EN and AR; passes axe in a real browser; keyboard-operable; no lint violations; uses only token classes.

**Needed from you for Phase 4:** at least one real product with screenshots, a version and a file (to replace samples); About and FAQ text; refund window; confirmation of the decisions in §5.
