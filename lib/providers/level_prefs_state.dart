import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/local_store.dart';
import '../models/app_models.dart';

class LevelPrefsNotifier extends Notifier<DifficultyTier> {
  static const _key = 'level_prefs_v1';

  @override
  DifficultyTier build() {
    final stored = '${localStore?.get(_key) ?? ''}';
    return DifficultyTier.values
            .where((tier) => tier.name == stored)
            .firstOrNull ??
        DifficultyTier.starter;
  }

  Future<void> setLevel(DifficultyTier tier) async {
    state = tier;
    await localStore?.put(_key, tier.name);
  }
}

final levelPrefsProvider =
    NotifierProvider<LevelPrefsNotifier, DifficultyTier>(
      LevelPrefsNotifier.new,
    );
