import 'package:booking_system_flutter/utils/theme_colors.dart';
import 'package:booking_system_flutter/utils/app_shadows.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

class AppTheme {
  //
  AppTheme._();

  // ——— Enhanced brand colors ———
  static const Color primaryColor =
      LightThemeColors.primaryGreenDark; // Using merged Green
  static const Color onPrimary = Color(0xffffffff);

  // ignore: deprecated_member_use
  static final Color primaryContainer = primaryColor.withOpacity(0.1);
  static const Color onPrimaryContianer = Color(0xFFDCDCDC);

  static const Color secondaryColor = LightThemeColors.secondaryGreen;
  static const Color accentColor = Color(0xFF66BB6A);

  // ——— Accents ———
  static const Color offerColor = Color(0xFFE53935);
  static const Color error = Color(0xffE53935);
  static const Color starColor = Color(0xFFFFB300);
  static const Color successColor = Color(0xFF43A047);
  static const Color warningColor = Color(0xFFFF9800);

  static ThemeData lightTheme({Color? color}) {
    // Legacy support: Allow overriding primary color
    final primary = color ?? primaryColor;

    return ThemeData(
      useMaterial3: true,
      primarySwatch: createMaterialColor(primary),
      primaryColor: primary,

      // Enhanced Scaffold (From New Theme)
      scaffoldBackgroundColor: LightThemeColors.pureWhite,

      fontFamily: GoogleFonts.inter()
          .fontFamily, // Keeping Inter as requested / default

      // Enhanced ColorScheme (From New Theme)
      colorScheme: ColorScheme.light(
        primary: primary, // Use dynamic if provided
        onPrimary: LightThemeColors.pureWhite,

        // ignore: deprecated_member_use
        secondary: LightThemeColors.secondaryGreen,
        onSecondary: LightThemeColors.deepBlack,

        // ignore: deprecated_member_use
        primaryContainer: primary,
        onPrimaryContainer: Color(0xFFDDDDDD),

        // ignore: deprecated_member_use
        secondaryContainer: Color(0xFFE9F2EF),
        onSecondaryContainer: LightThemeColors.mutedGray,

        surface: Color(0xFFF2F4F3),
        onSurface: LightThemeColors.deepBlack,

        inverseSurface: LightThemeColors.lightGray,
        onInverseSurface: LightThemeColors.deepBlack,

        surfaceContainerHighest: LightThemeColors.mediumGray,
        surfaceContainerHigh: LightThemeColors.lightGray,
        surfaceContainer: LightThemeColors.mediumGray,

        onSurfaceVariant: LightThemeColors.softGrey,
        tertiary: LightThemeColors.mediumGray,
        error: LightThemeColors.errorRed,
        onError: Colors.white,
        outline: LightThemeColors.primaryBorder,
        outlineVariant: LightThemeColors.dividerColor,
        shadow: LightThemeColors.shadowLight,
      ),

      // Enhanced AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: LightThemeColors.mediumGray,
        foregroundColor: LightThemeColors.deepBlack,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle:
            secondaryTextStyle(size: 22, color: LightThemeColors.deepBlack),
        iconTheme: IconThemeData(color: LightThemeColors.deepBlack, size: 24),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
      ),

      // Enhanced Card Theme
      cardTheme: CardThemeData(
        color: Color(0xFFF2F4F3),
        elevation: 1,
        // shadowColor: LightThemeColors.shadowLight, // Keeping commented as in original
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              8), // AppSizes.radiusLg -> 12 hardcoded or import
        ),
      ),

      // Note: TextTheme ignored as requested, relying on defaults + google fonts inter

      // Enhanced Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: LightThemeColors.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: boldTextStyle(color: LightThemeColors.pureWhite, size: 16),
        ),
      ),

      // Enhanced Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: boldTextStyle(color: primary, size: 16),
        ),
      ),

      // Enhanced Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LightThemeColors.pureWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: LightThemeColors.primaryBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: LightThemeColors.primaryBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: LightThemeColors.errorRed),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle:
            primaryTextStyle(color: LightThemeColors.mutedText, size: 14),
      ),

      // Enhanced ExpansionTile Theme
      expansionTileTheme: ExpansionTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide.none,
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide.none,
        ),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: primary,
        collapsedIconColor: primary,
        textColor: LightThemeColors.deepBlack,
        collapsedTextColor: LightThemeColors.deepBlack,
      ),

      dividerColor: LightThemeColors.dividerLightGrey,

      // Keeping original legacy theme bits just in case
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: LightThemeColors.bottomNavBackground,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: LightThemeColors.icon,
        titleTextStyle: boldTextStyle(color: LightThemeColors.deepBlack),
        subtitleTextStyle: secondaryTextStyle(),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius:
              radiusOnly(topLeft: defaultRadius, topRight: defaultRadius),
        ),
        backgroundColor: LightThemeColors.bottomSheetBackground,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: LightThemeColors.dialogBackground,
        surfaceTintColor: Colors.transparent,
        shape: dialogShape(),
      ),

      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.all(primaryTextStyle(size: 10)),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData darkTheme({Color? color}) {
    // Legacy support
    final primary =
        color ?? DarkThemeColors.primaryOrange; // Using merged Green

    return ThemeData(
      useMaterial3: true,
      primarySwatch: createMaterialColor(primary),
      primaryColor: primary,
      brightness: Brightness.dark,

      // Enhanced Scaffold
      scaffoldBackgroundColor: DarkThemeColors.richBlack,

      fontFamily: GoogleFonts.inter().fontFamily,

      // Enhanced ColorScheme
      colorScheme: ColorScheme.dark(
        primary: primary,
        onPrimary: DarkThemeColors.pureWhite,
        // ignore: deprecated_member_use
        primaryContainer: primary.withOpacity(0.1),
        onPrimaryContainer: DarkThemeColors.pureWhite,
        primaryFixed: DarkThemeColors.pureWhite,
        secondary: DarkThemeColors.secondaryOrange,
        // ignore: deprecated_member_use
        secondaryContainer: DarkThemeColors.secondaryOrange.withOpacity(0.1),

        surface: DarkThemeColors.mediumCharcoal,
        onSurface: DarkThemeColors.lightGray,

        inverseSurface: DarkThemeColors.mediumCharcoal,
        onInverseSurface: DarkThemeColors.lightGray,

        surfaceContainerHighest: DarkThemeColors.richBlack,
        surfaceContainerHigh: DarkThemeColors.softCharcoal,
        surfaceContainer: DarkThemeColors.lightCharcoal,

        onSurfaceVariant: DarkThemeColors.mutedGray,

        onSecondary: DarkThemeColors.pureWhite,
        tertiary: DarkThemeColors.softCharcoal,
        error: DarkThemeColors.errorRed,
        onError: DarkThemeColors.pureWhite,
        outline: DarkThemeColors.darkBorder,
        outlineVariant: DarkThemeColors.lightBorder,
        shadow: DarkThemeColors.shadowLight,
      ),

      // Enhanced AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: DarkThemeColors.richBlack,
        foregroundColor: DarkThemeColors.lightGray,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle:
            secondaryTextStyle(size: 22, color: DarkThemeColors.lightGray),
        iconTheme: IconThemeData(
          color: DarkThemeColors.lightGray,
          size: 24,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
        ),
      ),

      // Enhanced Card Theme
      cardTheme: CardThemeData(
        color: DarkThemeColors.mediumCharcoal,
        elevation: 1,
        // shadowColor: DarkThemeColors.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // TextTheme ignored as requested

      // Enhanced Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: DarkThemeColors.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: boldTextStyle(color: DarkThemeColors.pureWhite, size: 16),
        ),
      ),

      // Enhanced Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: boldTextStyle(size: 16),
        ),
      ),

      // Enhanced Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DarkThemeColors.softCharcoal,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DarkThemeColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DarkThemeColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DarkThemeColors.errorRed),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle:
            secondaryTextStyle(color: DarkThemeColors.mutedGray, size: 14),
      ),

      // Enhanced ExpansionTile Theme
      expansionTileTheme: ExpansionTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide.none,
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide.none,
        ),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: primary,
        collapsedIconColor: primary,
        textColor: DarkThemeColors.lightGray,
        collapsedTextColor: DarkThemeColors.lightGray,
      ),

      dividerColor: DarkThemeColors.mutedGray.withOpacity(0.5),

      // Legacy bits
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DarkThemeColors.bottomNavBackground,
      ),
      iconTheme: const IconThemeData(color: DarkThemeColors.icon),
      listTileTheme: ListTileThemeData(
        iconColor: DarkThemeColors.icon,
        titleTextStyle: boldTextStyle(color: DarkThemeColors.textWhite),
        subtitleTextStyle: secondaryTextStyle(),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius:
              radiusOnly(topLeft: defaultRadius, topRight: defaultRadius),
        ),
        backgroundColor: DarkThemeColors.bottomSheetBackground,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: DarkThemeColors.dialogBackground,
        surfaceTintColor: Colors.transparent,
        shape: dialogShape(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.all(
          primaryTextStyle(size: 10, color: Colors.white),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
