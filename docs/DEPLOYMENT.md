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

## Release checks

- verify the GitHub Pages deployment is green;
- verify installability as a progressive Web app;
- test phone, tablet and desktop widths;
- test first load and repeat load on a slow connection;
- confirm local progress survives reload and browser restart;
- confirm account sync fails safely when Supabase is unavailable;
- test reduced motion, keyboard navigation and screen-reader labels.
