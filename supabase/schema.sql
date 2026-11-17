-- =====================================================================
-- Nheb Panha portfolio: Supabase schema
-- Run once in Supabase → SQL Editor. Safe to re-run.
--
-- Access model
--   projects, blog_posts           public READ (anon key, used by the Flutter app)
--   contact_submissions, chat_logs NO public access; written only by the
--                                  Cloudflare Worker with the service-role key
--                                  (service role bypasses RLS).
-- =====================================================================

-- ---------------------------------------------------------------- projects
create table if not exists public.projects (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  category    text not null,
  description text not null,
  -- Icon key understood by the app: shopping_bag | storefront | delivery |
  -- phone | web | dns | storage | code. Unknown keys fall back to a default.
  icon        text not null default 'code',
  tags        jsonb not null default '[]'::jsonb,   -- ["Flutter", "Dart"]
  demo_url    text,                                 -- shown only if it starts with http
  source_url  text,
  sort_order  int  not null default 0,              -- ascending
  published   boolean not null default true,
  created_at  timestamptz not null default now()
);

alter table public.projects enable row level security;
drop policy if exists "Public can read published projects" on public.projects;
create policy "Public can read published projects"
  on public.projects for select
  to anon, authenticated
  using (published);

-- ---------------------------------------------------------------- blog_posts
create table if not exists public.blog_posts (
  id          uuid primary key default gen_random_uuid(),
  slug        text not null unique,
  title       text not null,
  category    text not null,
  summary     text not null,
  -- Plain text. Blocks separated by a blank line; a line starting with
  -- "### " is a sub-heading.
  content     text not null,
  read_time   text not null default '5 min read',
  published_at text not null,                       -- display date, e.g. 'Jul 2025'
  tags        jsonb not null default '[]'::jsonb,
  sort_order  int  not null default 0,
  published   boolean not null default true,
  created_at  timestamptz not null default now()
);

alter table public.blog_posts enable row level security;
drop policy if exists "Public can read published posts" on public.blog_posts;
create policy "Public can read published posts"
  on public.blog_posts for select
  to anon, authenticated
  using (published);

-- ---------------------------------------------------------------- contact_submissions
create table if not exists public.contact_submissions (
  id         uuid primary key default gen_random_uuid(),
  name       text not null check (char_length(name) <= 120),
  email      text not null check (char_length(email) <= 200),
  type       text not null default 'General Inquiry' check (char_length(type) <= 80),
  message    text not null check (char_length(message) <= 5000),
  status     text not null default 'unread',
  created_at timestamptz not null default now()
);

-- RLS on with no policies = no anon/authenticated access at all.
alter table public.contact_submissions enable row level security;

-- ---------------------------------------------------------------- chat_logs
create table if not exists public.chat_logs (
  id           uuid primary key default gen_random_uuid(),
  user_prompt  text not null,
  bot_response text not null,
  created_at   timestamptz not null default now()
);

alter table public.chat_logs enable row level security;

-- =====================================================================
-- Seed: current site content (only inserts rows that don't exist yet)
-- =====================================================================

insert into public.projects (title, category, description, icon, tags, sort_order)
select * from (values
  ('RED ANT Express', 'E-Commerce',
   'Customer app for ordering and sending parcels, with real-time tracking, QR code scanning and live delivery status updates.',
   'shopping_bag', '["Flutter", "Dart"]'::jsonb, 1),
  ('RED ANT Merchant', 'Merchant App',
   'Merchant app for managing orders, creating shipments and following every parcel from pickup to delivery.',
   'storefront', '["Flutter", "Dart"]'::jsonb, 2),
  ('RED ANT Driver', 'Delivery App',
   'Driver app for pickups and drop-offs with route updates, QR scanning and offline caching that syncs when the connection returns.',
   'delivery', '["Flutter", "Dart"]'::jsonb, 3),
  ('E-Shop Native', 'E-Commerce',
   'Native Android and iOS shopping app with product search, categories, a cart and checkout.',
   'phone', '["Kotlin", "Swift"]'::jsonb, 4)
) as v(title, category, description, icon, tags, sort_order)
where not exists (select 1 from public.projects p where p.title = v.title);

insert into public.blog_posts (slug, title, category, summary, content, read_time, published_at, tags, sort_order)
values
(
  'flutter-supabase-realtime',
  'Building Real-Time Mobile Apps with Flutter & Supabase',
  'Mobile Architecture',
  'A practical guide to implementing BLoC state isolation, Supabase Row-Level Security (RLS), and offline-first Hive caching in Flutter production apps.',
  E'Building real-time mobile applications requires a decoupled architecture that balances UI responsiveness, local data caching, and secure cloud synchronization.\n\n### 1. State Management with BLoC Pattern\nUsing the Business Logic Component (BLoC) pattern separates presentation logic from data streaming. This ensures predictable state transitions when receiving real-time WebSocket events from Supabase.\n\n### 2. Row Level Security (RLS) Policies\nSupabase PostgreSQL database policies allow row-level authorization directly at the database layer. By enforcing RLS, client mobile apps interact securely with data without complex intermediary API proxies.\n\n### 3. Offline-First Hive & Isar Caching\nTo maintain sub-100ms UI interactions, local key-value stores like Hive cache remote payloads locally. When network connectivity drops, operations queue locally and sync atomically once reconnected.',
  '5 min read', 'Jul 2025', '["Flutter", "Supabase", "BLoC", "PostgreSQL"]'::jsonb, 1
),
(
  'nuxt3-ssr-glassmorphism',
  'Optimizing Nuxt 3 SSR & Glassmorphism Design Tokens',
  'Frontend Engineering',
  'How to craft ultra-fast Vue 3 applications using Nuxt 3 server-side rendering, dynamic dark mode themes, and performance-first CSS glass utilities.',
  E'Modern web interfaces must deliver immediate visual impact without sacrificing Lighthouse web vitals or page transition speeds.\n\n### 1. Server-Side Rendering (SSR) Optimization\nNuxt 3 leverages Vite and Nitro server engines to render HTML payloads on the server. By utilizing `useAsyncData` with key caching, payload payloads double in initial load speed.\n\n### 2. Custom CSS Glass Tokens\nInstead of relying on heavy third-party UI libraries, custom backdrop-filter CSS utility classes maintain high frame rates (60fps) during window scrolling and dark mode transitions.',
  '4 min read', 'Jun 2025', '["Nuxt 3", "Vue 3", "Tailwind CSS", "SSR"]'::jsonb, 2
),
(
  'laravel-nodejs-api-throughput',
  'Architecting High-Throughput REST APIs in Laravel & Node.js',
  'Backend Systems',
  'Database indexing strategies, background worker queues, and automated Telegram bot telemetry triggers for mission-critical API backends.',
  E'When handling high daily transaction volume, API backend performance hinges on SQL indexing precision and asynchronous background queues.\n\n### 1. Database Indexing & Query Optimization\nCreating compound indexes on frequent query filter columns reduces database search time by up to 40%. Avoiding N+1 queries using Eloquent eager loading ensures tight memory bounds.\n\n### 2. Operational Error Telemetry with Telegram\nBy integrating automated webhook triggers into exception handlers, engineering teams receive immediate real-time stack trace alerts in Telegram channels for instantaneous triage.',
  '6 min read', 'May 2025', '["Laravel", "Node.js", "MySQL", "Telegram API"]'::jsonb, 3
)
on conflict (slug) do nothing;
