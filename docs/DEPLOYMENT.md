# Web deployment and domain

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
