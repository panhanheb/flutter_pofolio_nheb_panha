// Static site content (the data source behind PortfolioRepository).
// Update this file to change the site; views never import it directly.
//
// NOTE: The redesigned Nuxt source named in role_flutter.md was not available
// locally. Structure, headings, labels and lists follow role_flutter.md exactly;
// longer copy (paragraphs, descriptions) is adapted from the older Nuxt source in
// ../portfolio_nheb_panha. Items marked TODO need the owner's review.

import 'package:flutter/material.dart';

import '../models/portfolio.dart';

// ---------------------------------------------------------------- Profile

const ownerName = 'Nheb Panha';
const ownerRole = 'Flutter & Full-Stack Developer';
const email = 'nhebpanha78@gmail.com';
const githubUrl = 'https://github.com/panhanheb';
const telegramUrl = 'https://t.me/nhebpanha';
const telegramHandle = '@nhebpanha';
const location = 'Phnom Penh, Cambodia';
const timezone = 'UTC+7';

const availability = 'Available for freelance and full-time roles';

// TODO(owner): confirm against the live HeroSection.vue copy.
const heroIntro =
    "I'm a Flutter and full-stack developer who builds reliable mobile apps, "
    'web applications and the backends behind them, with a focus on clean '
    'architecture and interfaces that are easy to use.';

const heroFacts = <(String, String)>[
  ('Focus', 'Mobile & Web'),
  ('Building since', '2022'),
  ('Core stack', 'Flutter · Nuxt'),
];

// TODO(owner): confirm against the live About.vue copy.
const aboutParagraphs = <String>[
  'I build cross-platform mobile apps with Flutter and Dart, and the web '
      'applications and APIs that support them. I care about dependable, '
      'production-ready software where clean architecture and predictable '
      'state management come first.',
  'Working on courier and delivery apps like RED ANT Express, e-commerce '
      'products and data-heavy tools, I keep presentation code separate from '
      'business logic and data sources, so apps stay easy to test, maintain '
      'and grow.',
  'On the web and backend side I use Nuxt and Vue, Laravel, Supabase '
      '(PostgreSQL with Row Level Security) and REST APIs to connect '
      'everything end to end.',
];

const coreStack = <String>[
  'Flutter',
  'Dart',
  'Nuxt',
  'Vue',
  'Laravel',
  'Supabase',
  'PostgreSQL',
  'TypeScript',
];

// TODO(owner): confirm card text against the live About.vue copy.
const services = <Service>[
  Service(
    Icons.phone_iphone_outlined,
    'Mobile apps',
    'Cross-platform Android and iOS apps in Flutter, with clear state '
        'management, offline caching and smooth, responsive UI.',
  ),
  Service(
    Icons.web_outlined,
    'Web applications',
    'Fast, accessible web apps and dashboards with Nuxt, Vue 3, TypeScript '
        'and Tailwind CSS.',
  ),
  Service(
    Icons.dns_outlined,
    'Backends & APIs',
    'REST APIs with Laravel and Node.js, Supabase auth and storage, and '
        'integrations such as the Telegram Bot API.',
  ),
  Service(
    Icons.storage_outlined,
    'Data & databases',
    'PostgreSQL and MySQL schema design, indexing and Row Level Security '
        'policies that keep data correct and secure.',
  ),
];

/// "How I work" statements (adapted from the old "What I care about" list).
const practices = <String>[
  'Readable, strictly typed code with clear abstractions that is easy to test.',
  'Fluid interactions, responsive layouts and thoughtful error states.',
  'Separate presentation, domain and data layers so code scales without regressions.',
  'Keep learning: modern design systems, backend platforms and mobile standards.',
];

// ---------------------------------------------------------------- Experience

// TODO(owner): these four entries are PLACEHOLDERS. Replace with real roles
// before launch.
const jobs = <Job>[
  Job(
    period: '2025 – Present',
    role: 'Flutter Developer',
    company: 'Company name',
    location: 'Phnom Penh',
    type: 'Full-time',
    summary: 'Building and maintaining production Flutter apps.',
    highlights: [
      'Ship features across customer, merchant and driver apps.',
      'Integrate REST APIs and manage state with BLoC.',
    ],
    tech: ['Flutter', 'Dart', 'BLoC', 'REST API'],
  ),
  Job(
    period: '2024 – 2025',
    role: 'Full-Stack Developer',
    company: 'Company name',
    location: 'Phnom Penh',
    type: 'Full-time',
    summary: 'Web applications and APIs for internal and client products.',
    highlights: [
      'Built Nuxt and Vue front ends backed by Laravel APIs.',
      'Designed PostgreSQL and MySQL schemas.',
    ],
    tech: ['Nuxt', 'Vue 3', 'Laravel', 'PostgreSQL'],
  ),
  Job(
    period: '2023 – 2024',
    role: 'Mobile Developer',
    company: 'Company name',
    location: 'Phnom Penh',
    type: 'Contract',
    summary: 'Native and cross-platform mobile work.',
    highlights: [
      'Built e-commerce screens and checkout flows.',
      'Added Firebase auth and push notifications.',
    ],
    tech: ['Flutter', 'Firebase', 'Kotlin', 'Swift'],
  ),
  Job(
    period: '2022 – 2023',
    role: 'Junior Developer',
    company: 'Company name',
    location: 'Phnom Penh',
    type: 'Internship',
    summary: 'First professional projects across web and mobile.',
    highlights: [
      'Built UI components and fixed bugs.',
      'Learned Git workflows and code review.',
    ],
    tech: ['Dart', 'JavaScript', 'MySQL', 'Git'],
  ),
];

// ---------------------------------------------------------------- Projects

// TODO(owner): descriptions should be copied from FALLBACK_PROJECTS in the
// current useSupabase.ts. Add store / demo / GitHub links when available.
const projects = <Project>[
  Project(
    title: 'RED ANT Express',
    category: 'E-Commerce',
    description:
        'Customer app for ordering and sending parcels, with real-time '
        'tracking, QR code scanning and live delivery status updates.',
    icon: Icons.shopping_bag_outlined,
    tags: ['Flutter', 'Dart'],
  ),
  Project(
    title: 'RED ANT Merchant',
    category: 'Merchant App',
    description:
        'Merchant app for managing orders, creating shipments and following '
        'every parcel from pickup to delivery.',
    icon: Icons.storefront_outlined,
    tags: ['Flutter', 'Dart'],
  ),
  Project(
    title: 'RED ANT Driver',
    category: 'Delivery App',
    description:
        'Driver app for pickups and drop-offs with route updates, QR scanning '
        'and offline caching that syncs when the connection returns.',
    icon: Icons.delivery_dining_outlined,
    tags: ['Flutter', 'Dart'],
  ),
  Project(
    title: 'E-Shop Native',
    category: 'E-Commerce',
    description:
        'Native Android and iOS shopping app with product search, '
        'categories, a cart and checkout.',
    icon: Icons.phone_iphone_outlined,
    tags: ['Kotlin', 'Swift'],
  ),
];

// ---------------------------------------------------------------- Skills

const skillGroups = <SkillGroup>[
  SkillGroup(Icons.phone_iphone_outlined, 'Mobile', [
    ('Flutter', 'Primary'),
    ('Dart', null),
    ('BLoC & Riverpod', null),
    ('Firebase', 'Auth, FCM'),
  ]),
  SkillGroup(Icons.web_outlined, 'Frontend', [
    ('Nuxt', 'Primary'),
    ('Vue 3', null),
    ('TypeScript', null),
    ('Tailwind CSS', null),
  ]),
  SkillGroup(Icons.dns_outlined, 'Backend', [
    ('Laravel', 'REST APIs'),
    ('Node.js & Express', null),
    ('Supabase', 'Auth, RLS'),
    ('Telegram Bot API', null),
  ]),
  SkillGroup(Icons.storage_outlined, 'Data', [
    ('PostgreSQL', null),
    ('MySQL', null),
    ('Redis', null),
  ]),
  SkillGroup(Icons.build_outlined, 'Tooling', [
    ('Git & GitHub Actions', 'CI/CD'),
    ('Docker', null),
    ('Figma', 'Design to code'),
  ]),
];

// ---------------------------------------------------------------- Writing

// Copied from FALLBACK_BLOG_POSTS in useSupabase.ts.
const posts = <Post>[
  Post(
    title: 'Building Real-Time Mobile Apps with Flutter & Supabase',
    category: 'Mobile Architecture',
    date: 'Jul 2025',
    readTime: '5 min read',
    summary:
        'A practical guide to implementing BLoC state isolation, Supabase '
        'Row-Level Security (RLS), and offline-first Hive caching in Flutter '
        'production apps.',
    content:
        'Building real-time mobile applications requires a decoupled '
        'architecture that balances UI responsiveness, local data caching, and '
        'secure cloud synchronization.\n\n'
        '### 1. State Management with BLoC Pattern\n'
        'Using the Business Logic Component (BLoC) pattern separates '
        'presentation logic from data streaming. This ensures predictable state '
        'transitions when receiving real-time WebSocket events from Supabase.\n\n'
        '### 2. Row Level Security (RLS) Policies\n'
        'Supabase PostgreSQL database policies allow row-level authorization '
        'directly at the database layer. By enforcing RLS, client mobile apps '
        'interact securely with data without complex intermediary API proxies.\n\n'
        '### 3. Offline-First Hive & Isar Caching\n'
        'To maintain sub-100ms UI interactions, local key-value stores like '
        'Hive cache remote payloads locally. When network connectivity drops, '
        'operations queue locally and sync atomically once reconnected.',
    tags: ['Flutter', 'Supabase', 'BLoC', 'PostgreSQL'],
  ),
  Post(
    title: 'Optimizing Nuxt 3 SSR & Glassmorphism Design Tokens',
    category: 'Frontend Engineering',
    date: 'Jun 2025',
    readTime: '4 min read',
    summary:
        'How to craft ultra-fast Vue 3 applications using Nuxt 3 server-side '
        'rendering, dynamic dark mode themes, and performance-first CSS glass '
        'utilities.',
    content:
        'Modern web interfaces must deliver immediate visual impact without '
        'sacrificing Lighthouse web vitals or page transition speeds.\n\n'
        '### 1. Server-Side Rendering (SSR) Optimization\n'
        'Nuxt 3 leverages Vite and Nitro server engines to render HTML payloads '
        'on the server. By utilizing `useAsyncData` with key caching, payload '
        'payloads double in initial load speed.\n\n'
        '### 2. Custom CSS Glass Tokens\n'
        'Instead of relying on heavy third-party UI libraries, custom '
        'backdrop-filter CSS utility classes maintain high frame rates (60fps) '
        'during window scrolling and dark mode transitions.',
    tags: ['Nuxt 3', 'Vue 3', 'Tailwind CSS', 'SSR'],
  ),
  Post(
    title: 'Architecting High-Throughput REST APIs in Laravel & Node.js',
    category: 'Backend Systems',
    date: 'May 2025',
    readTime: '6 min read',
    summary:
        'Database indexing strategies, background worker queues, and automated '
        'Telegram bot telemetry triggers for mission-critical API backends.',
    content:
        'When handling high daily transaction volume, API backend performance '
        'hinges on SQL indexing precision and asynchronous background queues.\n\n'
        '### 1. Database Indexing & Query Optimization\n'
        'Creating compound indexes on frequent query filter columns reduces '
        'database search time by up to 40%. Avoiding N+1 queries using Eloquent '
        'eager loading ensures tight memory bounds.\n\n'
        '### 2. Operational Error Telemetry with Telegram\n'
        'By integrating automated webhook triggers into exception handlers, '
        'engineering teams receive immediate real-time stack trace alerts in '
        'Telegram channels for instantaneous triage.',
    tags: ['Laravel', 'Node.js', 'MySQL', 'Telegram API'],
  ),
];

// ---------------------------------------------------------------- Section copy

const projectsLead =
    'A selection of mobile applications and technical projects that reflect '
    'my interest in practical problem-solving, scalable systems and '
    'thoughtful user experiences.';

const writingLead =
    'Notes on cross-platform mobile architecture, web performance, database '
    'security and backend operations.';

const contactLead =
    'Open to full-time roles and freelance projects in mobile and web '
    'development. Send a message and I will get back to you.';

/// Contact form "What can I help with?" options: value -> label.
const inquiryTypes = <InquiryType>[
  InquiryType('Mobile App Development', 'Mobile app (Flutter)'),
  InquiryType('Full-Stack Web Development', 'Web application (Nuxt / Vue)'),
  InquiryType('Backend / API', 'Backend or API'),
  InquiryType('Full-time Role', 'Full-time role'),
  InquiryType('General Inquiry', 'Something else'),
];

// ---------------------------------------------------------------- Chat

const chatGreeting =
    "Hi! I can answer questions about Panha's experience, projects and skills.";

const chatError =
    'The assistant is unavailable right now. You can reach Panha through the '
    'contact form.';

const chatQuickPrompts = <QuickPrompt>[
  QuickPrompt('Skills', "What are Panha's main skills?"),
  QuickPrompt('Projects', 'What projects has Panha built?'),
  QuickPrompt('Experience', "What is Panha's work experience?"),
  QuickPrompt('Availability', 'Is Panha available for new work?'),
];

// ---------------------------------------------------------------- Profile object

const profile = Profile(
  name: ownerName,
  role: ownerRole,
  email: email,
  githubUrl: githubUrl,
  telegramUrl: telegramUrl,
  telegramHandle: telegramHandle,
  location: location,
  timezone: timezone,
  availability: availability,
  intro: heroIntro,
  facts: heroFacts,
);
