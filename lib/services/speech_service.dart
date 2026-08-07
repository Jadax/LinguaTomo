import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._();
  factory SpeechService() => _instance;
  SpeechService._();

  final FlutterTts _tts = FlutterTts();

  /// Chrome loads its speech voices asynchronously — `getVoices()` returns an
  /// empty list until a `voiceschanged` event fires shortly after load. We
  /// cannot subscribe to that event through flutter_tts, so we poll briefly
  /// for the Japanese voice list to become available before selecting one.
  /// This avoids the silent-speech bug where Chrome speaks with no audible
  /// Japanese because no voice was ever picked.
  /// Returns true once a Japanese voice has been configured (or none exists
  /// but speech should still be attempted), false never — speech always
  /// falls back to the platform default rather than silently disabling.
  Future<bool> _configureJapaneseVoice({bool awaitVoices = true}) async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(.72);
      await _tts.setPitch(.96);
      await _tts.setVolume(.9);
    } catch (_) {
      // Non-fatal; the platform default voice remains usable.
    }

    List<Map>? voices;
    if (awaitVoices) {
      // Wait (bounded) for Chrome's async voice list to populate.
      for (var attempt = 0; attempt < 6; attempt++) {
        try {
          final result = await _tts.getVoices;
          if (result is List && result.isNotEmpty) {
            voices = result.whereType<Map>().toList();
            break;
          }
        } catch (_) {
          // Keep polling below.
        }
        if (attempt < 5) {
          await Future<void>.delayed(const Duration(milliseconds: 250));
        }
      }
    } else {
      // Fast single read for a fresh voice pick on each speak.
      try {
        final result = await _tts.getVoices;
        if (result is List && result.isNotEmpty) {
          voices = result.whereType<Map>().toList();
        }
      } catch (_) {
        // Fall through to default voice.
      }
    }

    if (voices == null || voices.isEmpty) return true;

    const preferredNames = [
      'nanami',
      'kyoko',
      'haruka',
      'sayaka',
      'female',
      'natural',
      'enhanced',
    ];
    final japanese = voices.where((voice) {
      final locale = '${voice['locale'] ?? voice['language'] ?? ''}'
          .toLowerCase();
      return locale.startsWith('ja');
    }).toList();
    japanese.sort((a, b) {
      int warmthScore(Map voice) {
        final name = '${voice['name'] ?? ''}'.toLowerCase();
        for (var index = 0; index < preferredNames.length; index++) {
          if (name.contains(preferredNames[index])) {
            return preferredNames.length - index;
          }
        }
        return 0;
      }

      return warmthScore(b).compareTo(warmthScore(a));
    });
    if (japanese.isNotEmpty) {
      try {
        final selected = japanese.first;
        await _tts.setVoice({
          'name': '${selected['name']}',
          'locale':
              '${selected['locale'] ?? selected['language'] ?? 'ja-JP'}',
        });
      } catch (_) {
        // Keep the configured language; still attempt speech below.
      }
    }
    return true;
  }

  /// Prepare early so a browser's first speaker tap remains a user gesture.
  /// Chrome can reject speech that begins only after asynchronous voice lookup.
  Future<void> warmUp() {
    // Kick off a fire-and-forget warm-up so the Japanese voice is selected by
    // the time the learner taps a speaker. Safe to ignore the future here.
    return _configureJapaneseVoice();
  }

  /// Speech is always best-effort. A device with no TTS engine, a browser
  /// mid-load, or parental restrictions on a child's device must never turn
  /// a silent word into an unhandled exception — the lesson has already
  /// shown the word visually, so failing quietly here loses nothing critical.
  Future<void> speakJapanese(String text) async {
    try {
      await _tts.stop();
      // Re-select the voice right before speaking too: on very slow machines
      // the Chrome voice list may only finish loading after the early
      // warm-up, and a freshly re-picked voice is the safest path to audible
      // Japanese.
      await _configureJapaneseVoice(awaitVoices: false);
      if (!kIsWeb) await _tts.awaitSpeakCompletion(true);
      await _tts.speak(text);
    } catch (_) {
      // No TTS engine available; the word remains fully readable on screen.
    }
  }

  Future<void> dispose() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Already stopped or unavailable.
    }
  }
}
