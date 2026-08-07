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
- A returning learner is never shown the level picker again after onboarding.
- Failing a lesson below the pass gate retries without crashing (see below).
- Deleting cloud data before sign-in fails safely rather than crashing.
- Every postcard-unlock threshold stays within the actual postcard bank size.

## Release verification

Version 1.19.1, build 44 passed local analysis, all 33 automated tests, a Web
release build, an Android APK release build and an Android App Bundle release
build (the format Play actually requires — see [Deployment](docs/DEPLOYMENT.md)
for the full submission checklist). Store publication additionally requires
the private Android upload key.

This release closes a pre-launch Play Store readiness pass and alpha
playtest, and fixes two defects that would have shown up on a learner's very
first real session:

- **Every lesson retry was crashing.** `_words` in `WordLessonView` was
  declared `late final`, and `_retryFailed` reassigned it when a learner
  scored below the pass gate — a `late final` field throws
  `LateInitializationError` on a second assignment. This fires on any lesson
  a learner doesn't pass outright on the first try, which is routine, not an
  edge case. Fixed by dropping `final`; `test/word_lesson_retry_test.dart`
  drives a full fail-then-retry cycle end to end so a regression trips
  immediately. The pass gate was also hardcoded to "3 correct", which is
  impossible to reach on the review deck's occasional 1- or 2-word lessons;
  it now scales to `min(3, wordCount)`, and `_retryFailed` no longer clears
  `_words` to empty when every wrong answer has already been corrected.
- **A returning learner was asked to pick a level on every single launch.**
  The loading screen always showed its tier picker and would not proceed
  without a tap, regardless of whether onboarding had already finished.
  `LeoLoadingScreen` now takes a `needsLevelChoice` flag driven by
  `learnerProfileProvider.onboardingComplete`; a returning learner sees the
  splash and lands on their dashboard with no picker at all.
  `test/returning_learner_test.dart` covers both paths.
- **`Spacer`/`Expanded` inside `ResponsiveContent` throws in Flutter**, since
  `ResponsiveContent` wraps content in `SingleChildScrollView`, which gives
  an unbounded main axis — invalid input to a flex layout. This affected the
  entire lesson flow (`_buildIntro`, `_buildIntroduce`, `_buildQuiz`,
  `_buildReverseQuiz`, `_buildResults`) plus the Can-Do practice, weekly
  challenge and immersive reader screens: 8 call sites across 4 files.
  `ResponsiveContent` gained an opt-in `fillHeight` parameter
  (`LayoutBuilder` + `ConstrainedBox(minHeight)` + `IntrinsicHeight`) that
  reintroduces a bounded axis without losing the ability to scroll past it
  on short viewports; the 8 affected call sites now pass it. Every other
  `ResponsiveContent` usage is untouched, so this carries no regression risk
  for the ~25 screens that don't use flex spacers.
- **Living Postcards crashed for any learner who reached 50 words.**
  `WordProgress.availablePostcardCount` scales up to 30 as `wordsLearned`
  grows, but the postcard bank in `curriculum_data.dart` only has 12 entries
  — the schedule was written for a larger planned collection than exists
  today. `PostcardsView` indexes `postcards[i]` for `i` up to that count with
  no bound check, so `RangeError` on open, not on some obscure edge case but
  on the natural path of a moderately engaged learner. `availablePostcardCount`
  now clamps to `postcards.length`; `curriculum_integrity_test.dart` checks
  every unlock threshold against the actual bank size.
- **Text-to-speech could throw unhandled.** `SpeechService.speakJapanese`
  called `stop()`/`awaitSpeakCompletion()`/`speak()` with no guard; a device
  with no TTS engine, a mid-load browser, or parental TTS restrictions on a
  child's device would raise an uncaught exception on every word instead of
  failing quietly the way the file's own voice-configuration helper already
  did. Now wrapped consistently — a silent word never blocks a lesson that
  already shows it on screen.

Play Store readiness, beyond the fixes above:

- Added an in-app account-deletion path (**Account & Sync → Delete my cloud
  data**) and a hosted privacy policy (`web/privacy.html`, published at
  `https://jadax.github.io/LinguaTomo-Web/privacy.html`), both required for
  a listing that offers account creation. A new `profiles` delete RLS policy
  in `supabase/linguatomo.sql` lets a learner remove their own row; full
  identity (email) deletion still requires emailing support, disclosed in
  both places, since that needs the service-role key the client must never
  hold.
- Confirmed the app's Play-relevant footprint is already minimal: no ads, no
  analytics/tracking SDKs, no live user-generated-content surface (the
  community/friendship tables in the SQL schema have no client UI), and only
  two declared permissions. `compileSdk`/`targetSdk` 36 and AGP 9.0.1 already
  satisfy the current target-API and 16 KB native-page-size requirements.
- See [Deployment](docs/DEPLOYMENT.md) for the full submission checklist,
  including why this app should declare a general/all-ages content rating
  without enrolling in the Designed for Families program.

This release makes the learner path more direct and coherent:

- The loading-screen level picker now uses the same provider-backed onboarding
  path as the welcome journey, so choosing a level enters the dashboard rather
  than returning a learner to a second picker.
- A level selected while the loading artwork is still preparing is queued and
  enters the dashboard as soon as preparation completes.

- The weekly challenge card opens a playable challenge rather than a static
  summary, and a completed challenge retains its best score.
- Vocabulary alternatives now come first from the word's lesson theme and
  difficulty tier; the review route practises words the learner has actually
  encountered. The word garden explains its four visible growth stages, while
  Can-Do phrase and grammar review is labelled separately.
- Handwriting accepts touch pointer input, offers zoom controls, and repeats
  each character with a full guide, a faint guide and then no guide to build
  motor memory. Level selection now continues immediately.
- Japanese web speech pre-warms the available voice and avoids Web completion
  handling that can stall Chrome. This requires manual Chrome/Edge audio
  verification before claiming browser-wide audio support; Internet Explorer
  is not a supported browser.

The preceding release closed an audit of security, efficiency and duplication:

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
