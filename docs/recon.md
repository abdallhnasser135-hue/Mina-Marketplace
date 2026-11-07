# Recon map: Payhip seller storefront "JIN2 Studio" (web)

Scope: public storefront of one Payhip seller (shop, product page, contact, cart, wishlist, login entry) plus Payhip's publicly documented seller and pricing model
For: Abdallun's own multi-category technology marketplace (digital code products), operating from Egypt
Date: 2026-11-05

## Important finding: the reference is not a marketplace

`payhip.com/JIN2` is a **single-seller shop with one product** ("WILL YOU — Diamond Ring · Full Python Source", $5.99, ZIP ~10 KB), selling Python ASCII code art. It has no categories, no filters, no product grid beyond one card, and "You Might Also Like" shows "No products found". It is a template storefront rendered by **Payhip**, the platform.

So there are two different things to study, and this map separates them:

1. **Observed**: what the JIN2 shop actually shows (high confidence).
2. **Platform context**: what Payhip publicly documents or what third-party reviews report (medium confidence, not verified from inside any seller dashboard).

Everything in your directive beyond this (categories, multi-vendor, admin, seller dashboard, AR/EN RTL, refunds, analytics) is **not present in the reference** and is requirements from your brief, not clone targets. They are marked `source=brief` in features.csv.

## Sources

| # | source | URL | notes |
| --- | --- | --- | --- |
| 1 | shop home | https://payhip.com/JIN2 | observed |
| 2 | product page | https://payhip.com/b/4vXRc | observed |
| 3 | contact page | https://payhip.com/JIN2/contact | observed |
| 4 | login entry (not opened, not logged in) | https://payhip.com/JIN2/users/login | link seen only |
| 5 | Payhip pricing (via reviews, read Oct 2026) | https://www.inkfluenceai.com/blog/payhip-review-2026 | secondary; verify at payhip.com/pricing |
| 6 | Payhip pricing breakdown | https://sellfy.com/blog/payhip-pricing/ | competitor-authored, bias possible |
| 7 | Egypt payments | https://dodopayments.com/blogs/merchant-of-record-in-egypt | vendor-authored, bias possible |
| 8 | Paymob overview | https://yespress.io/paymob.md | press, secondary |

Not used: seller dashboards, Payhip JS bundles, network calls, any logged-in area.

## Core loop

A visitor lands on a seller shop, opens a product, pays by card or PayPal, and instantly receives a download (ZIP) with a license; they can later review it from the download page linked in the receipt email.

## Screens

| ID | screen | route / how to reach | purpose | key components | states seen |
| --- | --- | --- | --- | --- | --- |
| S01 | Shop home | `/JIN2` | showcase seller + products | header, hero product card, about block, follow/email capture, footer | filled (1 product) |
| S02 | Product page | `/b/4vXRc` | sell one product | media (image + GIF preview), title, price, Buy Now, Add to cart, wishlist, description, included files, requirements, license summary, share, related | filled, "On Sale", "in library", added-to-cart, wishlist toggled |
| S03 | Contact | `/JIN2/contact` | message the seller | form: first name, last name, email, message, Send | empty; success modal |
| S04 | Login | `/JIN2/users/login` | buyer account | not opened | unknown |
| S05 | Cart drawer | "Your Cart" panel | review items | loader, items | loading; error "Could not add item to cart" |
| S06 | Search overlay | header search icon, "View all results" | find products | results list | empty (not exercised) |
| S07 | Cookie banner | all pages | consent | Reject / Accept | shown |
| S08 | Review dialog | product page | explains reviews only after purchase via receipt link | modal | seen as message only |
| S09 | Buyer download page | `/JIN2/b-account/digital/4vXRc` | access purchase | link only, behind login | unseen |
| S10 | Application/request form modal | generic form success text mentions acceptance then checkout link | invite-only or approval products | modal | message only; unused on this shop (guess) |
| S11 | Legal/footer pages | Privacy, GDPR, EU VAT | compliance | links | not read |

## Flows

```
F01 Visitor buys a product (guest)
    S01 shop -> S02 product -> Buy Now -> checkout (not observed) -> receipt email -> S09 download
    happy path clicks to checkout from shop: 2 (card, then Buy Now), checkout steps unobserved
    edge: add-to-cart error, already-owned product ("already in your library"), cookie rejection

F02 Visitor adds to cart
    S02 -> Add to cart -> S05 -> checkout
    edge: "Could not add item to cart"

F03 Wishlist
    S02 -> Add to wishlist (toggle). Whether it needs login: unknown.

F04 Contact the seller
    S03 form -> success modal

F05 Returning buyer downloads
    login S04 -> library -> S09
    (unobserved; inferred from "View Content" link)

F06 Review after purchase
    receipt email -> download page -> review. Reviews are purchase-gated (observed message).
```

## Components

| component | variants | states | used on |
| --- | --- | --- | --- |
| Header nav | desktop, mobile | default | all |
| Search | overlay, "View all results" | empty (unseen) | all |
| Cart badge/drawer | count 0 | loading, error | all |
| Product card | hero | default | S01 |
| Buy Now / Add to cart button | primary | default, added | S02 |
| Wishlist toggle | add / added | toggled | S02 |
| Price + sale tag | "On Sale" | | S01, S02 |
| Form fields | text, email, textarea | empty | S03 |
| Modal | success, error, confirm | | S03, S05, S08, S10 |
| Cookie banner | Reject / Accept | | all |
| Payment-brand strip | Maestro, Mastercard, PayPal, Visa, Discover | | footer |
| Share control | | | S02 |

## Inferred data model

```
Seller      id, handle, shop_name, bio, hero_image, instagram, locale
            evidence: S01, S02 footer; confidence: high (fields), guess (schema)
Product     id, seller_id, slug/short_id, title, description_html, price, currency,
            on_sale, preview_media[], files[], size_bytes, license_text, requirements_text
            evidence: S02; confidence: high
ProductFile name, size, type (ZIP)    evidence: S02 "You will get a ZIP (10KB)"; confidence: medium
Buyer       id, email, seller scope   evidence: S04, "already in your library"; confidence: medium
Order       id, buyer_id, product_ids, amount, payment_method, status, receipt_email
            evidence: receipt email message; confidence: medium
Cart/Wishlist items                   evidence: S05, S02; confidence: medium
Review      product_id, buyer_id, rating, text, purchase-gated
            evidence: S08; confidence: medium
Message     seller_id, name, email, body          evidence: S03; confidence: high
Follower    email                                 evidence: S01 follow field; confidence: medium
```

Relationships: Seller 1-n Product, Product 1-n ProductFile, Buyer 1-n Order, Order n-n Product, Product 1-n Review, Seller 1-n Follower.

Not observable here (guess only): license keys, download limits, expiring links, coupons, affiliates, VAT handling. Reviews and pricing pages mention several of these; they stay **unverified** until checked against Payhip's own help docs.

## Feature matrix

See `features.csv`. Rows with `source=observed` come from the shop; `source=platform` from Payhip's public docs/reviews (unverified); `source=brief` from your directive and are not clone targets.

## Competitive observations

- Payhip model per third-party sources (verify): Free 5% fee, Plus $29/mo 2%, Pro $99/mo 0%; PayPal/Stripe processing fees (about 2.9% + $0.30) on top. Seller is seller of record for tax.
- Gaps reviewers cite: limited fraud tooling, thin support, API covers only coupons and license keys.
- The JIN2 shop shows a tiny catalog, no previews beyond one GIF, no categories, no ratings visible, a cookie banner, and a bare-bones footer. Plenty of room to be better on discovery and trust, but there is no marketplace behavior to copy.

## Out of scope (cannot or should not be cloned)

- JIN2's product, code art, descriptions, images, license text, branding (protected content).
- Payhip's brand, code, assets, and its processing relationships.
- Payhip's network and buyer base.
- Payment processing licences and merchant-of-record status (regulated).

## Egypt payments (preliminary, needs verification)

- Paymob (Cairo-based) supports cards, wallets, Meeza and others in Egypt; secondary sources only.
- A source reports National Bank of Egypt limits domestic FX transactions to USD 250/month on standard accounts, which affects receiving USD. Unverified; confirm with your bank.
- Local gateways are not merchants of record, so tax and compliance would be yours.
- Which international gateways onboard an Egypt-based seller: unknown, must be checked directly.

## Size

Screens 11 (5 observed in full), flows 6, entities 9. Hard parts: payments from Egypt, secure digital delivery with licensing, multi-vendor payouts and tax, Arabic/English RTL, seller and admin dashboards, abuse/moderation of uploaded code. Size: **XL as briefed** (full multi-vendor marketplace with admin). Realistic first slice: **L** for a single-vendor store with delivery, licenses and an admin panel; multi-vendor as phase two.

## Next step

`/replica-architect`. Two decisions need you first (see summary).
