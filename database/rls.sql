-- replica/rls.sql  |  Supabase row-level security (defence in depth)
-- Rule: browsers never write directly. All writes go through server code using the
-- DB connection / service role (bypasses RLS). RLS only governs direct reads via the
-- Supabase client, and protects us if an API key leaks or a query is written wrong.
-- Requires Supabase's auth.uid().

create schema if not exists app;
create or replace function app.has_permission(p text) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from user_roles ur
    join role_permissions rp on rp.role_id = ur.role_id
    where ur.user_id = auth.uid() and rp.permission_key = p);
$$;

do $$
declare t text;
begin
  -- 1) enable RLS everywhere in public (deny by default)
  for t in select tablename from pg_tables where schemaname = 'public' loop
    execute format('alter table %I enable row level security', t);
  end loop;
end $$;

-- 2) public catalog reads (anon + authenticated)
create policy cat_read on categories for select using (is_active);
create policy cat_tr_read on category_translations for select using (true);
create policy prod_read on products for select using (status = 'published');
create policy prod_tr_read on product_translations for select
  using (exists (select 1 from products p where p.id = product_id and p.status = 'published'));
create policy edition_read on product_editions for select
  using (is_active and exists (select 1 from products p where p.id = product_id and p.status = 'published'));
create policy media_read on product_media for select
  using (exists (select 1 from products p where p.id = product_id and p.status = 'published'));
create policy tags_read on tags for select using (true);
create policy ptags_read on product_tags for select using (true);
create policy review_read on reviews for select using (status = 'published' or user_id = auth.uid());
create policy version_read on product_versions for select
  using (status = 'published' and exists (select 1 from products p where p.id = product_id and p.status = 'published'));
-- product_files, license_templates, webhook_events, settings: NO client policy = no client access.

-- 3) owner-only reads
create policy users_self on users for select using (id = auth.uid());
create policy wishlist_own on wishlist_items for select using (user_id = auth.uid());
create policy orders_own on orders for select using (user_id = auth.uid());
create policy order_items_own on order_items for select
  using (exists (select 1 from orders o where o.id = order_id and o.user_id = auth.uid()));
create policy ent_own on entitlements for select using (user_id = auth.uid());
create policy lic_own on licenses for select
  using (exists (select 1 from entitlements e where e.id = entitlement_id and e.user_id = auth.uid()));
create policy tickets_own on support_tickets for select using (user_id = auth.uid());
create policy ticket_msgs_own on ticket_messages for select
  using (exists (select 1 from support_tickets s where s.id = ticket_id and s.user_id = auth.uid()));
create policy dl_own on download_events for select using (user_id = auth.uid());

-- 4) staff reads (admin UI uses server code, these cover direct reads)
create policy orders_staff on orders for select using (app.has_permission('order.read'));
create policy audit_staff on audit_logs for select using (app.has_permission('audit.read'));
create policy sec_staff on security_events for select using (app.has_permission('audit.read'));
