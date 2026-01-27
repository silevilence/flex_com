import 'package:flutter/material.dart';

/// Application theme configuration
///
/// Design System: Developer Tool / Dashboard
/// Style: Professional, Technical, Clean
/// Color Palette: Dark tech colors with vibrant accents
class AppTheme {
  AppTheme._();

  // ============ Color Constants ============
  // Primary colors - Professional Blue
  static const _primaryLight = Color(0xFF2563EB); // Blue-600
  static const _primaryDark = Color(0xFF3B82F6); // Blue-500

  // Secondary colors - Slate
  static const _secondaryLight = Color(0xFF475569); // Slate-600
  static const _secondaryDark = Color(0xFF64748B); // Slate-500

  // Accent/CTA colors - Green for connection/success
  static const _accentLight = Color(0xFF16A34A); // Green-600
  static const _accentDark = Color(0xFF22C55E); // Green-500

  // Error colors
  static const _errorLight = Color(0xFFDC2626); // Red-600
  static const _errorDark = Color(0xFFEF4444); // Red-500

  // Surface colors for Light theme
  static const _surfaceLight = Color(0xFFF8FAFC); // Slate-50
  static const _surfaceContainerLight = Color(0xFFF1F5F9); // Slate-100
  static const _surfaceContainerHighLight = Color(0xFFE2E8F0); // Slate-200

  // Surface colors for Dark theme
  static const _surfaceDark = Color(0xFF0F172A); // Slate-900
  static const _surfaceContainerDark = Color(0xFF1E293B); // Slate-800
  static const _surfaceContainerHighDark = Color(0xFF334155); // Slate-700

  // Text colors
  static const _textLight = Color(0xFF0F172A); // Slate-900
  static const _textSecondaryLight = Color(0xFF475569); // Slate-600
  static const _textDark = Color(0xFFF8FAFC); // Slate-50
  static const _textSecondaryDark = Color(0xFF94A3B8); // Slate-400

  // Outline colors
  static const _outlineLight = Color(0xFFCBD5E1); // Slate-300
  static const _outlineDark = Color(0xFF475569); // Slate-600

  /// Light theme for the application
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _primaryLight,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFDBEAFE), // Blue-100
      onPrimaryContainer: const Color(0xFF1E40AF), // Blue-800
      secondary: _secondaryLight,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFE2E8F0), // Slate-200
      onSecondaryContainer: const Color(0xFF1E293B), // Slate-800
      tertiary: _accentLight,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFDCFCE7), // Green-100
      onTertiaryContainer: const Color(0xFF166534), // Green-800
      error: _errorLight,
      onError: Colors.white,
      errorContainer: const Color(0xFFFEE2E2), // Red-100
      onErrorContainer: const Color(0xFF991B1B), // Red-800
      surface: _surfaceLight,
      onSurface: _textLight,
      onSurfaceVariant: _textSecondaryLight,
      outline: _outlineLight,
      outlineVariant: const Color(0xFFE2E8F0), // Slate-200
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFFAFAFA),
      surfaceContainer: _surfaceContainerLight,
      surfaceContainerHigh: _surfaceContainerHighLight,
      surfaceContainerHighest: const Color(0xFFCBD5E1), // Slate-300
    );

    return _buildTheme(colorScheme);
  }

  /// Dark theme for the application
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _primaryDark,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF1E3A8A), // Blue-900
      onPrimaryContainer: const Color(0xFFDBEAFE), // Blue-100
      secondary: _secondaryDark,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFF334155), // Slate-700
      onSecondaryContainer: const Color(0xFFF1F5F9), // Slate-100
      tertiary: _accentDark,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFF166534), // Green-800
      onTertiaryContainer: const Color(0xFFDCFCE7), // Green-100
      error: _errorDark,
      onError: Colors.white,
      errorContainer: const Color(0xFF991B1B), // Red-800
      onErrorContainer: const Color(0xFFFEE2E2), // Red-100
      surface: _surfaceDark,
      onSurface: _textDark,
      onSurfaceVariant: _textSecondaryDark,
      outline: _outlineDark,
      outlineVariant: const Color(0xFF334155), // Slate-700
      surfaceContainerLowest: const Color(0xFF020617), // Slate-950
      surfaceContainerLow: const Color(0xFF0F172A), // Slate-900
      surfaceContainer: _surfaceContainerDark,
      surfaceContainerHigh: _surfaceContainerHighDark,
      surfaceContainerHighest: const Color(0xFF475569), // Slate-600
    );

    return _buildTheme(colorScheme);
  }

  /// Build theme with shared configuration
  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // Typography - Technical/Dashboard style
      fontFamily: 'Segoe UI', // System font, clean and professional
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      // Card theme - Subtle elevation
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        color: isDark
            ? colorScheme.surfaceContainerLow
            : colorScheme.surfaceContainerLowest,
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Filled button theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        isDense: true,
      ),

      // Dropdown menu theme
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: isDark
              ? colorScheme.surfaceContainerHigh
              : colorScheme.surfaceContainer,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          isDense: true,
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colorScheme.surface,
        elevation: 8,
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        backgroundColor: colorScheme.surface,
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Tab bar theme
      tabBarTheme: TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: colorScheme.outlineVariant,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
      ),

      // Navigation rail theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // Tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerHigh
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        textStyle: TextStyle(color: colorScheme.onSurface, fontSize: 12),
      ),

      // Segmented button theme
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),

      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHigh,
        circularTrackColor: colorScheme.surfaceContainerHigh,
      ),

      // Scrollbar theme
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(
          colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        radius: const Radius.circular(4),
        thickness: const WidgetStatePropertyAll(8),
      ),
    );
  }
}
