# Architecture: premium single-vendor technology marketplace (multi-vendor-ready)

Phase 2 output of the Replica pipeline. Inputs: `recon.md`, `features.csv`, your approved decisions. Companion files: `schema.sql`, `seed.sql`, `rls.sql`, `schema_future.sql`, `api.md`, `traceability.csv`, `validation/`.

## 0. Approved decisions (recorded)

1. Single-vendor first; architecture multi-vendor-compatible; multi-vendor disabled in v1.
2. You sell your own products only; no external seller registration or upload in v1.
3. The reference is a UX/functional reference, not a ceiling. Scope is a full marketplace.
4. Realistic MVP, low running cost, no paid service activated without your approval.
5. No payment gateway is assumed available until verified.

## 1. Release tiers

**MVP (v1)**: catalog with 14 categories, tags, FTS + fuzzy search, filters/sorting; product pages with editions (Personal/Commercial), media, compatibility, version history; EN/AR with RTL/LTR; accounts with verified email (MFA for staff); cart, wishlist, coupons; hosted checkout through one verified provider; webhook-driven orders; entitlements, license keys (generate, reveal, validate, activate); protected downloads (short-lived links, limits, logs, scan gate); customer library, order history and status; verified-purchase reviews with moderation; support tickets and contact; newsletter double opt-in; admin (products, versions, files, categories, orders, refunds, coupons, reviews, customers, licenses, tickets, analytics, settings, audit/security logs, roles); first-party cookieless analytics; transactional email.

**Version 2**: second payment provider for local EGP methods (Paymob, if verified); displayed EGP prices; affiliate/referral links; bundles and subscriptions/updates plans; per-buyer watermarking of delivered archives; Meilisearch/Typesense for Arabic-aware search; personal-data export; accounting CSV exports; request-access flow for team/enterprise licenses; abandoned-cart emails; public API keys for developers.

**Future multi-vendor** (schema hooks exist, UI and logic do not): `vendor_members`, payout accounts, payouts, vendor applications (`schema_future.sql`); seller dashboard; commission engine (`order_items.platform_fee_cents / vendor_earnings_cents` already exist); product submission review queue with a malware-scan pipeline; vendor-scoped RLS and analytics; marketplace-compliant payment flow (see §3: the provider I researched prohibits marketplaces, so this needs a different payments design, not just a flag).

Note on "seller dashboard": in v1 the platform vendor is the only seller, so seller features collapse into the admin area. A separate seller UI is a future item.

## 2. Stack evaluation

| layer | choice | why | alternatives considered | cost note |
| --- | --- | --- | --- | --- |
| web | Next.js (App Router) + TypeScript | one codebase for storefront, admin and API; SSR/ISR for SEO; large ecosystem | Remix, SvelteKit (fine, smaller ecosystem for admin/auth tooling) | free software |
| styling / i18n | Tailwind with logical utilities (`ms-`, `pe-`, `start`/`end`), `next-intl` | RTL for free when logical properties are used consistently; tokens come from Phase 3 | CSS modules | free |
| database | PostgreSQL on Supabase | Postgres features I rely on (FTS, trigram, RLS, partial unique indexes, triggers) plus auth in one place | Neon + separate auth | free tier exists; production tier to be checked |
| auth | Supabase Auth | email verification, password reset, MFA and OAuth already built and maintained; less security code for us to get wrong | Auth.js, Clerk | included |
| ORM | Drizzle | SQL-first, stays close to `schema.sql` | Prisma | free |
| files | Cloudflare R2: one **private** bucket (product ZIPs), one **public** bucket (images/GIFs) | S3-compatible presigned URLs; low storage cost | Supabase Storage, S3 | to be checked |
| payments | provider adapter interface; first adapter **Lemon Squeezy** (see §3) | merchant of record, lists Egypt for bank payouts, handles tax | Paymob (local), Stripe/Paddle (availability for Egypt-based sellers not verified) | per-sale fee only (see §3) |
| email | Resend (SMTP/API) behind an `email_outbox` table | simple API; outbox gives retries and an audit trail | Amazon SES | to be checked |
| jobs | Vercel Cron + DB outbox/queues | no extra infrastructure | Inngest/Trigger.dev when needed | free tier |
| search | Postgres FTS (`simple` config) + `pg_trgm` | enough for hundreds to low thousands of products | Meilisearch/Typesense (V2) | free |
| analytics | first-party tables + nightly rollup | cookieless, private, no third-party tracker | GA, Plausible | free |
| bot/abuse | Cloudflare Turnstile (forms), Cloudflare WAF/CDN in front, Upstash-style rate limiter | cheap protection for auth, contact, license API | in-DB rate limits | free tiers likely; to be checked |
| monitoring | Sentry + uptime check + structured logs | catches errors and webhook failures | Datadog (overkill) | free tiers likely; to be checked |
| hosting | Vercel (fallback: Fly/Render/VPS) | zero-ops for Next.js | self-host | **I have not verified hosting plan terms; some free plans restrict commercial use. Check before launch.** |

Principle: one database, no microservices, every part replaceable. Prices other than the payment fee below are **not verified**; each paid step is an approval gate for you.

## 3. Payments: what is verified and what is not

**Verified from public sources (read today):**
- Lemon Squeezy's own supported-countries page lists **Egypt among bank-payout countries**, and PayPal payouts in 200+ countries. It says bank payouts are converted to local currency at the mid-market rate on payout day (secondary source quoting that page).
- It is a **merchant of record**: it is the legal seller, collects and remits tax, and you do not handle VAT filing (per third-party summaries and its own docs).
- Its prohibited-products page allows software/SaaS and lists, among others, **"marketplaces" where you use your store to sell others' products**, and spyware. This confirms the single-vendor decision is also a payments requirement.
- Reported fee (secondary sources, not the provider's page): **5% + $0.50 per transaction**, payouts in USD, roughly twice a month with a 13-day hold. Worked example: $5.99 item ≈ 13% total; $19.99 item ≈ 7.5%; $49 item ≈ 6%. This pushes toward higher-priced products and bundles.
- Paymob (Cairo-based) advertises cards, mobile wallets and other methods in Egypt. It is **not a merchant of record**, so tax and compliance remain yours (secondary sources).

**Not verified (do not assume):**
- Whether Lemon Squeezy will approve a store selling **cybersecurity tools**. Its prohibited list mentions spyware; offensive/dual-use tooling may be refused. Ask its support in writing with your product list before building around it. Keep v1 security products defensive or educational.
- The current status of Lemon Squeezy after its reported acquisition by Stripe (secondary source). Confirm the service and its terms are stable.
- Whether its API supports the exact discount/custom-price mechanism I need to apply your own coupons. Fallback: create provider-side discount codes or fixed-price variants from the admin.
- Whether Stripe, PayPal, Paddle or others will onboard an Egypt-based seller. I did not research Stripe or Paddle for Egypt; treat them as unavailable until confirmed.
- Whether Paymob accepts a digital-goods store and which international cards it settles.
- Banking: one vendor-authored source says National Bank of Egypt limits domestic FX transactions to $250/month on standard accounts. Ask your bank how USD payouts are treated.
- Your own tax and legal position as an Egyptian seller. I am not a lawyer or accountant; get professional advice.

**Design that survives any outcome:** a `PaymentProvider` interface (`createCheckout`, `verifyWebhook`, `refund`), so the provider can be swapped without touching orders, licenses or delivery. Development uses a `test` provider adapter that only works outside production. The only code path that marks an order paid is a verified webhook (never a browser redirect).

**Status: no provider is activated, no account created, no money handled.**

## 4. System overview

```
Browser ──> Cloudflare (CDN/WAF) ──> Next.js on Vercel ──┬─> Supabase Postgres (+Auth, RLS)
   │                                   │  storefront     ├─> R2 public bucket  (images/GIFs, direct)
   │                                   │  customer area  ├─> R2 private bucket (ZIPs, presigned only)
   │                                   │  admin          ├─> Resend (email via outbox)
   │                                   │  /api, /api/v1  └─> Sentry
   └── hosted checkout <──────────────>│ webhook in  <── Payment provider (verified signature)
```

## 5. Core flows

**Purchase and delivery (the critical path)**
1. User (verified email) checks out. Server re-prices every item from the DB, applies the coupon, creates a `pending` order and a provider checkout session; user is redirected.
2. Provider calls our webhook. We verify the signature on the **raw body**, store the event (`unique(provider,event_id)`), then in **one transaction**: confirm amount/currency match the order, mark paid, insert payment, entitlements, licenses, coupon redemption, and queue the confirmation email.
3. User returns; the page polls `/orders/:n/status` until `paid` (webhook may lag).
4. Library shows the product. Download button calls `POST /downloads/:fileId/link`: checks session, active entitlement, published version, `scan_status = clean`, daily limit and rate limit; writes `download_events`; returns a presigned URL valid for about 5 minutes. The private bucket URL is never stored or shown.
5. Refund: customer requests, staff approves, provider refund API is called, order/entitlement/license are updated per the `revoke_access` flag, everything audited.

**License keys.** 100-bit random key in Crockford base32 (`XXXXX-XXXXX-XXXXX-XXXXX`, prefix per product). Stored as `key_hash` = HMAC-SHA256(server secret, key) for verification and `key_ciphertext` = AES-256-GCM so the owner can view it again after re-authentication. Validation API uses the hash, constant-time responses and strict rate limits. Activations limited per edition. Honest limit: source code cannot be copy-protected; licenses, per-buyer identifiers (V2 watermarking) and terms are the deterrent.

**Reviews.** `reviews.entitlement_id` is NOT NULL and UNIQUE, so only a real purchaser can review, once per product; new and edited reviews start `pending` until moderated; rating aggregates are maintained by a trigger.

## 6. Security architecture

| threat | control |
| --- | --- |
| Fake "payment succeeded" | only a signature-verified webhook marks paid; amount, currency and order ref must match; idempotent replay-safe processing |
| Price tampering | all pricing recomputed server-side; client never sends amounts |
| Unauthorized download / link sharing | auth + active entitlement; 5-minute presigned URLs; daily limits; event log; scan gate; private bucket with no public listing |
| IDOR (reading others' orders/licenses) | ownership check in every query **and** RLS as a second layer (tested: other users see 0 rows) |
| Account takeover | Supabase Auth with verified email, rate-limited login, breached-password protections where available, security events; **MFA required for all staff** |
| Admin abuse/compromise | least-privilege permissions, recent re-auth for refunds, roles and settings, append-only `audit_logs` (enforced by DB trigger, tested) |
| License brute force | 100-bit keys, HMAC lookup, per-IP and per-key limits, uniform responses |
| XSS (markdown product text, reviews, tickets) | sanitize rendered markdown, strict CSP with nonces, escape everywhere else |
| CSRF | SameSite cookies, Origin check on mutating routes; webhooks excluded and signature-checked instead |
| SQL injection | parameterized queries only (ORM), zod validation on every input |
| Malicious files in the catalog | admin-only upload in v1; checksum + malware scan before `clean`; product review checklist rejects malware, spyware and exploit kits (also required by card networks and providers) |
| Secrets exposure | env vars only, service-role key server-only, `.env.example` committed, rotation notes in docs |
| Supply chain | lockfile, automated dependency alerts, minimal dependencies |
| Bots / spam | Turnstile on sign-up, contact, newsletter; WAF rate limits |
| Data loss | managed DB backups per chosen plan plus a weekly encrypted logical dump to R2; weekly restore test (job above) |
| Privacy | cookieless analytics, hashed IPs, minimal PII, deletion workflow that anonymises users but keeps legally required order records; Egypt's personal-data protection law should be reviewed with a lawyer |

Transport/headers: HTTPS only, HSTS, CSP, `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`.

## 7. Analytics architecture

Raw events (`analytics_events`) from `/api/collect`: page_view, product_view, search, add_to_cart, begin_checkout, wishlist_add, download. Visitor identity is a **daily-rotating salted hash** (no cookie, no raw IP). Money metrics come from `orders`/`order_items`, never from client events. A nightly job fills `analytics_daily`; admin dashboards read the rollup. Dashboards: revenue, orders, AOV, funnel (view → cart → checkout → purchase), top products, coupon performance, refund rate, downloads per product. Raw events pruned after 90 days.

## 8. Arabic/English and RTL/LTR

URL prefix `/en` and `/ar` with `hreflang`; `<html dir>` set per locale; logical CSS properties only; directional icons mirrored; code blocks and file names stay LTR inside RTL text; bilingual emails; content in `*_translations` tables (a product can ship in one language first). Postgres has no Arabic text-search configuration, so v1 uses the `simple` config plus trigram matching; the app should normalize Arabic (diacritics, alef/yaa variants) before indexing. Better Arabic stemming is a V2 search-engine upgrade. Number system (Western vs Arabic-Indic digits) and fonts are Phase 3 decisions.

## 9. The parts that bite

- **Idempotency:** webhooks repeat and arrive out of order; processing must be a no-op the second time.
- **Races:** coupon `max_redemptions` and per-user limits need an atomic conditional update inside the order transaction; two tabs buying the same edition must not create two entitlements (`order_items` unique per order, `entitlements.order_item_id` unique).
- **Refund after download:** business rule needed (see open items); system supports both revoke and keep.
- **Time:** everything `timestamptz` in UTC; display per user locale.
- **Money:** integer cents plus currency; checks keep `total = subtotal - discount + tax`.
- **Uploads:** large ZIPs go browser → R2 by presigned PUT, never through serverless request bodies.
- **Email deliverability:** SPF/DKIM/DMARC on the sending domain before launch.
- **Deletion vs retention:** deleting a user must not delete financial records.
- **Provider lock-in:** isolated behind the adapter.
- **Fees on cheap items:** a flat per-sale fee makes sub-$10 items unattractive.

## 10. Implementation roadmap

Each milestone lists what must work before the next begins.

| # | milestone | scope | exit criteria |
| --- | --- | --- | --- |
| M0 | Foundation | repo, CI, lint, env handling, migrations from `schema.sql`/`seed.sql`, RLS applied, i18n/RTL shell, design tokens (from Phase 3) | app boots in en/ar; migrations apply to a clean DB; secrets only via env |
| M1 | Vertical slice | one product, sign-up/login, `test` payment adapter, webhook → order → entitlement → license → presigned download, receipt email | end-to-end purchase and download works locally; webhook replay does not duplicate anything |
| M2 | Catalog & discovery | home, catalog, category, search, filters, product page, version history, license summary | filters/sort/search work in both languages; pages are accessible and responsive |
| M3 | Accounts, cart, library | cart, wishlist, coupons applied at checkout, orders, order status, library, license reveal | guest cart merges; owned items blocked; other users cannot read your data |
| M4 | Real payments (**gated on your approval and verification**) | provider adapter, hosted checkout, webhook, refunds | test-mode purchase and refund pass; nothing live until you approve |
| M5 | Admin | products, editions, versions, file upload + scan, categories, orders, refunds, coupons, customers, licenses, roles, settings | staff MFA enforced; every mutation audited |
| M6 | Reviews, support, analytics, content | verified reviews + moderation, tickets, contact, newsletter, analytics rollup + dashboards, legal/FAQ/about pages | funnel and revenue dashboards match order data |
| M7 | Hardening and launch prep | security tests, load smoke test, backups and restore test, monitoring, deploy config (Phases 6, 10, 11) | no critical findings; restore tested; deploy checklist complete |

Phase mapping to your pipeline: Phase 3 designs the screens below; Phase 4 builds M0–M3 frontend; Phase 5 builds backend M1/M4/M5; Phase 6 tests; Phase 7 compares against `traceability.csv`.

## 11. Screen inventory for Phase 3 (design handoff)

Public: home, catalog, category, search results, product detail, cart, checkout return/order status, about, FAQ, contact, legal pages (terms, privacy, refund, license terms), 404/error.
Account: sign up, log in, verify email, reset password, MFA setup, profile, orders list, order detail, library, library item (versions, downloads, license key, activations), wishlist, my reviews, support center, ticket thread.
Admin: dashboard, products list, product editor (details, translations, editions, media, versions and files), categories, orders, order detail with refund, customers, customer detail, coupons, reviews moderation, tickets, licenses, analytics (overview, products, funnel), settings, roles, audit and security logs.
Cross-cutting states to design: empty, loading, error, permission denied, offline/failed download, already owned, out-of-stock-equivalent (unpublished), RTL variants, mobile.

## 12. Open items that need you (none block Phase 3)

1. Apply for the payment provider account (needs your identity and bank details, which I cannot supply) and ask in writing whether your cybersecurity product list is acceptable.
2. Talk to an accountant/lawyer about receiving foreign revenue, tax status and seller-of-record obligations in Egypt.
3. Refund policy (suggested default to decide: refunds allowed before first download or for demonstrable defects).
4. Hosting and email plan choices once real prices are checked (approval gates).
5. Brand name and domain (Phase 9).
6. Prices are USD-only in v1 unless you object.
7. Licence wording for each product type should be reviewed by a lawyer before launch.

## 13. Phase 2 validation

See `validation/phase2-validation.log` (generated by running `validation/check-schema.mjs` against a real Postgres engine). Summary in the final report.
