# API design (Phase 2)

Style: Next.js route handlers (REST/JSON) + server actions for same-origin forms. Every handler: validate input with zod, check auth/permission in one shared guard, rate-limit, return `{ data }` or `{ error: { code, message } }`. Locale from `Accept-Language`/`?locale=`; strings localized server-side where stored (translation tables).

Actors: **anon**, **user** (verified customer), **staff:<permission>** (see seed.sql), **machine** (license API, key-authenticated).
Tier: **MVP** unless marked V2 / FUT (future multi-vendor, not built, route reserved).

## Public catalog

| method path | does | who | input | output | tier |
| --- | --- | --- | --- | --- | --- |
| GET /api/products | list/search/filter/sort | anon | q, category, tag, tech, includes (tests,docs,docker,ci,demo,types), license (personal,commercial,team,enterprise), updated_within (30,90,365 days), price_min/max (on `price_from_cents`), rating_min, exclude (slug), sort (newest, updated, popular, price, rating), page (size max 48), locale | paged product cards (title, summary, cover, tech_stack, includes, price_from, rating, last_released_at) | MVP (changed in Phase 3: `includes`, `license`, `updated_within`, `exclude`, `sort=updated`) |
| GET /api/products/suggest | search-as-you-type (rate limited, min 2 chars, published only) | anon | q, locale | `{products[≤5], categories[≤3], languages[≤3]}` | MVP (response shape changed in Phase 3; no client existed) |
| GET /api/products/:slug | product detail; **verification manifest**: stack, compatibility, system requirements, current version, directory tree + stats, per-file name/size/SHA-256, scan status, license summary per edition, changelog, rating summary. Never returns storage keys or file ids | anon (published only; drafts via admin preview) | slug, locale | product | MVP |
| GET /api/products/:slug/versions | public changelog of published versions | anon | slug | versions | MVP |
| GET /api/products/:slug/reviews | published reviews | anon | page, sort | reviews | MVP |
| GET /api/categories | category tree with names in locale | anon | locale | tree | MVP |
| POST /api/collect | cookieless analytics event | anon | event_name, product_id?, props | 204 | MVP |
| POST /api/newsletter | subscribe (double opt-in email) | anon | email, locale, captcha | 202 | MVP |
| GET /api/newsletter/confirm | confirm subscription | anon | token | redirect | MVP |
| POST /api/contact | contact form → ticket | anon | name, email, message, captcha | 202 | MVP |

## Accounts (Supabase Auth does sign-up, login, reset, email verification, MFA)

| method path | does | who | input | output | tier |
| --- | --- | --- | --- | --- | --- |
| POST /api/me/sync | create/refresh `users` row after verified login | user | (session) | profile | MVP |
| GET /api/me | profile | user | | profile | MVP |
| GET /api/me/reviews | my reviews with status (pending, published, hidden, rejected) | user | page | reviews | MVP (G7, Phase 3) |
| PATCH /api/me | name, locale, marketing opt-in | user | fields | profile | MVP |
| POST /api/me/export | request personal-data export (job) | user | | 202 | V2 |
| DELETE /api/me | request account deletion (anonymise, keep legal order records) | user | password re-check | 202 | MVP |

## Cart, wishlist, checkout

| method path | does | who | input | output | tier |
| --- | --- | --- | --- | --- | --- |
| GET /api/cart | current cart, server-priced | anon/user | cookie | cart | MVP |
| POST /api/cart/items | add edition (rejects already-owned) | anon/user | edition_id | cart | MVP |
| DELETE /api/cart/items/:editionId | remove | anon/user | | cart | MVP |
| POST /api/cart/merge | merge guest cart on login | user | | cart | MVP |
| POST /api/cart/coupon | apply code (validates window, limits, targets) | user | code | cart with discount | MVP |
| DELETE /api/cart/coupon | remove code | user | | cart | MVP |
| GET /api/wishlist | list | user | | products | MVP |
| PUT /api/wishlist/:productId | add | user | | 204 | MVP |
| DELETE /api/wishlist/:productId | remove | user | | 204 | MVP |
| POST /api/checkout | **re-price on server**, create `pending` order, create provider checkout, return redirect URL | user (verified email) | cart_id, locale | {order_number, redirect_url} | MVP (provider gated) |
| GET /api/orders/:orderNumber/status | poll after return from provider | user (owner) | | status | MVP |

## Webhooks in (the only path that marks an order paid)

| method path | does | who | notes | tier |
| --- | --- | --- | --- | --- |
| POST /api/webhooks/lemonsqueezy | verify HMAC signature on raw body → insert `webhook_events` (unique event_id) → in one DB transaction: order paid, payment row, entitlements, licenses, email_outbox, coupon_redemption, sales_count | provider | idempotent; replay-safe; bad signature → 400 + `security_events` | MVP, **gated on account approval** |
| POST /api/webhooks/paymob | same pattern, local EGP methods | provider | not built until Paymob is verified for digital goods | V2 |

Webhooks out: none in MVP (email goes through `email_outbox`).

## Orders, library, downloads, licenses

| method path | does | who | input | output | tier |
| --- | --- | --- | --- | --- | --- |
| GET /api/orders | purchase history | user | page | orders | MVP |
| GET /api/orders/:orderNumber | order detail + receipt data | user (owner) | | order | MVP |
| POST /api/orders/:orderNumber/refund-request | ask for refund | user (owner) | item?, reason | refund(requested) | MVP |
| GET /api/library | purchased products with `update_available`, `latest_version`, `downloaded_version`, `review_status` (none, pending, published, hidden, rejected), activations used | user | page | entitlements | MVP (fields added in Phase 3; the "waiting for a review" list on C12 is this route filtered by `review_status=none`) |
| GET /api/library/:entitlementId | versions, files, license summary | user (owner, active) | | detail | MVP |
| POST /api/downloads/:fileId/link | checks: owner + active entitlement + version published + file `clean` + daily limit + rate limit; logs `download_events`; returns presigned URL (default 300 s, `Content-Disposition: attachment`) | user | | {url, expires_at} | MVP |
| POST /api/licenses/:id/reveal | show full key (recent re-auth required) | user (owner) | | key | MVP |
| POST /api/v1/licenses/validate | is this key valid for product X | machine | key, product_slug | {valid, edition, expires_at} | MVP |
| POST /api/v1/licenses/activate | register fingerprint within limit | machine | key, fingerprint, label | activation | MVP |
| POST /api/v1/licenses/deactivate | free a slot | machine | key, fingerprint | 204 | MVP |

Machine API: HMAC-lookup of the key, constant-time responses for unknown keys, strict per-IP and per-key rate limits, no key echo in logs.

## Reviews, support

| method path | does | who | input | output | tier |
| --- | --- | --- | --- | --- | --- |
| POST /api/products/:slug/reviews | review (needs an active/ever-valid entitlement; unique per user+product; starts `pending`) | user (verified buyer) | rating, title, body | review | MVP |
| PATCH /api/reviews/:id | edit own review (returns to pending) | user | fields | review | MVP |
| GET /api/support/tickets | my tickets | user | | tickets | MVP |
| GET /api/support/tickets/:id | one ticket with its messages | user (owner) or staff with support.reply | | ticket + messages | MVP (G8, Phase 3) |
| POST /api/support/tickets | open ticket (optionally linked to order) | user | subject, category, body, order_number? | ticket | MVP |
| POST /api/support/tickets/:id/messages | reply | user (owner) | body | message | MVP |

## Admin (all under `/api/admin`, permission-checked, every mutation writes `audit_logs`)

| method path | does | permission | tier |
| --- | --- | --- | --- |
| GET/POST /products, GET/PATCH /products/:id | list (filters: status, category, `scan=flagged`), create, edit incl. translations, tags, includes, compat | product.write | MVP |
| POST /products/:id/publish, /archive | status change (requires ≥1 published version with clean file) | product.publish | MVP |
| POST /products/:id/editions, PATCH /editions/:id | price, license template, activation limit | product.write | MVP |
| POST /products/:id/media | upload cover/screenshots (public bucket) | product.write | MVP |
| PATCH /media/:id, DELETE /media/:id | reorder, set cover, edit alt text per locale, delete (also removes the object) | product.write | MVP (G12) |
| POST /products/:id/versions, PATCH /versions/:id, POST /versions/:id/publish, /yank | version lifecycle, changelog | product.write | MVP |
| POST /versions/:id/files/init, /files/complete | presigned PUT to **private** bucket, then record size + sha256, enqueue scan | product.write | MVP |
| GET/POST/PATCH /categories | taxonomy + translations | product.write | MVP |
| GET /orders, GET /orders/:id | list/filter, detail | order.read | MVP |
| GET /refunds | refund queue (status filter) | refund.decide or order.read | MVP (G10) |
| GET /licenses, GET /licenses/:id | search by key prefix, email or order number; detail with activations. Never returns key hash or ciphertext | license.manage | MVP (G11) |
| GET /attention | counts that need action, limited to what the caller may act on | any staff | MVP (G9) |
| GET /search | global search across orders, customers, products, tickets, licenses (see authorization rules) | any staff, results filtered per permission | MVP (owner decision, replaces G18 deferral) |
| POST /refunds/:id/decide | approve → provider refund API → revoke entitlement and license if `revoke_access` | refund.decide | MVP |
| GET/POST/PATCH /coupons | CRUD + targets | coupon.write | MVP |
| GET /reviews, POST /reviews/:id/moderate | publish/reject/hide, staff reply | review.moderate | MVP |
| GET /customers, GET /customers/:id, POST /customers/:id/block | support view | user.manage / order.read | MVP |
| POST /licenses/:id/revoke, /reissue | revoke (also revokes the entitlement; the single revocation path used by order detail and customer detail) or reissue key | license.manage | MVP |
| GET /tickets, POST /tickets/:id/reply, PATCH /tickets/:id | support desk | support.reply | MVP |
| GET /analytics/overview, /products, /funnel, /revenue | read `analytics_daily` + orders | analytics.read | MVP |
| GET/PATCH /settings | flags, limits | settings.write | MVP |
| GET /audit, GET /security-events | logs | audit.read | MVP |
| GET/POST /users/:id/roles | assign roles | user.manage | MVP |
| GET /exports/orders.csv | accounting export | order.read | V2 |
| POST /vendors, /vendor-applications/:id/decide, /payouts | multi-vendor admin | (future perms) | FUT |

## Background jobs

| job | schedule | does |
| --- | --- | --- |
| email-outbox-drain | every minute | send queued emails with retry/backoff |
| webhook-retry | every 10 min | reprocess `webhook_events` in `failed` |
| pending-order-expiry | hourly | cancel `pending` orders older than 24 h |
| file-scan | on upload | AV/heuristic scan, set `scan_status` (blocks downloads until `clean`) |
| analytics-rollup | nightly | `analytics_events` → `analytics_daily`; prune raw events >90 days |
| entitlement-expiry | nightly | expire `updates_until`/license `expires_at` |
| cart-cleanup | weekly | drop abandoned guest carts |
| visitor-salt-rotation | daily | rotate salt for cookieless visitor hash |
| gdpr-deletion | daily | process deletion requests (anonymise user, keep legally required order data) |
| backup-verify | weekly | restore latest backup into scratch DB, run smoke queries |


## Authorization rules for Phase 3 routes

Rules apply in the server handler **and** are asserted by tests; RLS protects direct database reads as a second layer. "404 not 403" means the response is identical for "does not exist" and "not yours", so ids cannot be probed.

| route | who | rule | data returned | extra controls |
| --- | --- | --- | --- | --- |
| GET /api/me/reviews | user | own rows only; no id parameter exists | review fields, product title and slug | 401 when signed out |
| GET /api/support/tickets/:id | owner or staff (support.reply) | `ticket.user_id = session user` or permission; otherwise 404 | ticket, messages (staff-only notes are V2 and are never returned to owners) | rate limit |
| GET /api/library (fields) | user | entitlements of the session user only | adds review_status, update_available, downloaded_version | none |
| GET /api/products/:slug (manifest) | anon | published products and published versions only; file entries only for `scan_status = clean` | filename, kind, size, SHA-256, scan status; **no storage_key, no file id, no URL** | file ids are returned only by `GET /api/library/:entitlementId` to the owner |
| GET /api/products (new filters) | anon | allowlists: `includes` ∈ the 6 values, `sort` ∈ allowlist, `updated_within` ∈ {30,90,365}, `price_*` integers ≥ 0, `page size ≤ 48`; invalid values return 400 | published products only | admin variant alone accepts `scan=flagged` and status |
| GET /api/products/suggest | anon | min 2 characters; published only | titles and slugs | rate limit 60/min per IP |
| GET /api/admin/attention | staff | each counter is included only if the caller holds its permission: refunds (refund.decide), reviews (review.moderate), files flagged (product.write), failed webhooks (audit.read), tickets (support.reply); no permission means `{}` | counts only, no personal data | cached 30 s per user |
| GET /api/admin/refunds | refund.decide or order.read | list is read-only for order.read; decisions need refund.decide | order number, customer email (order.read only), item, reason, amount, age | audit on decisions |
| GET /api/admin/licenses(/:id) | license.manage | any holder may search | `key_prefix`, edition, status, activations (fingerprint hash first 8 chars, label, last seen); **never key_hash or key_ciphertext** | detail views audited |
| PATCH/DELETE /api/admin/media/:id | product.write | media must belong to a product the caller may edit (vendor scope is added by the future multi-vendor migration) | updated media | audit; delete also removes the stored object |
| GET /api/admin/search | any staff | query ≥ 3 characters; per type the caller needs: orders and customers → order.read; products → product.write; tickets → support.reply; licenses (key prefix only) → license.manage; **types the caller cannot use are omitted silently**, never a 403 that reveals them | max 5 results per type; id, label, status; email shown only with order.read | indexed columns only (email prefix, order number prefix, key prefix, product title trigram), never message bodies; rate limit 20/min per user; audit entry stores result counts and a hash of the query, not the query text |

## Phase 3 integration summary (revision 2)

- **Added routes (8):** `GET /api/me/reviews`, `GET /api/support/tickets/:id`, `GET /api/admin/attention`, `GET /api/admin/refunds`, `GET /api/admin/licenses` and `/:id`, `PATCH|DELETE /api/admin/media/:id`, `GET /api/admin/search`.
- **Changed routes (4), all additive except one:** `GET /api/products` (new optional params), `GET /api/products/:slug` (manifest fields), `GET /api/library` (new fields), admin `GET /products` (filter); **`GET /api/products/suggest` changes response shape** (grouped instead of a flat title list), which is safe only because no client exists yet.
- **Not added, by design:** a separate "reviews waiting" endpoint (derived from `GET /api/library`), a separate "revoke access" endpoint (use licenses revoke), a separate order-receipt endpoint (receipt link is returned in order detail from `payments.receipt_url`).
- Schema changes behind these routes: `schema_addendum_phase3.sql` (migration 002).
