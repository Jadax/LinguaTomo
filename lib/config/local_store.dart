import 'package:hive_flutter/hive_flutter.dart';

import 'storage_keys.dart';

/// The learner's single Hive box, or `null` when Hive could not be opened.
///
/// Every provider persists through this one getter. Returning `null` rather
/// than throwing is deliberate: a corrupt or unavailable store degrades the
/// app to memory-only learning for the session instead of blocking the course.
Box<dynamic>? get localStore => Hive.isBoxOpen(StorageKeys.userData)
    ? Hive.box<dynamic>(StorageKeys.userData)
    : null;
