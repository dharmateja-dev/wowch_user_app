import 'package:flutter/material.dart';

class LightThemeColors {
  // ——— Clean White Shades (Perfect for Light Mode) ———
  static const Color pureWhite = Color(0xFFFFFFFF); // Pure white background
  static const Color softWhite = Color(0xFFDDDDDD); // Soft white surface
  static const Color lightGray =
      Color(0xFFF2F4F3); // Light gray background for card also
  static const Color mediumGray = Color(0xFFF1F0F0); // Medium gray surface
  static const Color warmGray = Color(0xFFEEEEEE); // Warm gray container
  static const Color subtleGray = Color(0xFFF2F4F3); // Subtle gray variant
  static const Color coolGray = Color(0xFFE0E0E0); // Cool gray border
  static const Color mutedGray = Color(0xFF9E9E9E); // Muted gray

  // ——— Text Colors with Enhanced Contrast ———
  static const Color deepBlack = Color(0xFF1E1E1E); // Primary text color
  static const Color darkGray = Color(0xFF4F4F4F); // Secondary text color
  static const Color softGrey = Color(0xFF6C7072); // Soft text
  static const Color mutedText = Color(0xFF9E9E9E); // Normal hint text color
  static const Color secondaryContainerHint =
      Color(0xFF4F4F4F); // Secondary container hint text

  // ——— Border and Divider Colors ———
  static const Color primaryBorder = Color(0xFFD6D6D6); // Input field border
  static const Color mainBorder = Color(0xFFD6D6D6); // Main border (not input)
  static const Color greenBorder = Color(0xFF2E6B4F); // Green border color
  static const Color dividerColor = Color(0xFFD6D6D6); // Dividers
  static const Color mainDivider = Color(0xFF1E1E1E); // Main divider in gray
  static const Color dividerOnSecondaryContainer =
      Color(0xFF1E1E1E); // Divider on secondary container

  // ——— Accent Colors for Light Theme ———
  static const Color primaryGreen =
      Color(0xFF2E6B4F); // MAIN BRAND COLOR (Green)
  static const Color primaryGreenLite = Color(0xFF65AE6A); // Primary color lite
  static const Color primaryGreenLight = Color(0xFF5EAF5E); // Light variant
  static const Color primaryGreenDark = Color(0xFF073807); // Dark variant

  static const Color secondaryGreen =
      Color(0xFF93C0AB); // Secondary brand (Light Greenish) / Primary container
  static const Color secondaryGreenLight =
      Color(0xFFE9F2EF); // Secondary container
  static const Color liteGreenContainerText =
      Color(0xFF9E9E9E); // Secondary text for lite green container

  static const Color accentBlue = Color(0xFF2196F3); // Info color
  static const Color accentPurple = Color(0xFF9C27B0); // Special accent
  static const Color accentTeal = Color(0xFF009688); // Alternative accent

  // ——— Status Colors ———
  static const Color successGreen = Color(0xFF43A047); // Success state
  static const Color warningOrange = Color(0xFFFF9800); // Warning state
  static const Color errorRed = Color(0xFFE53935); // Error state
  static const Color infoBlue = Color(0xFF2196F3); // Info state
  static const Color starColor = Color(0xFFFFC107); // Star color

  // ——— Container Colors ———
  static const Color serviceComponentColor =
      Color(0xFFF2F4F3); // Service/provider component color
  static const Color providerInfoDetailsContainer =
      Color(0xFFF2F4F3); // Provider info details container
  static const Color iconBackgroundColor =
      Color(0xFFFFFFFF); // Icon background color

  // ——— Icon Colors ———
  static const Color iconPrimaryGreen =
      Color(0xFF2E6B4F); // Icon primary green color
  static const Color iconOnPrimaryContainer =
      Color(0xFFFFFFFF); // Icon on primary container
  static const Color iconOnSecondaryContainer =
      Color(0xFF1E1E1E); // Icon on secondary container
  static const Color taxIconColor = Color(0xFF9E9E9E); // Tax icon color

  // ——— Bottom Navigation Colors ———
  static const Color bottomNavTextInactive =
      Color(0xFF999999); // Bottom nav text (inactive)
  static const Color bottomNavIconInactive =
      Color(0xFF999999); // Bottom nav icon (inactive)
  static const Color bottomNavTextActive =
      Color(0xFF2E6B4F); // Bottom nav text (active)
  static const Color bottomNavIconActive =
      Color(0xFF2E6B4F); // Bottom nav icon (active)

  // ——— Shadow Colors ———
  static Color shadowLight = Colors.grey.withValues(alpha: 0.05);
  static Color shadowMedium = Colors.grey.withValues(alpha: 0.08);
  static Color shadowHeavy = Colors.grey.withValues(alpha: 0.12);
  static Color shadowIntense = Colors.grey.withValues(alpha: 0.1);

  // ——— Overlay Colors ———
  static Color overlayLight = Colors.black.withValues(alpha: 0.05);
  static Color overlayMedium = Colors.black.withValues(alpha: 0.1);
  static Color overlayHeavy = Colors.black.withValues(alpha: 0.2);
  static Color overlayIntense = Colors.black.withValues(alpha: 0.4);

  // ——— LEGACY COMPATIBILITY ALIASES ———
  static const Color primary = primaryGreen;
  static const Color primaryLight = pureWhite;
  static const Color secondaryPrimary = secondaryGreen;
  static const Color lightPrimary = Color(0xffebebf7);
  static const Color scaffoldBackground = pureWhite;
  static const Color cardBackground = softWhite;
  static const Color bottomNavBackground = pureWhite;
  static const Color bottomSheetBackground = subtleGray;
  static const Color dialogBackground = pureWhite;
  static const Color textPrimary = deepBlack;
  static const Color textSecondary = darkGray;
  static const Color textBlack = deepBlack;
  static const Color border = primaryBorder;
  static const Color divider = mainDivider;
  static const Color icon = deepBlack;
  static const Color iconSecondary = mutedGray;
  static const Color unselectedWidget = deepBlack;
  static const Color shadow = Color(0x1F000000);

  /// Get a color with opacity for light theme
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}

class DarkThemeColors {
  // ——— Rich Black Shades (Perfect for OLED screens) ———
  static const Color richBlack = Color(0xFF121212); // Deepest black
  static const Color charcoal = Color(0xFF121212); // Material Design dark
  static const Color darkCharcoal = Color(0xFF1A1A1A); // Card background
  static const Color mediumCharcoal = Color(0xFF1E1E1E); // Surface background
  static const Color lightCharcoal = Color(0xFF242424); // Elevated surface
  static const Color softCharcoal = Color(0xFF2A2A2A); // Surface variant
  static const Color warmCharcoal = Color(0xFF2E2E2E); // Container background

  // ——— Text Colors with Better Contrast ———
  static const Color pureWhite = Color(0xFFE8F5F0); // Primary text color
  static const Color softWhite = Color(0xFF4F4F4F); // Secondary text color
  static const Color lightGray = Color(0xFFE8E8E8); // Surface text
  static const Color softGray = Color(0xFFD0D0D0); // Container text
  static const Color mutedGray = Color(0xFFB8B8B8); // Variant text
  static const Color subtleGray = Color(0xFF9E9E9E); // Disabled text
  static const Color hintText = Color(0xFF6E7D78); // Normal hint text color
  static const Color secondaryContainerHint =
      Color(0xFFB2C78F); // Secondary container hint text

  // ——— Border and Divider Colors ———
  static const Color primaryBorder =
      Color(0xFFB2C7BF); // Input field border color
  static const Color mainBorder = Color(0xFFE0E0E0); // Main border (not input)
  static const Color greenBorder = Color(0xFF93C0AB); // Green border color
  static const Color darkBorder = Color(0xFF4A4A4A); // Dark borders
  static const Color mediumBorder = Color(0xFF3A3A3A); // Secondary borders
  static const Color lightBorder = Color(0xFF2A2A2A); // Subtle borders
  static const Color dividerColor = Color(0xFF2E2E2E); // Dividers
  static const Color mainDivider = Color(0xFFE8F5F0); // Main divider in gray
  static const Color dividerOnSecondaryContainer =
      Color(0xFF6E7D73); // Divider on secondary container

  // ——— Accent Colors for Dark Theme ———
  static const Color primaryOrange = Color(0xFF2E6B4F); // Main brand color
  static const Color primaryGreenLite = Color(0xFF65AE6A); // Primary color lite
  static const Color primaryGreenLight = Color(0xFF66BB6A); // Light variant
  static const Color primaryGreenDark = Color(0xFF2E7D32); // Dark variant

  static const Color secondaryOrange =
      Color(0xFF3A3A3A); // Secondary brand (Dark)
  static const Color secondaryOrangeLight = Color(0xFF4A4A4A); // Light variant
  static const Color secondaryContainer =
      Color(0xFF101D1C); // Secondary container
  static const Color liteGreenContainerText =
      Color(0xFFB2C7BF); // Secondary text for lite green container

  static const Color accentBlue = Color(0xFF2196F3); // Info color
  static const Color accentPurple = Color(0xFF9C27B0); // Special accent
  static const Color accentTeal = Color(0xFF009688); // Alternative accent

  // ——— Status Colors ———
  static const Color successGreen = Color(0xFF43A047); // Success state
  static const Color warningOrange = Color(0xFFFF9800); // Warning state
  static const Color errorRed = Color(0xFFE53935); // Error state
  static const Color infoBlue = Color(0xFF2196F3); // Info state
  static const Color starColor = Color(0xFFFFC107); // Star color

  // ——— Container Colors ———
  static const Color serviceComponentColor =
      Color(0xFF2A2A2A); // Service/provider component color
  static const Color providerInfoDetailsContainer =
      Color(0xFF2A2A2A); // Provider info details container
  static const Color iconBackgroundColor =
      Color(0xFFF2F4F3); // Icon background color
  static const Color primaryContainer =
      Color(0xFF93C0AB); // Primary container (shaded green)
  static const Color onPrimaryContainer =
      Color(0xFF121212); // On primary container

  // ——— Icon Colors ———
  static const Color iconPrimaryGreen =
      Color(0xFF2E6B4F); // Icon primary green color
  static const Color iconOnPrimaryContainer =
      Color(0xFFFFFFFF); // Icon on primary container
  static const Color iconOnSecondaryContainer =
      Color(0xFFE8F5F0); // Icon on secondary container
  static const Color taxIconColor = Color(0xFF6E7D78); // Tax icon color

  // ——— Bottom Navigation Colors ———
  static const Color bottomNavTextInactive =
      Color(0xFF999999); // Bottom nav text (inactive)
  static const Color bottomNavIconInactive =
      Color(0xFF999999); // Bottom nav icon (inactive)
  static const Color bottomNavTextActive =
      Color(0xFF2E6B4F); // Bottom nav text (active)
  static const Color bottomNavIconActive =
      Color(0xFF2E6B4F); // Bottom nav icon (active)

  // ——— Rating and Special Colors ———
  static const Color starGold = Color(0xFFFFB300); // Star ratings
  static const Color starGoldLight = Color(0xFFFFC107); // Light star
  static const Color offerRed = Color(0xFFE53935); // Offer/discount
  static const Color priceGreen = Color(0xFF2E7D32); // Price color

  // ——— Shadow Colors ———
  static Color shadowLight = Colors.black.withValues(alpha: 0.7);
  static Color shadowMedium = Colors.black.withValues(alpha: 0.2);
  static Color shadowHeavy = Colors.black.withValues(alpha: 0.4);
  static Color shadowIntense = Colors.black.withValues(alpha: 0.1);

  // ——— Overlay Colors ———
  static Color overlayLight = Colors.black.withValues(alpha: 0.07);
  static Color overlayMedium = Colors.black.withValues(alpha: 0.3);
  static Color overlayHeavy = Colors.black.withValues(alpha: 0.5);
  static Color overlayIntense = Colors.black.withValues(alpha: 0.8);

  // ——— LEGACY COMPATIBILITY ALIASES ———
  static const Color primary = primaryOrange;
  static const Color primaryLight = Color(0xFF1C1F26);
  static const Color scaffoldBackground = richBlack;
  static const Color scaffoldSecondary = charcoal;
  static const Color cardBackground = darkCharcoal;
  static const Color bottomNavBackground = darkCharcoal;
  static const Color bottomSheetBackground = softCharcoal; // #2A2A2A
  static const Color dialogBackground =
      Color(0xFF202325); // Dialog box background
  static const Color appButtonBackground = Color(0xFF282828);
  static const Color textPrimary = pureWhite;
  static const Color textSecondary = softWhite;
  static const Color textWhite = pureWhite;
  static const Color border = darkBorder;
  static const Color divider = mainDivider;
  static const Color icon = pureWhite;
  static const Color iconSecondary = hintText;
  static const Color unselectedWidget = Colors.white60;
  static const Color shadow = Color(0x1FFFFFFF);
  static const Color inputFillColor =
      Color(0xFF101D1C); // Input field fill color
}

class AppColors {
  // Primary Colors (New)
  static Color primaryGreen = Color(0xFF2E6B4F);
  static Color secondaryGreen = Color(0xFF93C0AB);

  // Text Colors
  static const Color mutedText = Color(0xFF9E9E9E);

  // Accent Colors
  static const Color accent = Color(0xFF66BB6A);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Status/Rating Colors
  static const Color starFilled = Color(0xFFFFB300);

  // Background Colors (used as iconColor)
  static const Color background = Color(0xFFFAFAFA);

  // ——— LEGACY COMPATIBILITY ———
  static const Color pending = Color(0xFFEA2F2F);
  static const Color accept = Color(0xFF00968A);
  static const Color onGoing = Color(0xFFFD6922);
  static const Color inProgress = Color(0xFFB953C0);
  static const Color hold = Color(0xFFFFBD49);
  static const Color cancelled = Color(0xffFF0303);
  static const Color rejected = Color(0xFF8D0E06);
  static const Color failed = Color(0xFFC41520);
  static const Color completed = Color(0xFF3CAE5C);
  static const Color defaultStatus = Color(0xFF3CAE5C);
  static const Color pendingApproval = Color(0xFF690AD3);
  static const Color waiting = Color(0xFF2CAFAF);

  static const Color addBooking = Color(0xFFEA2F2F);
  static const Color assignedBooking = Color(0xFFFD6922);
  static const Color transferBooking = Color(0xFF00968A);
  static const Color updateBookingStatus = Color(0xFF3CAE5C);
  static const Color cancelBooking = Color(0xFFC41520);
  static const Color paymentMessageStatus = Color(0xFFFFBD49);
  static const Color defaultActivityStatus = Color(0xFF3CAE5C);

  static const Color walletCard = Color(0xFF1C1E33);
  static const Color showRedForZeroRating = Color(0xFFFA6565);
  static const Color ratingBar = Color(0xfff5c609);
  static const Color verifyAc = Colors.blue;
  static const Color favourite = Colors.red;
  static const Color unFavourite = Colors.grey;
  static const Color lineText = Color(0xFF6C757D);
  static const Color jobRequestComponent = Color(0xFFE4BB97);
  static const Color dashboard3Card = Color(0xFFF6F7F9);
  static const Color cancellationsBg = Color(0xFFEBA5A5);
  static const Color shop = Color(0xFF1C1E33);
  static const Color grey = Color(0xFFBDBDBD);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color amber = Color(0xFFFFC107);
}

/// Helper class to get theme colors based on current theme mode
class ThemeColors {
  static Color getPrimaryColor(bool isDarkMode) {
    return isDarkMode ? DarkThemeColors.primary : LightThemeColors.primary;
  }

  static Color getScaffoldBackground(bool isDarkMode) {
    return isDarkMode
        ? DarkThemeColors.scaffoldBackground
        : LightThemeColors.scaffoldBackground;
  }

  static Color getCardBackground(bool isDarkMode) {
    return isDarkMode
        ? DarkThemeColors.cardBackground
        : LightThemeColors.cardBackground;
  }

  static Color getTextPrimary(bool isDarkMode) {
    return isDarkMode
        ? DarkThemeColors.textPrimary
        : LightThemeColors.textPrimary;
  }

  static Color getTextSecondary(bool isDarkMode) {
    return isDarkMode
        ? DarkThemeColors.textSecondary
        : LightThemeColors.textSecondary;
  }

  static Color getBorderColor(bool isDarkMode) {
    return isDarkMode ? DarkThemeColors.border : LightThemeColors.border;
  }

  static Color getDividerColor(bool isDarkMode) {
    return isDarkMode ? DarkThemeColors.divider : LightThemeColors.divider;
  }

  static Color getIconColor(bool isDarkMode) {
    return isDarkMode ? DarkThemeColors.icon : LightThemeColors.icon;
  }
}
