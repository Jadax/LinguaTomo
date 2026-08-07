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
| `data/word_bank.dart` | Main word list (~1,780 words) via spread merges from 10+ files; includes `_exampleSentences` map (160 context sentences for starter/elementary) |
| `data/word_bank_extras.dart` | 100 additional starter-tier words |
| `data/words_a1.dart` – `words_n1.dart` | CEFR and JLPT-aligned vocabulary expansions |
| `data/words_themes_extra.dart` | Extra themed vocabulary |
| `data/words_extra_2.dart` | Kitchen, home, and specialised vocabulary |
| `data/conversation_data.dart` | Daily conversation pairs with romaji |
| `data/achievement_data.dart` | 85 achievements with progress/target functions |
| `data/festival_calendar_data.dart` | Seasonal and cultural events |
| `data/grammar_data.dart` | N5–N1 grammar corpus |

## Word bank pattern

`final wordBank` (not `const`) uses spread operators to merge all vocabulary
files into a single list. `wordsForTierInOrder()` respects `_lessonPath` per
tier and appends unplaced words alphabetically. Tests assert ≥600 words.

## Theme picker pattern

Themes are the eight `WordCategory` values, not a separate registry. The
picker derives its chips from `WordCategory.values` filtered to those with
words at the learner's tier, so adding a category is the only wiring needed.

`_ContinueLearningCard.onTap` calls `_showThemePicker()` which opens a modal
bottom sheet with themed category chips. The sheet is filtered by the user's
current tier. Each chip navigates to `WordLessonView` with category and tier
filters. No category grid is shown inline on the dashboard.

## Responsive layout

`ResponsiveContent` wraps content in `SingleChildScrollView` + `ConstrainedBox`
(maxWidth 600). Never nest a `ListView` inside it — use `Column` instead.
For screens needing `Expanded` + `ListView.builder`, use a plain `Column`
with `ConstrainedBox` directly.

`SingleChildScrollView` gives its child an unbounded height, and `Spacer`/
`Expanded` require a bounded one — using either directly inside
`ResponsiveContent`'s default mode throws a `RenderFlex` assertion. A screen
that needs flex-based spacing (an intro or results card centred with
`Spacer`) must pass `ResponsiveContent(fillHeight: true, ...)`, which
reintroduces a bounded axis via `LayoutBuilder` + `ConstrainedBox(minHeight)`
+ `IntrinsicHeight` while still scrolling past it on a short viewport. Leave
`fillHeight` off for every screen that doesn't use `Spacer`/`Expanded` in its
top-level `Column` — it costs an extra layout pass and buys nothing there.

## Persistence

Hive box: `linguatomo_user_data`.

The app performs a one-time compatible copy from the legacy
`nekokana_user_data` box when the new box is empty. Do not remove that migration
until a deliberate data-retention decision is made.

Stored domains: learner profile, experience mode, mission and postcard
progress, handwriting history, FSRS phrase cards, grammar cards, word
progress (including per-word correct counts for growth stages),
bookmarks, sync state, weekly challenge progress, and Leo mood state.

## Context-first learning

The `Word` model includes optional `exampleSentence` and `exampleTranslation`
fields. `word_bank.dart` contains a `_exampleSentences` map (160 entries for
starter and elementary tiers) that is merged into the word bank at load time.
`WordLessonView` shows context sentences during the introduce and quiz phases.
The `ImmersiveReaderView` lets users paste or type Japanese text and tap
segments to look up words from the word bank.

## Engagement providers

| Provider | File | Purpose |
|----------|------|---------|
| `leoMoodProvider` | `providers/leo_mood_state.dart` | Derives Leo's mood from streak, milestones, reviews, inactivity |
| `seasonalProgressProvider` | `providers/seasonal_state.dart` | Monthly season progress, active festivals, badge target |
| `weeklyChallengeProvider` | `providers/weekly_challenge_state.dart` | Rotating weekly challenge type, streak, best score |

Dashboard cards: `_LeoMoodGreeting`, `_WordGardenSummary`, `_SeasonalCard`,
`_WeeklyChallengeCard` in `views/dashboard_view.dart`.

## Persistence boundary

Providers never open Hive themselves. They read and write through
`localStore` in `config/local_store.dart`, which returns `null` when the box
could not be opened so a storage failure degrades to memory-only learning.

State classes that a provider holds must implement value equality. Riverpod
compares with `==`, so a class without it notifies on every assignment; for
the progress models that also re-arms the cloud sync debounce and syncs in a
loop. Add `copyWith` and `==`/`hashCode` together with any new state class.

## Supabase

`supabase/linguatomo.sql` is the only canonical SQL file. Modify it in place
and update its schema-version comment. Do not add migration fragments.

Only `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` belong in Flutter
build-time configuration. A service-role key is server-only.

### Progress snapshot

`SyncNotifier._buildSnapshot` writes the whole of the learner's earned
progress into `learner_progress.snapshot` as one JSON object. Anything a
learner would grieve losing on a reinstall belongs in it. Snapshot schema 2
covers mission, postcard, reward, skill, XP, streak, handwriting and word
progress — word progress was absent from schema 1, so a snapshot written by
an older build simply lacks those keys.

Each `mergeCloudSnapshot` keeps the larger of every value and returns whether
the remote actually contributed anything. That boolean is what stops the
sync loop: an unchanged download must not look like fresh local work.

The publishable key is public, so the database, not the client, is the place
to enforce limits. The snapshot is capped at 256 KB and the `on_profile_update`
trigger keeps leaderboard figures monotonic and rate-limited.

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
3. `lib/config/app_info.dart` — `AppInfo.version` and `AppInfo.buildNumber`,
   which every screen reads through `AppInfo.versionLabel`

TTS speed: 0.72 in `speech_service.dart` (warm and clear for learning).
