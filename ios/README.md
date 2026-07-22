# iOS parity

LinguaTomo keeps iOS source, permissions, dependencies and CI in the same
repository as Web and Android. Windows can maintain the shared Dart code and
iOS project files, but Apple requires macOS and Xcode to compile, sign and
submit an iPhone build.

Every push runs an unsigned iOS release build on a macOS GitHub Actions runner.
This catches Dart, CocoaPods and Xcode integration failures while development
continues on Windows.

## First signed build on a Mac

1. Install the current stable Xcode and accept its licence.
2. Install Flutter stable and CocoaPods.
3. Run `flutter pub get` from the repository root.
4. Run `pod install` inside `ios`.
5. Open `ios/Runner.xcworkspace`, not the `.xcodeproj` file.
6. Select the Astraiva Apple Developer team and retain the bundle identifier
   `com.astraiva.linguatomo`.
7. Supply a Supabase publishable key through the same build-time environment
   used by Web and Android. Never embed a service-role key.
8. Test camera, photo library, microphone, speech, local storage and offline
   reviews on a physical iPhone.

Shared features are not complete until the iOS CI build passes.
