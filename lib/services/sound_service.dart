import 'package:audioplayers/audioplayers.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../config/storage_keys.dart';

/// Plays short original feedback sounds (correct / wrong / tap / chimes) that
/// were synthesised from scratch (see tool/generate_sfx.py). They ship as WAV
/// assets matching the filenames below. All playback is best-effort: if a file
/// is missing or playback is unsupported the learner simply hears nothing and
/// learning is never blocked.
class SoundService {
  SoundService._();

  static final SoundService _instance = SoundService._();
  factory SoundService() => _instance;

  static const _soundMutedKey = 'sound_muted';

  final AudioPlayer _player = AudioPlayer();

  bool _muted = false;

  /// Reads the persisted mute preference once available.
  Future<void> init() async {
    try {
      final box = Hive.isBoxOpen(_boxName) ? Hive.box(_boxName) : null;
      _muted = box?.get(_soundMutedKey, defaultValue: false) as bool? ?? false;
    } catch (_) {
      _muted = false;
    }
  }

  static const _boxName = StorageKeys.userData;

  bool get isMuted => _muted;

  Future<void> setMuted(bool value) async {
    _muted = value;
    try {
      final box = Hive.isBoxOpen(_boxName) ? Hive.box<dynamic>(_boxName) : null;
      await box?.put(_soundMutedKey, value);
    } catch (_) {
      // In-memory mute still applies for this session.
    }
  }

  Future<void> _play(String filename, {double volume = 0.7}) async {
    if (_muted) return;
    try {
      _player.setVolume(volume);
      await _player.play(AssetSource('sounds/$filename.wav'));
    } catch (_) {
      // Ignore missing/unsupported audio; learning proceeds silently.
    }
  }

  Future<void> playCorrect() => _play('correct', volume: 0.75);
  Future<void> playWrong() => _play('wrong', volume: 0.6);
  Future<void> playTap() => _play('tap', volume: 0.5);
  Future<void> playOpen() => _play('open', volume: 0.55);
  Future<void> playAchievement() => _play('achievement_chime', volume: 0.8);
  Future<void> playLessonComplete() => _play('lesson_complete', volume: 0.8);

  Future<void> stop() => _player.stop();

  void dispose() => _player.dispose();
}
