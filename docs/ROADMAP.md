# Feature roadmap

Stability and pedagogical correctness outrank feature count. A feature is not
complete until its content rights, accessibility, persistence and tests are
defined.

## Current version: 1.14.6 (build 26)

## Product teaching model

LinguaTomo is the in-app instructor from beginner through advanced study. There
will be no instructor marketplace, booked tutoring or implied access to native
speakers. The course should stand alone for committed self-study and also fit
alongside lessons delivered by a learner's own external teacher.

---

## P0: launch-critical depth

### Completed

1. **Complete kana course**
   - 46 basic hiragana and 46 basic katakana with recognition and recall tasks
   - Writing canvas with stroke-order guidance
   - Undo for accidental answers
2. **Vocabulary foundation**
   - ~1,780 words across 10+ CEFR-aligned data files
   - Starter through Expert tiers with frequency-based ordering
   - FSRS spaced repetition with context sentences
   - Per-category theme lessons via `theme_registry.dart` (31 themed sections)
   - Listen-first quiz mode with audio auto-play
   - Quiz gate: 3/5 to pass; wrong words auto-retry; always pass on retry
3. **Dashboard and progression**
   - Cozy pixel-art loading scene with Leo the cat
   - Continue Learning card opens bottom-sheet theme picker
   - Daily Conversation card with audio playback (tappable dialog)
   - Level picker (tier radio list)
   - CEFR/JLPT guide accessible from learning hub
   - XP levels with titles (Explorer → Grand Master)
   - Streak tracking and stat pills
4. **Nest and rewards**
   - CustomPainter Nest scene with Leo sprite poses
   - Trophy shelf and achievement banner on lesson completion
   - Achievement tracker with 85 achievements, progress bars, secret hiding
   - Nest item placement and collection
5. **Platform**
   - Responsive: portrait-first mobile, centred 600 px on wide screens
   - British English throughout
   - Web build via GitHub Pages (`Jadax/LinguaTomo-Web`)
   - Hive local persistence; optional Supabase cloud sync
   - Version visible in-app and in commit messages

### Remaining

1. **Systematic kanji foundation**
   - Licensed KANJIDIC/JMdict data
   - Components, stroke count, vocabulary families, mnemonics
   - N5 to N1 filters
2. **Native audio pipeline**
   - Contributor consent, licence and speaker metadata
   - Normal and slow playback from recordings
   - Device TTS retained as offline fallback
   - Achievement sound effects (needs `.mp3` assets)

## P1: comprehension and output

### Completed (partial)

- Graded vocabulary lessons by category and tier
- Listen-first quiz with romaji support
- Postcard collection unlocked at 10 words

### Remaining

1. Graded readers from N5 to N1 with furigana toggle and dictionary lookup.
2. Listening stories with timed text highlighting.
3. Shadowing, recording and forgiving speech-recognition feedback.
4. FSI-style situation packs with branching dialogues.
5. Progress analytics for words, grammar, kanji, reviews and handwriting.
6. Full checkpoint assessments and original mock examinations.

## P2: retention and delight

### Completed (partial)

- Leo sprite with basic poses (idle, happy, sleeping)
- Nest scene with cottage, pond, fence, flowers, trees
- Achievement system with reward types
- Postcard collection
- Festival calendar with seasonal content
- Haptic feedback on achievement unlock

### Remaining

1. Expand Leo with restrained animation states: greet, listen, think, cheer,
   reassure, nap and celebrate.
2. Add optional gentle sound design, haptics and reduced-motion equivalents.
3. Expand the Nest with category collections and meaningful mastery rewards.
4. Before-and-after handwriting cards and private shareable progress cards.
5. A non-expiring calendar archive for postcards and seasonal stories.

## P3: optional community

1. Friend challenges and ghost-mode personal bests.
2. Moderated peer questions and clearly labelled community suggestions.
3. Guardian-controlled child accounts.
4. Opt-in leaderboards with complete stress-free disablement.

Direct messaging is out of scope until safeguarding, moderation and reporting
are independently designed and reviewed.

## Beyond v2: durable mastery

1. Complete original N5 to N1 lesson, reader, listening and mock-exam banks.
2. Professional domains including workplace interaction, public services,
   academic reading, formal presentation and mediation.
3. Dialect and register awareness using licensed recordings and original
   explanations.
4. Downloadable offline course packs with versioned content migrations.
5. A deep Nest collection, postcard archive, memory garden and seasonal story
   catalogue tied to demonstrated learning rather than compulsive spending.
6. Longitudinal progress views showing current position, next checkpoint,
   remaining scope and confidence decay.

## Definition of done

A roadmap item requires:

- a clear learner outcome and acceptance criteria;
- verified content ownership and attribution;
- offline behaviour or an explicit online requirement;
- accessible mobile and desktop interaction;
- persistence and migration handling;
- analytics events that avoid sensitive content;
- automated tests and target builds;
- documentation updated to match reality.
