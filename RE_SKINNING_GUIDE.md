# Flutter App Re-Skinning & Theming Guide

This document explains the architecture used for the UI re-skinning, theming system, and backend bypassing (Demo Mode) in the Handyman User App. Follow these principles to maintain consistency and implement similar features in the Provider App.

## 🎨 1. Theming Architecture

The project uses a theme-aware system that eliminates hardcoded color checks and ternary operators in the UI code.

### Core Files:
- `lib/utils/theme_colors.dart`: Contains raw hex codes for `LightThemeColors` and `DarkThemeColors`.
- `lib/app_theme.dart`: Maps raw colors to the Material 3 `ColorScheme` for both Light and Dark modes.
- `lib/utils/context_extensions.dart`: The primary way to access theme properties.
- `lib/utils/app_shadows.dart`: Centralized, theme-aware `BoxShadow` definitions.

### Accessing Colors:
Always use `context` extensions instead of `Colors.xxx` or `appStore.isDarkMode ? ...`.

```dart
// ✅ DO THIS
color: context.primary
color: context.scaffold
color: context.card

// ❌ AVOID THIS
color: appStore.isDarkMode ? Colors.white : Colors.black
```

---

## ✍️ 2. Custom Text Styles

We have replaced legacy `nb_utils` text styles with context-aware extensions to ensure text automatically flips between light and dark modes.

- **Location**: `lib/utils/text_styles.dart`
- **Key Methods**: `context.boldTextStyle()`, `context.primaryTextStyle()`, `context.secondaryTextStyle()`.

### Why use these?
Standard `nb_utils` styles use global variables that don't always react correctly to Material 3 ColorSchemes. These custom extensions default to `context.onSurface` (dynamic black/white) and `context.onSurfaceVariant` (dynamic muted colors).

---

## 🌑 3. Theme-Aware Shadows

Shadows are often hard to see in dark mode or too harsh in light mode. Use the `AppShadows` utility.

```dart
decoration: BoxDecoration(
  color: context.card,
  boxShadow: AppShadows.cardShadow(context), // Handled automatically
),
```

---

## 🚀 4. Demo Mode & Backend Bypassing

The app can run without a live backend connection for UI testing and client demonstrations.

### Configuration Skipping:
In `lib/screens/splash_screen.dart`, the app checks `demoModeStore.isDemoMode`. If enabled, it skips the mandatory configuration sync and allow navigation even if API calls fail.

### Mocking Login:
In `lib/screens/auth/sign_in_screen.dart`, when `isDemoMode` is active:
1. It ignores network errors.
2. It creates a local `demoUser` in the MobX store.
3. It redirects to the Dashboard with fake credentials.

### Dummy Data:
- `lib/utils/dummy_data_helper.dart`: Returns mock models for Dashboard, Services, and Categories.
- `lib/store/demo_mode_store.dart`: Manages state for fake bookings, notifications, and wallet history.

---

## 🛠️ 5. Moving to the Provider App

To replicate this "re-skin" in the Provider App:

1. **Migration**: Copy `theme_colors.dart`, `app_theme.dart`, `context_extensions.dart`, `app_shadows.dart`, and `text_styles.dart` to the new project.
2. **Update Branding**: Modify `LightThemeColors.primary` and `DarkThemeColors.primary` in `theme_colors.dart` to your new brand color.
3. **Mocking**: 
   - Create a `ProviderDummyDataHelper` for Handyman-specific data (Earnings, Appointments).
   - Update the `DemoModeStore` to handle Provider-specific states.
4. **Reskinning Components**: Search for hardcoded colors (e.g., `Color(0xFF...)`) in the Provider UI and replace them with `context.onSurfaceVariant`, `context.primaryContainer`, etc.

---

## ✅ Best Practices Checklist
- [ ] No hardcoded colors in UI files.
- [ ] Use `context.boldTextStyle()` instead of `boldTextStyle()`.
- [ ] Use `context.primary` for brand accents.
- [ ] Use `context.surface` for component backgrounds.
- [ ] Ensure `isDemoMode` is toggled in `configs.dart` or `demo_mode_store.dart` for testing.
