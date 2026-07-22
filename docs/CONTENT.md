# Content sources and research

## Import rule

Open source code does not imply that linked text, audio, video, logos or
textbooks are reusable. Before bundling material, record:

- exact source URL and revision;
- licence for the specific data, not merely the repository code;
- required attribution and share-alike terms;
- whether the source itself derived material from elsewhere;
- review status and any transformations;
- files included and deliberately excluded.

Exact bundled provenance lives in `../THIRD_PARTY_CONTENT.md`.

## Audited sources, 22 July 2026

| Source | Finding | LinguaTomo use |
|---|---|---|
| `tristcoil/hanabira.org-japanese-content` | In-house content published under Creative Commons terms | 828 attributed grammar points bundled |
| `tristcoil/hanabira.org` | MIT code; content and upstream sources have separate terms | Product research and provenance cross-checking |
| `lingdojo/kana-dojo` | AGPL-3.0 application with strong practice and customisation patterns | Behavioural research only; no copied code |
| `donkuri/japanese-resources` and guide | MIT list and immersion roadmap; linked works retain their own rights | Pedagogical research and outbound-resource candidates |
| `sigvt/learn-japanese` | MIT link directory with little original course material | Discovery only |
| `naghim/awesome-japanese-study-materials` | Useful directory; no clear repository licence displayed | Discovery only; do not copy |
| `firish/webfetch` | MIT local search, extraction, ranking and cache tool | Optional research tooling; never a mobile dependency |
| JMdict and KANJIDIC | CC BY-SA 4.0 dictionary data | Preferred future dictionary foundation |
| Tatoeba | Sentence text is CC BY; audio rights vary by contributor | Future sentences only with author attribution and quality filtering |

## Research lessons applied

- Start with kana and a small grammar and vocabulary foundation.
- Move into learner-chosen native content early rather than waiting for mastery.
- Let learners mine useful language from context into spaced repetition.
- Treat speaking, writing, reading and listening as distinct abilities.
- Offer systematic kanji components, but connect them to vocabulary and context.
- Provide more than one explanation for difficult grammar.

## Research workflow

For broad source discovery, use a search, fetch, rank and cache workflow such as
`webfetch` when available. Return only the top relevant passages to the working
context. Always open the authoritative licence or primary source before making
an import decision. Cached summaries never replace licence verification.

Do not scrape or bundle:

- commercial textbook prose or exercises;
- anime, podcast or YouTube audio without explicit distribution rights;
- native-speaker recordings without contributor consent and licence metadata;
- lists whose only provenance is “found online”;
- community content involving minors without guardian and moderation controls.
