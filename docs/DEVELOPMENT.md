# Development and release

## Supported toolchain

- Flutter stable 3.44.7
- Dart 3.12.2
- Java 17 for Android
- iOS deployment target 15.5

Use `flutter pub outdated --no-dev-dependencies` before upgrades. Direct
dependencies should be current and changes to transitive constraints should not
be forced around Flutter or plugin compatibility.

## Local commands

```sh
flutter pub get
flutter analyze
flutter test
flutter build web --release
flutter build apk --release
```

Windows users can run `tool/verify.ps1`. Pass `-SkipAndroid` only when the
Android toolchain is genuinely unavailable.

## Public configuration

Use Dart defines for public Supabase client values:

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://PROJECT.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=PUBLIC_PUBLISHABLE_KEY
```

`.env.example` is documentation only. Flutter does not load it automatically.

## Android signing

Local release verification falls back to debug signing. Store distribution must
use a private keystore and `android/key.properties`:

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=C:/secure/location/linguatomo-upload.jks
```

The properties file and keystores are ignored by Git. Never generate or commit
production keys as part of an automated coding task.

## iOS

iOS compilation and signing require macOS, Xcode and CocoaPods. Run:

```sh
flutter pub get
cd ios
pod install
cd ..
flutter build ios --release
```

Windows verification can inspect configuration but cannot certify an iOS build.

## Release checklist

1. Increment `pubspec.yaml` version and build number.
2. Update `supabase/linguatomo.sql` schema-version comment.
3. Update README feature status and `docs/QUALITY.md`.
4. Run the complete quality gate.
5. Scan for secrets and obsolete branding.
6. Review `git diff --check` and the staged file list.
7. Commit using `fix:`, `feat:`, `docs:` or `release:` with a specific summary.
8. Push `main` to `https://github.com/Jadax/LinguaTomo.git`.

Do not commit generated `build/`, `.dart_tool/`, environment secrets or signing
material.
