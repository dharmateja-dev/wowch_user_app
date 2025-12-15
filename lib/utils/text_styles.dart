import 'package:flutter/material.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';

/// ══════════════════════════════════════════════════════════════════════════
/// TEXT STYLES - Context-aware versions that automatically use theme colors
/// ══════════════════════════════════════════════════════════════════════════
///
/// These functions mirror nb_utils text styles but use context.colorScheme
/// for automatic theme-aware colors.
///
/// Usage:
///   Text('Hello', style: context.boldTextStyle())
///   Text('Hello', style: context.primaryTextStyle(size: 16))
///   Text('Hello', style: context.secondaryTextStyle(color: Colors.red))

// ——— Global defaults (can be customized) ———
double textBoldSizeGlobal = 14;
double textPrimarySizeGlobal = 14;
double textSecondarySizeGlobal = 12;

FontWeight fontWeightBoldGlobal = FontWeight.bold;
FontWeight fontWeightPrimaryGlobal = FontWeight.normal;
FontWeight fontWeightSecondaryGlobal = FontWeight.normal;

String? fontFamilyBoldGlobal;
String? fontFamilyPrimaryGlobal;
String? fontFamilySecondaryGlobal;

extension TextStyleExtension on BuildContext {
  /// Returns a TextStyle with bold weight.
  /// Color defaults to `onSurface` (black in light, white in dark).
  TextStyle boldTextStyle({
    int? size,
    Color? color,
    FontWeight? weight,
    String? fontFamily,
    double? letterSpacing,
    FontStyle? fontStyle,
    double? wordSpacing,
    TextDecoration? decoration,
    TextDecorationStyle? textDecorationStyle,
    TextBaseline? textBaseline,
    Color? decorationColor,
    Color? backgroundColor,
    double? height,
  }) {
    return TextStyle(
      fontSize: size != null ? size.toDouble() : textBoldSizeGlobal,
      color: color ?? onSurface, // Theme-aware!
      fontWeight: weight ?? fontWeightBoldGlobal,
      fontFamily: fontFamily ?? fontFamilyBoldGlobal,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      decoration: decoration,
      decorationStyle: textDecorationStyle,
      decorationColor: decorationColor,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      backgroundColor: backgroundColor,
      height: height,
    );
  }

  /// Returns a TextStyle with primary text settings.
  /// Color defaults to `onSurface` (black in light, white in dark).
  TextStyle primaryTextStyle({
    int? size,
    Color? color,
    FontWeight? weight,
    String? fontFamily,
    double? letterSpacing,
    FontStyle? fontStyle,
    double? wordSpacing,
    TextDecoration? decoration,
    TextDecorationStyle? textDecorationStyle,
    TextBaseline? textBaseline,
    Color? decorationColor,
    Color? backgroundColor,
    double? height,
  }) {
    return TextStyle(
      fontSize: size != null ? size.toDouble() : textPrimarySizeGlobal,
      color: color ?? onSurface, // Theme-aware!
      fontWeight: weight ?? fontWeightPrimaryGlobal,
      fontFamily: fontFamily ?? fontFamilyPrimaryGlobal,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      decoration: decoration,
      decorationStyle: textDecorationStyle,
      decorationColor: decorationColor,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      backgroundColor: backgroundColor,
      height: height,
    );
  }

  /// Returns a TextStyle with secondary (muted) text settings.
  /// Color defaults to `onSurfaceVariant` (muted gray).
  TextStyle secondaryTextStyle({
    int? size,
    Color? color,
    FontWeight? weight,
    String? fontFamily,
    double? letterSpacing,
    FontStyle? fontStyle,
    double? wordSpacing,
    TextDecoration? decoration,
    TextDecorationStyle? textDecorationStyle,
    TextBaseline? textBaseline,
    Color? decorationColor,
    Color? backgroundColor,
    double? height,
  }) {
    return TextStyle(
      fontSize: size != null ? size.toDouble() : textSecondarySizeGlobal,
      color: color ?? onSurfaceVariant, // Theme-aware muted color!
      fontWeight: weight ?? fontWeightSecondaryGlobal,
      fontFamily: fontFamily ?? fontFamilySecondaryGlobal,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      decoration: decoration,
      decorationStyle: textDecorationStyle,
      decorationColor: decorationColor,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      backgroundColor: backgroundColor,
      height: height,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ADDITIONAL CONVENIENCE TEXT STYLES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Caption/small text style
  TextStyle captionTextStyle({
    int? size,
    Color? color,
    FontWeight? weight,
  }) {
    return TextStyle(
      fontSize: size?.toDouble() ?? 10,
      color: color ?? onSurfaceVariant,
      fontWeight: weight ?? FontWeight.normal,
    );
  }

  /// Title text style (larger, bold)
  TextStyle titleTextStyle({
    int? size,
    Color? color,
    FontWeight? weight,
  }) {
    return TextStyle(
      fontSize: size?.toDouble() ?? 20,
      color: color ?? onSurface,
      fontWeight: weight ?? FontWeight.bold,
    );
  }

  /// Heading text style (largest)
  TextStyle headingTextStyle({
    int? size,
    Color? color,
    FontWeight? weight,
  }) {
    return TextStyle(
      fontSize: size?.toDouble() ?? 24,
      color: color ?? onSurface,
      fontWeight: weight ?? FontWeight.bold,
    );
  }

  /// Label text style (for form labels, etc.)
  TextStyle labelTextStyle({
    int? size,
    Color? color,
    FontWeight? weight,
  }) {
    return TextStyle(
      fontSize: size?.toDouble() ?? 12,
      color: color ?? onSurfaceVariant,
      fontWeight: weight ?? FontWeight.w500,
    );
  }

  /// Button text style
  TextStyle buttonTextStyle({
    int? size,
    Color? color,
    FontWeight? weight,
  }) {
    return TextStyle(
      fontSize: size?.toDouble() ?? 14,
      color: color ?? onPrimary,
      fontWeight: weight ?? FontWeight.bold,
    );
  }
}
