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
- Word progress survives a complete round trip through a cloud snapshot.
- Merging an unchanged snapshot reports no change, so sync cannot self-trigger.
- A schema-1 snapshot never erases word progress written by a newer build.

## Release verification

Version 1.17.9, build 39 passed local analysis, all 27 automated tests, a Web
release build, and an Android APK release build. Store publication additionally
requires the private Android upload key.

This release closes an audit of security, efficiency and duplication:

- The cloud snapshot now carries word progress, per-word growth counts, lesson
  history and word activity dates. Schema 1 omitted all of these, so a learner
  who reinstalled lost their vocabulary history despite being signed in.
- Progress state classes gained value equality. Without it every cloud merge
  looked like fresh local work and re-armed the sync debounce, so a signed-in
  device downloaded and uploaded its snapshot every few seconds indefinitely.
- The Supabase snapshot column is capped at 256 KB and a profile trigger keeps
  leaderboard XP monotonic and rate-limited, since the publishable key is
  public and the client can otherwise assert any figure.
- Word bank tier and category lookups are bucketed once at load instead of
  rescanning ~1,800 words inside build methods.
- Bundled artwork moved to sized WebP: web assets fell from 25 MB to 4.1 MB.
- Five unreferenced source files (846 lines) and two orphaned images were
  removed, and the duplicated Hive accessor, date key and streak calculation
  were consolidated.

Android release builds now run R8. **This has been verified to build and to
produce a mapping file, but not yet verified on a device.** Before publishing,
install the release APK and exercise ML Kit OCR, text-to-speech, the image
picker and Supabase sign-in, since those paths depend on reflection that
shrinking can affect. Retain `build/app/outputs/mapping/release/mapping.txt`
for every published build or crash reports will be unreadable.

The next stability work should cover sync conflict recovery on genuinely
divergent devices, magic-link delivery on both supported targets, and OCR
service fallbacks.

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
