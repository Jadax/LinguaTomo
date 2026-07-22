import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  final FlutterTts _tts = FlutterTts();
  bool _prepared = false;

  Future<void> _prepareWarmJapaneseVoice() async {
    if (_prepared) return;
    await _tts.setLanguage('ja-JP');
    await _tts.setSpeechRate(.42);
    await _tts.setPitch(.96);
    await _tts.setVolume(.9);

    final voices = await _tts.getVoices;
    if (voices is List) {
      const preferredNames = [
        'nanami',
        'kyoko',
        'haruka',
        'sayaka',
        'female',
        'natural',
        'enhanced',
      ];
      final japanese = voices.whereType<Map>().where((voice) {
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
        final selected = japanese.first;
        await _tts.setVoice({
          'name': '${selected['name']}',
          'locale': '${selected['locale'] ?? selected['language'] ?? 'ja-JP'}',
        });
      }
    }
    _prepared = true;
  }

  Future<void> speakJapanese(String text) async {
    await _tts.stop();
    await _prepareWarmJapaneseVoice();
    await _tts.awaitSpeakCompletion(true);
    await _tts.speak(text);
  }

  Future<void> dispose() => _tts.stop();
}
