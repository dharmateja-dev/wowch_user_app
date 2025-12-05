# App Screen Flow - From Start to Home

## Complete Screen Navigation Flow

### 1. **App Launch** (`main.dart`)
   - **Entry Point**: `MyApp` widget
   - **Initial Screen**: `SplashScreen()` (set as `home` in MaterialApp)

---

### 2. **Splash Screen** (`splash_screen.dart`)
   - **What it does:**
     - Displays app logo and app name
     - Sets language preferences
     - Syncs app configurations from server
     - Sets theme mode (light/dark/system)
     - Checks user authorization status
   
   - **Navigation Logic:**
     ```
     IF maintenance mode is ON
       → Navigate to MaintenanceModeScreen
     ELSE
       → Navigate to DashboardScreen (Home)
     ```

---

### 3. **Dashboard Screen** (`dashboard_screen.dart`)
   - **Main Container**: Bottom navigation bar with multiple tabs
   - **Default Tab**: Index 0 (Home tab)
   
   - **Bottom Navigation Tabs:**
     1. **Home Tab** (Index 0) - Shows one of:
        - `DashboardFragment1()` - If dashboard type is DASHBOARD_1
        - `DashboardFragment2()` - If dashboard type is DASHBOARD_2
        - `DashboardFragment3()` - If dashboard type is DASHBOARD_3
        - `DashboardFragment4()` - If dashboard type is DASHBOARD_4
        - `DashboardFragment()` - Default dashboard (fallback)
     
     2. **Booking Tab** (Index 1) - Shows:
        - `BookingFragment()` - If user is logged in
        - `SignInScreen()` - If user is NOT logged in
     
     3. **Category Tab** (Index 2) - Shows:
        - `CategoryScreen()` - Always visible
     
     4. **Chat Tab** (Index 3) - Shows (if chat is enabled):
        - `ChatListScreen()` - If user is logged in
        - `SignInScreen()` - If user is NOT logged in
     
     5. **Profile Tab** (Index 4) - Shows:
        - `ProfileFragment()` - Always visible

---

### 4. **Home Tab Content** (Dashboard Fragments)

   **Default DashboardFragment** includes:
   - Slider & Location Component
   - Pending Booking Component
   - Category Component
   - Promotional Banner Slider (if enabled)
   - Featured Service List
   - Service List
   - Horizontal Shop List
   - New Job Request Component (if enabled)

   **Alternative Dashboard Fragments** (1-4):
   - Similar content with different layouts/styles
   - Same data but different UI presentation

---

## Summary Flow Diagram

```
App Start
    ↓
main.dart (MyApp)
    ↓
SplashScreen
    ├─ Load app configurations
    ├─ Set language & theme
    └─ Check maintenance mode
         ↓
    IF maintenance mode
         ↓
    MaintenanceModeScreen
         ↓
    ELSE
         ↓
    DashboardScreen (Home)
         ├─ Tab 0: Home (DashboardFragment variants)
         ├─ Tab 1: Booking (BookingFragment or SignInScreen)
         ├─ Tab 2: Category (CategoryScreen)
         ├─ Tab 3: Chat (ChatListScreen or SignInScreen) [if enabled]
         └─ Tab 4: Profile (ProfileFragment)
```

---

## Key Points

1. **No Walkthrough**: The walkthrough screen has been removed - app goes directly to home
2. **No Reload Button**: The splash screen no longer shows a reload button
3. **Direct Navigation**: Splash screen → Dashboard screen (home) directly
4. **Maintenance Mode**: Only exception - if maintenance mode is active, shows maintenance screen
5. **Login Check**: Some tabs (Booking, Chat) require login - redirects to SignInScreen if not logged in







