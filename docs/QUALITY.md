# Quality and known limitations

GitHub Actions builds Web and Android on Linux and performs an unsigned iOS
release build on macOS. Windows developers can therefore keep iPhone support in
parity even though Apple signing and device distribution require Xcode on macOS.

## Required verification

| Check | Purpose |
|---|---|
| Dependency resolution | Reproducible package graph |
| Direct dependency audit | Detect safe production-package upgrades |
| Static analysis | Type, lint and API mistakes |
| Unit and widget tests | Progression, content integrity and critical navigation |
| Web release build | Browser compiler and bundled-asset validation |
| Android release build | Gradle, Kotlin, manifest and mobile plugin validation |
| Responsive visual QA | Overflow, clipping and navigation regressions |
| Secret scan | Prevent credentials or signing material entering Git |

## Current automated tests

- Widget test: LinguaTomo opens loading screen, user picks level, enters app (7 variants).
- Grammar repository loads exactly 828 records with expected N-level counts.
- Every bundled grammar point contains at least one example.
- Both basic syllabaries contain 46 distinct characters with no fabricated pitch data.
- Missions preserve stage order, valid prerequisites and usable answer keys.
- Postcards contain complete Japanese study sets without broken characters.
- Achievement catalogue has unique IDs, progression, real rewards and trophies.
- Cultural calendar covers every month with vocabulary and a reward.
- Word bank contains ≥600 words with ≥80 per tier, ≥30 per category.
- Every vocabulary item appears exactly once in its tier lesson path.
- Learner progress and placement boundaries persist through provider restarts.
- Word growth, lesson history and FSRS ratings persist through provider restarts.
- Expired weekly challenges roll over without losing the learner's best score.

## Release verification

Version 1.17.8, build 38 passed local analysis, all 23 automated tests, a Web
release build, and an Android APK release build. Store publication additionally
requires the private Android upload key.

This release fixes weekly challenge rollover, hardens malformed Hive and FSRS
restoration, verifies placement and word-growth persistence, strengthens lesson
path integrity, and updates Riverpod to 3.4.2.

The next stability work should cover sync conflict and outbox recovery,
magic-link delivery on both supported targets, and OCR service fallbacks.

## Known platform limitations

- `flutter_tts` currently produces Flutter’s WebAssembly dry-run warning. The
  standard JavaScript Web release builds and runs.
- Some mobile plugins still apply the Kotlin Gradle Plugin and emit Flutter’s
  future Built-in Kotlin migration warning.
- A production Android store artefact requires Astraiva’s private signing key.
- iOS release compilation is verified by the macOS GitHub Actions runner; signing and device distribution still require Apple credentials.
- Device text-to-speech quality depends on installed voices and is not a
  substitute for licensed native-speaker recordings.
- Web handwriting photo OCR is not provided by the mobile ML Kit adapter.

## Failure triage

1. Reproduce with the smallest relevant test or command.
2. Read only the owning module and its provider or service boundary.
3. Confirm whether the failure is local, platform-specific or optional-cloud.
4. Fix the cause without changing unrelated learner data.
5. Add a regression test where practical.
6. Run analysis and the affected target build before the complete quality gate.

For asset failures, run the grammar repository test before opening JSON files.
For state failures, inspect the Hive key and notifier before changing views.
For cloud failures, confirm core offline learning still starts and functions.
