# 🎨 Flutter Dynamic Theme System Implementation Guide

A complete guide to implementing a dynamic theme system in Flutter with support for **Light**, **Dark**, and **System** (auto-follows device) theme modes.

---

## 📋 Table of Contents

1. [Features](#features)
2. [Prerequisites](#prerequisites)
3. [Project Structure](#project-structure)
4. [Step-by-Step Implementation](#step-by-step-implementation)
5. [Usage Examples](#usage-examples)
6. [API Reference](#api-reference)
7. [Troubleshooting](#troubleshooting)

---

## ✨ Features

- ✅ Three theme modes: Light, Dark, System (auto-detect)
- ✅ Persists user preference across app restarts
- ✅ Real-time system theme detection (when System mode is selected)
- ✅ Reactive UI updates using MobX
- ✅ Clean context extensions for theme-aware color access
- ✅ System UI overlay styling (status bar, navigation bar)
- ✅ Material 3 support

---

## 📦 Prerequisites

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  mobx: ^2.3.0+1
  flutter_mobx: ^2.2.0+1
  
  # Utilities (for SharedPreferences, extensions)
  nb_utils: ^6.1.5
  
  # Fonts (optional but recommended)
  google_fonts: ^6.1.0

dev_dependencies:
  # MobX code generator
  build_runner: ^2.4.8
  mobx_codegen: ^2.6.0+1
```

Run:
```bash
flutter pub get
```

---

## 📁 Project Structure

Create the following files in your project:

```
lib/
├── main.dart                          # App entry point
├── app_theme.dart                     # Theme definitions
├── store/
│   ├── app_store.dart                 # MobX store
│   └── app_store.g.dart               # Generated file
├── utils/
│   ├── constant.dart                  # Theme mode constants
│   ├── theme_colors.dart              # Color definitions
│   └── context_extensions.dart        # Theme color extensions
└── components/
    └── theme_selection_dialog.dart    # Theme picker UI
```

---

## 🔧 Step-by-Step Implementation

### Step 1: Create Constants (`lib/utils/constant.dart`)

```dart
// Theme Mode Constants
const THEME_MODE_LIGHT = 0;
const THEME_MODE_DARK = 1;
const THEME_MODE_SYSTEM = 2;

// SharedPreferences Key
const THEME_MODE_INDEX = 'THEME_MODE_INDEX';
```

---

### Step 2: Define Theme Colors (`lib/utils/theme_colors.dart`)

```dart
import 'package:flutter/material.dart';

class LightThemeColors {
  // ——— Background Colors ———
  static const Color scaffold = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF2F4F3);
  static const Color card = Color(0xFFF2F4F3);
  
  // ——— Primary Colors ———
  static const Color primary = Color(0xFF2E6B4F);  // Your brand color
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF93C0AB);
  static const Color onPrimaryContainer = Color(0xFF1E1E1E);
  
  // ——— Secondary Colors ———
  static const Color secondary = Color(0xFF93C0AB);
  static const Color secondaryContainer = Color(0xFFE9F2EF);
  static const Color onSecondaryContainer = Color(0xFF4F4F4F);
  
  // ——— Text Colors ———
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF4F4F4F);
  static const Color textHint = Color(0xFF9E9E9E);
  
  // ——— Border Colors ———
  static const Color border = Color(0xFFD6D6D6);
  static const Color divider = Color(0xFFD6D6D6);
  
  // ——— Status Colors ———
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFF9800);
  
  // ——— Icon Colors ———
  static const Color icon = Color(0xFF1E1E1E);
  
  // ——— Component Colors ———
  static const Color dialogBackground = Color(0xFFFFFFFF);
  static const Color bottomSheet = Color(0xFFF2F4F3);
  static const Color bottomNav = Color(0xFFFFFFFF);
}

class DarkThemeColors {
  // ——— Background Colors ———
  static const Color scaffold = Color(0xFF121212);
  static const Color surface = Color(0xFF2A2A2A);
  static const Color card = Color(0xFF1E1E1E);
  
  // ——— Primary Colors ———
  static const Color primary = Color(0xFF2E6B4F);  // Same brand color
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF93C0AB);
  static const Color onPrimaryContainer = Color(0xFF121212);
  
  // ——— Secondary Colors ———
  static const Color secondary = Color(0xFF3A3A3A);
  static const Color secondaryContainer = Color(0xFF101D1C);
  static const Color onSecondaryContainer = Color(0xFFB2C7BF);
  
  // ——— Text Colors ———
  static const Color textPrimary = Color(0xFFE8F5F0);
  static const Color textSecondary = Color(0xFFB2C7BF);
  static const Color textHint = Color(0xFF6E7D78);
  
  // ——— Border Colors ———
  static const Color border = Color(0xFF4A4A4A);
  static const Color divider = Color(0xFF2E2E2E);
  
  // ——— Status Colors ———
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFF9800);
  
  // ——— Icon Colors ———
  static const Color icon = Color(0xFFE8F5F0);
  
  // ——— Component Colors ———
  static const Color dialogBackground = Color(0xFF202325);
  static const Color bottomSheet = Color(0xFF2A2A2A);
  static const Color bottomNav = Color(0xFF1E1E1E);
}
```

---

### Step 3: Create Theme Definitions (`lib/app_theme.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/theme_colors.dart';

class AppTheme {
  AppTheme._();

  // ══════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ══════════════════════════════════════════════════════════════
  static ThemeData lightTheme({Color? primaryColor}) {
    final primary = primaryColor ?? LightThemeColors.primary;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: LightThemeColors.scaffold,
      fontFamily: GoogleFonts.inter().fontFamily,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: LightThemeColors.onPrimary,
        primaryContainer: LightThemeColors.primaryContainer,
        onPrimaryContainer: LightThemeColors.onPrimaryContainer,
        secondary: LightThemeColors.secondary,
        secondaryContainer: LightThemeColors.secondaryContainer,
        onSecondaryContainer: LightThemeColors.onSecondaryContainer,
        surface: LightThemeColors.surface,
        onSurface: LightThemeColors.textPrimary,
        onSurfaceVariant: LightThemeColors.textHint,
        error: LightThemeColors.error,
        outline: LightThemeColors.border,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: LightThemeColors.scaffold,
        foregroundColor: LightThemeColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: LightThemeColors.icon),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: LightThemeColors.card,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: LightThemeColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LightThemeColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LightThemeColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: LightThemeColors.dialogBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: LightThemeColors.bottomSheet,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Divider
      dividerColor: LightThemeColors.divider,
    );
  }

  // ══════════════════════════════════════════════════════════════
  // DARK THEME
  // ══════════════════════════════════════════════════════════════
  static ThemeData darkTheme({Color? primaryColor}) {
    final primary = primaryColor ?? DarkThemeColors.primary;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: DarkThemeColors.scaffold,
      fontFamily: GoogleFonts.inter().fontFamily,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: primary,
        onPrimary: DarkThemeColors.onPrimary,
        primaryContainer: DarkThemeColors.primaryContainer,
        onPrimaryContainer: DarkThemeColors.onPrimaryContainer,
        secondary: DarkThemeColors.secondary,
        secondaryContainer: DarkThemeColors.secondaryContainer,
        onSecondaryContainer: DarkThemeColors.onSecondaryContainer,
        surface: DarkThemeColors.surface,
        onSurface: DarkThemeColors.textPrimary,
        onSurfaceVariant: DarkThemeColors.textHint,
        error: DarkThemeColors.error,
        outline: DarkThemeColors.border,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: DarkThemeColors.scaffold,
        foregroundColor: DarkThemeColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: DarkThemeColors.icon),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: DarkThemeColors.card,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: DarkThemeColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DarkThemeColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DarkThemeColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DarkThemeColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: DarkThemeColors.dialogBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: DarkThemeColors.bottomSheet,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Divider
      dividerColor: DarkThemeColors.divider,
    );
  }
}
```

---

### Step 4: Create MobX Store (`lib/store/app_store.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import '../utils/constant.dart';
import '../utils/theme_colors.dart';

part 'app_store.g.dart';

class AppStore = _AppStore with _$AppStore;

abstract class _AppStore with Store {
  
  @observable
  bool isDarkMode = false;

  @observable
  bool isLoading = false;

  @action
  Future<void> setDarkMode(bool val) async {
    isDarkMode = val;

    // Update system UI overlay (status bar, navigation bar)
    if (isDarkMode) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: DarkThemeColors.scaffold,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ));
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: LightThemeColors.scaffold,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ));
    }
  }

  @action
  void setLoading(bool val) {
    isLoading = val;
  }
}

// Global instance
AppStore appStore = AppStore();
```

**Generate the `.g.dart` file:**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### Step 5: Create Context Extensions (`lib/utils/context_extensions.dart`)

```dart
import 'package:flutter/material.dart';
import 'theme_colors.dart';

/// Theme-aware color access via BuildContext
extension ThemeExtensions on BuildContext {
  
  // ══════════════════════════════════════════════════════════════
  // CORE THEME ACCESS
  // ══════════════════════════════════════════════════════════════
  
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // ══════════════════════════════════════════════════════════════
  // COLOR SCHEME ACCESSORS (Auto theme-aware!)
  // ══════════════════════════════════════════════════════════════

  // ——— Primary Colors ———
  Color get primary => colorScheme.primary;
  Color get onPrimary => colorScheme.onPrimary;
  Color get primaryContainer => colorScheme.primaryContainer;
  Color get onPrimaryContainer => colorScheme.onPrimaryContainer;

  // ——— Secondary Colors ———
  Color get secondary => colorScheme.secondary;
  Color get secondaryContainer => colorScheme.secondaryContainer;
  Color get onSecondaryContainer => colorScheme.onSecondaryContainer;

  // ——— Surface Colors ———
  Color get surface => colorScheme.surface;
  Color get onSurface => colorScheme.onSurface;
  Color get onSurfaceVariant => colorScheme.onSurfaceVariant;

  // ——— Error Colors ———
  Color get error => colorScheme.error;

  // ——— Border Colors ———
  Color get outline => colorScheme.outline;

  // ══════════════════════════════════════════════════════════════
  // SEMANTIC ALIASES
  // ══════════════════════════════════════════════════════════════

  /// Primary text color
  Color get textPrimary => onSurface;

  /// Secondary/muted text color
  Color get textSecondary => onSurfaceVariant;

  /// Hint text color
  Color get hintColor => onSurfaceVariant;

  /// Main icon color
  Color get iconColor => onSurface;

  /// Scaffold background
  Color get scaffoldBackground => theme.scaffoldBackgroundColor;

  /// Card background
  Color get cardColor => theme.cardTheme.color ?? surface;

  /// Divider color
  Color get dividerColor => theme.dividerColor;

  // ══════════════════════════════════════════════════════════════
  // CUSTOM COLORS (Need manual dark/light handling)
  // ══════════════════════════════════════════════════════════════

  /// Dialog background
  Color get dialogBackground => isDarkMode
      ? DarkThemeColors.dialogBackground
      : LightThemeColors.dialogBackground;

  /// Bottom sheet background
  Color get bottomSheetBackground => isDarkMode
      ? DarkThemeColors.bottomSheet
      : LightThemeColors.bottomSheet;

  /// Success color
  Color get success => isDarkMode
      ? DarkThemeColors.success
      : LightThemeColors.success;

  /// Warning color
  Color get warning => isDarkMode
      ? DarkThemeColors.warning
      : LightThemeColors.warning;
}
```

---

### Step 6: Create Theme Selection Dialog (`lib/components/theme_selection_dialog.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../store/app_store.dart';
import '../utils/constant.dart';
import '../utils/context_extensions.dart';

class ThemeSelectionDialog extends StatefulWidget {
  @override
  _ThemeSelectionDialogState createState() => _ThemeSelectionDialogState();
}

class _ThemeSelectionDialogState extends State<ThemeSelectionDialog> {
  final List<String> themeModes = ['Light', 'Dark', 'System Default'];
  int currentIndex = THEME_MODE_SYSTEM;

  @override
  void initState() {
    super.initState();
    currentIndex = getIntAsync(THEME_MODE_INDEX, defaultValue: THEME_MODE_SYSTEM);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.dialogBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Choose Theme',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: context.iconColor),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Theme Options
          ...List.generate(themeModes.length, (index) {
            final isSelected = currentIndex == index;
            return InkWell(
              onTap: () => _selectTheme(index),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    // Radio indicator
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? context.primary
                              : context.outline,
                          width: isSelected ? 2 : 1.5,
                        ),
                        color: isSelected ? context.primary : Colors.transparent,
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: context.onPrimary,
                                ),
                              ),
                            )
                          : null,
                    ),
                    SizedBox(width: 12),
                    // Label
                    Text(
                      themeModes[index],
                      style: TextStyle(
                        fontSize: 16,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _selectTheme(int index) async {
    currentIndex = index;

    // Apply theme
    if (index == THEME_MODE_SYSTEM) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      appStore.setDarkMode(brightness == Brightness.dark);
    } else if (index == THEME_MODE_LIGHT) {
      appStore.setDarkMode(false);
    } else if (index == THEME_MODE_DARK) {
      appStore.setDarkMode(true);
    }

    // Persist preference
    await setValue(THEME_MODE_INDEX, index);
    
    setState(() {});
    Navigator.pop(context);
  }
}

// Helper function to show the dialog
void showThemeSelectionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: ThemeSelectionDialog(),
    ),
  );
}
```

---

### Step 7: Setup Main App (`lib/main.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import 'app_theme.dart';
import 'store/app_store.dart';
import 'utils/constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  await initialize();

  // Initialize theme based on saved preference
  int themeModeIndex = getIntAsync(THEME_MODE_INDEX, defaultValue: THEME_MODE_SYSTEM);
  
  if (themeModeIndex == THEME_MODE_LIGHT) {
    appStore.setDarkMode(false);
  } else if (themeModeIndex == THEME_MODE_DARK) {
    appStore.setDarkMode(true);
  } else {
    // THEME_MODE_SYSTEM: Detect from platform
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    appStore.setDarkMode(brightness == Brightness.dark);
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    // Subscribe to system brightness changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Unsubscribe
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called when system dark mode changes
  @override
  void didChangePlatformBrightness() {
    int themeModeIndex = getIntAsync(THEME_MODE_INDEX, defaultValue: THEME_MODE_SYSTEM);
    
    // Only react if user has selected "System" mode
    if (themeModeIndex == THEME_MODE_SYSTEM) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      appStore.setDarkMode(brightness == Brightness.dark);
    }
  }

  /// Get ThemeMode based on appStore.isDarkMode
  ThemeMode _getThemeMode() {
    return appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MaterialApp(
        title: 'My App',
        debugShowCheckedModeBanner: false,
        
        // Theme setup
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: _getThemeMode(),
        
        home: HomeScreen(),
      ),
    );
  }
}

// Example Home Screen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Theme Demo'),
        actions: [
          IconButton(
            icon: Icon(Icons.palette),
            onPressed: () => showThemeSelectionDialog(context),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Hello, World!',
          style: TextStyle(color: context.textPrimary),
        ),
      ),
    );
  }
}
```

---

## 📖 Usage Examples

### Access Theme Colors Anywhere

```dart
// In any widget with BuildContext:

// Primary brand color
Color primary = context.primary;

// Text colors
Color mainText = context.textPrimary;
Color mutedText = context.textSecondary;

// Background colors
Color background = context.scaffoldBackground;
Color cardBg = context.cardColor;

// Check current theme
bool isDark = context.isDarkMode;

// Error/Success colors
Color errorColor = context.error;
Color successColor = context.success;
```

### Toggle Theme Programmatically

```dart
// Set to dark mode
appStore.setDarkMode(true);

// Set to light mode
appStore.setDarkMode(false);

// Follow system (detect current)
final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
appStore.setDarkMode(brightness == Brightness.dark);
await setValue(THEME_MODE_INDEX, THEME_MODE_SYSTEM);
```

### Show Theme Picker

```dart
// Import the dialog
import 'components/theme_selection_dialog.dart';

// Show it
showThemeSelectionDialog(context);
```

---

## 📚 API Reference

### AppStore (MobX)

| Property/Method | Type | Description |
|-----------------|------|-------------|
| `isDarkMode` | `bool` | Current theme state (observable) |
| `setDarkMode(bool)` | `Future<void>` | Set theme and update system UI |

### Context Extensions

| Extension | Returns | Description |
|-----------|---------|-------------|
| `context.isDarkMode` | `bool` | Is current theme dark? |
| `context.primary` | `Color` | Primary brand color |
| `context.onPrimary` | `Color` | Color on primary |
| `context.surface` | `Color` | Surface/card color |
| `context.onSurface` | `Color` | Text on surface |
| `context.textPrimary` | `Color` | Main text color |
| `context.textSecondary` | `Color` | Muted text color |
| `context.iconColor` | `Color` | Icon color |
| `context.error` | `Color` | Error color |
| `context.outline` | `Color` | Border color |

### Theme Mode Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `THEME_MODE_LIGHT` | `0` | Force light mode |
| `THEME_MODE_DARK` | `1` | Force dark mode |
| `THEME_MODE_SYSTEM` | `2` | Follow system setting |

---

## 🐛 Troubleshooting

### Issue: Theme doesn't update immediately

**Solution:** Make sure your `MaterialApp` is wrapped with `Observer`:

```dart
Observer(
  builder: (_) => MaterialApp(
    themeMode: _getThemeMode(),
    ...
  ),
)
```

### Issue: `app_store.g.dart` not found

**Solution:** Run the MobX code generator:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: System theme changes not detected

**Solution:** Ensure your `State` class:
1. Mixes in `WidgetsBindingObserver`
2. Calls `WidgetsBinding.instance.addObserver(this)` in `initState`
3. Calls `WidgetsBinding.instance.removeObserver(this)` in `dispose`
4. Overrides `didChangePlatformBrightness()`

### Issue: Status bar icons not visible

**Solution:** The `setDarkMode` action updates `SystemUiOverlayStyle`. Make sure you're calling `appStore.setDarkMode()` and not just setting the variable directly.

---

## 📄 License

MIT License - Feel free to use in your projects!

---

## 🙏 Credits

Implemented based on best practices from:
- Material Design 3 guidelines
- Flutter MobX documentation
- nb_utils package patterns

---

**Happy theming! 🎨**
