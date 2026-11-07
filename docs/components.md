# Component specifications

Format per the replica-design skill: variants, sizes, states, tokens, a11y, RTL, used on. Screen IDs: W = public web, C = customer account, M = admin (see `screens.md`). Every interactive component has a visible `:focus-visible` ring (2px `focus-ring`, 2px offset, 4px `surface` halo; on ink surfaces `accent-on-ink`). All states below include **disabled, loading, error and empty** where they apply. Components are built in Phase 4 on an accessible base (Radix primitives or React Aria) with Tailwind token classes; nothing here is built yet.

Global rules: logical properties only (`ms-`, `pe-`, `start-`, `text-start`, `rounded-s`); minimum 44px target on touch widths; text never conveys state by colour alone; no raw hex.

## A. Primitives

```
Button
  variants  primary (accent), secondary (surface + border-input), ghost (text only), danger (danger fill, confirm actions only)
  sizes     sm 32, md 40, lg 48 (44 minimum on touch widths: md and sm grow to 44)
  states    default, hover (accent-hover / surface-sunken), active, focus-visible, disabled (aria-disabled, not removed from tab order when it explains why), loading (spinner at inline-start, label kept, aria-busy)
  tokens    radius control, font small/600, padding-inline 5 (20px)
  a11y      real <button> or <a>; label says the result; loading keeps label for screen readers; disabled with reason via aria-describedby
  RTL       icon sits at inline-start; chevron icons mirrored
  used on   all
```
```
IconButton
  variants  secondary, ghost
  sizes     40, 44 touch
  states    as Button + pressed (aria-pressed) for toggles (wishlist)
  a11y      required aria-label in the current locale; tooltip on hover/focus (not the only label)
  used on   W01 to W07, C11, M-all
```
```
Link
  variants  inline (accent, underline on hover and always underlined in prose), nav (text, no underline, current page gets 3px accent underline and aria-current), quiet (text-muted)
  states    default, hover, visited (prose only: on-accent-subtle tint no), focus-visible
  a11y      link text is meaningful out of context; external links announce "opens in a new tab"
  used on   all
```
```
TextField (input, textarea)
  variants  input, textarea (min 4 rows, vertical resize), with prefix/suffix slots
  sizes     md 40 (lg 48 on auth forms and mobile)
  states    default, hover, focus (2px ring), filled, disabled, read-only, error (danger border + message + icon), loading (async validation)
  tokens    border border-input, radius control, bg surface, text text, placeholder text-muted
  a11y      visible <label> always (placeholder is never the label); help and error text linked with aria-describedby; error announced via aria-live=polite; correct type, inputmode and autocomplete values; required marked in text ("required"), not only with an asterisk
  RTL       text aligned to start; email, URL, code and password fields use dir=ltr
  used on   C01 to C06, C12 to C14, W06, W10, M-forms
```
```
PasswordField
  extends   TextField + show/hide IconButton (aria-pressed, label "Show password")
  rules     paste allowed, no composition rules beyond length 12+, strength hint is text not colour-only
  used on   C01, C02, C04, C06
```
```
SearchField
  variants  header (inline, 40), page (lg 48)
  states    default, focus, with-suggestions (combobox open), loading, no-results
  a11y      role=combobox, aria-expanded, aria-activedescendant, listbox suggestions grouped (Products, Categories, Languages); Enter submits, Esc closes, "/" focuses from anywhere (documented in a visible hint on desktop)
  RTL       magnifier icon at inline-start; clear button at inline-end
  used on   header (all W and C), W04
```
```
Select
  variants  native <select> styled with tokens (preferred for sort, locale, status), custom listbox only for rich options
  states    as TextField
  a11y      native semantics first
  used on   W02 to W04 (sort), M-filters, C06
```
```
Checkbox / Radio
  sizes     20px box in a 44px target row (32px on desktop filter rail)
  states    unchecked, checked, indeterminate, disabled, error, focus-visible
  tokens    border-input, checked fill accent, check mark on-accent
  a11y      native inputs with custom styling; grouped in <fieldset><legend>
  RTL       box at inline-start of the label
  used on   filters (W02 to W04), C01 (terms), W06 (license acceptance), M-forms
```
```
Switch
  states    off, on, disabled, focus-visible; label states the setting ("Email me about updates"), never "On/Off" alone
  a11y      role=switch, aria-checked
  used on   C06, M14
```
```
SegmentedControl
  use       List/Grid view toggle, All/Updates-available library filter
  a11y      radio-group semantics (aria-pressed buttons for 2 options is acceptable); arrow keys move
  RTL       order mirrors; rounded corners use logical radii
  used on   W02 to W04, C09, M-lists
```
```
Tabs (in-page nav and tablist)
  variants  in-page anchors (product page; links with aria-current=location), true tabs (admin product editor: role=tablist, arrow keys, Home/End)
  states    default, hover, selected (3px accent underline + text colour), focus-visible, disabled
  a11y      anchors are links, not role=tab; true tabs follow the ARIA tabs pattern
  RTL       arrow keys swap; tab order mirrors
  used on   W05, M03
```
```
Tag
  variants  neutral (surface-sunken), selected filter (accent-subtle), removable (with ×, label "Remove Python")
  sizes     12px text 16 line, radius tag 4
  a11y      static tags are text; removable tags are buttons
  used on   W02 to W05, C09
```
```
StatusBadge
  variants  success, warning, danger, info, neutral; each = icon + word + subtle fill
  examples  Paid, Refund requested, Failed, Update available, Pending review, Flagged, Clean
  a11y      the word is always present; the icon is aria-hidden
  used on   C07 to C10, M-all
```
```
Beacon (verified mark)
  meaning   "checked by us": scan clean, license valid, verified buyer
  sizes     16, 20; colour accent on light, accent-on-ink on ink
  a11y      aria-hidden when beside text; standalone use needs a label
  rule      never decorative
  used on   W01, W05, W10 reviews, C10
```
```
Tooltip
  trigger   hover and focus; dismiss with Esc; never the only place information lives; not on touch
  a11y      role=tooltip, aria-describedby
  used on   IconButtons, truncated hashes
```
```
Popover / Menu
  variants  menu (actions), disclosure (filters on tablet), account menu
  tokens    surface, border, radius panel, shadow overlay
  a11y      focus moves in, Esc returns focus to trigger, arrow-key navigation for menus
  RTL       opens toward inline-end, flips if clipped
  used on   header account menu, locale switch, M-row actions
```
```
Dialog
  variants  confirm, form, destructive (danger button), re-authentication
  sizes     sm 400, md 560; full-screen below 600
  states    default, submitting, error
  a11y      role=dialog, aria-modal, labelled and described, focus trap, Esc closes (except while submitting), focus returns to trigger, background inert
  used on   C08 (refund request), C10 (reveal key), M-confirmations
```
```
Sheet (bottom sheet / side drawer)
  use       mobile filters, mobile navigation, admin drawer
  motion    slide 200ms from bottom (filters) or inline-start (nav); none under reduced motion
  a11y      same as Dialog; filter sheet has a sticky "Show results" button and "Clear all"
  used on   W02 to W04, header, M-shell
```
```
Toast
  variants  success, error, info; position bottom-end (bottom-centre on mobile)
  rules     auto-dismiss 6s but pauses on hover/focus; errors persist until dismissed; never the only place an error appears
  a11y      role=status (role=alert for errors)
  used on   copy, save, wishlist, add to cart
```
```
Banner (inline alert)
  variants  info, success, warning, danger; icon + title + text + optional action
  a11y      role=status or alert by severity
  used on   W07 (payment processing), C10 (update available), M01
```
```
Breadcrumb
  rules     <nav aria-label="Breadcrumb"> ordered list, last item aria-current=page, separator is a CSS chevron mirrored in RTL (not a character in text)
  used on   W03, W05, C08, C10, M03, M06
```
```
Pagination
  variants  numbered (catalog), load-more (mobile, library)
  a11y      <nav aria-label="Pagination">, current page aria-current, prev/next labelled; focus moves to results heading after navigation
  RTL       prev/next arrows swap
  used on   W02 to W04, C07, M-lists
```
```
Table
  variants  data (desktop), stacked description-list rows (below 600; no cards)
  features  sticky header, sortable columns (button in header with aria-sort), row actions menu, bulk select (admin), empty/loading/error rows
  a11y      <caption>, <th scope>, sort announced, keyboard-reachable actions, horizontal scroll container has tabindex=0 and a label
  RTL       column order and alignment mirror; numeric columns align to end and stay LTR
  used on   C07, M02, M05, M07, M09, M12, M16
```
```
DescriptionList (facts)
  use       manifest facts, order details, license details
  pattern   <dl> with dt text-muted and dd text; two-column grid (auto/1fr); stacks at <360
  used on   W05, C08, C10, M06
```
```
EmptyState
  anatomy   one sentence of what is missing, one sentence of what to do, one primary action
  rules     no illustration required; never blames the user
  examples  library empty, wishlist empty, no search results (suggest removing filters and show popular categories)
  used on   C07, C09, C11, C13, W04
```
```
Skeleton / Spinner / Progress
  skeleton  for lists and panels with known shape; no shimmer under reduced motion
  spinner   inline in buttons only (16px)
  progress  determinate for uploads and downloads, with text "Uploading 42%" and aria-valuenow
  used on   all data screens, M03 uploader
```
```
CopyField (CopyButton)
  use       SHA-256, license key, order number
  behaviour copies the full value; shows "Copied" inline for 2s (and polite live region)
  a11y      button label "Copy SHA-256"
  RTL       value in an LTR island
  used on   W05, C08, C10, M06
```
```
Accordion
  use       manifest on mobile, FAQ
  a11y      native <details> where possible; summary is a 44px target
  used on   W05 (mobile), W09
```
```
FormField (wrapper)
  anatomy   label, optional hint, control, error; error text uses danger on surface with an icon
  rules     one error summary at the top of long forms with links to fields; errors never rely on colour alone
  used on   all forms
```
```
FileUploader (admin)
  variants  archive upload (presigned PUT), image upload
  states    idle, dragover, uploading (progress + cancel), processing (hash + scan), clean, flagged, failed (retry)
  a11y      real <input type=file> reachable by keyboard; drag-and-drop is optional; status announced; reordering media uses move up/move down buttons as well as drag
  used on   M03
```

## B. Marketplace components

```
CoverTile
  variants  image (screenshot crop), tile (ink with stack mark)
  ratios    4:3 (tile), 16:10 (screenshots)
  tokens    ink, on-ink, radius media
  a11y      decorative on rows (alt=""), meaningful in gallery
  used on   W01 to W07, C09 to C11
```
```
ProductRow  (default result view)
  anatomy   cover 96x72 | title (h2 link) + summary + tags | meta column (updated, license, rating) | price + View
  tablet    meta column folds under the summary; mobile: cover 72x56 left, title/summary/price stacked, tags max 3
  states    default, hover (surface-sunken row), focus-within, owned ("In your library" replaces price and View becomes Open), unavailable
  a11y      the whole row is not a link; the title is, so link text is the product name; price has an accessible "Price: $49"
  RTL       cover at inline-start; price at inline-end
  used on   W02 to W04, C11
```
```
ProductTile  (grid view and featured)
  anatomy   cover 16:10 or 4:3, title, one-line summary, price, rating
  rules     max 4 per row at xl, 3 at lg, 2 at md, 1 at sm/base (grid view only); used sparingly on the home page for one featured item, not as the main pattern
  used on   W01, W02 to W04 (grid)
```
```
PriceBlock
  variants  single, from-price ("From $49"), with compare-at (strikethrough with "was $199" text), owned
  rules     USD, tabular numerals; note "One-time payment in USD" under the large price
  used on   W05, W06, rows
```
```
Rating
  anatomy   "4.8 from 31 verified buyers" as text first; optional 5 ink stars (decorative)
  empty     "No reviews yet. Buyers can review after purchase."
  used on   rows, W05
```
```
ReviewItem
  anatomy   rating, title, body, locale chip if different from page, date, Beacon + "Verified buyer", staff reply (indented, labelled)
  states    published, pending (own review only, StatusBadge), edit
  a11y      article with heading; body with lang attribute when its locale differs
  RTL       dir=auto on user text
  used on   W05, C12, M10
```
```
Gallery + Lightbox
  anatomy   16:10 stage, 96x60 thumbnails, GIF/video with controls and no autoplay sound, lightbox on activate
  states    loading (skeleton), error (placeholder + retry), video playing
  a11y      thumbnails are buttons with alt text, aria-current on the active one, arrow keys, Esc closes lightbox, GIF respects reduced motion by showing a still with a "Play" button
  RTL       thumbnails and arrows mirror
  used on   W05
```
```
ManifestPanel
  variants  hero (ink, non-interactive sample or featured listing), purchase (surface, sticky, interactive), compact (mobile accordion)
  anatomy   [edition picker] [price] [Buy now / Add to cart / Save] [facts: Version, License, Updates, Malware scan, SHA-256, Works with] [license and refund links]
  hero      file tree in ink-raised well, facts in a dl, Beacon "Clean" in accent-on-ink; one inspection pass on first view
  states    default, edition-changed (price updates and announces), owned ("In your library", Open), unavailable (unpublished), loading, error
  a11y      region labelled "Purchase"; price change announced by aria-live=polite; sticky panel does not trap focus
  RTL       fully mirrored; file tree and checksum remain LTR islands
  used on   W01 (hero), W05
```
```
EditionPicker
  anatomy   radio cards: name, one-line scope ("Personal: one person, one project"), price; selected = 2px accent border
  a11y      radio group in fieldset/legend "Edition"; scope text is part of the label
  used on   W05, mobile buy bar sheet
```
```
FileTree
  anatomy   mono, indented, folders collapsible, file sizes optional, counts for tests/docs
  rules     read-only; max depth 3 shown, "+ N more files" expands; always an LTR island
  a11y      role=tree with treeitem rows, or a nested list; arrow keys when role=tree
  used on   W01, W05, C10
```
```
VersionTimeline
  anatomy   vertical rule with a node per version: version (mono), date, StatusBadge (Current, Yanked), changelog (markdown), Download (library only)
  note      the rule and nodes encode order of release, so structure carries meaning
  a11y      ordered list, newest first; yanked versions explain why
  RTL       rule sits at inline-start
  used on   W05, C10
```
```
LicenseCard
  anatomy   edition name, scope summary in plain words (what you may and may not do), activations (X of Y), key (masked) with Reveal, Copy, "Read full license"
  states    active, revoked (explains and links to support), expired, revealing (needs re-authentication)
  a11y      key is read as characters on request only; masked value announced as "key hidden"
  RTL       key in an LTR island
  used on   W05 (summary), C10
```
```
DownloadButton  (state machine)
  states    ready ("Download 2.5.0"), requesting (spinner), starting ("Your download is starting"), error-expired, error-limit ("Daily limit reached. Try again at 14:00."), blocked (file pending scan: "This file is being checked. Try again soon."), revoked
  a11y      state changes announced via live region; never opens a new window silently
  used on   C09, C10
```
```
FilterRail / FilterSheet / ActiveFilters
  groups    Category, Language/stack, License, Includes, Price, Updated within, Rating
  behaviour filters apply instantly on desktop; on mobile, "Show results" applies; URL reflects every filter (shareable)
  ActiveFilters  removable tags row above results with "Clear all"; result count is a live region
  a11y      each group in fieldset/legend; collapsed groups use buttons with aria-expanded; the result count announces changes
  used on   W02 to W04, C09 (simple), M-lists
```
```
CategoryIndex
  anatomy   typographic list in a column layout, hairline rules, name as link; "All 14 categories" at the end
  rules     no icons, no cards; counts appear only when real data exists
  used on   W01, footer
```
```
CartLine / OrderSummary / CouponField
  CartLine      cover, title, edition, price, Remove (button), "Already in your library" error variant
  OrderSummary  subtotal, discount, tax (from provider, "Calculated at payment" until known), total, license acceptance checkbox, "Continue to payment" primary
  CouponField   input + Apply; success shows the discount line and a removable tag; error says why (expired, not valid for these items)
  a11y          totals in a live region; removal returns focus to the next line or the heading
  used on       W06
```
```
OrderStatusStepper
  steps     Order placed, Payment confirmed, Ready to download (a true sequence, so numbering is appropriate)
  states    pending (spinner, "Waiting for confirmation, this can take a minute"), paid, failed (reason and retry), cancelled
  a11y      ordered list with aria-current=step; status in a live region; polling stops and says why after 2 minutes with a support link
  used on   W07
```
```
MobileBuyBar
  anatomy   price + "One-time" + Buy now (primary 48) fixed to the bottom, safe-area padding; edition selector opens a Sheet
  rules     appears once the in-flow manifest scrolls out of view; does not cover focused elements (scroll-padding-bottom)
  used on   W05 (below 900)
```
```
ReviewForm
  fields    rating (radio group of 5 with text labels), title, body (min 20 chars), locale auto-set
  states    default, submitting, submitted ("Thanks. Your review will appear after moderation."), edit existing
  used on   C12, C10
```

## C. Shell and navigation

```
SiteHeader
  desktop   logo | Browse (menu) | Support | search (flex) | locale | cart | account (Sign in / avatar menu)
  mobile    menu button | logo | search button | cart; search expands to a full-width field
  states    default, scrolled (border-bottom appears; no shadow), menu open
  a11y      skip link first; landmark <header>; <nav aria-label="Main">; cart link "Cart, 2 items"
  RTL       logo at inline-start; everything mirrors
  used on   W, C pages (not C01 to C05)
```
```
SiteFooter
  content   category index (short), Support, About, FAQ, legal links (Terms, Privacy, Refunds, Licenses), locale switch, payment methods shown only if verified, copyright
  used on   W, C pages
```
```
AccountShell
  desktop   240 sidebar (Library, Orders, Wishlist, My reviews, Support, Profile and security); current item aria-current=page with surface + border
  mobile    horizontally scrolling tab strip under the header (scroll snaps, current item scrolled into view)
  used on   C06 to C14
```
```
AdminShell
  desktop   248 ink sidebar (Overview, Products, Orders, Refunds, Reviews, Customers, Coupons, Support, Analytics, Settings, then Roles and Audit for permitted staff), top bar with page title and account menu (search lives inside each list; global search is V2)
  mobile    sidebar becomes a drawer
  rules     navigation items appear only when the user has the permission; staff without MFA are redirected to C05
  a11y      <nav aria-label="Admin">; breadcrumbs inside pages; keyboard-reachable collapse control
  used on   M01 to M17
```
```
LocaleSwitch
  rules     shows the other language in its own script ("العربية" / "English"), sets lang and dir immediately, keeps the path and query, remembers choice for signed-in users (PATCH /api/me)
  a11y      link with lang attribute on the label, not a select
  used on   header, footer, C06
```
```
CookieNotice
  rules     appears only if non-essential storage is added; analytics is cookieless, so MVP shows an information notice with a link, not a blocking banner; if a consent choice is ever required: equal-weight Accept and Reject
  used on   W (first visit)
```

## D. Data and admin components

```
KpiTile
  anatomy   label (small, text-muted), value (28/700 tabular), optional delta text ("up 12% from the previous 30 days" in words)
  rules     delta never colour-only; no sparkline inside the tile
  used on   M01, M13
```
```
Chart (line, bar)
  rules     one accent series + ink for comparison; direct labels instead of legends when possible; every chart has a "Show as table" toggle and a text summary; axes labelled; time runs left to right in both locales (numbers are LTR) while the chart's layout and legend mirror
  a11y      role=img with a summary label; table fallback is real data
  used on   M01, M13
```
```
AttentionQueue
  anatomy   list of counts with the action that clears them: refund requests, reviews to moderate, files flagged, failed webhooks, tickets waiting over 24h
  rules     hides items with zero count; when empty shows "Nothing needs your attention"
  used on   M01
```
```
RowActionsMenu / BulkBar
  rules     row actions in a menu button labelled "Actions for <row name>"; bulk bar appears on selection with count in a live region
  used on   M-lists
```
```
StaffForm patterns
  rules     long forms use sticky "Save changes" bar with unsaved-changes indicator; destructive actions (Archive, Revoke license, Block customer) confirm in a Dialog that states the consequence; every save shows a toast named like the button ("Save changes" → "Changes saved")
  used on   M03, M04, M09, M14, M15
```
