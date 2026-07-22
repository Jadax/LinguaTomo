# LinguaTomo agent guide

This file is the compact entry point for coding agents. Do not load every
project document or content asset by default.

## Read routing

1. Read `README.md` for product status and commands.
2. Read only one task document unless the change crosses boundaries:
   - app structure: `docs/ARCHITECTURE.md`
   - lessons or progression: `docs/CURRICULUM.md`
   - external data or licensing: `docs/CONTENT.md`
   - builds, signing or releases: `docs/DEVELOPMENT.md`
   - failures or warnings: `docs/QUALITY.md`
   - prioritisation: `docs/ROADMAP.md`
3. Use `rg` to locate symbols before opening whole Dart files.
4. Never print or load full grammar JSON files. Inspect one record or use tests.

## Non-negotiable rules

- Product name: LinguaTomo.
- Author: Tushant Sharma. Company: Astraiva.
- Companion: Leo, a Norwegian Forest Cat. Keep that identity consistent.
- User-facing English: British English.
- Tone: warm, concise, encouraging and non-punitive.
- Platforms: Web, Android and iOS.
- State: Riverpod NotifierProvider architecture.
- Local source of truth: Hive.
- Cloud: optional Supabase using public client values only.
- Supabase SQL: `supabase/linguatomo.sql` is the only SQL file.
- Never commit a service-role key, keystore, password or private environment file.
- JLPT, CEFR and ILR labels are references, not certificates or exact conversions.

## Change boundaries

- Models contain domain data and no UI.
- Data repositories load immutable bundled content.
- Providers own state transitions and persistence.
- Services isolate platform and network integrations.
- Views compose feature UI and delegate state changes.
- Theme tokens belong in `lib/theme/app_theme.dart`.
- New large content belongs under `assets/content/<domain>/` with provenance.

## Required release sequence

1. Increment `pubspec.yaml` version and build.
2. Update the version comment in `supabase/linguatomo.sql`.
3. Run `tool/verify.ps1` or the equivalent Flutter commands.
4. Scan for secrets and stale legacy branding.
5. Check `git diff --check` and review the exact staged files.
6. Commit with a specific message and push `main` to `Jadax/LinguaTomo`.

Do not claim a release is stable if analysis, tests or a required target build
failed. Document platform-specific warnings in `docs/QUALITY.md`.
