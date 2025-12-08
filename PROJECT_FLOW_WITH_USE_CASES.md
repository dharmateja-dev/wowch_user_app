# Project Flow: From Start to Home Screen - Complete Guide with Use Cases

## 📱 Application Overview
**App Name:** Wowch User App (Handyman Service User App)  
**Type:** On-Demand Services Booking Application  
**Framework:** Flutter (Dart)

---

## 🔄 Complete Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    APP LAUNCH (main.dart)                    │
│  • Initialize Flutter Binding                                │
│  • Initialize Firebase (Core, Messaging, Crashlytics)       │
│  • Initialize Global Services & Stores                       │
│  • Set Theme & Language Preferences                          │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│              MyApp Widget (MaterialApp)                      │
│  • Set SplashScreen as initial route                         │
│  • Configure Theme (Light/Dark/System)                       │
│  • Setup Localization & Language Support                     │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                  SPLASH SCREEN                               │
│  • Display App Logo & Name                                   │
│  • Initialize App Configurations                             │
│  • Check Maintenance Mode                                    │
│  • Navigate to Dashboard                                     │
└───────────────────────┬─────────────────────────────────────┘
                        │
        ┌───────────────┴───────────────┐
        │                               │
        ▼                               ▼
┌───────────────────┐         ┌──────────────────────┐
│ Maintenance Mode  │         │   DASHBOARD SCREEN   │
│     Screen        │         │   (Home Screen)       │
└───────────────────┘         └──────────────────────┘
```

---

## 📋 Detailed Step-by-Step Flow

### **Phase 1: App Initialization (`main.dart`)**

#### **Step 1.1: Entry Point - `main()` Function**

**What Happens:**
```dart
void main() async {
  // 1. Initialize Flutter Engine
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialize Firebase Services
  await Firebase.initializeApp()
    - Firebase Core
    - Firebase Cloud Messaging (Push Notifications)
    - Firebase Crashlytics (Error Reporting)
  
  // 3. Initialize Global Services
  - UserService
  - AuthService  
  - ChatServices
  
  // 4. Initialize MobX Stores
  - AppStore (User state, login status, theme)
  - FilterStore (Search filters)
  - AppConfigurationStore (App settings)
  - RolesAndPermissionStore (Permissions)
  
  // 5. Set Global UI Configuration
  - Button colors, radius, elevation
  - Text sizes and colors
  - Theme mode (Light/Dark/System)
  
  // 6. Initialize SharedPreferences
  await initialize()
  
  // 7. Run the App
  runApp(MyApp())
}
```

**Use Cases:**
- ✅ **First Time Launch:** All services initialize, default settings applied
- ✅ **Subsequent Launches:** Cached preferences loaded, faster initialization
- ✅ **Network Error:** App still launches, but some features may be limited
- ✅ **Firebase Error:** App continues, but push notifications won't work

---

### **Phase 2: MaterialApp Setup (`MyApp` Widget)**

#### **Step 2.1: App Configuration**

**What Happens:**
```dart
MaterialApp(
  home: SplashScreen(),  // Initial screen
  theme: AppTheme.lightTheme(),
  darkTheme: AppTheme.darkTheme(),
  themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
  supportedLocales: [All supported languages],
  localizationsDelegates: [Localization handlers],
)
```

**Use Cases:**
- ✅ **System Theme:** App follows device theme automatically
- ✅ **Manual Theme:** User can override with Light/Dark mode
- ✅ **Language Change:** App supports multiple languages
- ✅ **Material You:** Dynamic color theming based on Material Design 3

---

### **Phase 3: Splash Screen (`splash_screen.dart`)**

#### **Step 3.1: Splash Screen Display**

**Visual Elements:**
- App Logo (120x120)
- App Name: "Wowch User App"
- Background Image (Dark/Light mode based)

#### **Step 3.2: Initialization Process**

**What Happens:**
```dart
Future<void> init() async {
  // 1. Set Language Preference
  await appStore.setLanguage(
    getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: 'en')
  )
  
  // 2. Reset Configuration Sync Time
  await setValue(LAST_APP_CONFIGURATION_SYNCED_TIME, 0)
  
  // 3. Fetch App Configurations from Server
  await getAppConfigurations()
    - Maintenance mode status
    - Currency settings
    - Payment methods
    - Feature flags (Chat, Blog, etc.)
    - Dashboard type
    - Theme settings
  
  // 4. Set Theme Mode
  if (themeModeIndex == THEME_MODE_SYSTEM) {
    appStore.setDarkMode(
      MediaQuery.of(context).platformBrightness == Brightness.dark
    )
  }
  
  // 5. Check User Authorization
  if (!appConfigurationStore.isUserAuthorized && appStore.isLoggedIn) {
    await clearPreferences()  // User deactivated from admin
    cachedWalletHistoryList?.clear()
  }
  
  // 6. Navigate Based on Status
  if (appConfigurationStore.maintenanceModeStatus) {
    → MaintenanceModeScreen
  } else {
    → DashboardScreen
  }
}
```

**Use Cases:**

**Use Case 1: Normal Launch (No Maintenance)**
- ✅ Splash screen displays (2-3 seconds)
- ✅ Configurations fetched successfully
- ✅ User is authorized
- ✅ **Result:** Navigate to DashboardScreen

**Use Case 2: Maintenance Mode Active**
- ✅ Splash screen displays
- ✅ Configurations fetched
- ✅ Maintenance mode detected
- ✅ **Result:** Navigate to MaintenanceModeScreen

**Use Case 3: Network Error During Config Fetch**
- ✅ Splash screen displays
- ⚠️ Network unavailable
- ⚠️ Configuration fetch fails (error logged)
- ✅ **Result:** Still navigates to DashboardScreen (uses cached config)

**Use Case 4: User Deactivated**
- ✅ Splash screen displays
- ✅ Configurations fetched
- ⚠️ User marked as inactive from admin panel
- ✅ **Result:** Preferences cleared, navigate to DashboardScreen

**Use Case 5: First Time Launch**
- ✅ Splash screen displays
- ✅ Default language set (English)
- ✅ Default theme set (System)
- ✅ **Result:** Navigate to DashboardScreen

---

### **Phase 4: Dashboard Screen (`dashboard_screen.dart`)**

#### **Step 4.1: Dashboard Initialization**

**What Happens:**
```dart
@override
void initState() {
  // 1. Check if redirect to booking tab
  if (widget.redirectToBooking) {
    currentIndex = 1  // Switch to Booking tab
  }
  
  // 2. Setup Theme Listener
  if (THEME_MODE_SYSTEM) {
    Listen to system theme changes
  }
  
  // 3. Setup Firebase Notification Handler
  LiveStream().on(LIVESTREAM_FIREBASE, (value) {
    if (value == 3) {
      currentIndex = 3  // Switch to Chat tab
    }
  })
  
  // 4. Check Force Update
  await 3.seconds.delay
  if (FORCE_UPDATE_USER_APP) {
    showForceUpdateDialog()
  }
}
```

#### **Step 4.2: Bottom Navigation Structure**

**Navigation Tabs (5 Total):**

1. **Home Tab (Index 0)** - Default Tab
   - Shows Dashboard Fragment based on configuration:
     - `DashboardFragment1()` - Modern layout
     - `DashboardFragment2()` - Classic layout
     - `DashboardFragment3()` - Grid layout
     - `DashboardFragment4()` - List layout
     - `DashboardFragment()` - Default fallback

2. **Booking Tab (Index 1)**
   - If **Logged In:** `BookingFragment()` - Shows user bookings
   - If **Not Logged In:** `SignInScreen()` - Prompts login

3. **Category Tab (Index 2)**
   - Always shows: `CategoryScreen()` - Browse service categories

4. **Chat Tab (Index 3)** - Conditional
   - Only visible if `appConfigurationStore.isEnableChat == true`
   - If **Logged In:** `ChatListScreen()` - Chat conversations
   - If **Not Logged In:** `SignInScreen()` - Prompts login

5. **Profile Tab (Index 4)**
   - Always shows: `ProfileFragment()` - User profile & settings

#### **Step 4.3: Home Tab Content (Dashboard Fragment)**

**What's Displayed:**
```dart
DashboardFragment contains:
  1. Slider & Location Component
     - Image slider with services/offers
     - Location selector/search
  
  2. Pending Booking Component
     - Upcoming confirmed bookings
     - Quick access to booking details
  
  3. Category Component
     - Service categories grid/list
     - Tap to browse services in category
  
  4. Promotional Banner Slider (if enabled)
     - Promotional offers/banners
  
  5. Featured Service List
     - Highlighted/popular services
  
  6. Service List
     - All available services
  
  7. Horizontal Shop List
     - Top 5 shops/providers
  
  8. New Job Request Component (if enabled)
     - Post a job request feature
```

**Data Loading:**
- Fetches from API: `userDashboard()` endpoint
- Includes: Services, Categories, Shops, Bookings, Sliders
- Caches response for offline access
- Pull-to-refresh enabled

---

## 🎯 Complete Use Case Scenarios

### **Scenario 1: First Time User - Normal Flow**

**Steps:**
1. User opens app → `main()` executes
2. Firebase initializes → Services ready
3. Splash screen shows → Logo + App name displayed
4. Configurations fetch → Default settings applied
5. **Navigation:** Splash → Dashboard (Home Tab)
6. **Home Tab Shows:**
   - Service categories
   - Featured services
   - Location selector
   - **User Status:** Not logged in
7. **User Actions Available:**
   - Browse services (no login required)
   - Browse categories (no login required)
   - View profile (limited, prompts login)
   - **Cannot:** Book services, view bookings, chat

**Result:** ✅ User can explore app without login

---

### **Scenario 2: Returning User - Logged In**

**Steps:**
1. App opens → Cached login state detected
2. Splash screen → Quick initialization
3. Configurations fetch → User-specific settings loaded
4. **Navigation:** Splash → Dashboard (Home Tab)
5. **Home Tab Shows:**
   - Personalized content
   - Upcoming bookings (if any)
   - Recommended services
6. **All Tabs Accessible:**
   - Home: Full dashboard
   - Booking: User's booking history
   - Category: Browse categories
   - Chat: Conversations (if enabled)
   - Profile: Full profile with settings

**Result:** ✅ Full app access with personalized experience

---

### **Scenario 3: Network Error During Launch**

**Steps:**
1. App opens → Firebase initializes (cached)
2. Splash screen shows
3. Configuration fetch → **Network error occurs**
4. Error logged → Toast shown: "Internet not available"
5. **Navigation:** Still proceeds to Dashboard
6. **Dashboard Uses:**
   - Cached configurations
   - Cached dashboard data
   - Limited functionality (no new data fetch)

**Result:** ✅ App still usable with cached data

---

### **Scenario 4: Maintenance Mode Active**

**Steps:**
1. App opens → Normal initialization
2. Splash screen shows
3. Configuration fetch → Maintenance mode = true
4. **Navigation:** Splash → MaintenanceModeScreen
5. **User Sees:**
   - Maintenance message
   - Cannot access dashboard
   - Must wait for maintenance to complete

**Result:** ⚠️ App blocked until maintenance ends

---

### **Scenario 5: User Deactivated by Admin**

**Steps:**
1. App opens → User was previously logged in
2. Splash screen shows
3. Configuration fetch → User authorization check
4. **Detection:** `!appConfigurationStore.isUserAuthorized && appStore.isLoggedIn`
5. **Actions Taken:**
   - Clear all preferences
   - Clear cached wallet history
   - Logout user
6. **Navigation:** Splash → Dashboard
7. **User Status:** Logged out, must login again

**Result:** ✅ User data cleared, fresh start required

---

### **Scenario 6: Theme Change Detection**

**Steps:**
1. User changes device theme (Light ↔ Dark)
2. Dashboard screen detects change
3. **If System Theme Mode:**
   - App theme updates automatically
   - All screens reflect new theme
4. **If Manual Theme:**
   - App theme remains as user selected

**Result:** ✅ Seamless theme adaptation

---

### **Scenario 7: Push Notification Click**

**Steps:**
1. User receives push notification
2. User taps notification
3. Firebase handler processes notification
4. **Navigation:** Dashboard opens → Switches to Chat Tab (if notification type = 3)
5. **User Sees:** Relevant chat conversation

**Result:** ✅ Direct navigation to relevant content

---

### **Scenario 8: Force Update Required**

**Steps:**
1. App opens → Normal flow
2. Dashboard loads
3. After 3 seconds delay → Force update check
4. **If Update Required:**
   - Dialog appears
   - User must update to continue
   - Redirects to Play Store/App Store

**Result:** ⚠️ User must update app to continue

---

## 🔑 Key Configuration Data Fetched

**App Configurations Include:**
- ✅ Maintenance mode status
- ✅ Currency settings (code, symbol, position)
- ✅ Payment methods enabled
- ✅ Feature flags:
  - Chat enabled/disabled
  - Blog enabled/disabled
  - Job request enabled/disabled
  - Social login (Google, Apple, OTP)
- ✅ Dashboard type (1, 2, 3, 4, or default)
- ✅ Promotional banner status
- ✅ Date/Time format
- ✅ Timezone
- ✅ Store URLs (Play Store, App Store)
- ✅ Support email & helpline

---

## 📊 State Management

**MobX Stores Used:**
1. **AppStore:** User state, login status, theme, language
2. **AppConfigurationStore:** App-wide settings and feature flags
3. **FilterStore:** Search and filter preferences
4. **RolesAndPermissionStore:** User permissions

**Global Services:**
1. **UserService:** User-related operations
2. **AuthService:** Authentication (Firebase, Google, Apple)
3. **ChatServices:** Chat functionality

---

## 🎨 UI/UX Features

**Dashboard Features:**
- ✅ Pull-to-refresh on home tab
- ✅ Shimmer loading states
- ✅ Empty state widgets
- ✅ Error state handling
- ✅ Voice search component (if enabled)
- ✅ Double back press to exit
- ✅ Smooth page transitions

**Navigation:**
- ✅ Bottom navigation bar with 4-5 tabs
- ✅ Tab switching with smooth animations
- ✅ Profile image in navigation (if logged in)
- ✅ Badge indicators (unread notifications)

---

## 🚀 Performance Optimizations

1. **Caching:**
   - Dashboard response cached
   - Configuration cached (5-minute TTL)
   - Images cached
   - Service/Provider data cached

2. **Lazy Loading:**
   - Dashboard fragments load on demand
   - Images load progressively
   - Pagination for lists

3. **Error Handling:**
   - Graceful degradation on errors
   - Offline mode with cached data
   - Retry mechanisms

---

## 📝 Summary

**Flow:**
```
App Launch → Firebase Init → Splash Screen → 
Config Fetch → Navigation Decision → Dashboard Screen
```

**Key Points:**
- ✅ Always navigates to Dashboard (unless maintenance mode)
- ✅ No walkthrough screen (removed)
- ✅ No reload button (removed)
- ✅ Works offline with cached data
- ✅ Handles errors gracefully
- ✅ Supports multiple dashboard layouts
- ✅ Conditional features based on configuration

**User Experience:**
- Fast app launch (< 3 seconds)
- Smooth transitions
- Offline capability
- Personalized content (when logged in)
- Multi-language support
- Theme flexibility














