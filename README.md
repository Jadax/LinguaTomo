# LinguaTomo

> Learn Japanese with Leo. Warm, free, and built to work.

LinguaTomo is a local-first Japanese learning application for Web, Android and
iOS. It combines structured Can-Do progression, grammar explanations,
handwriting practice, spaced repetition and gentle cultural exploration in one
calm, modern interface.

Created by **Tushant Sharma**. An **Astraiva** product.

## Product principles

- Free and without advertising
- Useful Japanese before novelty sentences
- Clear explanations before assessment
- Encouragement without punishment or expiring progress
- Beginner-friendly without becoming beginner-only
- Accessible layouts for children, adults and older learners
- Traceable learning sources and honest proficiency claims
- Offline-first learning with optional cloud synchronisation

Leo, a Norwegian Forest Cat, is the companion throughout the experience.

## Current release

**Version 1.3.0, build 5**

| Area | Available now |
|---|---|
| Progression | Starter to Expert entry choice, placement check, 18 practical Can-Do missions |
| Grammar | 828 searchable lessons across N5 to N1 study references |
| Memory | FSRS scheduling for phrases and grammar patterns |
| Characters | Hiragana, katakana and an introductory kanji studio with KanjiVG diagrams |
| Writing | Touch canvas plus paper-photo OCR grading on Android and iOS |
| Culture | 30 Living Postcards and 24 seasonal story side quests |
| Motivation | Leo’s Nest, 28 achievements, streaks and stress-free streak freezes |
| Accessibility | Visual Explorer, Standard and Comfort experiences |
| Cloud | Optional Supabase PKCE account and progress synchronisation |

The application does not yet contain native-speaker recordings, complete
systematic kanji coverage, graded readers, speech recognition or full mock
examinations. These are tracked explicitly in [the roadmap](docs/ROADMAP.md).

## Learning model

LinguaTomo keeps three kinds of progress separate:

1. **Functional Can-Dos** describe what the learner can accomplish in a real
   situation.
2. **Knowledge coverage** organises grammar and exam preparation using JLPT
   reference levels.
3. **Skill evidence** tracks listening, speaking, reading, writing,
   interaction and culture independently.

JLPT, CEFR and ILR measure different things. Labels shown in the application
are learning references, not official score conversions or certificates.

See [Curriculum and pedagogy](docs/CURRICULUM.md) for the progression model and
quality gates.

## Technology

| Layer | Choice |
|---|---|
| Client | Flutter 3.44.7 and Dart 3.12.2 |
| State | Riverpod NotifierProvider architecture |
| Local data | Hive, using IndexedDB on Web and app storage on mobile |
| Review scheduling | FSRS with 90% desired retention |
| OCR | Google ML Kit Japanese text recognition on Android and iOS |
| Speech | Device Japanese text-to-speech, with a warm voice preference |
| Optional backend | Supabase Auth, PostgreSQL, Storage and Realtime |

All direct production dependencies were current when build 5 was verified on
22 July 2026.

## Repository map

```text
assets/
  branding/                 Astraiva and Leo application artwork
  content/grammar/          Attributed N5 to N1 grammar corpus
docs/                       Small, task-focused project documentation
lib/
  config/                   Public build-time configuration
  data/                     Immutable curriculum and content repositories
  models/                   Domain models only
  providers/                Riverpod state and persistence boundaries
  services/                 OCR, speech and optional cloud integrations
  theme/                    Design system and responsive helpers
  views/                    Screens and feature flows
  widgets/                  Reusable presentation components
supabase/linguatomo.sql      The only canonical Supabase SQL file
test/                       Widget and content-integrity tests
tool/verify.ps1             Repeatable local quality gate
```

For a deeper dependency map, read [Architecture](docs/ARCHITECTURE.md).

## Quick start

Prerequisites:

- Flutter stable 3.44.7 or newer compatible stable release
- Dart 3.12.2 or newer within the Flutter SDK
- Chrome or Edge for Web development
- Android Studio and Android SDK for Android builds
- macOS with Xcode and CocoaPods for iOS builds

```sh
flutter pub get
flutter run -d chrome
```

Android:

```sh
flutter run -d android
```

Run the complete local quality gate on Windows:

```powershell
./tool/verify.ps1
```

Use `./tool/verify.ps1 -SkipAndroid` when Android tooling is unavailable.

## Optional Supabase configuration

Core learning works without an account or network connection. Cloud features
require the public project URL and a public publishable key:

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://PROJECT.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=PUBLIC_PUBLISHABLE_KEY
```

Apply [supabase/linguatomo.sql](supabase/linguatomo.sql) to a fresh project.
Do not create additional SQL migration files. Update the canonical file and its
schema-version comment with every release.

Never compile, commit or expose a Supabase `service_role` key. If one is
disclosed, rotate it immediately.

## Production builds

```sh
flutter build web --release
flutter build apk --release
```

An unsigned local Android release falls back to the debug key so developers can
verify the artefact. Play Store distribution requires `android/key.properties`
and a private keystore outside Git. See [Development and release](docs/DEVELOPMENT.md).

iOS builds and signing must be completed on macOS:

```sh
flutter build ios --release
```

## Stability policy

Every release must pass:

1. `flutter pub get`
2. `flutter pub outdated --no-dev-dependencies`
3. `flutter analyze`
4. `flutter test`
5. `flutter build web --release`
6. `flutter build apk --release`, when Android tooling is available
7. secret scan and clean Git worktree check
8. responsive visual QA for mobile and desktop when UI changes

Build warnings and platform limitations are recorded in
[Quality and known limitations](docs/QUALITY.md). “No known test failure” must
never be described as proof that software has no possible defects.

## Documentation router

Read only the document needed for the task:

| Task | Document |
|---|---|
| Understand modules and data flow | [Architecture](docs/ARCHITECTURE.md) |
| Change lessons, stages or assessments | [Curriculum](docs/CURRICULUM.md) |
| Import or attribute learning material | [Content and sources](docs/CONTENT.md) |
| Build, configure or release | [Development](docs/DEVELOPMENT.md) |
| Diagnose failures and warnings | [Quality](docs/QUALITY.md) |
| Select the next feature | [Roadmap](docs/ROADMAP.md) |
| Work with an LLM agent | [AGENTS.md](AGENTS.md) |

This segmentation is intentional. Large content JSON files should not be loaded
when fixing unrelated UI, state or build issues.

## Content and licences

The bundled Hanabira grammar corpus is CC BY-SA 3.0 and remains attributed in
the application. Exact source revisions and exclusions are recorded in
[THIRD_PARTY_CONTENT.md](THIRD_PARTY_CONTENT.md).

The LinguaTomo repository does not currently declare a general project licence.
Do not assume that public visibility grants reuse rights. Third-party content
continues to use its own stated licence.

## Contributing safely

- Keep user-facing English in British English.
- Keep Leo’s feedback warm, brief and non-punitive.
- Do not add timers to Comfort mode.
- Do not call community JLPT lists official.
- Do not copy external content until its licence and provenance are documented.
- Keep the client free of server secrets.
- Preserve local learning when optional services fail.
- Add or update tests with behavioural changes.

See [docs/README.md](docs/README.md) for the complete documentation index.
