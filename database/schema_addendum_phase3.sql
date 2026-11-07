-- replica/schema_addendum_phase3.sql  |  migration 002 (v2)  |  Phase 3 design requirements.
-- Forward-only and SAFE ON A POPULATED DATABASE: new columns are nullable or defaulted, existing rows are
-- backfilled, constraints are added after the backfill. Tested on fresh and populated databases
-- (validation/check-migration.mjs). Apply after schema.sql, seed.sql and rls.sql.
-- Changes from v1 of this file: (a) terms evidence no longer breaks existing orders, (b) last_released_at is
-- recomputed on yank/delete, (c) receipt link moved to payments, (d) prefix-search indexes for admin search.

-- G1: contents tree + stats shown on listings
--   {"tree":[{"path":"src","type":"dir","children":[...]}], "stats":{"files":24,"tests":61,"docs":["README","API guide"]}}
alter table product_versions add column contents jsonb not null default '{}'::jsonb;

-- G2: controlled "Includes" facet (not free-form tags)
alter table products add column includes text[] not null default '{}';
alter table products add constraint products_includes_values
  check (includes <@ array['tests','docs','docker','ci','demo','types']::text[]);
create index products_includes on products using gin (includes);

-- G3: last_released_at (filter "Updated within", sort "Recently updated"); always derived from published versions
alter table products add column last_released_at timestamptz;
create or replace function refresh_last_released(pid uuid) returns void language sql as $$
  update products
     set last_released_at = (select max(released_at) from product_versions v where v.product_id = pid and v.status = 'published')
   where id = pid
$$;
create or replace function versions_release_trg() returns trigger language plpgsql as $$
begin perform refresh_last_released(coalesce(new.product_id, old.product_id)); return null; end $$;
create trigger versions_release_aiud after insert or delete or update of status, released_at on product_versions
  for each row execute function versions_release_trg();
update products p set last_released_at =
  (select max(released_at) from product_versions v where v.product_id = p.id and v.status = 'published');
create index products_last_released on products (status, last_released_at desc);

-- G4: price_from_cents (price filter/sort, "From $49"); always derived from active editions
alter table products add column price_from_cents int check (price_from_cents is null or price_from_cents >= 0);
create or replace function editions_price_from_trg() returns trigger language plpgsql as $$
declare pid uuid := coalesce(new.product_id, old.product_id);
begin
  update products set price_from_cents =
    (select min(price_cents) from product_editions e where e.product_id = pid and e.is_active) where id = pid;
  return null;
end $$;
create trigger editions_price_from_aiud after insert or delete or update of price_cents, is_active on product_editions
  for each row execute function editions_price_from_trg();
update products p set price_from_cents =
  (select min(price_cents) from product_editions e where e.product_id = p.id and e.is_active);
create index products_price_from on products (status, price_from_cents);

-- G5: evidence of what the buyer accepted, and which license text applied.
-- Orders that already exist are marked 'legacy' (no evidence was recorded; none is invented).
-- Every order created after this migration must carry both fields; 'legacy' is rejected for new orders.
alter table orders add column terms_accepted_at timestamptz;
alter table orders add column terms_version text;
update orders set terms_version = 'legacy' where terms_version is null;
do $m$ begin
  execute format($f$alter table orders add constraint orders_terms_evidence check (
    (terms_accepted_at is not null and terms_version is not null)
    or (terms_version = 'legacy' and terms_accepted_at is null and created_at < %L::timestamptz))$f$, now());
end $m$;
alter table order_items add column license_template_id uuid references license_templates(id) on delete restrict;
create index order_items_license_template on order_items (license_template_id);

-- G6: provider receipt/invoice link belongs to the payment (an order can have several payment attempts)
alter table payments add column receipt_url text;

-- G18 (reversed by owner decision): admin global search needs prefix-searchable columns
create index users_email_prefix on users (lower(email) text_pattern_ops);
create index orders_number_prefix on orders (order_number text_pattern_ops);
create index licenses_key_prefix on licenses (key_prefix text_pattern_ops);
create index support_tickets_email_prefix on support_tickets (lower(email) text_pattern_ops);

-- G17: featured product for the home hero manifest
insert into settings (key, value) values ('home.featured_product', 'null'::jsonb) on conflict (key) do nothing;
