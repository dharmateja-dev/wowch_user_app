# Development Phase Requirements

## 📋 Overview

This document outlines all the requirements needed to move the **Wowch User App (Handyman Service User App)** from the UI reskinning phase to the active development phase. It covers all APIs, third-party integrations, backend services, and authentication requirements.

---

## 🔌 API Requirements

### Existing APIs (From `rest_apis.dart`)

The application currently expects the following REST API endpoints. These need to be implemented on your backend server.

#### 1. Authentication APIs

| Endpoint | Method | Description | Request Body | Response |
|----------|--------|-------------|--------------|----------|
| `register` | POST | User registration | `{first_name, last_name, email, password, username, contact_number, user_type}` | `LoginResponse` with `UserData` |
| `login` | POST | Standard user login | `{email, password}` | `LoginResponse` with `api_token` |
| `social-login` | POST | Social login (Google/Apple) | `{email, first_name, last_name, username, social_image, accessToken, login_type, user_type}` | `LoginResponse` |
| `logout` | GET | User logout | Authorization header | Success message |
| `change-password` | POST | Change user password | `{old_password, new_password}` | `BaseResponseModel` |
| `forgot-password` | POST | Forgot password | `{email}` | `BaseResponseModel` |
| `delete-user-account` | POST | Delete user account permanently | `{}` | `BaseResponseModel` |
| `user-email-verify` | POST | Verify user email | `{email}` | `VerificationModel` |
| `update-profile` | POST | Update user profile | `{first_name, last_name, email, contact_number, address, etc.}` | `LoginResponse` |
| `user-detail?id={id}` | GET | Get user details | Query param: `id` | `LoginResponse` |

#### 2. Dashboard & Configuration APIs

| Endpoint | Method | Description | Request Body | Response |
|----------|--------|-------------|--------------|----------|
| `configurations` | POST | Get app configurations | `{user_id}` (if logged in) | `AppConfigurationModel` |
| `dashboard-detail` | GET | Get dashboard data | Query params: `latitude`, `longitude`, `customer_id` | `DashboardResponse` |

**Expected `DashboardResponse` structure:**
```json
{
  "status": true,
  "is_email_verified": 1,
  "notification_unread_count": 5,
  "slider": [...],
  "category": [...],
  "service": [...],
  "featuredService": [...],
  "provider": [...],
  "booking_data": [...],
  "shop": [...]
}
```

#### 3. Service APIs

| Endpoint | Method | Description | Request Body | Response |
|----------|--------|-------------|--------------|----------|
| `service-detail` | POST | Get service details | `{service_id, customer_id}` | `ServiceDetailResponse` |
| `search-list` | GET | Search services | Query params: `category_id`, `provider_id`, `is_price_min`, `is_price_max`, `is_rating`, `search`, `latitude`, `longitude`, `is_featured`, `subcategory_id`, `shop_id`, `zone_id`, `page`, `per_page` | `ServiceResponse` |
| `service-list?customer_id={id}` | GET | Get services by customer | Query param: `customer_id` | `ServiceResponse` |
| `service-delete/{id}` | POST | Delete a service | Path param: `id` | `BaseResponseModel` |

#### 4. Category APIs

| Endpoint | Method | Description | Request Body | Response |
|----------|--------|-------------|--------------|----------|
| `category-list` | GET | Get categories | Query params: `page`, `per_page` | `CategoryResponse` |
| `subcategory-list` | GET | Get subcategories | Query params: `category_id`, `per_page` | `CategoryResponse` |

#### 5. Provider APIs

| Endpoint | Method | Description | Request Body | Response |
|----------|--------|-------------|--------------|----------|
| `user-detail?id={id}&login_user_id={userId}` | GET | Get provider details | Query params + optional `latitude`, `longitude` | `ProviderInfoResponse` |
| `user-list` | GET | Get list of providers/handymen | Query params: `user_type`, `type`, `per_page`, `page` | `ProviderListResponse` |

#### 6. Booking APIs

| Endpoint | Method | Description | Request Body | Response |
|----------|--------|-------------|--------------|----------|
| `booking-list` | GET | Get user's bookings | Query params: `shop_id`, `service_id`, `date_from`, `date_to`, `provider_id`, `handyman_id`, `status`, `payment_status`, `payment_type`, `per_page`, `page` | `BookingListResponse` |
| `booking-detail` | POST | Get booking details | `{booking_id, customer_id}` | `BookingDetailResponse` |
| `booking-save` | POST | Create new booking | Booking request data | `BookingDetailResponse` |
| `booking-update` | POST | Update booking | Booking update data | `BaseResponseModel` |
| `booking-status` | GET | Get booking statuses | - | Array of `BookingStatusResponse` |
| `get-location?booking_id={id}` | GET | Get provider location | Query param: `booking_id` | `UpdateLocationResponse` |

**Booking Request Body Example:**
```json
{
  "service_id": 1,
  "description": "Service description",
  "date": "2024-01-15",
  "slot": "09:00:00",
  "address": "123 Main Street",
  "latitude": 12.9716,
  "longitude": 77.5946,
  "provider_id": 1,
  "quantity": 1,
  "coupon_id": null,
  "type": "fixed"
}
```

#### 7. Payment APIs

| Endpoint | Method | Description | Request Body | Response |
|----------|--------|-------------|--------------|----------|
| `save-payment` | POST | Save payment record | Payment data | `BaseResponseModel` |
| `payment-gateways` | GET | Get available payment gateways | Query param: `is_add_wallet` (optional) | Array of `PaymentSetting` |
| `payment-list?booking_id={id}` | GET | Get payments for booking | Query param: `booking_id` | `PaymentListResponse` |

#### 8. Wallet APIs

| Endpoint | Method | Description | Request Body | Response |
|----------|--------|-------------|--------------|----------|
| `user-wallet-balance` | GET | Get user wallet balance | - | `WalletResponse` |
| `wallet-history` | GET | Get wallet history | Query params: `per_page`, `page`, `orderby` | `UserWalletHistoryResponse` |
| `wallet-top-up` | POST | Add money to wallet | `{amount, payment_type, transaction_id}` | `BaseResponseModel` |
| `withdraw-money` | POST | Withdraw from wallet | `{amount, bank_id}` | `BaseResponseModel` |

#### 9. Notification APIs

| Endpoint | Method | Description | Request Body | Response |
|----------|--------|-------------|--------------|----------|
| `notification-list?customer_id={id}` | POST | Get notifications | Optional request body | `NotificationListResponse` |

#### 10. Coupon APIs

| Endpoint | Method | Description | Request Body | Response |
|----------|--------|-------------|--------------|----------|
| `coupon-list` | GET | Get available coupons | Query params: `service_id`, `price` | `CouponListResponse` |

#### 11. Review APIs

| Endpoint | Method | Description | Request Body | Response |
|----------|--------|-------------|--------------|----------|
| `save-booking-rating` | POST | Add/update review | `{booking_id, rating, review}` | `BaseResponseModel` |
| `service-reviews?per_page=all` | POST | Get service reviews | `{service_id}` | `ServiceReviewResponse` |
| `get-user-ratings?per_page=all` | GET | Get user's given ratings | - | `ServiceReviewResponse` |
| `handyman-reviews?per_page=all` | POST | Get handyman reviews | `{handyman_id}` | `ServiceReviewResponse` |
| `delete-booking-rating` | POST | Delete booking review | `{id}` | `BaseResponseModel` |
| `save-handyman-rating` | POST | Rate handyman | `{handyman_id, rating, review}` | `BaseResponseModel` |
| `delete-handyman-rating` | POST | Delete handyman rating | `{id}` | `BaseResponseModel` |

#### 12. Wishlist/Favorites APIs

| Endpoint | Method | Description | Request Body | Response |
|----------|--------|-------------|--------------|----------|
| `user-favourite-service` | GET | Get favorite services | Query params: `per_page`, `page` | `ServiceResponse` |
| `save-favourite` | POST | Add to favorites | `{service_id}` | `BaseResponseModel` |
| `delete-favourite` | POST | Remove from favorites | `{service_id}` | `BaseResponseModel` |
| `user-favourite-provider` | GET | Get favorite providers | Query params: `per_page`, `page` | `ProviderListResponse` |
| `save-favourite-provider` | POST | Add provider to favorites | `{provider_id}` | `BaseResponseModel` |
| `delete-favourite-provider` | POST | Remove provider from favorites | `{provider_id}` | `BaseResponseModel` |

#### 13. Post Job Request APIs

| Endpoint | Method | Description | Request Body | Response |
|----------|--------|-------------|--------------|----------|
| `save-post-job` | POST | Post a job request | Job request data | `BaseResponseModel` |
| `get-post-job` | GET | Get user's post jobs | Query params: `per_page`, `page` | `GetPostJobResponse` |
| `get-post-job-detail` | POST | Get post job details | `{post_job_id}` | `PostJobDetailResponse` |
| `post-job-delete/{id}` | POST | Delete post job | Path param: `id` | `BaseResponseModel` |

#### 14. Shop APIs

| Endpoint | Method | Description | Request Body | Response |
|----------|--------|-------------|--------------|----------|
| `shop-list` | GET | Get shops list | Query params: `per_page`, `page`, `search`, `service_id`, `provider_id` | `ShopResponse` |
| `shop-detail/{id}` | GET | Get shop details | Path param: `id` | `ShopDetailResponse` |
| `wishlist-shops` | GET | Get favorite shops | Query params: `per_page`, `page` | `ShopResponse` |

#### 15. Location APIs

| Endpoint | Method | Description | Request Body | Response |
|----------|--------|-------------|--------------|----------|
| `country-list` | POST | Get countries | - | Array of `CountryListResponse` |
| `state-list` | POST | Get states | `{country_id}` | Array of `StateListResponse` |
| `city-list` | POST | Get cities | `{state_id}` | Array of `CityListResponse` |
| `zones` | GET | Get zones | Query params: `page`, `zone_id`, `per_page` | `ProviderZoneResponse` |

#### 16. Bank APIs

| Endpoint | Method | Description | Request Body | Response |
|----------|--------|-------------|--------------|----------|
| `user-bank-detail` | GET | Get user's banks | Query params: `per_page`, `page`, `user_id` | `BankListResponse` |
| `default-bank?id={bankId}` | POST | Set default bank | Query param: `id` | `BaseResponseModel` |
| `delete-bank/{bankId}` | POST | Delete bank | Path param: `bankId` | `BaseResponseModel` |
| `provider-payout` | POST | Provider payout | Payout request | `BaseResponseModel` |

#### 17. Utility APIs

| Endpoint | Method | Description | Request Body | Response |
|----------|--------|-------------|--------------|----------|
| `remove-file` | POST | Delete uploaded file | `{id, type}` | `BaseResponseModel` |
| `download-invoice` | POST | Send invoice via email | `{booking_id}` | `BaseResponseModel` |

---

### 📊 API Response Format Standards

All APIs should follow this standard response format:

**Success Response:**
```json
{
  "status": true,
  "message": "Success message",
  "data": { ... }
}
```

**Error Response:**
```json
{
  "status": false,
  "message": "Error message"
}
```

**Paginated Response:**
```json
{
  "status": true,
  "data": [...],
  "pagination": {
    "total": 100,
    "per_page": 20,
    "current_page": 1,
    "last_page": 5
  }
}
```

---

## 🔗 Third-Party Integrations

### 1. Firebase Services (Required)

| Service | Purpose | Configuration Required |
|---------|---------|----------------------|
| **Firebase Core** | App initialization | `google-services.json` (Android), `GoogleService-Info.plist` (iOS) |
| **Firebase Auth** | Authentication | Enable Email/Password and Phone auth in Firebase Console |
| **Firebase Messaging** | Push notifications | FCM Server Key, APNS configuration for iOS |
| **Firebase Crashlytics** | Crash reporting | Enable in Firebase Console |
| **Cloud Firestore** | Real-time chat | Create required collections |
| **Firebase Storage** | Chat file uploads | Configure storage rules |

**Firebase Configuration Files Needed:**
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

### 2. Payment Gateway Integrations

| Gateway | Package | Configuration Required |
|---------|---------|----------------------|
| **Stripe** | `flutter_stripe: ^12.0.2` | Publishable Key, Secret Key, Merchant Country Code |
| **Razorpay** | `razorpay_flutter: ^1.4.0` | API Key, Secret Key |
| **PayPal** | `flutter_paypal_checkout` | Client ID, Secret, Sandbox/Live mode |
| **Flutterwave** | `flutterwave_standard` | Public Key, Secret Key, Encryption Key |
| **CinetPay** | `cinetpay` | Site ID, API Key |
| **Paystack** | `flutter_paystack` | Public Key, Secret Key |
| **Sadad** | Custom integration | API URL, Credentials |
| **PhonePe** | Custom integration | Merchant ID, Salt Key, Salt Index |
| **Airtel Money** | Custom integration | Client ID, Client Secret, Country/Currency codes |
| **Midtrans** | `midpay` | Client Key, Server Key |
| **PIX (Brazil)** | `pix_flutter: ^2.2.0` | PIX Key configuration |

**Payment Gateway Backend Requirements:**
- Each payment gateway may require server-side verification
- Save payment transactions in database
- Webhook endpoints for payment status updates

### 3. Social Login Integrations

| Provider | Package | Configuration Required |
|----------|---------|----------------------|
| **Google Sign-In** | `google_sign_in: ^7.1.1` | OAuth Client ID (Web Client ID for Firebase) |
| **Apple Sign-In** | `the_apple_sign_in: ^1.1.1` | Apple Developer Account, Service ID, Team ID |

**FIREBASE_SERVER_CLIENT_ID:**
- Found in `google-services.json` under `client_type: 3`
- Currently: `438524885554-57q5kelj6uhtjnbebkb8o82mbb3262gt.apps.googleusercontent.com`

### 4. Maps & Location Services

| Service | Package | Configuration Required |
|---------|---------|----------------------|
| **Google Maps** | `google_maps_flutter: ^2.12.3` | Google Maps API Key |
| **Geocoding** | `geocoding: ^4.0.0` | Google Geocoding API Key |
| **Geolocator** | `geolocator: ^14.0.2` | Location permissions |

**Platform Configuration:**
- **Android:** Add API key to `AndroidManifest.xml`
- **iOS:** Add API key to `AppDelegate.swift`

### 5. Other Third-Party Services

| Service | Package | Purpose |
|---------|---------|---------|
| **Speech to Text** | `speech_to_text: ^7.3.0` | Voice search functionality |
| **Image Picker** | `image_picker: ^1.2.0` | Camera and gallery access |
| **File Picker** | `file_picker: ^10.3.2` | Document uploads |
| **WebView** | `webview_flutter: ^4.13.0` | In-app web content |
| **Custom Tabs** | `flutter_custom_tabs: ^2.4.0` | External links |
| **Share Plus** | `share_plus: ^11.1.0` | Content sharing |
| **Playx Version Update** | `playx_version_update: ^1.0.0` | Force update handling |

---

## 🖥️ Backend Services Requirements

### 1. Core Backend Services

| Service | Description | Priority |
|---------|-------------|----------|
| **User Management** | Registration, login, profile, password reset | Critical |
| **Service Management** | CRUD for services, categories, subcategories | Critical |
| **Booking System** | Booking creation, status updates, history | Critical |
| **Payment Processing** | Payment gateway integration, wallet management | Critical |
| **Provider Management** | Provider profiles, assignments, locations | Critical |
| **Notification Service** | Push notifications, in-app notifications | High |
| **Chat Service** | Real-time messaging (Firebase Firestore) | High |
| **Review System** | Ratings for services, providers, handymen | High |
| **Shop/Store Management** | Shop listings, details | Medium |
| **Job Request System** | User-posted job requests | Medium |

### 2. Database Schema Requirements

**Core Tables/Collections:**
- `users` - User accounts (customers, providers, handymen)
- `services` - Available services
- `categories` - Service categories
- `subcategories` - Service subcategories
- `bookings` - Booking records
- `payments` - Payment transactions
- `wallets` - User wallet balances
- `wallet_transactions` - Wallet history
- `reviews` - User reviews
- `notifications` - Push/in-app notifications
- `coupons` - Discount coupons
- `shops` - Provider shops
- `post_jobs` - User job requests
- `banks` - User bank accounts
- `taxes` - Tax configurations
- `zones` - Service zones
- `configurations` - App configurations

### 3. Configuration Management

The backend must provide these configurations via the `configurations` endpoint:

```json
{
  "maintenance_mode": false,
  "currency": {
    "currency_name": "Indian Rupee",
    "currency_symbol": "₹",
    "currency_code": "INR",
    "currency_position": "left"
  },
  "otp_login_enable": 1,
  "google_login_enable": 1,
  "apple_login_enable": 1,
  "enable_chat": 1,
  "enable_user_wallet": 1,
  "job_request_enable": 1,
  "blog_enable": 1,
  "online_payment_status": 1,
  "advance_payment_amount": null,
  "promotional_banner_status": 1,
  "dashboard_type": "dashboard_1",
  "user_app_minimum_version": "1.0.0",
  "user_app_latest_version": "1.0.0",
  "force_update_user_app": 0,
  "customer_play_store_url": "https://play.google.com/store/apps/details?id=...",
  "customer_app_store_url": "https://apps.apple.com/app/..."
}
```

### 4. Real-time Features (Firebase Firestore)

**Required Collections:**
```
users/
  {userId}/
    - id, email, firstName, lastName, profileImage, createdAt, updatedAt

messages/
  {chatId}/
    messages/
      {messageId}/
        - senderId, receiverId, message, createdAt, messageType, isRead

contacts/
  {userId}/
    - lastMessageTime, unreadCount, contactId
```

---

## 🔐 Authentication & Authorization Requirements

### 1. Authentication Methods

| Method | Status | Backend Requirement |
|--------|--------|---------------------|
| **Email/Password** | Required | Standard auth with JWT tokens |
| **Google Sign-In** | Optional | OAuth token verification |
| **Apple Sign-In** | Optional (iOS) | Apple ID token verification |
| **OTP Login** | Optional | SMS gateway integration |

### 2. JWT Token Management

- **Token Generation:** On successful login
- **Token Refresh:** Automatic when 401 received
- **Token Storage:** Secure local storage (SharedPreferences)
- **Token Expiry:** Configurable (recommended: 24 hours)

### 3. User Roles & Types

| User Type | Constant | Access Level |
|-----------|----------|--------------|
| `user` | `USER_TYPE_USER` | Customer - book services |
| `provider` | `USER_TYPE_PROVIDER` | Service provider - manage services |
| `handyman` | `USER_TYPE_HANDYMAN` | Worker - assigned to bookings |

### 4. Permission Checks

The app expects these permission flags from backend:
- Service booking permissions
- Wallet access permissions
- Chat access permissions
- Review permissions

### 5. Security Headers

Required headers for authenticated requests:
```
Authorization: Bearer {api_token}
Content-Type: application/json; charset=utf-8
Accept: application/json; charset=utf-8
language-code: {selected_language}
```

---

## 📱 API Format Updates for Demo Data

### Current Demo Mode Status

The app currently has a `DEMO_MODE_ENABLED = true` flag in `demo_mode_store.dart`. This provides:
- Demo user login
- Demo bookings data
- Demo notifications
- Demo wallet transactions

### APIs Requiring Format Updates

Based on the demo data structure, verify these API response formats match:

#### 1. Booking Data Model
```json
{
  "id": 12345,
  "service_name": "Home Deep Cleaning",
  "service_id": 101,
  "customer_id": 1,
  "customer_name": "John Doe",
  "provider_id": 1,
  "provider_name": "CleanPro Services",
  "provider_image": "https://...",
  "status": "pending",
  "status_label": "Pending",
  "date": "2024-01-15 00:00:00",
  "booking_slot": "10:00:00",
  "address": "123 Main Street",
  "description": "Deep cleaning for 3BHK",
  "type": "fixed",
  "amount": 1500,
  "total_amount": 1650,
  "discount": 10,
  "quantity": 1,
  "service_attachments": ["https://..."],
  "handyman": [...],
  "coupon_data": {...},
  "taxes": [...]
}
```

#### 2. User Data Model
```json
{
  "id": 1,
  "first_name": "John",
  "last_name": "Doe",
  "display_name": "John Doe",
  "email": "john@example.com",
  "contact_number": "+919876543210",
  "profile_image": "https://...",
  "user_type": "user",
  "status": 1,
  "login_type": "user",
  "uid": "firebase_uid",
  "address": "123 Demo Street",
  "api_token": "jwt_token_here"
}
```

#### 3. Notification Data Model
```json
{
  "id": "1",
  "created_at": "2024-01-15T10:00:00.000Z",
  "read_at": null,
  "data": {
    "id": 12345,
    "notification_type": "booking",
    "message": "Your booking has been confirmed",
    "subject": "Booking Confirmed"
  }
}
```

#### 4. Wallet Transaction Model
```json
{
  "id": 1,
  "datetime": "2024-01-15T10:00:00.000Z",
  "activity_type": "wallet",
  "activity_message": "Wallet top-up successful",
  "activity_data": {
    "title": "Wallet Top-up",
    "user_id": 1,
    "amount": 500,
    "credit_debit_amount": 500,
    "transaction_type": "credit"
  }
}
```

### New APIs That May Be Required

| API | Purpose | Priority |
|-----|---------|----------|
| `verify-otp` | OTP verification for phone login | High (if OTP enabled) |
| `resend-otp` | Resend OTP | High (if OTP enabled) |
| `save-bank` | Add user bank account | Medium |
| `update-location` | Update provider/handyman location | Medium (for real-time tracking) |
| `help-desk` | Customer support tickets | Low |
| `blog-list` | Blog/article listing | Low |

---

## ✅ Pre-Development Checklist

### Backend Setup
- [ ] Set up REST API server (Laravel/Node.js/Django/etc.)
- [ ] Configure database (MySQL/PostgreSQL/MongoDB)
- [ ] Implement all required API endpoints
- [ ] Set up JWT authentication
- [ ] Configure CORS for API access
- [ ] Set up file upload storage (local or cloud)

### Firebase Setup
- [ ] Create Firebase project
- [ ] Enable Authentication methods
- [ ] Set up Cloud Firestore database
- [ ] Configure Firebase Storage
- [ ] Enable Firebase Crashlytics
- [ ] Set up Firebase Cloud Messaging
- [ ] Download and add config files to project

### Third-Party Setup
- [ ] Configure Google Sign-In
- [ ] Configure Apple Sign-In (iOS)
- [ ] Set up payment gateway accounts
- [ ] Get Google Maps API key
- [ ] Configure SMS gateway for OTP (if needed)

### App Configuration
- [ ] Update `DOMAIN_URL` in `configs.dart`
- [ ] Update `FIREBASE_SERVER_CLIENT_ID`
- [ ] Configure payment gateway keys
- [ ] Update app package name
- [ ] Update store URLs

---

## 🔄 Migration from Demo Mode to Production

1. **Disable Demo Mode:**
   ```dart
   // In demo_mode_store.dart
   const bool DEMO_MODE_ENABLED = false;
   ```

2. **Update API Base URL:**
   ```dart
   // In configs.dart
   const DOMAIN_URL = "https://your-production-api.com";
   ```

3. **Update Firebase Configuration:**
   - Replace `google-services.json` with production config
   - Replace `GoogleService-Info.plist` with production config

4. **Update Payment Gateway Keys:**
   - Switch from test/sandbox to production keys

5. **Test All Features:**
   - Authentication flows
   - Booking workflow
   - Payment processing
   - Push notifications
   - Chat functionality
   - Location services

---

**Document Version:** 1.0  
**Last Updated:** December 29, 2024  
**Project Version:** 11.15.1
