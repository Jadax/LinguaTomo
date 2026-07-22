# Architecture

## Decision

LinguaTomo is a local-first Flutter application. Core study must survive network
failure, account failure and optional-service failure. Hive is the learning
source of truth; Supabase is an optional synchronisation and social boundary.

## Runtime flow

```text
Flutter views
    ↓ user intent / rendered state
Riverpod NotifierProviders
    ↓ domain transitions
Hive repositories and FSRS cards
    ↘ optional device services: OCR, TTS, image picker, sharing
    ↘ optional Supabase: PKCE auth and progress snapshots
```

## Module ownership

- `lib/models`: immutable domain objects and enums
- `lib/data`: bundled curriculum and parsing repositories
- `lib/providers`: state transitions, FSRS scheduling and Hive persistence
- `lib/services`: platform or network adapters
- `lib/views`: feature screens and navigation destinations
- `lib/widgets`: reusable UI without feature persistence
- `lib/theme`: colours, typography, accessibility and responsive constraints

Views must not write Hive directly. Platform packages must remain behind
services. Optional cloud state must not block local application startup.

## Persistence

Hive box: `linguatomo_user_data`.

The app performs a one-time compatible copy from the legacy
`nekokana_user_data` box when the new box is empty. Do not remove that migration
until a deliberate data-retention decision is made.

Stored domains currently include learner profile, experience mode, mission and
postcard progress, handwriting history, FSRS phrase cards, grammar cards,
bookmarks and sync state.

## Supabase

`supabase/linguatomo.sql` is the only canonical SQL file. Modify it in place and
update its schema-version comment. Do not add migration fragments.

Only `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` belong in Flutter build-time
configuration. A service-role key is server-only.

## Responsive and accessibility boundaries

- Mobile uses a portrait-first column flow.
- Wide browsers centre content at a maximum width of 600 px.
- Visual Explorer enlarges visuals and reduces typing.
- Comfort increases contrast and type size while reducing motion.
- Learning access never changes with presentation mode.

## Graphics boundary

Keep the Nest in Flutter widgets and CustomPainter while interaction remains
simple. Consider Flame only for a validated explorable-world requirement, and
isolate it behind a feature module rather than replacing the application shell.
