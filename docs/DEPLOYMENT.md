# Web and Android deployment

## Public testing address

The private source repository builds a deployment-only website for:

<https://jadax.github.io/LinguaTomo-Web/>

`Jadax/LinguaTomo-Web` contains compiled Web output only. The Dart source,
tests, SQL and development history stay private in `Jadax/LinguaTomo`.
GitHub Pages is therefore free without exposing the maintainable source.

The deployment repository's Pages source is its `main` branch root. The private
workflow produces a reviewed build artefact. Automatic cross-repository push
uses a write deploy key restricted to `Jadax/LinguaTomo-Web`.

## Memorable production address

Use `linguatomo.app` as the preferred production address, followed by
`linguatomo.ai`. Domain availability and renewal prices change, so confirm both
immediately before purchasing. GitHub Pages supports a custom domain and HTTPS.

After purchase:

1. Add the domain in GitHub repository Settings > Pages.
2. Add GitHub's requested DNS records at the registrar.
3. Enable **Enforce HTTPS** after DNS verification.
4. Add the final Web URL to Supabase Auth's allowed redirect URLs.
5. Keep the `jadax.github.io/LinguaTomo-Web` address as a testing and fallback
   origin.

## Public configuration

The workflow compiles only the Supabase URL and publishable client key. A
publishable key is expected to be visible in a browser. Row Level Security in
`supabase/linguatomo.sql` is the data boundary.

Never compile, commit or expose a Supabase `service_role` key. Rotate any
service-role key that has ever been shared outside a protected server secret.

## Passwordless sign-in readiness

Before publishing a build with account sync enabled, verify these settings in
the hosted authentication project:

1. Enable email sign-in and set a verified, production SMTP sender. The
   provider's development sender is rate-limited and is not suitable for a
   public launch.
2. Add `https://jadax.github.io/LinguaTomo-Web/` to the site URL and allowed
   redirect URLs.
3. Add `com.astraiva.linguatomo://login-callback/` as an allowed mobile
   redirect URL and test it on a physical Android device.
4. Send a real sign-in link to a monitored inbox, check delivery and spam
   placement, then complete the link on both Web and Android.

The app validates addresses, limits repeat sends, and keeps learning local if
authentication is unavailable. Mail delivery itself is the responsibility of
the configured SMTP provider and should be monitored in its dashboard.

## Release checks

- verify the GitHub Pages deployment is green;
- verify installability as a progressive Web app;
- test phone, tablet and desktop widths;
- test first load and repeat load on a slow connection;
- confirm local progress survives reload and browser restart;
- confirm account sync fails safely when Supabase is unavailable;
- test reduced motion, keyboard navigation and screen-reader labels.

## Google Play submission

LinguaTomo's own footprint is deliberately small for review purposes: no ads,
no analytics or tracking SDKs, no user-generated content surface today, and
only two permissions (`INTERNET`, `ACCESS_NETWORK_STATE`). What still needs
doing at submission time:

1. **Build an App Bundle, not an APK.** Play requires `.aab` for new apps and
   updates:

   ```sh
   flutter build appbundle --release
   ```

   `flutter build apk --release` remains useful for local installs and the
   CI quality gate, but is not what gets uploaded to Play Console.

2. **Sign with the real upload key**, not the debug fallback. Create
   `android/key.properties` per [Development](docs/DEVELOPMENT.md) before
   building the bundle you intend to upload — an unsigned build silently
   falls back to the debug key, which Play will reject.

3. **Reapply `supabase/linguatomo.sql`** before release if it has changed
   since the last submission; the app ships against whatever schema is
   live, and schema and client version must move together.

4. **Data safety form.** Declare: email address (collected only if the
   learner opts into an account, used for authentication, not shared),
   app-generated learning progress (stored if signed in, used to provide
   the sync feature, not shared), and no other data types. Answer "no" to
   data sold, and "yes, user can request deletion" — see the in-app
   **Account & Sync → Delete my cloud data** and the privacy policy at
   `https://astraiva.app/privacy/linguatomo.html`, which must also be
   linked directly in the Play Console listing.

5. **Target audience.** Do not enrol in the Designed for Families / Ads
   program or mark the app "primarily child-directed" — email sign-in is not
   COPPA-compliant on its own, and none of the account-mode/guardian
   scaffolding in the SQL schema has a client-side parental-consent flow
   built yet. Content is naturally suitable for a general/all-ages content
   rating; declare the target age range to reflect that without claiming the
   stricter families-program status.

6. **16 KB page size / target API level.** Already satisfied by this
   project's toolchain (AGP 9.0.1, `compileSdk`/`targetSdk` 36 from the
   Flutter Gradle plugin defaults) — no action needed unless the Android
   Gradle Plugin or Flutter version is downgraded.

7. **Before the first real users**: install the actual uploaded bundle (not
   a debug build) and exercise ML Kit OCR, TTS, the photo picker, magic-link
   sign-in and the new cloud-deletion flow once each — R8 shrinking can
   affect reflection-based plugin code in ways `flutter analyze` cannot
   catch. See [Quality](docs/QUALITY.md) for what's already been verified
   versus what still needs a physical device.
