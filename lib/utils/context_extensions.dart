import 'package:flutter/material.dart';
import 'package:booking_system_flutter/utils/theme_colors.dart';

/// ══════════════════════════════════════════════════════════════════════════
/// CONTEXT EXTENSIONS - Theme-aware color access
/// ══════════════════════════════════════════════════════════════════════════
///
/// This extension provides easy access to theme colors via BuildContext.
///
/// USAGE:
///   context.primary       // Primary brand color
///   context.onSurface     // Text color (black/white based on theme)
///   context.surface       // Background color for cards/components
///
/// PRINCIPLE:
///   - Colors from ColorScheme → Use directly (auto theme-aware)
///   - Custom semantic colors → Only when ColorScheme doesn't have equivalent
/// ══════════════════════════════════════════════════════════════════════════

extension ColorSchemeExtension on BuildContext {
  // ══════════════════════════════════════════════════════════════════════════
  // CORE THEME ACCESS
  // ══════════════════════════════════════════════════════════════════════════

  ThemeData get appTheme => Theme.of(this);
  ColorScheme get colorScheme => appTheme.colorScheme;
  TextTheme get appTextTheme => appTheme.textTheme;
  bool get isDarkMode => appTheme.brightness == Brightness.dark;

  // ══════════════════════════════════════════════════════════════════════════
  // COLOR SCHEME ACCESSORS (Direct from Material 3 ColorScheme)
  // These are ALWAYS theme-aware - no manual isDarkMode checks needed!
  // ══════════════════════════════════════════════════════════════════════════

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
  // SEMANTIC ALIASES (Map to ColorScheme - NO redundant ternaries!)
  // Use these for semantic meaning in your code
  // ══════════════════════════════════════════════════════════════════════════

  // ——— Text Colors ———
  /// Primary text color → Uses onSurface (auto theme-aware)
  Color get primaryTextColor => onSurface;

  /// Secondary/muted text color → Uses onSurfaceVariant
  Color get secondaryTextColor => onSurfaceVariant;

  /// Hint text color → Uses onSurfaceVariant
  Color get hintTextColor => onSurfaceVariant;

  // ——— Icon Colors ———
  /// Main icon color → Uses onSurface
  Color get iconColor => onSurface;

  /// Muted/inactive icon → Uses onSurfaceVariant
  Color get iconMuted => onSurfaceVariant;

  /// Primary/active icon → Uses primary
  Color get iconPrimary => primary;

  // ——— Border Colors ———
  /// Input field border → Uses outline
  Color get inputBorderColor => outline;

  // ——— Container Aliases ———
  /// Shaded green container → Uses primaryContainer
  Color get shadedGreenContainer => primaryContainer;

  /// On shaded green container → Uses onPrimaryContainer
  Color get onShadedGreenContainer => onPrimaryContainer;

  /// Light shaded green container → Uses secondaryContainer
  Color get lightShadedGreenContainer => secondaryContainer;

  /// Input fill for secondary sections → Uses secondaryContainer
  Color get inputFillColorSecondary => secondaryContainer;

  // ══════════════════════════════════════════════════════════════════════════
  // CUSTOM SEMANTIC COLORS (Only when ColorScheme doesn't have equivalent)
  // These NEED ternary operators because they're custom to your design
  // ══════════════════════════════════════════════════════════════════════════

  // ——— Custom Text Colors ———

  /// Accent text color for emphasis
  /// Light: primary (#2E6B4F green), Dark: primaryContainer (#93C0AB lighter green)
  /// Use for important text that needs brand color but readable in both themes
  Color get cancelText => isDarkMode ? primaryContainer : primary;

  /// Subtitle/muted text color for secondary information
  /// Light: #72777A (slate gray), Dark: #B2C7BF (light greenish)
  /// Use for subtitle text that needs good contrast in both themes
  Color get subtitleTextColor =>
      isDarkMode ? const Color(0xFFB2C7BF) : const Color(0xFF72777A);

  /// Grey text color - Both: #9E9E9E
  /// Use for muted labels, secondary info that should stay grey in both themes
  Color get textGrey => const Color(0xFF9E9E9E);

  /// Secondary container hint text - Light: #4F4F4F, Dark: #B2C78F
  Color get secondaryContainerHintColor => isDarkMode
      ? DarkThemeColors.secondaryContainerHint
      : LightThemeColors.secondaryContainerHint;

  /// Lite green container text - Light: #9E9E9E, Dark: #B2C7BF
  Color get liteGreenContainerTextColor => isDarkMode
      ? DarkThemeColors.liteGreenContainerText
      : LightThemeColors.liteGreenContainerText;

  /// Description text color - Light: #4F4F4F, Dark: #B2C7BF
  /// Use for description/body text that needs good contrast in both themes
  Color get descriptionTextColor =>
      isDarkMode ? const Color(0xFFB2C7BF) : const Color(0xFF4F4F4F);

  // ——— Custom Icon Colors ———
  /// Icon primary green - Both: #2E6B4F
  Color get iconPrimaryGreen => LightThemeColors.iconPrimaryGreen;

  /// Icon background - Light: #FFFFFF, Dark: #F2F4F3
  Color get iconBackgroundColor =>
      isDarkMode ? Color(0xFFB2C7BF) : Color(0xFF4F4F4F);

  /// Icon on primary container - Both: #FFFFFF
  Color get iconOnPrimaryContainer => LightThemeColors.iconOnPrimaryContainer;

  /// Icon on secondary container - Light: #1E1E1E, Dark: #E8F5F0
  Color get iconOnSecondaryContainer => isDarkMode
      ? DarkThemeColors.iconOnSecondaryContainer
      : LightThemeColors.iconOnSecondaryContainer;

  /// Tax icon color - Light: #9E9E9E, Dark: #6E7D78
  Color get taxIconColor =>
      isDarkMode ? DarkThemeColors.taxIconColor : LightThemeColors.taxIconColor;

  // ——— Custom Border Colors ———
  /// Green border - Light: #2E6B4F, Dark: #93C0AB
  Color get greenBorderColor =>
      isDarkMode ? DarkThemeColors.greenBorder : LightThemeColors.greenBorder;

  /// Main border (non-input) - Light: #D6D6D6, Dark: #E0E0E0
  Color get mainBorderColor =>
      isDarkMode ? DarkThemeColors.mainBorder : LightThemeColors.mainBorder;

  // ——— Custom Divider Colors ———
  /// Main divider - Light: #1E1E1E, Dark: #E8F5F0
  Color get mainDividerColor =>
      isDarkMode ? DarkThemeColors.mainDivider : LightThemeColors.mainDivider;

  /// Divider on secondary container - Light: #1E1E1E, Dark: #6E7D73
  Color get dividerOnSecondaryContainerColor => isDarkMode
      ? DarkThemeColors.dividerOnSecondaryContainer
      : LightThemeColors.dividerOnSecondaryContainer;

  /// Theme divider color
  Color get themeDividerColor => appTheme.dividerColor;

  // ——— Custom Input Colors ———
  /// Input fill - Light: transparent, Dark: #10101C
  Color get inputFillColor =>
      isDarkMode ? DarkThemeColors.inputFillColor : Colors.transparent;

  /// Search fill - Light: #FFFFFF, Dark: #B2C7BF
  Color get searchFillColor =>
      isDarkMode ? const Color(0xFFB2C7BF) : const Color(0xFFFFFFFF);

  /// Search hint color - Light: #9E9E9E, Dark: #1E1E1E
  Color get searchHintColor =>
      isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFF9E9E9E);

  /// Search icon color - Both: #1E1E1E
  Color get searchIconColor => const Color(0xFF1E1E1E);

  /// Search text color - Both: #1E1E1E
  Color get searchTextColor => const Color(0xFF1E1E1E);

  /// Search hint text - Light: #6C7072, Dark: #B2C7BF
  Color get searchHintTextColor => isDarkMode
      ? DarkThemeColors.liteGreenContainerText
      : LightThemeColors.softGrey;

  // ——— Custom Container Colors ———
  /// Service/provider component - Light: #F2F4F3, Dark: #2A2A2A
  Color get serviceComponentColor => isDarkMode
      ? DarkThemeColors.serviceComponentColor
      : LightThemeColors.serviceComponentColor;

  /// Provider info container - Light: #F2F4F3, Dark: #2A2A2A
  Color get providerInfoDetailsContainerColor => isDarkMode
      ? DarkThemeColors.providerInfoDetailsContainer
      : LightThemeColors.providerInfoDetailsContainer;

  /// Alternative button background - Light: onPrimary (white), Dark: #101D1C (dark green)
  /// Use for buttons on colored backgrounds (like primary/green sections)
  Color get buttonBackgroundAlt => isDarkMode
      ? DarkThemeColors.secondaryContainer // #101D1C
      : onPrimary; // white

  // ——— Bottom Navigation Colors ———
  /// Bottom nav inactive text - Both: #999999
  Color get bottomNavTextInactive => const Color(0xFF999999);

  /// Bottom nav inactive icon - Both: #999999
  Color get bottomNavIconInactive => const Color(0xFF999999);

  /// Bottom nav active text - Both: #2E6B4F
  Color get bottomNavTextActive => LightThemeColors.primaryGreen;

  /// Bottom nav active icon - Both: #2E6B4F
  Color get bottomNavIconActive => LightThemeColors.primaryGreen;

  // ——— Special Colors ———
  /// Star color - Both: #FFC107
  Color get starColor => const Color(0xFFFFC107);

  /// Primary lite - Both: #65AE6A
  Color get primaryLiteColor => const Color(0xFF65AE6A);

  /// Dialog background - Light: #FFFFFF, Dark: #203325
  Color get dialogBackgroundColor => isDarkMode
      ? DarkThemeColors.dialogBackground
      : LightThemeColors.dialogBackground;

  /// Bottom sheet background - Light: #F2F4F3, Dark: #2A2A2A
  Color get bottomSheetBackgroundColor => isDarkMode
      ? DarkThemeColors.bottomSheetBackground
      : LightThemeColors.bottomSheetBackground;

  // ——— Status Colors ———
  /// Status success/active background - Both: #5EAF5E
  Color get statusSuccessBackground => const Color(0xFF5EAF5E);

  /// Status success/active text - Light: #073807, Dark: #101D1C
  Color get statusSuccessText =>
      isDarkMode ? const Color(0xFF101D1C) : const Color(0xFF073807);

  // ——— Dialog Colors ———
  /// Dialog icon color - Light: primary (#2E6B4F), Dark: #93C0AB
  Color get dialogIconColor => isDarkMode ? primaryContainer : primary;

  /// Dialog title color - Light: #1E1E1E, Dark: #FFFFFF (white)
  Color get dialogTitleColor =>
      isDarkMode ? const Color(0xFFE8F5F0) : const Color(0xFF1E1E1E);

  /// Dialog cancel button border & text - Light: primary (#2E6B4F), Dark: #93C0AB
  Color get dialogCancelColor => isDarkMode ? primaryContainer : primary;

  // ══════════════════════════════════════════════════════════════════════════
  // CONVENIENCE HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  /// Scaffold background
  Color get scaffold => appTheme.scaffoldBackgroundColor;

  /// Card background
  Color get card => appTheme.cardTheme.color ?? surface;

  /// Status bar brightness (for SystemUiOverlayStyle)
  Brightness get statusBarBrightness =>
      isDarkMode ? Brightness.light : Brightness.dark;

  // ══════════════════════════════════════════════════════════════════════════
  // LEGACY ALIASES (For backward compatibility)
  // ══════════════════════════════════════════════════════════════════════════

  Color get fillColor => inputFillColor;
  Color get hintColor => hintTextColor;
  Color get icon => iconColor;
  Color get divider => themeDividerColor;
}
