# Web deployment and domain

## Public testing address

Every push to `main` is built and deployed by
`.github/workflows/pages.yml` to:

<https://jadax.github.io/LinguaTomo/>

GitHub Pages is a good free, stable choice for this Flutter static client. It
also keeps preview hosting beside the source repository. Supabase remains the
optional account and progress-sync backend.

The repository's Settings > Pages source must be set to **GitHub Actions** once.
The workflow then handles later releases automatically.

## Memorable production address

Use `linguatomo.app` as the preferred production address, followed by
`linguatomo.ai`. Domain availability and renewal prices change, so confirm both
immediately before purchasing. GitHub Pages supports a custom domain and HTTPS.

After purchase:

1. Add the domain in GitHub repository Settings > Pages.
2. Add GitHub's requested DNS records at the registrar.
3. Enable **Enforce HTTPS** after DNS verification.
4. Add the final Web URL to Supabase Auth's allowed redirect URLs.
5. Keep the `jadax.github.io` address as a testing and fallback origin.

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
