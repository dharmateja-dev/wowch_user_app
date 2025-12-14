import 'package:flutter/material.dart';
import 'package:booking_system_flutter/utils/theme_colors.dart';

extension ColorSchemeExtension on BuildContext {
  ThemeData get appTheme => Theme.of(this);
  ColorScheme get colorScheme => appTheme.colorScheme;
  TextTheme get appTextTheme => appTheme.textTheme;
  bool get isDarkMode => appTheme.brightness == Brightness.dark;

  // ——— Primary Colors ———
  Color get primary => colorScheme.primary;
  Color get onPrimary => colorScheme.onPrimary;
  Color get primaryContainer => colorScheme.primaryContainer;
  Color get onPrimaryContainer => colorScheme.onPrimaryContainer;

  // ——— Secondary Colors ———
  Color get secondary => colorScheme.secondary;
  Color get onSecondary => colorScheme.onSecondary;
  Color get secondaryContainer => colorScheme.secondaryContainer;
  Color get onSecondaryContainer => colorScheme.onSecondaryContainer;

  // ——— Tertiary Colors ———
  Color get tertiary => colorScheme.tertiary;
  Color get onTertiary => colorScheme.onTertiary;
  Color get tertiaryContainer => colorScheme.tertiaryContainer;
  Color get onTertiaryContainer => colorScheme.onTertiaryContainer;

  // ——— Error Colors ———
  Color get error => colorScheme.error;
  Color get onError => colorScheme.onError;
  Color get errorContainer => colorScheme.errorContainer;
  Color get onErrorContainer => colorScheme.onErrorContainer;

  // ——— Surface Colors ———
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

  // ——— Outline (Border) Colors ———
  Color get outline => colorScheme.outline;
  Color get outlineVariant => colorScheme.outlineVariant;

  // ——— Others ———
  Color get shadow => colorScheme.shadow;
  Color get scrim => colorScheme.scrim;
  Color get inversePrimary => colorScheme.inversePrimary;

  // ══════════════════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ══════════════════════════════════════════════════════════════════════════

  /// Primary text color - Light: #1E1E1E, Dark: #E8F5F0
  Color get primaryTextColor =>
      isDarkMode ? DarkThemeColors.pureWhite : LightThemeColors.deepBlack;

  /// Secondary text color - Light: #4F4F4F, Dark: #4F4F4F
  Color get secondaryTextColor =>
      isDarkMode ? DarkThemeColors.softWhite : LightThemeColors.darkGray;

  /// Normal hint text color - Light: #9E9E9E, Dark: #6E7D78
  Color get hintTextColor =>
      isDarkMode ? DarkThemeColors.hintText : LightThemeColors.mutedText;

  /// Secondary container hint text color - Light: #4F4F4F, Dark: #B2C78F
  Color get secondaryContainerHintColor => isDarkMode
      ? DarkThemeColors.secondaryContainerHint
      : LightThemeColors.secondaryContainerHint;

  /// Secondary text for lite green container - Light: #9E9E9E, Dark: #B2C7BF
  Color get liteGreenContainerTextColor => isDarkMode
      ? DarkThemeColors.liteGreenContainerText
      : LightThemeColors.liteGreenContainerText;

  // ══════════════════════════════════════════════════════════════════════════
  // ICON COLORS
  // ══════════════════════════════════════════════════════════════════════════

  /// Main icon color - Light: #1E1E1E, Dark: #E8F5F0
  Color get iconColor =>
      isDarkMode ? DarkThemeColors.icon : LightThemeColors.icon;

  /// Icon primary green color - Both: #2E6B4F
  Color get iconPrimaryGreen => isDarkMode
      ? DarkThemeColors.iconPrimaryGreen
      : LightThemeColors.iconPrimaryGreen;

  /// Icon background color - Light: #FFFFFF, Dark: #F2F4F3
  Color get iconBackgroundColor => isDarkMode
      ? DarkThemeColors.iconBackgroundColor
      : LightThemeColors.iconBackgroundColor;

  /// Icon on primary container - Both: #FFFFFF
  Color get iconOnPrimaryContainer => isDarkMode
      ? DarkThemeColors.iconOnPrimaryContainer
      : LightThemeColors.iconOnPrimaryContainer;

  /// Icon on secondary container - Light: #1E1E1E, Dark: #E8F5F0
  Color get iconOnSecondaryContainer => isDarkMode
      ? DarkThemeColors.iconOnSecondaryContainer
      : LightThemeColors.iconOnSecondaryContainer;

  /// Tax icon color - Light: #9E9E9E, Dark: #6E7D78
  Color get taxIconColor =>
      isDarkMode ? DarkThemeColors.taxIconColor : LightThemeColors.taxIconColor;

  /// Muted/Unselected icon color (e.g., bottom nav unselected)
  Color get iconMuted => onSurfaceVariant;

  /// Primary/Active icon color (e.g., bottom nav selected, action icons)
  Color get iconPrimary => primary;

  // ══════════════════════════════════════════════════════════════════════════
  // BORDER COLORS
  // ══════════════════════════════════════════════════════════════════════════

  /// Input field border color - Light: #D6D6D6, Dark: #B2C7BF
  Color get inputBorderColor => outline;

  /// Green border color - Light: #2E6B4F, Dark: #93C0AB
  Color get greenBorderColor =>
      isDarkMode ? DarkThemeColors.greenBorder : LightThemeColors.greenBorder;

  /// Main border color (not for input field) - Light: #D6D6D6, Dark: #E0E0E0
  Color get mainBorderColor =>
      isDarkMode ? DarkThemeColors.mainBorder : LightThemeColors.mainBorder;

  // ══════════════════════════════════════════════════════════════════════════
  // DIVIDER COLORS
  // ══════════════════════════════════════════════════════════════════════════

  /// Main divider color in gray - Light: #1E1E1E, Dark: #E8F5F0
  Color get mainDividerColor =>
      isDarkMode ? DarkThemeColors.mainDivider : LightThemeColors.mainDivider;

  /// Divider on secondary container color - Light: #1E1E1E, Dark: #6E7D73
  Color get dividerOnSecondaryContainerColor => isDarkMode
      ? DarkThemeColors.dividerOnSecondaryContainer
      : LightThemeColors.dividerOnSecondaryContainer;

  /// Standard theme divider color
  Color get themeDividerColor => appTheme.dividerColor;

  // ══════════════════════════════════════════════════════════════════════════
  // INPUT FIELD COLORS
  // ══════════════════════════════════════════════════════════════════════════

  /// Input field fill color
  /// Light theme: transparent (for authentication section), secondary container otherwise
  /// Dark theme: #10101C
  Color get inputFillColor =>
      isDarkMode ? DarkThemeColors.inputFillColor : Colors.transparent;

  /// Input field fill color for secondary container sections
  Color get inputFillColorSecondary => secondaryContainer;

  /// Search/picker fill color - Light: #FFFFFF, Dark: #B2C7BF
  Color get searchFillColor =>
      isDarkMode ? const Color(0xFFB2C7BF) : const Color(0xFFFFFFFF);

  /// Search hint text color - Light: #9E9E9E (grey), Dark: #1E1E1E (black)
  Color get searchHintColor =>
      isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFF9E9E9E);

  /// Search icon color - Light: #1E1E1E (dark), Dark: #1E1E1E (black)
  Color get searchIconColor => const Color(0xFF1E1E1E);

  /// Search text color (typed text) - Dark in both themes: #1E1E1E
  Color get searchTextColor => const Color(0xFF1E1E1E);

  // ══════════════════════════════════════════════════════════════════════════
  // CONTAINER COLORS
  // ══════════════════════════════════════════════════════════════════════════

  /// Service component and provider component color - Light: #F2F4F3, Dark: #2A2A2A
  Color get serviceComponentColor => isDarkMode
      ? DarkThemeColors.serviceComponentColor
      : LightThemeColors.serviceComponentColor;

  /// Provider info details container color - Light: #F2F4F3, Dark: #2A2A2A
  Color get providerInfoDetailsContainerColor => isDarkMode
      ? DarkThemeColors.providerInfoDetailsContainer
      : LightThemeColors.providerInfoDetailsContainer;

  /// Primary container for shaded green color - Both: #93C0AB
  Color get shadedGreenContainer => primaryContainer;

  /// On primary container for shaded green color - Light: #1E1E1E, Dark: #121212
  Color get onShadedGreenContainer => onPrimaryContainer;

  /// Secondary container for complete light shaded green - Light: #E9F2EF, Dark: #101D1C
  Color get lightShadedGreenContainer => secondaryContainer;

  // ══════════════════════════════════════════════════════════════════════════
  // BOTTOM NAVIGATION COLORS
  // ══════════════════════════════════════════════════════════════════════════

  /// Bottom nav text color (inactive) - Both: #999999
  Color get bottomNavTextInactive => isDarkMode
      ? DarkThemeColors.bottomNavTextInactive
      : LightThemeColors.bottomNavTextInactive;

  /// Bottom nav icon color (inactive) - Both: #999999
  Color get bottomNavIconInactive => isDarkMode
      ? DarkThemeColors.bottomNavIconInactive
      : LightThemeColors.bottomNavIconInactive;

  /// Bottom nav text color (active) - Both: #2E6B4F
  Color get bottomNavTextActive => isDarkMode
      ? DarkThemeColors.bottomNavTextActive
      : LightThemeColors.bottomNavTextActive;

  /// Bottom nav icon color (active) - Both: #2E6B4F
  Color get bottomNavIconActive => isDarkMode
      ? DarkThemeColors.bottomNavIconActive
      : LightThemeColors.bottomNavIconActive;

  // ══════════════════════════════════════════════════════════════════════════
  // SPECIAL COLORS
  // ══════════════════════════════════════════════════════════════════════════

  /// Star color - Both: #FFC107
  Color get starColor =>
      isDarkMode ? DarkThemeColors.starColor : LightThemeColors.starColor;

  /// Primary color lite - Both: #65AE6A
  Color get primaryLiteColor => isDarkMode
      ? DarkThemeColors.primaryGreenLite
      : LightThemeColors.primaryGreenLite;

  /// Dialog box background color - Light: #FFFFFF, Dark: #203325
  Color get dialogBackgroundColor => isDarkMode
      ? DarkThemeColors.dialogBackground
      : LightThemeColors.dialogBackground;

  /// Bottom sheet background - Light: #F2F4F3, Dark: #2A2A2A
  Color get bottomSheetBackgroundColor => isDarkMode
      ? DarkThemeColors.bottomSheetBackground
      : LightThemeColors.bottomSheetBackground;

  // ══════════════════════════════════════════════════════════════════════════
  // CONVENIENCE ALIASES
  // ══════════════════════════════════════════════════════════════════════════

  /// Access scaffold background
  Color get scaffold => appTheme.scaffoldBackgroundColor;

  /// Access card background
  Color get card => appTheme.cardTheme.color ?? surface;

  // ——— Brightness Helpers ———

  /// Returns the appropriate status bar icon brightness based on theme
  /// Dark theme -> light icons, Light theme -> dark icons
  Brightness get statusBarBrightness =>
      isDarkMode ? Brightness.light : Brightness.dark;

  // ——— Legacy Aliases ———

  /// Fill color for input fields (legacy alias)
  Color get fillColor => inputFillColor;

  /// Hint text color for input fields (legacy alias)
  Color get hintColor => hintTextColor;

  /// Standard icon color (legacy alias)
  Color get icon => iconColor;

  /// Standard divider (legacy alias)
  Color get divider => themeDividerColor;
}
