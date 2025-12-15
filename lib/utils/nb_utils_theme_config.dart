import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:booking_system_flutter/utils/theme_colors.dart';
import 'package:booking_system_flutter/utils/colors.dart';

/// ══════════════════════════════════════════════════════════════════════════
/// NB_UTILS GLOBAL CONFIGURATION
/// ══════════════════════════════════════════════════════════════════════════
///
/// For TEXT STYLES, use context-based methods from text_styles.dart:
///   - context.boldTextStyle()
///   - context.primaryTextStyle()
///   - context.secondaryTextStyle()
///
/// This file only configures nb_utils features that read globals at runtime
/// (like toasts, loaders, buttons) rather than at widget build time.
/// ══════════════════════════════════════════════════════════════════════════

/// Configure nb_utils theme-dependent settings.
/// Call this when the app starts and when the theme changes.
void configureNbUtilsTheme({required bool isDarkMode}) {
  // ——— Toast Colors ———
  defaultToastBackgroundColor = isDarkMode ? Colors.white : Colors.black;
  defaultToastTextColor = isDarkMode ? Colors.black : Colors.white;

  // ——— Loader Colors ———
  defaultLoaderBgColorGlobal =
      isDarkMode ? DarkThemeColors.softCharcoal : Colors.white;
  defaultLoaderAccentColorGlobal = primaryColor;

  // ——— AppBar Colors ———
  appBarBackgroundColorGlobal =
      isDarkMode ? DarkThemeColors.richBlack : LightThemeColors.mediumGray;

  // ——— Button Colors ———
  appButtonBackgroundColorGlobal = primaryColor;
  defaultAppButtonTextColorGlobal =
      isDarkMode ? DarkThemeColors.pureWhite : Colors.white;

  // ——— InkWell Colors ———
  defaultInkWellSplashColor = isDarkMode ? Colors.white12 : Colors.black12;
  defaultInkWellHoverColor =
      isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.04);
  defaultInkWellHighlightColor =
      isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.04);

  // ——— Shadow Colors ———
  shadowColorGlobal =
      isDarkMode ? DarkThemeColors.shadowLight : LightThemeColors.shadowLight;
}

/// Configure nb_utils settings that don't depend on theme.
/// Call this once during app initialization.
void configureNbUtilsDefaults() {
  // Password & validation
  passwordLengthGlobal = 6;

  // UI defaults
  defaultRadius = 12;
  defaultBlurRadius = 0;
  defaultSpreadRadius = 0;
  defaultAppButtonElevation = 0;

  // Animation
  pageRouteTransitionDurationGlobal = 400.milliseconds;

  // Toast defaults
  defaultToastGravityGlobal = ToastGravity.CENTER;
  defaultToastBorderRadiusGlobal = radius(30);
}
