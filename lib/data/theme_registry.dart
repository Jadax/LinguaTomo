import '../models/app_models.dart';

/// All 21 themed word sections — browsable in the app.
class ThemeEntry {
  const ThemeEntry({
    required this.id,
    required this.name,
    required this.emoji,
    required this.tier,
    required this.cefr,
    required this.jlpt,
    required this.wordIds,
  });
  final String id, name, emoji, cefr, jlpt;
  final DifficultyTier tier;
  final List<String> wordIds;
}

final allThemes = <ThemeEntry>[
  // Pre-A1 / N5 — Starter
  ThemeEntry(id: 'basics_hello', name: 'Hello & Goodbye', emoji: '👋', tier: DifficultyTier.starter, cefr: 'Pre-A1', jlpt: 'N5', wordIds: const ['s_01','s_02','s_03','s_04','s_05','s_08','s_09','s_10','s_81','s_82','s_83']),
  ThemeEntry(id: 'basics_people', name: 'Family & People', emoji: '👨‍👩‍👧', tier: DifficultyTier.starter, cefr: 'Pre-A1', jlpt: 'N5', wordIds: const ['s_21','s_22','s_23','s_24','s_25','s_26','s_27','s_86','s_87']),
  ThemeEntry(id: 'basics_home', name: 'My Home', emoji: '🏠', tier: DifficultyTier.starter, cefr: 'Pre-A1', jlpt: 'N5', wordIds: const ['s_11','s_12','s_13','s_14','s_16','s_17','s_18','s_84','s_85','s_93']),
  ThemeEntry(id: 'basics_food', name: 'Yummy Food', emoji: '🍙', tier: DifficultyTier.starter, cefr: 'Pre-A1', jlpt: 'N5', wordIds: const ['s_31','s_32','s_33','s_34','s_36','s_37','s_88','s_89']),
  ThemeEntry(id: 'basics_animals', name: 'Cute Animals', emoji: '🐱', tier: DifficultyTier.starter, cefr: 'Pre-A1', jlpt: 'N5', wordIds: const ['s_71','s_72','s_73','s_74','s_75','s_76','s_78','s_98','s_99']),
  ThemeEntry(id: 'basics_verbs', name: 'First Actions', emoji: '🏃', tier: DifficultyTier.starter, cefr: 'Pre-A1', jlpt: 'N5', wordIds: const ['s_41','s_42','s_43','s_44','s_45','s_90','s_91','s_92']),
  ThemeEntry(id: 'basics_nature', name: 'Outdoors', emoji: '🌿', tier: DifficultyTier.starter, cefr: 'Pre-A1', jlpt: 'N5', wordIds: const ['s_61','s_62','s_63','s_64','s_65','s_70','s_96','s_97','s_100']),
  ThemeEntry(id: 'basics_places', name: 'Places To Go', emoji: '🏫', tier: DifficultyTier.starter, cefr: 'Pre-A1', jlpt: 'N5', wordIds: const ['s_51','s_52','s_55','s_56','s_58','s_59','s_94','s_95']),

  // A1 / N5 — Elementary
  ThemeEntry(id: 'numbers', name: 'Numbers & Counting', emoji: '🔢', tier: DifficultyTier.elementary, cefr: 'A1', jlpt: 'N5', wordIds: const ['n_01','n_02','n_03','n_04','n_05','n_06','n_07','n_08','n_09','n_10','n_11','n_12']),
  ThemeEntry(id: 'days_time', name: 'Days & Time', emoji: '📅', tier: DifficultyTier.elementary, cefr: 'A1', jlpt: 'N5', wordIds: const ['dt_01','dt_02','dt_03','dt_04','dt_05','dt_06','dt_07','dt_08','dt_09','dt_10','dt_11','dt_12']),
  ThemeEntry(id: 'colours', name: 'Colours', emoji: '🎨', tier: DifficultyTier.elementary, cefr: 'A1', jlpt: 'N5', wordIds: const ['co_01','co_02','co_03','co_04','co_05','co_06','co_07','co_08','co_09','co_10']),
  ThemeEntry(id: 'body', name: 'Body & Health', emoji: '🏥', tier: DifficultyTier.elementary, cefr: 'A1', jlpt: 'N5', wordIds: const ['bd_01','bd_02','bd_03','bd_04','bd_05','bd_06','bd_07','bd_08','bd_09','bd_10','bd_11']),
  ThemeEntry(id: 'clothing', name: 'Clothing', emoji: '👗', tier: DifficultyTier.elementary, cefr: 'A1', jlpt: 'N5', wordIds: const ['cl_01','cl_02','cl_03','cl_04','cl_05','cl_06','cl_07','cl_08','cl_09','cl_10']),
  ThemeEntry(id: 'weather', name: 'Weather & Seasons', emoji: '⛅', tier: DifficultyTier.elementary, cefr: 'A1', jlpt: 'N5', wordIds: const ['ws_01','ws_02','ws_03','ws_04','ws_05','ws_06','ws_07','ws_08','ws_09','ws_10']),
  ThemeEntry(id: 'transport', name: 'Transport', emoji: '🚗', tier: DifficultyTier.elementary, cefr: 'A1', jlpt: 'N5', wordIds: const ['tp_01','tp_02','tp_03','tp_04','tp_05','tp_06','tp_07','tp_08','tp_09','tp_10']),
  ThemeEntry(id: 'shopping', name: 'Shopping', emoji: '🛍️', tier: DifficultyTier.elementary, cefr: 'A1', jlpt: 'N5', wordIds: const ['sh_01','sh_02','sh_03','sh_04','sh_05','sh_06','sh_07','sh_08','sh_09','sh_10']),
  ThemeEntry(id: 'hobbies', name: 'Hobbies & Fun', emoji: '🎮', tier: DifficultyTier.elementary, cefr: 'A1', jlpt: 'N5', wordIds: const ['hb_01','hb_02','hb_03','hb_04','hb_05','hb_06','hb_07','hb_08','hb_09','hb_10']),

  // A2 / N4 — Intermediate  
  ThemeEntry(id: 'people_desc', name: 'Describing People', emoji: '🧑‍🤝‍🧑', tier: DifficultyTier.intermediate, cefr: 'A2', jlpt: 'N4', wordIds: const ['dp_01','dp_02','dp_03','dp_04','dp_05','dp_06','dp_07','dp_08','dp_09','dp_10']),
  ThemeEntry(id: 'restaurant', name: 'Restaurant & Cafe', emoji: '🍽️', tier: DifficultyTier.intermediate, cefr: 'A2', jlpt: 'N4', wordIds: const ['rc_01','rc_02','rc_03','rc_04','rc_05','rc_06','rc_07','rc_08','rc_09','rc_10']),
  ThemeEntry(id: 'work', name: 'Work & Office', emoji: '💼', tier: DifficultyTier.intermediate, cefr: 'A2', jlpt: 'N4', wordIds: const ['wo_01','wo_02','wo_03','wo_04','wo_05','wo_06','wo_07','wo_08','wo_09','wo_10']),
  ThemeEntry(id: 'travel', name: 'Travel & Hotels', emoji: '🏨', tier: DifficultyTier.intermediate, cefr: 'A2', jlpt: 'N4', wordIds: const ['tr_01','tr_02','tr_03','tr_04','tr_05','tr_06','tr_07','tr_08','tr_09','tr_10']),
  ThemeEntry(id: 'feelings', name: 'Feelings & Emotions', emoji: '😊', tier: DifficultyTier.intermediate, cefr: 'A2', jlpt: 'N4', wordIds: const ['fe_01','fe_02','fe_03','fe_04','fe_05','fe_06','fe_07','fe_08','fe_09','fe_10']),
  ThemeEntry(id: 'tech', name: 'Technology', emoji: '📱', tier: DifficultyTier.intermediate, cefr: 'A2', jlpt: 'N4', wordIds: const ['te_01','te_02','te_03','te_04','te_05','te_06','te_07','te_08','te_09','te_10']),

  // B1/B2 / N3/N2 — Advanced/Expert
  ThemeEntry(id: 'media', name: 'Media & News', emoji: '📰', tier: DifficultyTier.advanced, cefr: 'B1/B2', jlpt: 'N3/N2', wordIds: const ['mn_01','mn_02','mn_03','mn_04','mn_05','mn_06','mn_07','mn_08','mn_09','mn_10']),
  ThemeEntry(id: 'business', name: 'Business & Economy', emoji: '💼', tier: DifficultyTier.advanced, cefr: 'B1/B2', jlpt: 'N3/N2', wordIds: const ['be_01','be_02','be_03','be_04','be_05','be_06','be_07','be_08','be_09','be_10']),
  ThemeEntry(id: 'culture', name: 'Culture & Arts', emoji: '🎭', tier: DifficultyTier.advanced, cefr: 'B1/B2', jlpt: 'N3/N2', wordIds: const ['ca_01','ca_02','ca_03','ca_04','ca_05','ca_06','ca_07','ca_08','ca_09','ca_10']),
  ThemeEntry(id: 'abstract', name: 'Abstract Ideas', emoji: '💭', tier: DifficultyTier.expert, cefr: 'B2', jlpt: 'N2', wordIds: const ['ai_01','ai_02','ai_03','ai_04','ai_05','ai_06','ai_07','ai_08','ai_09','ai_10']),
  ThemeEntry(id: 'society', name: 'Society & Politics', emoji: '🏛️', tier: DifficultyTier.expert, cefr: 'B2', jlpt: 'N2', wordIds: const ['sp_01','sp_02','sp_03','sp_04','sp_05','sp_06','sp_07','sp_08','sp_09','sp_10']),
  ThemeEntry(id: 'adv_verbs', name: 'Advanced Verbs', emoji: '⚡', tier: DifficultyTier.expert, cefr: 'B2', jlpt: 'N2', wordIds: const ['av_01','av_02','av_03','av_04','av_05','av_06','av_07','av_08','av_09','av_10']),
];
