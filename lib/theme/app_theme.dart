import 'package:flutter/material.dart';

import '../models/app_models.dart';

abstract final class AppColors {
  static const cream = Color(0xFFFFF9F2);
  static const surface = Color(0xFFFFFFFF);
  static const coral = Color(0xFFFF6B6B);
  static const teal = Color(0xFF4ECDC4);
  static const charcoal = Color(0xFF2D3436);
  static const muted = Color(0xFF747D80);
  static const peach = Color(0xFFFFE8D6);
  static const matcha = Color(0xFF6F8F3D);
  static const persimmon = Color(0xFFD94F45);
  static const bambooMist = Color(0xFFDDE7D3);
  static const sakura = Color(0xFFF5D8D5);
}

abstract final class AppTheme {
  static ThemeData lightFor(ExperienceMode mode) {
    final comfort = mode == ExperienceMode.comfort;
    final explorer = mode == ExperienceMode.visualExplorer;
    final interactiveHeight = explorer ? 60.0 : (comfort ? 56.0 : 48.0);
    final scheme = ColorScheme.light(
      primary: comfort ? AppColors.matcha : AppColors.persimmon,
      onPrimary: Colors.white,
      secondary: AppColors.matcha,
      onSecondary: AppColors.charcoal,
      surface: AppColors.surface,
      onSurface: AppColors.charcoal,
      error: Color(0xFFC94B4B),
      onError: Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      fontFamily: 'Nunito',
      visualDensity: explorer
          ? const VisualDensity(horizontal: 1, vertical: 1)
          : VisualDensity.standard,
    );

    return base.copyWith(
      textTheme: base.textTheme
          .apply(
            bodyColor: AppColors.charcoal,
            displayColor: AppColors.charcoal,
          )
          .copyWith(
            displaySmall: const TextStyle(
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w800,
            ),
            headlineSmall: const TextStyle(
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w800,
            ),
            titleLarge: const TextStyle(
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w800,
            ),
            titleMedium: const TextStyle(fontWeight: FontWeight.w700),
            bodyLarge: const TextStyle(height: 1.45),
            bodyMedium: const TextStyle(height: 1.4),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.charcoal,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: AppColors.charcoal.withValues(alpha: .08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        prefixIconColor: AppColors.muted,
        hintStyle: const TextStyle(color: AppColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColors.charcoal.withValues(alpha: .06),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.teal, width: 2),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: AppColors.charcoal.withValues(alpha: .08)),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size(48, interactiveHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.coral.withValues(alpha: .13),
        elevation: 3,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size(48, interactiveHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      pageTransitionsTheme: comfort
          ? const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: _NoMotionPageTransitionsBuilder(),
                TargetPlatform.iOS: _NoMotionPageTransitionsBuilder(),
                TargetPlatform.windows: _NoMotionPageTransitionsBuilder(),
                TargetPlatform.macOS: _NoMotionPageTransitionsBuilder(),
                TargetPlatform.linux: _NoMotionPageTransitionsBuilder(),
              },
            )
          : const PageTransitionsTheme(),
    );
  }
}

class _NoMotionPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoMotionPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({required this.child, super.key, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: padding ?? const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: child,
          ),
        ),
      ),
    );
  }
}
