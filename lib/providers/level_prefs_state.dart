import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../config/storage_keys.dart';
import '../models/app_models.dart';

const _boxName = StorageKeys.userData;

Box<dynamic>? get _box =>
    Hive.isBoxOpen(_boxName) ? Hive.box<dynamic>(_boxName) : null;

class LevelPrefsNotifier extends Notifier<DifficultyTier> {
  static const _key = 'level_prefs_v1';

  @override
  DifficultyTier build() {
    final stored = '${_box?.get(_key) ?? ''}';
    return DifficultyTier.values
            .where((tier) => tier.name == stored)
            .firstOrNull ??
        DifficultyTier.starter;
  }

  Future<void> setLevel(DifficultyTier tier) async {
    state = tier;
    await _box?.put(_key, tier.name);
  }
}

final levelPrefsProvider =
    NotifierProvider<LevelPrefsNotifier, DifficultyTier>(
      LevelPrefsNotifier.new,
    );
