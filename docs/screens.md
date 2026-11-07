# Screen specifications (all MVP screens)

48 screens: 17 public (W), 14 customer account (C), 17 admin (M). The index table is machine-checked against `api.md`, `schema.sql` and `traceability.csv` (`validate-design.py`). Entries marked `GAP:` need an API or schema addition recorded in `design-gaps.md`. `static` = content page in the repo (translated MDX), no API. `supabase-auth` = handled by the auth provider, not our API. **Board** = a visual board on the design canvas; "spec" = specified here only.

Shared rules for every screen: page template from `design-system.md` §5; header/footer from `components.md`; logical directions; Western digits; all strings exist in EN and AR; every data region has loading (skeleton), empty and error states; focus moves to the page `<h1>` after client-side navigation; one `<h1>` per page.

## Index

| ID | name | route | template | api | tables | board |
| --- | --- | --- | --- | --- | --- | --- |
| W01 | Home | / | Storefront | GET /api/products; GET /api/categories; POST /api/newsletter | products; categories | Main |
| W02 | Catalog | /browse | List + rail | GET /api/products; GET /api/categories | products; product_translations; categories | Catalog |
| W03 | Category | /browse/[category] | List + rail | GET /api/products; GET /api/categories | products; categories | spec |
| W04 | Search results | /search | List + rail | GET /api/products; GET /api/products/suggest | product_translations | spec |
| W05 | Product detail | /p/[slug] | Product | GET /api/products/:slug; GET /api/products/:slug/versions; GET /api/products/:slug/reviews; POST /api/cart/items; PUT /api/wishlist/:productId; POST /api/collect | products; product_editions; product_media; product_versions; product_files; license_templates; reviews | Product, Product-ar-mobile |
| W06 | Cart | /cart | Storefront | GET /api/cart; DELETE /api/cart/items/:editionId; POST /api/cart/coupon; DELETE /api/cart/coupon; POST /api/checkout | carts; cart_items; coupons; orders | spec |
| W07 | Order status | /orders/[number]/status | Focused form | GET /api/orders/:orderNumber/status | orders; payments | spec |
| W08 | About | /about | Prose | static | none | spec |
| W09 | FAQ | /faq | Prose | static | none | spec |
| W10 | Contact | /contact | Focused form | POST /api/contact | support_tickets | spec |
| W11 | Terms of service | /legal/terms | Prose | static | none | spec |
| W12 | Privacy policy | /legal/privacy | Prose | static | none | spec |
| W13 | Refund policy | /legal/refunds | Prose | static | none | spec |
| W14 | License terms | /legal/licenses | Prose | static | license_templates | spec |
| W15 | Not found and error | /404 /500 | Focused form | static | none | spec |
| W16 | How delivery works | /how-delivery-works | Prose | static | none | spec |
| W17 | Newsletter confirmed | /newsletter/confirmed | Focused form | GET /api/newsletter/confirm | newsletter_subscribers | spec |
| C01 | Sign up | /auth/sign-up | Focused form | supabase-auth; POST /api/me/sync | users | spec |
| C02 | Log in | /auth/log-in | Focused form | supabase-auth; POST /api/cart/merge | users; carts | spec |
| C03 | Verify email | /auth/verify | Focused form | supabase-auth | users | spec |
| C04 | Reset password | /auth/reset | Focused form | supabase-auth | users | spec |
| C05 | Two-step verification setup | /account/security/mfa | Focused form | supabase-auth | users | spec |
| C06 | Profile and security | /account/profile | Account shell | GET /api/me; PATCH /api/me; DELETE /api/me | users | spec |
| C07 | Orders | /account/orders | Account shell | GET /api/orders | orders | spec |
| C08 | Order detail | /account/orders/[number] | Account shell | GET /api/orders/:orderNumber; POST /api/orders/:orderNumber/refund-request | orders; order_items; payments; refunds | spec |
| C09 | Library | /account/library | Account shell | GET /api/library | entitlements; product_versions | Library |
| C10 | Library item | /account/library/[id] | Account shell | GET /api/library/:entitlementId; POST /api/downloads/:fileId/link; POST /api/licenses/:id/reveal | entitlements; product_files; licenses; license_activations; download_events | spec |
| C11 | Wishlist | /account/wishlist | Account shell | GET /api/wishlist; DELETE /api/wishlist/:productId | wishlist_items | spec |
| C12 | My reviews | /account/reviews | Account shell | GAP:GET /api/me/reviews; POST /api/products/:slug/reviews; PATCH /api/reviews/:id | reviews | spec |
| C13 | Support center | /account/support | Account shell | GET /api/support/tickets; POST /api/support/tickets | support_tickets | spec |
| C14 | Ticket thread | /account/support/[id] | Account shell | GAP:GET /api/support/tickets/:id; POST /api/support/tickets/:id/messages | support_tickets; ticket_messages | spec |
| M01 | Overview | /admin | Admin shell | GAP:GET /api/admin/attention; GET /api/admin/analytics/overview | analytics_daily; orders; refunds; reviews; webhook_events | Admin |
| M02 | Products | /admin/products | Admin shell | GET /api/admin/products; POST /api/admin/products/:id/publish; POST /api/admin/products/:id/archive | products; product_translations | spec |
| M03 | Product editor | /admin/products/[id] | Admin shell | GET /api/admin/products; GET /api/admin/products/:id; POST /api/admin/products; PATCH /api/admin/products/:id; POST /api/admin/products/:id/publish; POST /api/admin/products/:id/editions; POST /api/admin/products/:id/media; POST /api/admin/products/:id/versions; PATCH /api/admin/editions/:id; PATCH /api/admin/versions/:id; POST /api/admin/versions/:id/files/init; POST /api/admin/versions/:id/files/complete; POST /api/admin/versions/:id/publish; POST /api/admin/versions/:id/yank; GAP:PATCH /api/admin/media/:id | products; product_translations; product_editions; product_media; product_versions; product_files; license_templates; tags | spec |
| M04 | Categories | /admin/categories | Admin shell | GET /api/admin/categories; POST /api/admin/categories; PATCH /api/admin/categories | categories; category_translations | spec |
| M05 | Orders | /admin/orders | Admin shell | GET /api/admin/orders | orders | spec |
| M06 | Order detail | /admin/orders/[id] | Admin shell | GET /api/admin/orders/:id; POST /api/admin/refunds/:id/decide | orders; order_items; payments; refunds; entitlements | spec |
| M07 | Customers | /admin/customers | Admin shell | GET /api/admin/customers | users | spec |
| M08 | Customer detail | /admin/customers/[id] | Admin shell | GET /api/admin/customers/:id; POST /api/admin/customers/:id/block | users; orders; entitlements | spec |
| M09 | Coupons | /admin/coupons | Admin shell | GET /api/admin/coupons; POST /api/admin/coupons; PATCH /api/admin/coupons | coupons; coupon_targets; coupon_redemptions | spec |
| M10 | Review moderation | /admin/reviews | Admin shell | GET /api/admin/reviews; POST /api/admin/reviews/:id/moderate | reviews | spec |
| M11 | Support desk | /admin/tickets | Admin shell | GET /api/admin/tickets; POST /api/admin/tickets/:id/reply; PATCH /api/admin/tickets/:id | support_tickets; ticket_messages | spec |
| M12 | Licenses | /admin/licenses | Admin shell | GAP:GET /api/admin/licenses; POST /api/admin/licenses/:id/revoke; POST /api/admin/licenses/:id/reissue | licenses; license_activations | spec |
| M13 | Analytics | /admin/analytics | Admin shell | GET /api/admin/analytics/overview; GET /api/admin/analytics/products; GET /api/admin/analytics/funnel; GET /api/admin/analytics/revenue | analytics_daily; analytics_events | spec |
| M14 | Settings | /admin/settings | Admin shell | GET /api/admin/settings; PATCH /api/admin/settings | settings | spec |
| M15 | Roles and staff | /admin/roles | Admin shell | GET /api/admin/users/:id/roles; POST /api/admin/users/:id/roles | roles; permissions; user_roles | spec |
| M16 | Audit and security logs | /admin/audit | Admin shell | GET /api/admin/audit; GET /api/admin/security-events | audit_logs; security_events | spec |
| M17 | Refunds | /admin/refunds | Admin shell | GAP:GET /api/admin/refunds; POST /api/admin/refunds/:id/decide | refunds | spec |

## Public screens

### W01 Home
**Purpose:** state the promise, prove it with a real manifest, route to browsing.
**Desktop:** header; hero in 7/5 columns (left: h1 "Software you can inspect before you pay for it", one lead paragraph, Browse projects + How delivery works; right: hero ManifestPanel showing a featured listing with a real file tree, license, scan, checksum); category index (4 columns, hairline rows); "Recently updated" list of 5 ProductRows; "How delivery works" in three real steps (pay, receive a key and library entry, download, with the single permitted sequence numbering); verified reviews strip (3 quotes with Beacon, only when real reviews exist); FAQ excerpt (4 questions); newsletter (one field, double opt-in note); footer.
**Mobile:** hero stacks, manifest below the CTAs as a compact accordion collapsed to "Scan: clean, License, Updated"; category index single column; recently updated rows use mobile row layout.
**States:** no products yet shows a "Catalog opens soon" panel with the newsletter field; featured listing missing hides the manifest and shows the category index above the fold.
**Notes:** hero manifest content comes from the featured product (setting), never invented numbers. Inspection pass once per session, off under reduced motion. Board: Main.

### W02 Catalog
**Purpose:** compare many listings quickly.
**Desktop:** title and one-line description; filter rail (Category, Language, License, Includes, Price, Updated within, Rating) + results: ActiveFilters, count (live region), sort Select, List/Grid SegmentedControl, ProductRows, Pagination. Default view is List.
**Mobile:** sticky bar under header with "Filters (2)" button and sort; filters open in a Sheet with "Show results" and "Clear all"; results as mobile rows; load-more instead of numbered pagination.
**States:** loading (5 skeleton rows), no results (EmptyState: "Nothing matches these filters." + remove-last-filter button + popular categories), error (Banner with Retry).
**Notes:** every filter is in the URL. Grid view is a preference stored per device. Board: Catalog.

### W03 Category
Same template as W02 with the category as the page title, its description (from `category_translations`), the category pre-selected and locked in the rail (shown as a removable context, not a filter), and sibling categories as a CategoryIndex under the title. Breadcrumb: Browse / Category.

### W04 Search results
Same template as W02. Title "Results for “query”" (quotation marks of the locale; in AR «query»), count, "Did you mean" suggestion when trigram match exists, filters as W02. No results: EmptyState with spelling advice and the category index. Search suggestions (SearchField) group Products, Categories, Languages and never navigate until chosen.

### W05 Product detail
**Purpose:** let a buyer decide with confidence, then buy.
**Desktop:** breadcrumb; main column (title, summary, rating line, Gallery, in-page Tabs (Overview, What is included, Versions, License, Reviews), sections in that order) + sticky purchase ManifestPanel (EditionPicker, price, Buy now, Add to cart, Save, facts, license/refund links). A Share IconButton sits beside the title (Web Share API where available, otherwise copies the link and confirms with a Toast).
Sections: *Overview* (markdown from `description_md`, tags, stack, compatibility list); *What is included* (FileTree from the current version, counts, documentation list); *Versions* (VersionTimeline, current marked); *License* (plain-language summary per edition then link to full text); *Reviews* (Rating summary, ReviewItems sorted newest, pagination, note "Only verified buyers can review"); *Related* (up to 4 ProductRows, only when real).
**Mobile:** manifest compact accordion after the gallery; MobileBuyBar fixed; edition choice in a Sheet; sections stack with the Tabs becoming a horizontally scrolling anchor strip.
**States:** owned ("In your library. Open" replaces Buy and Add to cart), unpublished/archived (410-style notice and category link), edition out of date (price changes announce), add-to-cart error (Toast + inline Banner), loading skeleton, reviews empty.
**RTL:** full mirror; file tree, version numbers, hash, code in LTR islands; gallery arrows mirrored. Board: Product (desktop EN), Product-ar-mobile (mobile AR RTL).

### W06 Cart
**Purpose:** review, apply a coupon, accept license terms, continue to payment.
**Layout:** CartLines (cover, title, edition, price, Remove) + OrderSummary (subtotal, discount, tax "Calculated at payment", total), CouponField, required checkbox "I have read the license terms and refund policy" with links, "Continue to payment" primary. Signed-out users see "Sign in to continue" (cart is preserved and merged) with sign in / create account.
**Mobile:** summary below lines; Continue button sticky.
**States:** empty ("Your cart is empty. Browse projects."), item already owned (inline error and Remove), item no longer available (inline error), coupon error, checkout error (Banner, retry), redirecting ("Taking you to secure payment" with spinner).
**Note:** payment happens on the provider's hosted page; no card fields exist in our UI. Terms acceptance is recorded (addendum G14).

### W07 Order status
**Purpose:** tell the buyer what is happening after payment.
**Layout:** focused column; OrderStatusStepper; order number (CopyField); summary; primary action by state: paid → "Go to your library"; pending → polling message; failed → reason and "Try payment again"; cancelled → "Return to cart".
**States:** pending (polls every 3 s for up to 2 min, then explains the delay and links to support and email), paid, failed, cancelled, order not found or not yours (neutral message).
**A11y:** status in live region; no timeouts that lose the order reference.

### W08 About
Prose template. Who builds the platform and why, how products are reviewed before publication, how to contact. Real content from the owner; placeholder headings only until supplied.

### W09 FAQ
Prose with Accordion groups: Buying, Downloads and updates, Licenses, Refunds, Security. Each answer links to the relevant legal page. Search field filters questions client-side.

### W10 Contact
Focused form: name, email, order number (optional), topic (Select), message, Turnstile. Success page states what happens next and typical reply expectation (owner supplies). Signed-in users are pre-filled and the message becomes a ticket in C13.

### W11 to W14 Legal pages
Prose template with in-page contents on desktop, "Last updated" date, versioned in the repo. W14 renders each license template (scope, redistribution rule) from `license_templates`, in both languages. These texts need lawyer review before launch.

### W15 Not found and error
Focused column: plain explanation, search field, link to catalog; 500 variant shows a reference id (from Sentry) for support.

### W16 How delivery works
Prose: what happens after payment (confirmation email, library entry, download link valid for minutes, daily limit, key reveal, activations), with the single permitted sequence. Mentions only implemented behaviour.

### W17 Newsletter confirmed
Focused column: "You are subscribed" or "This link has expired" with resubscribe field.

## Customer account screens

### C01 Sign up
Focused form (440): email, password (PasswordField), consent text with links, Turnstile, "Create account"; link to log in. After submit → C03. Errors: email exists (neutral: "Check your email" to avoid account enumeration), weak password, network. Marketing opt-in is a separate unchecked checkbox.

### C02 Log in
Email + password, "Forgot password", "Log in"; MFA code step when enabled; rate-limit message with time; links to sign up. After login: merge guest cart, return to the page the user came from.

### C03 Verify email
Explains the email was sent to the address, "Resend email" (cooldown 60 s with live countdown text), "Use a different email". Success state redirects to the intended page.

### C04 Reset password
Two states: request (email field, neutral confirmation) and set-new-password (token page, PasswordField, success with log in). Expired link state explains and offers a new link.

### C05 Two-step verification setup
Required for staff, optional for customers. Steps: scan QR (with text key alternative in an LTR island), enter 6-digit code, save recovery codes (download or copy; must tick "I saved these"). Disable requires password. Staff without MFA are redirected here.

### C06 Profile and security
Account shell. Sections: name, email (change requires password), language (LocaleSwitch), email preferences (Switch), password change, two-step verification status, sessions (list, sign out others), "Delete my account" (Dialog explains that order records are kept as legally required and licenses stop working).

### C07 Orders
Table (desktop) of order number, date, items, total, StatusBadge; stacked rows on mobile; filter by status; Pagination. Empty: "You have not bought anything yet. Browse projects."

### C08 Order detail
Order number (CopyField), date, StatusBadge; items with edition, price, "Open in library"; totals incl. tax from provider; payment method; provider receipt link (addendum G19); "Request a refund" (Dialog: select items, reason, shows policy, submit) shown only inside the refund window; refund status timeline when requested.

### C09 Library
**Purpose:** get to what you bought, fast.
**Desktop:** page title, SegmentedControl (All, Updates available), rows: cover, name, edition and installed version, update StatusBadge, masked license key with Reveal, activations used, Download button (latest). Sort by recently updated or name.
**Mobile:** rows stack: name, status, Download (full width), "Details" link; key reveal inside C10 only.
**States:** empty (EmptyState with Browse projects), loading, error, pending scan on latest file ("being checked").
Board: Library.

### C10 Library item
Back link to Library; header (cover, name, edition, StatusBadge). Sections: *Downloads* (current version, files with size and SHA-256 CopyField, DownloadButton per file), *Versions* (VersionTimeline with per-version downloads and changelog), *License* (LicenseCard with Reveal key via re-authentication Dialog, activations list with Deactivate), *Documentation and support* (links), *Your review* (ReviewForm prompt if none). Update Banner when newer version exists.
**States:** revoked (all downloads disabled, explanation and support link), expired updates (older versions downloadable, newer need renewal), limit reached, scan pending.

### C11 Wishlist
ProductRows with Remove (IconButton) and Add to cart / Open if owned; Empty: "Save projects to compare them later."; note: price shown is current price.

### C12 My reviews
List of own reviews with StatusBadge (Pending review, Published, Hidden), Edit; "Waiting for a review" section listing purchases without one. Edit opens ReviewForm; edited reviews return to pending and say so.

### C13 Support center
Two columns desktop: "Open a ticket" form (topic, order optional, subject, message) and ticket list with StatusBadge and last update; link to FAQ above the form. Empty ticket list: "No tickets. Most answers are in the FAQ."

### C14 Ticket thread
Thread with author, time, staff label; reply field; status; "Mark as resolved". Closed tickets show read-only with "Open a new ticket" linking back.

## Admin screens

All admin screens: AdminShell, breadcrumbs, one primary action top-end, destructive actions confirmed in Dialogs, every mutation audited, sticky save bar on forms, empty/loading/error states, keyboard-operable (no drag-only interaction).

### M01 Overview
AttentionQueue first (refund requests, reviews to moderate, files flagged, failed webhooks, tickets waiting over 24 h; each with the action that clears it), then KpiTiles (revenue 30 days, orders, average order, refund rate; each with a delta in words), a revenue Chart with table toggle, top five products, recent orders table. Date range Select (7, 30, 90 days). Board: Admin.

### M02 Products
Table: cover tile, title, status, editions (price range), current version, scan state, rating, updated; filters (status, category, scan state), search, "New product" primary. Row action menu: Edit, Preview, Publish/Archive. Empty: "No products yet. Create your first product."

### M03 Product editor
Header: title, status StatusBadge, Preview (opens product page as draft), Save changes, Publish (disabled with reasons: needs a published version with a clean file, at least one active edition, an English title). Tabs: *Details* (slug, category, tags, delivery type, includes, stack, compatibility, demo link); *Translations* (EN/AR side by side: title, summary, description markdown with preview, SEO fields); *Editions* (list with name, price, compare-at, license template, activations, update window); *Media* (cover, screenshots, GIF/video; reorder with move buttons and drag; alt text required per locale); *Versions and files* (new version form: number, changelog per locale, requirements; FileUploader per file with hash and scan status; contents tree preview and editable stats; Publish version, Yank with reason). Unsaved-changes guard.

### M04 Categories
Tree/list with reorder (buttons), active toggle, EN/AR names and descriptions; product count; delete blocked when products exist (explains).

### M05 Orders
Table: order number, date, customer email, total, provider, status; filters (status, date range, coupon), search by number or email; export is V2. Row opens M06.

### M06 Order detail
Items, totals, payment (provider reference, method), coupon, entitlements and licenses created, download activity summary, refunds list with decision controls (Approve/Reject with reason; approve states whether access is revoked), timeline, internal notes (V2). Actions: Resend receipt, Revoke access (Dialog).

### M07 Customers
Table: email, name, joined, orders, lifetime spend, status; search; filter blocked. Row opens M08.

### M08 Customer detail
Profile, orders, library entitlements, tickets, security events for this user; actions: Block/Unblock (Dialog), Resend verification, Revoke a license.

### M09 Coupons
Table (code, type and value, usage x of limit, window, status) and a form Dialog or page: code, percent/fixed, value, currency (fixed), dates, usage limits, minimum order, applies to (all, products, categories) with pickers; shows a live preview of the effect on a sample price. Deactivate instead of delete once used.

### M10 Review moderation
Queue filtered to Pending by default: product, rating, body (full), buyer, order link, Beacon "Verified buyer", actions Publish, Reject (reason), Hide; staff reply field. Bulk publish.

### M11 Support desk
Ticket list (status, priority, category, age) and thread view with reply, status change, order link and customer summary; saved replies are V2.

### M12 Licenses
Search by key prefix, email, order number; detail: status, edition, activations list (fingerprint hash prefix, label, last seen) with deactivate; actions Revoke (reason), Reissue (generates a new key, old one invalid). Keys are never shown in full here.

### M13 Analytics
Tabs: Overview, Products, Funnel (view, cart, checkout, purchase), Revenue (by day, by product, by coupon), Refunds. Date range, compare to previous period, every chart with table toggle and text summary; data note "Visitors are counted without cookies, so repeat visits on different days count separately."

### M14 Settings
Sections: Store (name, support email, default locale), Delivery (link lifetime, daily download limit), Reviews (moderation required), Features (multi-vendor and seller registration shown as off and locked), Legal (refund window text), Payments (provider status: not configured/test/live, webhook last received), Email (sender, test email). Dangerous changes confirm.

### M15 Roles and staff
Staff list with roles, MFA status (required badge), invite staff, assign roles (checklist of permissions per role shown read-only), remove access. Changing roles requires recent re-authentication.

### M16 Audit and security logs
Two tabs. Audit: time, actor, action, entity, diff (expandable), IP hash; filters. Security: login failures, webhook signature failures, download denials, severity; filter and detail. Read-only, export V2.

### M17 Refunds
Queue (Requested by default): order, customer, item, reason, amount, age; decision Dialog (Approve and refund, Approve and revoke access, Reject with reason); processed and rejected tabs.

## Cross-screen states to design once (shared components)

Already owned; unpublished/unavailable; loading skeleton; empty list; error with retry; permission denied ("You do not have access to this page" with way back); session expired (re-login keeps the destination); offline (Banner); long strings (German-length and Arabic expansion tested at 130%); 400% zoom reflow; RTL variants of all of the above.
