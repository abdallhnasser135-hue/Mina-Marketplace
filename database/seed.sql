-- replica/seed.sql  |  required reference data (run after schema.sql)
insert into vendors (id, slug, display_name, status, is_platform_owned)
values ('00000000-0000-0000-0000-000000000001', 'platform', 'Platform (first-party)', 'active', true);

insert into roles (key, description) values
  ('customer','Default buyer'),
  ('support','Support agent'),
  ('catalog_manager','Manages products and reviews'),
  ('admin','Full administrator');

insert into permissions (key, description) values
  ('product.write','Create/edit products, versions, files'),
  ('product.publish','Publish or archive products'),
  ('order.read','View orders and customers'),
  ('refund.decide','Approve or reject refunds'),
  ('coupon.write','Manage coupons'),
  ('review.moderate','Moderate reviews'),
  ('support.reply','Reply to tickets'),
  ('license.manage','Revoke or reissue licenses'),
  ('analytics.read','View analytics'),
  ('settings.write','Change platform settings'),
  ('user.manage','Manage users and roles'),
  ('audit.read','View audit and security logs');

insert into role_permissions (role_id, permission_key)
select r.id, p.key from roles r join permissions p on
  (r.key = 'admin')
  or (r.key = 'support' and p.key in ('order.read','support.reply','license.manage'))
  or (r.key = 'catalog_manager' and p.key in ('product.write','product.publish','review.moderate','coupon.write','analytics.read'));

insert into settings (key, value) values
  ('features.multi_vendor', 'false'),
  ('features.seller_registration', 'false'),
  ('download.max_per_entitlement_per_day', '10'),
  ('download.link_ttl_seconds', '300'),
  ('reviews.require_moderation', 'true'),
  ('locales.enabled', '["en","ar"]');

-- 14 launch categories (flat in v1; tags cover overlaps)
with c(slug, sort, en, ar) as (values
 ('software-projects',1,'Software Projects','مشاريع البرمجيات'),
 ('ai-machine-learning',2,'AI & Machine Learning','الذكاء الاصطناعي وتعلّم الآلة'),
 ('cybersecurity',3,'Cybersecurity Tools & Projects','أدوات ومشاريع الأمن السيبراني'),
 ('web-development',4,'Web Development','تطوير الويب'),
 ('mobile-apps',5,'Mobile Applications','تطبيقات الجوّال'),
 ('saas-templates',6,'SaaS Templates','قوالب SaaS'),
 ('automation-tools',7,'Automation Tools','أدوات الأتمتة'),
 ('python-projects',8,'Python Projects','مشاريع بايثون'),
 ('source-code-packages',9,'Source Code Packages','حزم الشيفرة المصدرية'),
 ('developer-resources',10,'Developer Resources','موارد المطورين'),
 ('ui-kits-design-systems',11,'UI Kits & Design Systems','حزم الواجهات وأنظمة التصميم'),
 ('apis-integrations',12,'APIs & Integrations','واجهات برمجية وتكاملات'),
 ('technical-documentation',13,'Technical Documentation','وثائق تقنية'),
 ('ready-to-deploy-apps',14,'Ready-to-deploy Applications','تطبيقات جاهزة للنشر')),
ins as (insert into categories (slug, sort_order) select slug, sort from c returning id, slug)
insert into category_translations (category_id, locale, name)
select ins.id, l.locale, case l.locale when 'en' then c.en else c.ar end
from ins join c on c.slug = ins.slug cross join (values ('en'),('ar')) as l(locale);
