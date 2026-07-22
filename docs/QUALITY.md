# Quality and known limitations

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

- Guided start choice reaches the Nest and Learning Library.
- Grammar repository loads exactly 828 records with expected N-level counts.
- Every bundled grammar point contains at least one example.

## Last verified release

Version 1.2.1, build 4 was verified on 22 July 2026 with Flutter 3.44.7
and Dart 3.12.2:

- static analysis: no issues;
- tests: 3 passed;
- direct production dependencies: current;
- Web release build: passed;
- Android APK release build: passed;
- PowerShell verification script syntax: passed.

The next stability tests should cover Hive restoration, FSRS persistence,
placement boundaries, cloud-disabled account screens and OCR service fallbacks.

## Known platform limitations

- `flutter_tts` currently produces Flutter’s WebAssembly dry-run warning. The
  standard JavaScript Web release builds and runs.
- Some mobile plugins still apply the Kotlin Gradle Plugin and emit Flutter’s
  future Built-in Kotlin migration warning.
- A production Android store artefact requires Astraiva’s private signing key.
- iOS release compilation cannot be verified on Windows.
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
