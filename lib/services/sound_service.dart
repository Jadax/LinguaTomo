import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._();
  factory SoundService() => _instance;
  SoundService._();

  final _player = AudioPlayer();

  Future<void> playAchievement() async {
    try {
      await _player.play(AssetSource('sounds/achievement_chime.mp3'));
    } catch (_) {
      // Sound file not yet added — fail silently
    }
  }

  Future<void> playComplete() async {
    try {
      await _player.play(AssetSource('sounds/lesson_complete.mp3'));
    } catch (_) {}
  }

  void dispose() => _player.dispose();
}
