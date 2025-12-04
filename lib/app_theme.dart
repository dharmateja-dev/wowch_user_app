import 'package:booking_system_flutter/utils/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

class AppTheme {
  //
  AppTheme._();

  static ThemeData lightTheme({Color? color}) {
    final primary = color ?? LightThemeColors.primary;
    return ThemeData(
      useMaterial3: true,
      primarySwatch: createMaterialColor(primary),
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        outlineVariant: LightThemeColors.border,
      ),
      scaffoldBackgroundColor: LightThemeColors.scaffoldBackground,
      fontFamily: GoogleFonts.inter().fontFamily,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: LightThemeColors.bottomNavBackground,
      ),
      iconTheme: const IconThemeData(color: LightThemeColors.icon),
      listTileTheme: ListTileThemeData(
        iconColor: LightThemeColors.icon,
        titleTextStyle: boldTextStyle(color: LightThemeColors.textBlack),
        subtitleTextStyle: secondaryTextStyle(),
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          headlineSmall: TextStyle(color: LightThemeColors.textBlack),
          headlineMedium: TextStyle(color: LightThemeColors.textBlack),
          bodyMedium: TextStyle(color: LightThemeColors.textBlack),
          bodySmall: TextStyle(color: LightThemeColors.textBlack),
        ),
      ),
      unselectedWidgetColor: LightThemeColors.unselectedWidget,
      dividerColor: LightThemeColors.divider,
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius:
              radiusOnly(topLeft: defaultRadius, topRight: defaultRadius),
        ),
        backgroundColor: LightThemeColors.bottomSheetBackground,
      ),
      cardColor: LightThemeColors.cardBackground,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: secondaryTextStyle(size: 22, color: white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
        ),
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
    final primary = color ?? DarkThemeColors.primary;
    return ThemeData(
      useMaterial3: true,
      primarySwatch: createMaterialColor(primary),
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        outlineVariant: DarkThemeColors.border,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: secondaryTextStyle(size: 22, color: white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      scaffoldBackgroundColor: DarkThemeColors.scaffoldBackground,
      fontFamily: GoogleFonts.inter().fontFamily,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DarkThemeColors.bottomNavBackground,
      ),
      iconTheme: const IconThemeData(color: DarkThemeColors.icon),
      listTileTheme: ListTileThemeData(
        iconColor: DarkThemeColors.icon,
        titleTextStyle: boldTextStyle(color: DarkThemeColors.textWhite),
        subtitleTextStyle: secondaryTextStyle(),
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          headlineSmall: TextStyle(color: DarkThemeColors.textWhite),
          headlineMedium: TextStyle(color: DarkThemeColors.textWhite),
          bodyMedium: TextStyle(color: DarkThemeColors.textWhite),
          bodySmall: TextStyle(color: DarkThemeColors.textWhite),
          bodyLarge: TextStyle(color: DarkThemeColors.textWhite),
          headlineLarge: TextStyle(color: DarkThemeColors.textWhite),
        ),
      ),
      unselectedWidgetColor: DarkThemeColors.unselectedWidget,
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius:
              radiusOnly(topLeft: defaultRadius, topRight: defaultRadius),
        ),
        backgroundColor: DarkThemeColors.bottomSheetBackground,
      ),
      dividerColor: DarkThemeColors.divider,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
      ),
      cardColor: DarkThemeColors.cardBackground,
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
