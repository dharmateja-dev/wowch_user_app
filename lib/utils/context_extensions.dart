import 'package:flutter/material.dart';

extension ColorSchemeExtension on BuildContext {
  ThemeData get appTheme => Theme.of(this);
  ColorScheme get colorScheme => appTheme.colorScheme;
  TextTheme get appTextTheme => appTheme.textTheme;

  // Primary
  Color get primary => colorScheme.primary;
  Color get onPrimary => colorScheme.onPrimary;
  Color get primaryContainer => colorScheme.primaryContainer;
  Color get onPrimaryContainer => colorScheme.onPrimaryContainer;

  // Secondary
  Color get secondary => colorScheme.secondary;
  Color get onSecondary => colorScheme.onSecondary;
  Color get secondaryContainer => colorScheme.secondaryContainer;
  Color get onSecondaryContainer => colorScheme.onSecondaryContainer;

  // Tertiary
  Color get tertiary => colorScheme.tertiary;
  Color get onTertiary => colorScheme.onTertiary;
  Color get tertiaryContainer => colorScheme.tertiaryContainer;
  Color get onTertiaryContainer => colorScheme.onTertiaryContainer;

  // Error
  Color get error => colorScheme.error;
  Color get onError => colorScheme.onError;
  Color get errorContainer => colorScheme.errorContainer;
  Color get onErrorContainer => colorScheme.onErrorContainer;

  // Surface
  Color get surface => colorScheme.surface;
  Color get onSurface => colorScheme.onSurface;
  Color get onSurfaceVariant => colorScheme.onSurfaceVariant;
  Color get inverseSurface => colorScheme.inverseSurface;
  Color get onInverseSurface => colorScheme.onInverseSurface;
  Color get surfaceContainerHighest => colorScheme.surfaceContainerHighest;
  Color get surfaceContainerHigh => colorScheme.surfaceContainerHigh;
  Color get surfaceContainer => colorScheme.surfaceContainer;
  Color get surfaceContainerLow => colorScheme.surfaceContainerLow;
  Color get surfaceContainerLowest => colorScheme.surfaceContainerLowest;

  // Outline (Border)
  Color get outline => colorScheme.outline;
  Color get outlineVariant => colorScheme.outlineVariant;

  // Others
  Color get shadow => colorScheme.shadow;
  Color get scrim => colorScheme.scrim;
  Color get inversePrimary => colorScheme.inversePrimary;

  // ——— Convenience Aliases (Non-conflicting with nb_utils) ———

  /// Access standard divider color
  Color get divider => appTheme.dividerColor;

  /// Input border color: Primary border in light, Dark border in dark
  Color get inputBorderColor => outline;

  /// Standard icon color: Black in light, White in dark
  Color get icon => appTheme.iconTheme.color ?? onSurface;

  /// Muted/Unselected icon color (e.g., bottom nav unselected)
  Color get iconMuted => onSurfaceVariant;

  /// Primary/Active icon color (e.g., bottom nav selected, action icons)
  Color get iconPrimary => primary;

  /// Access scaffold background
  Color get scaffold => appTheme.scaffoldBackgroundColor;

  /// Access card background
  Color get card => appTheme.cardTheme.color ?? surface;

  // ——— Brightness Helpers ———

  /// Returns the appropriate status bar icon brightness based on theme
  /// Dark theme -> light icons, Light theme -> dark icons
  Brightness get statusBarBrightness => appTheme.brightness == Brightness.dark
      ? Brightness.light
      : Brightness.dark;

  // ——— Input Field Helpers ———

  /// Fill color for input fields
  /// Light theme: transparent, Dark theme: tinted background
  Color get fillColor => appTheme.brightness == Brightness.dark
      ? const Color(0xFF101d1c)
      : Colors.transparent;

  /// Hint text color for input fields
  /// Light theme: muted gray, Dark theme: greenish gray
  Color get hintColor => appTheme.brightness == Brightness.dark
      ? const Color(0xFF6E7D78)
      : const Color(0xFF9E9E9E);
}
