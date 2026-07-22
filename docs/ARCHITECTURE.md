# LinguaTomo architecture

## Decision

LinguaTomo is a local-first Flutter application for Web, Android and iOS. Hive is the learning source of truth. Supabase is an optional synchronisation and social layer configured only through public build-time values.

## Supabase

`supabase/linguatomo.sql` is the only canonical SQL file. Future schema changes must update that file and its version comment rather than adding migration fragments. The project URL is public and is supplied by default. A Supabase publishable key may be passed with `--dart-define=SUPABASE_PUBLISHABLE_KEY=...`. Service-role keys are server-only and must never be compiled into Flutter or committed to Git.

## Runtime layers

1. Flutter presentation: adaptive Material 3 UI, responsive layouts, CustomPainter graphics.
2. Riverpod application state: progression, FSRS, accessibility, OCR history, synchronization.
3. Local persistence: Hive/IndexedDB stores all learning data and a bounded sync outbox.
4. Device services: ML Kit Japanese OCR on Android/iOS, system TTS, image picker, share sheet.
5. Optional Supabase: PKCE authentication, PostgreSQL snapshots, private storage, Realtime social events, and row-level security.

## Configuration

No private service key belongs in the client. Use only the Supabase project URL and public anonymous key:

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://PROJECT.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=PUBLIC_PUBLISHABLE_KEY
```

Apply `supabase/migrations/202607220001_initial_schema.sql` through the Supabase CLI or SQL editor before enabling sync.

## Safety boundaries

- Local learning never requires authentication.
- Handwriting photos are not uploaded by default.
- Child profiles require a guardian and cannot create community posts, friendships, or challenges.
- Community submissions begin in `pending` moderation state.
- Direct messaging is deliberately absent.
- The client never awards official JLPT, CEFR, or ILR certification.

## Future graphics layer

Keep the main Nest in Flutter widgets and CustomPainter until room interactions exceed simple placement. If a larger explorable world is validated, adopt the open-source Flame engine inside an isolated feature module rather than rebuilding the whole app as a game.
