-- replica/schema.sql  |  Phase 2  |  PostgreSQL 15+ (Supabase-compatible)
-- Single-vendor MVP. Every sellable thing carries vendor_id pointing at ONE seeded
-- platform vendor, so multi-vendor later is data + features, not a redesign.
-- Money = integer minor units (cents) + currency. Times = timestamptz (UTC).

create extension if not exists pg_trgm;

create or replace function set_updated_at() returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;

-- ───────── vendors (one row in v1) ─────────
create table vendors (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  display_name text not null,
  status text not null default 'active' check (status in ('pending','active','suspended')),
  is_platform_owned boolean not null default false,
  commission_bps int not null default 0 check (commission_bps between 0 and 10000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index vendors_one_platform on vendors (is_platform_owned) where is_platform_owned;

-- ───────── users & RBAC ─────────
-- users.id equals the auth provider's user id (Supabase auth.users.id).
create table users (
  id uuid primary key,
  email text not null,
  display_name text,
  locale text not null default 'en' check (locale in ('en','ar')),
  status text not null default 'active' check (status in ('active','blocked','deleted')),
  marketing_opt_in boolean not null default false,
  email_verified_at timestamptz,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index users_email_lower on users (lower(email));

create table roles (
  id uuid primary key default gen_random_uuid(),
  key text not null unique,
  description text
);
create table permissions (key text primary key, description text);
create table role_permissions (
  role_id uuid not null references roles(id) on delete cascade,
  permission_key text not null references permissions(key) on delete cascade,
  primary key (role_id, permission_key)
);
create table user_roles (
  user_id uuid not null references users(id) on delete cascade,
  role_id uuid not null references roles(id) on delete restrict,
  granted_by uuid references users(id) on delete set null,
  created_at timestamptz not null default now(),
  primary key (user_id, role_id)
);
create index user_roles_role on user_roles (role_id);

-- ───────── catalog ─────────
create table categories (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid references categories(id) on delete restrict,
  slug text not null unique,
  icon text,
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index categories_parent on categories (parent_id);
create table category_translations (
  category_id uuid not null references categories(id) on delete cascade,
  locale text not null check (locale in ('en','ar')),
  name text not null,
  description text,
  primary key (category_id, locale)
);

create table license_templates (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references vendors(id) on delete restrict,
  key text not null,
  version int not null default 1,
  scope text not null check (scope in ('personal','commercial','team','enterprise')),
  allows_redistribution boolean not null default false,
  terms_i18n jsonb not null default '{}',          -- {"en": "...md", "ar": "...md"}
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (vendor_id, key, version)
);

create table products (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references vendors(id) on delete restrict,
  category_id uuid not null references categories(id) on delete restrict,
  slug text not null unique,
  status text not null default 'draft' check (status in ('draft','in_review','published','archived')),
  delivery_type text not null default 'both' check (delivery_type in ('download','license_key','both')),
  is_featured boolean not null default false,
  tech_stack text[] not null default '{}',
  compatibility jsonb not null default '{}',       -- {"os":[..],"python":">=3.10",...}
  demo_url text,
  rating_avg numeric(3,2) not null default 0,
  rating_count int not null default 0,
  sales_count int not null default 0,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (status <> 'published' or published_at is not null)
);
create index products_vendor on products (vendor_id);
create index products_category_status on products (category_id, status, published_at desc);
create index products_status_featured on products (status, is_featured);
create index products_tech_stack on products using gin (tech_stack);

create table product_translations (
  product_id uuid not null references products(id) on delete cascade,
  locale text not null check (locale in ('en','ar')),
  title text not null,
  summary text,
  description_md text,
  seo_title text,
  seo_description text,
  search_vector tsvector generated always as (
    to_tsvector('simple', coalesce(title,'') || ' ' || coalesce(summary,'') || ' ' || coalesce(description_md,''))
  ) stored,
  primary key (product_id, locale)
);
create index product_translations_fts on product_translations using gin (search_vector);
create index product_translations_title_trgm on product_translations using gin (title gin_trgm_ops);

create table tags (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  names_i18n jsonb not null default '{}'
);
create table product_tags (
  product_id uuid not null references products(id) on delete cascade,
  tag_id uuid not null references tags(id) on delete cascade,
  primary key (product_id, tag_id)
);
create index product_tags_tag on product_tags (tag_id);

create table product_media (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references products(id) on delete cascade,
  kind text not null check (kind in ('image','screenshot','gif','video')),
  storage_key text not null,                        -- PUBLIC media bucket only
  alt_i18n jsonb not null default '{}',
  sort_order int not null default 0,
  is_cover boolean not null default false,
  created_at timestamptz not null default now()
);
create index product_media_product on product_media (product_id, sort_order);
create unique index product_media_one_cover on product_media (product_id) where is_cover;

-- editions = the purchasable SKUs (e.g. Personal / Commercial)
create table product_editions (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references products(id) on delete cascade,
  key text not null,
  name_i18n jsonb not null default '{}',
  price_cents int not null check (price_cents >= 0),
  compare_at_cents int check (compare_at_cents is null or compare_at_cents >= price_cents),
  currency char(3) not null default 'USD',
  license_template_id uuid references license_templates(id) on delete restrict,
  activation_limit int not null default 3 check (activation_limit >= 0),
  update_window_days int,                           -- null = lifetime updates
  is_active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (product_id, key)
);
create index product_editions_template on product_editions (license_template_id);

create table edition_provider_refs (                -- maps our SKU to a payment provider's product/variant
  edition_id uuid not null references product_editions(id) on delete cascade,
  provider text not null,
  external_id text not null,
  primary key (edition_id, provider)
);

create table product_versions (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references products(id) on delete cascade,
  version text not null,
  changelog_i18n jsonb not null default '{}',
  requirements jsonb not null default '{}',
  status text not null default 'draft' check (status in ('draft','published','yanked')),
  is_current boolean not null default false,
  released_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (product_id, version)
);
create unique index product_versions_one_current on product_versions (product_id) where is_current;

create table product_files (                        -- PRIVATE bucket; never exposed as a URL
  id uuid primary key default gen_random_uuid(),
  version_id uuid not null references product_versions(id) on delete cascade,
  storage_key text not null unique,
  filename text not null,
  kind text not null default 'archive' check (kind in ('archive','docs','other')),
  size_bytes bigint not null check (size_bytes >= 0),
  sha256 char(64) not null,
  content_type text not null,
  scan_status text not null default 'pending' check (scan_status in ('pending','clean','flagged','error')),
  created_at timestamptz not null default now()
);
create index product_files_version on product_files (version_id);

-- ───────── cart, wishlist ─────────
create table carts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade,
  guest_token_hash text unique,
  status text not null default 'active' check (status in ('active','converted','abandoned')),
  currency char(3) not null default 'USD',
  coupon_code text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (user_id is not null or guest_token_hash is not null)
);
create index carts_user on carts (user_id, status);
create table cart_items (
  cart_id uuid not null references carts(id) on delete cascade,
  edition_id uuid not null references product_editions(id) on delete cascade,
  added_at timestamptz not null default now(),
  primary key (cart_id, edition_id)                 -- digital goods: quantity is always 1
);
create index cart_items_edition on cart_items (edition_id);

create table wishlist_items (
  user_id uuid not null references users(id) on delete cascade,
  product_id uuid not null references products(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, product_id)
);
create index wishlist_product on wishlist_items (product_id);

-- ───────── coupons ─────────
create table coupons (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  kind text not null check (kind in ('percent','fixed')),
  value int not null check (value > 0),
  currency char(3),
  starts_at timestamptz,
  ends_at timestamptz,
  max_redemptions int check (max_redemptions is null or max_redemptions > 0),
  per_user_limit int not null default 1 check (per_user_limit > 0),
  min_order_cents int not null default 0 check (min_order_cents >= 0),
  applies_to text not null default 'all' check (applies_to in ('all','products','categories')),
  is_active boolean not null default true,
  created_by uuid references users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (kind <> 'percent' or value <= 100),
  check (kind <> 'fixed' or currency is not null),
  check (ends_at is null or starts_at is null or ends_at > starts_at)
);
create unique index coupons_code_upper on coupons (upper(code));
create table coupon_targets (
  id uuid primary key default gen_random_uuid(),
  coupon_id uuid not null references coupons(id) on delete cascade,
  product_id uuid references products(id) on delete cascade,
  category_id uuid references categories(id) on delete cascade,
  check ((product_id is not null)::int + (category_id is not null)::int = 1)
);
create index coupon_targets_coupon on coupon_targets (coupon_id);
create index coupon_targets_product on coupon_targets (product_id);
create index coupon_targets_category on coupon_targets (category_id);

-- ───────── orders & payments ─────────
create sequence order_number_seq;
create table orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique default
    ('ORD-' || to_char(now() at time zone 'utc','YYYY') || '-' || lpad(nextval('order_number_seq')::text, 6, '0')),
  user_id uuid not null references users(id) on delete restrict,
  status text not null default 'pending'
    check (status in ('pending','paid','failed','cancelled','partially_refunded','refunded')),
  currency char(3) not null,
  subtotal_cents int not null check (subtotal_cents >= 0),
  discount_cents int not null default 0 check (discount_cents >= 0),
  tax_cents int not null default 0 check (tax_cents >= 0),
  total_cents int not null check (total_cents >= 0),
  coupon_id uuid references coupons(id) on delete set null,
  provider text not null,
  provider_order_ref text,
  email text not null,
  locale text not null default 'en',
  paid_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (total_cents = subtotal_cents - discount_cents + tax_cents),
  check (status <> 'paid' or paid_at is not null)
);
create index orders_user on orders (user_id, created_at desc);
create index orders_status on orders (status, created_at desc);
create index orders_coupon on orders (coupon_id);
create unique index orders_provider_ref on orders (provider, provider_order_ref) where provider_order_ref is not null;

create table order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete restrict,
  product_id uuid not null references products(id) on delete restrict,
  edition_id uuid not null references product_editions(id) on delete restrict,
  vendor_id uuid not null references vendors(id) on delete restrict,
  title_snapshot text not null,
  edition_snapshot text not null,
  unit_price_cents int not null check (unit_price_cents >= 0),
  discount_cents int not null default 0 check (discount_cents >= 0),
  platform_fee_cents int not null default 0 check (platform_fee_cents >= 0),     -- future multi-vendor
  vendor_earnings_cents int not null default 0 check (vendor_earnings_cents >= 0), -- future multi-vendor
  created_at timestamptz not null default now(),
  unique (order_id, edition_id)
);
create index order_items_order on order_items (order_id);
create index order_items_product on order_items (product_id);
create index order_items_edition on order_items (edition_id);
create index order_items_vendor on order_items (vendor_id);

create table payments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete restrict,
  provider text not null,
  provider_payment_ref text not null,
  status text not null check (status in ('pending','succeeded','failed','refunded')),
  amount_cents int not null check (amount_cents >= 0),
  currency char(3) not null,
  method text,
  meta jsonb not null default '{}',                 -- redacted; never card data
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (provider, provider_payment_ref)
);
create index payments_order on payments (order_id);

create table refunds (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete restrict,
  order_item_id uuid references order_items(id) on delete restrict,
  payment_id uuid references payments(id) on delete restrict,
  amount_cents int not null check (amount_cents > 0),
  reason text,
  status text not null default 'requested' check (status in ('requested','approved','processed','rejected','failed')),
  provider_refund_ref text,
  requested_by uuid references users(id) on delete set null,
  decided_by uuid references users(id) on delete set null,
  revoke_access boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index refunds_order on refunds (order_id);
create index refunds_item on refunds (order_item_id);
create index refunds_payment on refunds (payment_id);

create table webhook_events (                       -- idempotency + replay log
  id uuid primary key default gen_random_uuid(),
  provider text not null,
  event_id text not null,
  event_type text not null,
  payload jsonb not null,
  status text not null default 'received' check (status in ('received','processed','failed','ignored')),
  error text,
  received_at timestamptz not null default now(),
  processed_at timestamptz,
  unique (provider, event_id)
);
create index webhook_events_status on webhook_events (status, received_at);

create table coupon_redemptions (
  id uuid primary key default gen_random_uuid(),
  coupon_id uuid not null references coupons(id) on delete restrict,
  order_id uuid not null references orders(id) on delete restrict,
  user_id uuid not null references users(id) on delete restrict,
  amount_cents int not null check (amount_cents >= 0),
  created_at timestamptz not null default now(),
  unique (coupon_id, order_id)
);
create index coupon_redemptions_user on coupon_redemptions (coupon_id, user_id);
create index coupon_redemptions_order on coupon_redemptions (order_id);
create index coupon_redemptions_user_only on coupon_redemptions (user_id);

-- ───────── entitlements, licenses, downloads ─────────
create table entitlements (                         -- "this user may access this product edition"
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete restrict,
  product_id uuid not null references products(id) on delete restrict,
  edition_id uuid not null references product_editions(id) on delete restrict,
  order_item_id uuid not null unique references order_items(id) on delete restrict,
  status text not null default 'active' check (status in ('active','revoked','expired')),
  updates_until timestamptz,                        -- null = lifetime
  revoked_at timestamptz,
  revoked_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index entitlements_user on entitlements (user_id, status);
create index entitlements_product on entitlements (product_id);
create index entitlements_edition on entitlements (edition_id);

create table licenses (
  id uuid primary key default gen_random_uuid(),
  entitlement_id uuid not null unique references entitlements(id) on delete restrict,
  key_prefix text not null,                         -- first chars, for support lookup
  key_hash char(64) not null unique,                -- HMAC-SHA256(server secret, key): verification
  key_ciphertext text not null,                     -- AES-256-GCM: lets owner re-view key
  status text not null default 'active' check (status in ('active','revoked','expired')),
  activation_limit int not null check (activation_limit >= 0),
  expires_at timestamptz,
  issued_at timestamptz not null default now(),
  revoked_at timestamptz,
  revoked_reason text
);
create table license_activations (
  id uuid primary key default gen_random_uuid(),
  license_id uuid not null references licenses(id) on delete cascade,
  fingerprint_hash char(64) not null,
  label text,
  first_seen_at timestamptz not null default now(),
  last_seen_at timestamptz not null default now(),
  revoked_at timestamptz,
  unique (license_id, fingerprint_hash)
);

create table download_events (                      -- every issued download link, for limits + forensics
  id uuid primary key default gen_random_uuid(),
  entitlement_id uuid not null references entitlements(id) on delete restrict,
  file_id uuid not null references product_files(id) on delete restrict,
  user_id uuid not null references users(id) on delete restrict,
  ip_hash text,
  user_agent_hash text,
  issued_at timestamptz not null default now(),
  expires_at timestamptz not null
);
create index download_events_ent_time on download_events (entitlement_id, issued_at desc);
create index download_events_file on download_events (file_id);
create index download_events_user on download_events (user_id);

-- ───────── reviews (verified purchasers only, enforced by FK) ─────────
create table reviews (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references products(id) on delete cascade,
  user_id uuid not null references users(id) on delete cascade,
  entitlement_id uuid not null unique references entitlements(id) on delete restrict,
  rating smallint not null check (rating between 1 and 5),
  title text,
  body text,
  locale text not null default 'en' check (locale in ('en','ar')),
  status text not null default 'pending' check (status in ('pending','published','rejected','hidden')),
  staff_reply text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (product_id, user_id)
);
create index reviews_product_status on reviews (product_id, status, created_at desc);
create index reviews_user on reviews (user_id);

create or replace function recompute_product_rating() returns trigger language plpgsql as $$
declare pid uuid := coalesce(new.product_id, old.product_id);
begin
  update products p set
    rating_avg = coalesce((select round(avg(rating)::numeric,2) from reviews r where r.product_id = pid and r.status = 'published'), 0),
    rating_count = (select count(*) from reviews r where r.product_id = pid and r.status = 'published')
  where p.id = pid;
  return null;
end $$;
create trigger reviews_rating_aiud after insert or update or delete on reviews
  for each row execute function recompute_product_rating();

-- ───────── support, newsletter ─────────
create table support_tickets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete set null,
  email text not null,
  order_id uuid references orders(id) on delete set null,
  subject text not null,
  category text not null default 'general' check (category in ('general','order','download','license','refund','bug')),
  status text not null default 'open' check (status in ('open','pending','resolved','closed')),
  priority text not null default 'normal' check (priority in ('low','normal','high')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index support_tickets_user on support_tickets (user_id);
create index support_tickets_order on support_tickets (order_id);
create index support_tickets_status on support_tickets (status, created_at desc);
create table ticket_messages (
  id uuid primary key default gen_random_uuid(),
  ticket_id uuid not null references support_tickets(id) on delete cascade,
  author_user_id uuid references users(id) on delete set null,
  is_staff boolean not null default false,
  body text not null,
  created_at timestamptz not null default now()
);
create index ticket_messages_ticket on ticket_messages (ticket_id, created_at);

create table newsletter_subscribers (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  locale text not null default 'en' check (locale in ('en','ar')),
  confirmed_at timestamptz,
  unsubscribed_at timestamptz,
  created_at timestamptz not null default now()
);
create unique index newsletter_email_lower on newsletter_subscribers (lower(email));

-- ───────── platform: email outbox, settings, audit, security, analytics ─────────
create table email_outbox (
  id uuid primary key default gen_random_uuid(),
  to_email text not null,
  template text not null,
  locale text not null default 'en',
  payload jsonb not null default '{}',
  status text not null default 'queued' check (status in ('queued','sent','failed')),
  attempts int not null default 0,
  send_after timestamptz not null default now(),
  sent_at timestamptz,
  provider_message_id text,
  created_at timestamptz not null default now()
);
create index email_outbox_due on email_outbox (status, send_after);

create table settings (
  key text primary key,
  value jsonb not null,
  updated_by uuid references users(id) on delete set null,
  updated_at timestamptz not null default now()
);

create table audit_logs (                           -- append-only (enforced by trigger below)
  id bigint generated always as identity primary key,
  actor_user_id uuid references users(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id text,
  diff jsonb,
  ip_hash text,
  created_at timestamptz not null default now()
);
create index audit_logs_actor on audit_logs (actor_user_id, created_at desc);
create index audit_logs_entity on audit_logs (entity_type, entity_id);
create or replace function forbid_mutation() returns trigger language plpgsql as $$
begin raise exception 'audit_logs is append-only'; end $$;
create trigger audit_logs_no_update before update or delete on audit_logs
  for each row execute function forbid_mutation();

create table security_events (
  id bigint generated always as identity primary key,
  user_id uuid references users(id) on delete set null,
  kind text not null,                               -- login_failed, download_denied, webhook_bad_sig, ...
  severity text not null default 'info' check (severity in ('info','warn','critical')),
  ip_hash text,
  meta jsonb not null default '{}',
  created_at timestamptz not null default now()
);
create index security_events_user on security_events (user_id, created_at desc);
create index security_events_kind on security_events (kind, created_at desc);

create table analytics_events (                     -- first-party, cookieless, no raw IP
  id bigint generated always as identity primary key,
  occurred_at timestamptz not null default now(),
  event_name text not null check (event_name in
    ('page_view','product_view','search','add_to_cart','begin_checkout','purchase','download','wishlist_add')),
  visitor_hash text,                                -- daily-rotating salted hash
  user_id uuid references users(id) on delete set null,
  product_id uuid references products(id) on delete set null,
  locale text,
  referrer_host text,
  utm jsonb not null default '{}',
  props jsonb not null default '{}'
);
create index analytics_events_time on analytics_events (occurred_at);
create index analytics_events_product on analytics_events (product_id, event_name, occurred_at);
create index analytics_events_user on analytics_events (user_id);
create table analytics_daily (                      -- nightly rollup; dashboards read this
  day date not null,
  product_id uuid references products(id) on delete cascade,
  views int not null default 0,
  cart_adds int not null default 0,
  checkouts int not null default 0,
  orders int not null default 0,
  revenue_cents bigint not null default 0,
  downloads int not null default 0
);
create unique index analytics_daily_key on analytics_daily (day, coalesce(product_id, '00000000-0000-0000-0000-000000000000'::uuid));
create index analytics_daily_product on analytics_daily (product_id);

-- ───────── updated_at triggers on every table that has the column ─────────
do $$
declare t text;
begin
  for t in select table_name from information_schema.columns
           where table_schema = 'public' and column_name = 'updated_at'
  loop
    execute format('create trigger %I before update on %I for each row execute function set_updated_at()', t || '_set_updated_at', t);
  end loop;
end $$;

-- ───────── supplementary FK indexes (admin/actor columns) ─────────
create index coupons_created_by on coupons (created_by);
create index refunds_requested_by on refunds (requested_by);
create index refunds_decided_by on refunds (decided_by);
create index role_permissions_perm on role_permissions (permission_key);
create index settings_updated_by on settings (updated_by);
create index ticket_messages_author on ticket_messages (author_user_id);
create index user_roles_granted_by on user_roles (granted_by);
