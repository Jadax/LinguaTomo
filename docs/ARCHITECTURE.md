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
- `lib/data`: bundled curriculum, word banks and parsing repositories
- `lib/providers`: state transitions, FSRS scheduling and Hive persistence
- `lib/services`: platform or network adapters (TTS, cloud, sound)
- `lib/views`: feature screens and navigation destinations
- `lib/widgets`: reusable UI without feature persistence (Leo sprite, banners)
- `lib/theme`: colours, typography, accessibility and responsive constraints

Views must not write Hive directly. Platform packages must remain behind
services. Optional cloud state must not block local application startup.

## Key data files

| File | Purpose |
|------|---------|
| `data/word_bank.dart` | Main word list (~1,780 words) via spread merges from 10+ files |
| `data/word_bank_extras.dart` | 100 additional starter-tier words |
| `data/words_a1.dart` – `words_n1.dart` | CEFR and JLPT-aligned vocabulary expansions |
| `data/words_themes_extra.dart` | Extra themed vocabulary |
| `data/words_extra_2.dart` | Kitchen, home, and specialised vocabulary |
| `data/theme_registry.dart` | 31 themed sections with `ThemeEntry` model |
| `data/sections_intro.dart` | Pre-A1 section definitions |
| `data/conversation_data.dart` | Daily conversation pairs with romaji |
| `data/achievement_data.dart` | 85 achievements with progress/target functions |
| `data/festival_calendar_data.dart` | Seasonal and cultural events |
| `data/grammar_data.dart` | N5–N1 grammar corpus |

## Word bank pattern

`final wordBank` (not `const`) uses spread operators to merge all vocabulary
files into a single list. `wordsForTierInOrder()` respects `_lessonPath` per
tier and appends unplaced words alphabetically. Tests assert ≥600 words.

## Theme picker pattern

`_ContinueLearningCard.onTap` calls `_showThemePicker()` which opens a modal
bottom sheet with themed category chips. The sheet is filtered by the user's
current tier. Each chip navigates to `WordLessonView` with category and tier
filters. No category grid is shown inline on the dashboard.

## Responsive layout

`ResponsiveContent` wraps content in `SingleChildScrollView` + `ConstrainedBox`
(maxWidth 600). Never nest a `ListView` inside it — use `Column` instead.
For screens needing `Expanded` + `ListView.builder`, use a plain `Column`
with `ConstrainedBox` directly.

## Persistence

Hive box: `linguatomo_user_data`.

The app performs a one-time compatible copy from the legacy
`nekokana_user_data` box when the new box is empty. Do not remove that migration
until a deliberate data-retention decision is made.

Stored domains: learner profile, experience mode, mission and postcard
progress, handwriting history, FSRS phrase cards, grammar cards, word
progress, bookmarks and sync state.

## Supabase

`supabase/linguatomo.sql` is the only canonical SQL file. Modify it in place
and update its schema-version comment. Do not add migration fragments.

Only `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` belong in Flutter
build-time configuration. A service-role key is server-only.

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

## Versioning

Version appears in three places kept in sync:
1. `pubspec.yaml` — `version: X.Y.Z+build`
2. `supabase/linguatomo.sql` — schema version comment
3. `lib/views/account_view.dart` — hardcoded display string

TTS speed: 0.72 in `speech_service.dart` (warm and clear for learning).
