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

- Guided start choice waits for the loading chase finale, then reaches the Nest and Learning Library.
- Grammar repository loads exactly 828 records with expected N-level counts.
- Every bundled grammar point contains at least one example.
- Both basic syllabaries contain 46 distinct characters.
- Missions preserve stage order, valid prerequisites and usable answer keys.
- Postcards contain complete Japanese study sets without broken characters.
- The 69-achievement catalogue has unique IDs, progression, real rewards and at least six trophies.
- The cultural calendar covers every month with vocabulary and a reward.

## Release verification

Version 1.6.0, build 9 is the last fully verified release. For the 1.8.0,
build 11 candidate, Dart static analysis reports no issues, all tests pass and
the Web release builds locally. The GitHub Web, Android and unsigned iOS gates
must pass before 1.8.0 is described as stable.

The next stability tests should cover Hive restoration, FSRS persistence,
placement boundaries, cloud-disabled account screens and OCR service fallbacks.

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
