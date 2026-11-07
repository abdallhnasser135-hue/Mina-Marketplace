-- replica/schema_future.sql  |  NOT applied in v1. Additive only: nothing here changes v1 tables.
-- Enabling multi-vendor = apply this file + flip settings 'features.multi_vendor' + build seller UI.
create table vendor_members (
  vendor_id uuid not null references vendors(id) on delete cascade,
  user_id uuid not null references users(id) on delete cascade,
  role text not null check (role in ('owner','editor','viewer')),
  created_at timestamptz not null default now(),
  primary key (vendor_id, user_id)
);
create index vendor_members_user on vendor_members (user_id);

create table vendor_payout_accounts (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references vendors(id) on delete cascade,
  provider text not null,
  external_account_ref text not null,
  status text not null default 'pending' check (status in ('pending','verified','disabled')),
  created_at timestamptz not null default now(),
  unique (vendor_id, provider)
);
create table vendor_payouts (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references vendors(id) on delete restrict,
  period_start date not null,
  period_end date not null,
  gross_cents bigint not null,
  fee_cents bigint not null,
  net_cents bigint not null,
  currency char(3) not null,
  status text not null default 'draft' check (status in ('draft','approved','paid','failed')),
  provider_payout_ref text,
  created_at timestamptz not null default now(),
  check (period_end >= period_start)
);
create index vendor_payouts_vendor on vendor_payouts (vendor_id, period_start);
create table vendor_applications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  status text not null default 'submitted' check (status in ('submitted','approved','rejected')),
  answers jsonb not null default '{}',
  reviewed_by uuid references users(id) on delete set null,
  created_at timestamptz not null default now()
);
create index vendor_applications_user on vendor_applications (user_id);
create index vendor_applications_reviewer on vendor_applications (reviewed_by);
-- Also future: product_submissions (review queue), malware-scan pipeline for third-party uploads,
-- RLS policies scoped by vendor_members, per-vendor analytics rollups.
