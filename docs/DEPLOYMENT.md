# Web deployment and domain

## Public address

Use a memorable custom domain for every public launch. `linguatomo.app` is the
preferred product address, followed by `linguatomo.ai`. Availability and renewal
price must be confirmed with an accredited registrar immediately before
purchase. The temporary `pages.dev` address is an origin and preview address,
not the address used in marketing.

## Hosting

Cloudflare Pages remains the static Web host. Connect the purchased domain in
the Pages project, enable automatic HTTPS and redirect the `www` hostname to the
canonical apex hostname. Supabase remains the optional account and sync backend.

Build the client with public values only:

```powershell
flutter build web --release --no-wasm-dry-run `
  --dart-define=SUPABASE_URL=https://lfoczkivkesxxmuowebm.supabase.co `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLIC_KEY
```

Never compile a Supabase service-role key into the website. The publishable key
is expected to be visible, so Row Level Security is the actual data boundary.

## Release checks

- confirm the custom domain and HTTPS redirect;
- verify installability as a progressive Web app;
- test phone, tablet and desktop widths;
- test first load and repeat load on a slow connection;
- confirm local progress survives reload and browser restart;
- confirm account sync fails safely when Supabase is unavailable;
- run accessibility checks with reduced motion and keyboard navigation.
