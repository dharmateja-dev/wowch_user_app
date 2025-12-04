import 'package:flutter/material.dart';

/// ============================================
/// THEME COLORS STRUCTURE
/// ============================================
///
/// This file organizes theme colors into three classes:
/// 1. LightThemeColors - Colors for light theme mode
/// 2. DarkThemeColors - Colors for dark theme mode
/// 3. AppColors - Common colors used in both themes
///
/// TO ADD YOUR PREVIOUS THEME COLORS:
/// 1. Open your previous lightThemeColors file
/// 2. Copy color definitions and add them to LightThemeColors class
/// 3. Open your previous darkThemeColors file
/// 4. Copy color definitions and add them to DarkThemeColors class
/// 5. Open your previous appColors file
/// 6. Copy color definitions and add them to AppColors class
///
/// Example:
///   // In your previous file: static const Color primary = Color(0xFF123456);
///   // Add here: static const Color primary = Color(0xFF123456);
///
/// The existing colors.dart file will automatically use these new colors
/// for backward compatibility with existing code.
/// ============================================

/// Light Theme Colors
/// Add your previous lightThemeColors here
class LightThemeColors {
  // Primary Colors
  static const Color primary =
      Color(0xFF2E6B4F); // You can replace with your color
  static const Color primaryLight = Color(0xFFEFEFF8);
  static const Color secondaryPrimary = Color(0xfff3f4fa);
  static const Color lightPrimary = Color(0xffebebf7);

  // Background Colors
  static const Color scaffoldBackground = Colors.white;
  static const Color cardBackground = Color(0xFFF6F7F9);
  static const Color bottomNavBackground = Colors.white;
  static const Color bottomSheetBackground = Colors.white;
  static const Color dialogBackground = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xff1C1F34);
  static const Color textSecondary = Color(0xff6C757D);
  static const Color textBlack = Colors.black;

  // Border & Divider Colors
  static const Color border = Color(0xFFEBdBdB);
  static const Color divider = Color(0xFF6c757d);

  // Icon Colors
  static const Color icon = Color(0xff000000);
  static const Color iconSecondary = Color(0xff6C757D);

  // Other Colors
  static const Color unselectedWidget = Colors.black;
  static const Color shadow = Color(0x1F000000); // black12

  // Add more colors from your previous lightThemeColors here
  // Example:
  // static const Color accent = Color(0xFF...);
  // static const Color surface = Color(0xFF...);
}

/// Dark Theme Colors
/// Add your previous darkThemeColors here
class DarkThemeColors {
  // Primary Colors
  static const Color primary =
      Color(0xFF2E6B4F); // You can replace with your color
  static const Color primaryLight = Color(0xFF1C1F26);

  // Background Colors
  static const Color scaffoldBackground = Color(0xFF0E1116);
  static const Color scaffoldSecondary = Color(0xFF1C1F26);
  static const Color cardBackground = Color(0xFF1C1F26);
  static const Color bottomNavBackground = Color(0xFF1C1F26);
  static const Color bottomSheetBackground = Color(0xFF1C1F26);
  static const Color dialogBackground = Color(0xFF1C1F26);
  static const Color appButtonBackground = Color(0xFF282828);

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textWhite = Colors.white;

  // Border & Divider Colors
  static const Color border = Color(0xFF2C2C2C);
  static const Color divider = Color(0xFF2C2C2C);

  // Icon Colors
  static const Color icon = Colors.white;
  static const Color iconSecondary = Colors.white70;

  // Other Colors
  static const Color unselectedWidget = Colors.white60;
  static const Color shadow = Color(0x1FFFFFFF); // white12

  // Add more colors from your previous darkThemeColors here
  // Example:
  // static const Color accent = Color(0xFF...);
  // static const Color surface = Color(0xFF...);
}

/// App Colors (Common colors used in both themes)
/// Add your previous appColors here
class AppColors {
  // Status Colors
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

  // Activity Colors
  static const Color addBooking = Color(0xFFEA2F2F);
  static const Color assignedBooking = Color(0xFFFD6922);
  static const Color transferBooking = Color(0xFF00968A);
  static const Color updateBookingStatus = Color(0xFF3CAE5C);
  static const Color cancelBooking = Color(0xFFC41520);
  static const Color paymentMessageStatus = Color(0xFFFFBD49);
  static const Color defaultActivityStatus = Color(0xFF3CAE5C);

  // UI Colors
  static const Color ratingBar = Color(0xfff5c609);
  static const Color verifyAc = Colors.blue;
  static const Color favourite = Colors.red;
  static const Color unFavourite = Colors.grey;
  static const Color lineText = Color(0xFF6C757D);
  static const Color walletCard = Color(0xFF1C1E33);
  static const Color showRedForZeroRating = Color(0xFFFA6565);

  // Dashboard Colors
  static const Color jobRequestComponent = Color(0xFFE4BB97);
  static const Color dashboard3Card = Color(0xFFF6F7F9);
  static const Color cancellationsBg = Color(0xFFFFE5E5);
  static const Color shop = Color(0xFF1C1E33);

  // Common Colors
  static const Color grey = Colors.grey;
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color amber = Color(0xFFFFC107);

  // Add more common colors from your previous appColors here
  // Example:
  // static const Color error = Color(0xFF...);
  // static const Color success = Color(0xFF...);
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
