# Design validation: gaps against architecture.md, api.md and schema.sql

Method: every screen in `screens.md` was checked against the routes in `api.md`, the tables in `schema.sql` and the feature tiers in `traceability.csv` (`validate-design.py`, results at the end). The design needed additions in 18 places. **Nothing in the Phase 2 files was edited**; additions live in `schema_addendum_phase3.sql` (applied and tested on a real Postgres engine, `validation/check-addendum.mjs`) and in the API additions below. Phase 5 folds them into the base migrations and `api.md`.

| id | needed by | gap | resolution | where |
| --- | --- | --- | --- | --- |
| G1 | W01, W05, C10 | listings show a file tree and counts (files, tests); schema stores only archives | `product_versions.contents jsonb`; filled from the archive listing in the scan job, stats editable by admin. The scan job must read the listing safely (zip-bomb limits, no extraction) | schema addendum |
| G2 | W02 to W04 | "Includes" facet (tests, docs, Docker, CI, demo, types) | `products.includes text[]` with check constraint and GIN index | schema addendum |
| G3 | W02 to W04, W01 | "Updated within" filter and "recently updated" sort | `products.last_released_at`, maintained by trigger when a version is published (tested: older releases never move it back) | schema addendum |
| G4 | W02 to W04 | price filter and price sort ("From $49") | `products.price_from_cents`, maintained by trigger from active editions (tested through insert, deactivate, delete) | schema addendum |
| G5 | W06 | buyer must accept license and refund terms; we need proof of what applied | `orders.terms_accepted_at`, `orders.terms_version`, `order_items.license_template_id` snapshot | schema addendum |
| G6 | C08 | link to the provider's receipt/invoice | `orders.provider_receipt_url` | schema addendum |
| G7 | C12 | list of my reviews and purchases without a review | **new** `GET /api/me/reviews` (user): reviews with status plus entitlements lacking a review | API addition |
| G8 | C14 | open one ticket with its messages | **new** `GET /api/support/tickets/:id` (owner) | API addition |
| G9 | M01 | attention queue counts | **new** `GET /api/admin/attention` (any staff; returns only counts the user may act on): pending refunds, reviews pending, files flagged, failed webhooks, tickets waiting over 24 h | API addition |
| G10 | M17 | refund queue list | **new** `GET /api/admin/refunds?status=` (refund.decide) | API addition |
| G11 | M12 | search and open licenses | **new** `GET /api/admin/licenses?q=` and `GET /api/admin/licenses/:id` with activations (license.manage); keys never returned in full | API addition |
| G12 | M03 | reorder, edit alt text, delete media | **new** `PATCH /api/admin/media/:id`, `DELETE /api/admin/media/:id` (product.write) | API addition |
| G13 | W01 to W05, M02 | param and response changes to existing routes | `GET /api/products`: add `sort=updated`, `exclude=<slug>`, `includes=`, `price_min/max` use `price_from_cents`; `GET /api/products/suggest`: return grouped `{products, categories, languages}`; `GET /api/admin/products`: add `scan=flagged` filter | API change |
| G14 | W08, W09, W11 to W14, W16 | static content pages | decision: translated MDX files in the repo (versioned, reviewed), no CMS in MVP; W14 renders `license_templates` | decision |
| G15 | W10 | anonymous contact has no thread | decision: signed-out contact creates a ticket and emails a confirmation; replies go by email; a thread view needs an account | decision |
| G16 | W05, W01 | Share and cookie notice | client-only (Web Share API; notice is informational because analytics is cookieless); no API | decision |
| G17 | W01 | hero manifest needs a featured listing | `settings` key `home.featured_product` (slug or null) | schema addendum (seed) |
| G18 | AdminShell | global admin search | **removed from MVP**; each list has its own search; global search is V2 | scope change |

## Also noted

- **Features check:** all 38 MVP rows in `traceability.csv` map to at least one screen (`design-traceability.csv`). The 2 V2 rows, the future row, 3 skipped rows and the N/A row map to none, by design.
- **Routes with no screen (by design):** webhooks, the machine licence API (`/api/v1/licenses/*`), `/api/collect`, `/api/me/sync`, `/api/me/export` (V2), job-only endpoints. Listed by the validator.
- **Content that needs the owner:** About copy, FAQ answers, legal texts, real product listings, screenshots, refund window, response-time promise. The design never invents these.
- **Arabic copy:** drafted by me; needs native review before launch.
- **Brand:** codename, logo tower and colours are provisional until Phase 9.
