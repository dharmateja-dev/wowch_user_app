# API Analysis Report

## 📊 API Comparison: Demo Data vs Expected Backend Format

This document analyzes the demo data structures currently used in the app and identifies any API format updates needed.

---

## ✅ Existing APIs (Already Defined - Need Implementation)

The following APIs are already expected by the Flutter app and need to be implemented on your backend:

### Critical APIs (Required for Basic Functionality)

| # | API Endpoint | Status | Notes |
|---|--------------|--------|-------|
| 1 | `POST /register` | 🔴 Needs Backend | User registration |
| 2 | `POST /login` | 🔴 Needs Backend | Standard login |
| 3 | `POST /social-login` | 🔴 Needs Backend | Google/Apple login |
| 4 | `GET /logout` | 🔴 Needs Backend | Logout endpoint |
| 5 | `POST /update-profile` | 🔴 Needs Backend | Profile updates |
| 6 | `GET /user-detail` | 🔴 Needs Backend | User details |
| 7 | `POST /configurations` | 🔴 Needs Backend | App configurations |
| 8 | `GET /dashboard-detail` | 🔴 Needs Backend | Dashboard data |
| 9 | `GET /category-list` | 🔴 Needs Backend | Categories |
| 10 | `GET /subcategory-list` | 🔴 Needs Backend | Subcategories |
| 11 | `POST /service-detail` | 🔴 Needs Backend | Service details |
| 12 | `GET /search-list` | 🔴 Needs Backend | Service search |
| 13 | `GET /booking-list` | 🔴 Needs Backend | User bookings |
| 14 | `POST /booking-detail` | 🔴 Needs Backend | Booking details |
| 15 | `POST /booking-save` | 🔴 Needs Backend | Create booking |
| 16 | `POST /booking-update` | 🔴 Needs Backend | Update booking |
| 17 | `GET /booking-status` | 🔴 Needs Backend | Booking statuses |
| 18 | `GET /payment-gateways` | 🔴 Needs Backend | Payment methods |
| 19 | `POST /save-payment` | 🔴 Needs Backend | Save payment |
| 20 | `GET /user-wallet-balance` | 🔴 Needs Backend | Wallet balance |
| 21 | `GET /wallet-history` | 🔴 Needs Backend | Wallet transactions |
| 22 | `POST /wallet-top-up` | 🔴 Needs Backend | Add to wallet |
| 23 | `POST /notification-list` | 🔴 Needs Backend | Notifications |

### Important APIs (Required for Full Features)

| # | API Endpoint | Status | Notes |
|---|--------------|--------|-------|
| 24 | `POST /change-password` | 🔴 Needs Backend | Password change |
| 25 | `POST /forgot-password` | 🔴 Needs Backend | Password reset |
| 26 | `POST /delete-user-account` | 🔴 Needs Backend | Account deletion |
| 27 | `GET /user-list` | 🔴 Needs Backend | Provider/handyman list |
| 28 | `POST /save-booking-rating` | 🔴 Needs Backend | Add review |
| 29 | `GET /service-reviews` | 🔴 Needs Backend | Service reviews |
| 30 | `GET /user-favourite-service` | 🔴 Needs Backend | Wishlist services |
| 31 | `POST /save-favourite` | 🔴 Needs Backend | Add to wishlist |
| 32 | `POST /delete-favourite` | 🔴 Needs Backend | Remove wishlist |
| 33 | `GET /coupon-list` | 🔴 Needs Backend | Available coupons |
| 34 | `POST /country-list` | 🔴 Needs Backend | Countries |
| 35 | `POST /state-list` | 🔴 Needs Backend | States |
| 36 | `POST /city-list` | 🔴 Needs Backend | Cities |

### Additional APIs (For Complete Feature Set)

| # | API Endpoint | Status | Notes |
|---|--------------|--------|-------|
| 37 | `GET /shop-list` | 🔴 Needs Backend | Shop listings |
| 38 | `GET /shop-detail/{id}` | 🔴 Needs Backend | Shop details |
| 39 | `POST /save-post-job` | 🔴 Needs Backend | Post job request |
| 40 | `GET /get-post-job` | 🔴 Needs Backend | Get post jobs |
| 41 | `GET /user-bank-detail` | 🔴 Needs Backend | User banks |
| 42 | `POST /withdraw-money` | 🔴 Needs Backend | Wallet withdrawal |
| 43 | `GET /zones` | 🔴 Needs Backend | Service zones |
| 44 | `GET /payment-list` | 🔴 Needs Backend | Payment history |
| 45 | `POST /download-invoice` | 🔴 Needs Backend | Send invoice |

---

## 🆕 New APIs Potentially Required

Based on the app's functionality and demo data, these additional APIs may be needed:

### OTP Authentication APIs (If OTP Login Enabled)

| API Endpoint | Method | Purpose | Priority |
|--------------|--------|---------|----------|
| `/send-otp` | POST | Send OTP to phone | High |
| `/verify-otp` | POST | Verify OTP code | High |
| `/resend-otp` | POST | Resend OTP | High |

**Request Format:**
```json
// send-otp
{
  "phone": "9876543210",
  "country_code": "+91"
}

// verify-otp
{
  "phone": "9876543210",
  "country_code": "+91",
  "otp": "123456"
}
```

### Bank Account Management APIs

| API Endpoint | Method | Purpose | Priority |
|--------------|--------|---------|----------|
| `/save-bank` | POST | Add bank account | Medium |
| `/update-bank` | POST | Update bank | Medium |

**Request Format:**
```json
{
  "bank_name": "HDFC Bank",
  "account_number": "1234567890",
  "ifsc_code": "HDFC0001234",
  "account_holder_name": "John Doe",
  "is_default": 1
}
```

### Real-time Location Tracking APIs

| API Endpoint | Method | Purpose | Priority |
|--------------|--------|---------|----------|
| `/update-my-location` | POST | Provider updates location | Medium |
| `/track-provider/{booking_id}` | GET | Customer tracks provider | Medium |

**Request Format:**
```json
{
  "latitude": 12.9716,
  "longitude": 77.5946,
  "booking_id": 12345
}
```

### Help Desk/Support APIs

| API Endpoint | Method | Purpose | Priority |
|--------------|--------|---------|----------|
| `/helpdesk-list` | GET | Get support tickets | Low |
| `/save-helpdesk` | POST | Create support ticket | Low |
| `/helpdesk-reply` | POST | Reply to ticket | Low |

---

## 📋 API Response Format Updates

### Issue 1: Booking Status Labels

**Current Demo Data Uses:**
```dart
statusLabel: "Pending"  // Human-readable
status: BOOKING_STATUS_PENDING  // "pending" constant
```

**Backend Should Return:**
```json
{
  "status": "pending",
  "status_label": "Pending"
}
```

**Booking Status Constants Expected:**
| Status Constant | Value | Label |
|-----------------|-------|-------|
| BOOKING_STATUS_PENDING | `pending` | Pending |
| BOOKING_STATUS_ACCEPT | `accept` | Accepted |
| BOOKING_STATUS_ON_GOING | `on_going` | On Going |
| BOOKING_STATUS_IN_PROGRESS | `in_progress` | In Progress |
| BOOKING_STATUS_HOLD | `hold` | Hold |
| BOOKING_STATUS_CANCELLED | `cancelled` | Cancelled |
| BOOKING_STATUS_REJECTED | `rejected` | Rejected |
| BOOKING_STATUS_FAILED | `failed` | Failed |
| BOOKING_STATUS_COMPLETED | `completed` | Completed |
| BOOKING_STATUS_PENDING_APPROVAL | `pending_approval` | Pending Approval |
| BOOKING_STATUS_WAITING_ADVANCED_PAYMENT | `waiting` | Waiting |

### Issue 2: Payment Status

**Expected Payment Status Values:**
```dart
SERVICE_PAYMENT_STATUS_PAID = 'paid'
SERVICE_PAYMENT_STATUS_ADVANCE_PAID = 'advanced_paid'
SERVICE_PAYMENT_STATUS_PENDING = 'pending'
```

### Issue 3: Service Type

**Expected Service Type Values:**
```dart
SERVICE_TYPE_FIXED = 'fixed'
SERVICE_TYPE_HOURLY = 'hourly'
SERVICE_TYPE_FREE = 'free'
```

### Issue 4: User Type

**Expected User Type Values:**
```dart
USER_TYPE_PROVIDER = 'provider'
USER_TYPE_HANDYMAN = 'handyman'
USER_TYPE_USER = 'user'
```

### Issue 5: Login Type

**Expected Login Type Values:**
```dart
LOGIN_TYPE_USER = 'user'
LOGIN_TYPE_GOOGLE = 'google'
LOGIN_TYPE_OTP = 'mobile'
LOGIN_TYPE_APPLE = 'apple'
```

---

## 🔧 Model Field Naming Convention

The Flutter app uses **camelCase** internally but may expect **snake_case** from API.

### Example Transformations:

| Flutter Field | API Field | Notes |
|---------------|-----------|-------|
| `firstName` | `first_name` | User model |
| `lastName` | `last_name` | User model |
| `displayName` | `display_name` | User model |
| `contactNumber` | `contact_number` | User model |
| `profileImage` | `profile_image` | User model |
| `userType` | `user_type` | User model |
| `loginType` | `login_type` | User model |
| `apiToken` | `api_token` | Authentication |
| `serviceName` | `service_name` | Booking model |
| `serviceId` | `service_id` | Booking model |
| `customerId` | `customer_id` | Booking model |
| `providerId` | `provider_id` | Booking model |
| `providerName` | `provider_name` | Booking model |
| `providerImage` | `provider_image` | Booking model |
| `statusLabel` | `status_label` | Booking model |
| `bookingSlot` | `booking_slot` | Booking model |
| `totalAmount` | `total_amount` | Booking model |
| `serviceAttachments` | `service_attachments` | Booking model |
| `paymentStatus` | `payment_status` | Booking model |
| `paymentMethod` | `payment_method` | Booking model |

---

## 🔐 Authentication Flow

### Standard Email/Password Login
```
1. User submits email + password
2. Backend validates credentials
3. Backend generates JWT token
4. Response: { api_token, user_data }
5. App stores token in SharedPreferences
6. All subsequent requests include: Authorization: Bearer {token}
```

### Social Login (Google/Apple)
```
1. User authenticates with Google/Apple
2. App gets OAuth token
3. App sends social login data to backend
4. Backend verifies OAuth token (optional)
5. Backend creates/finds user
6. Backend generates JWT token
7. Response: { api_token, user_data }
```

### OTP Login
```
1. User enters phone number
2. App calls /send-otp
3. Backend sends SMS via gateway
4. User enters OTP
5. App calls /verify-otp
6. Backend validates OTP
7. Backend generates JWT token
8. Response: { api_token, user_data }
```

### Token Refresh
```
1. API returns 401 (Unauthorized)
2. App automatically calls login with stored credentials
3. New token received
4. Original request retried with new token
```

---

## 📊 Summary

### Total APIs Required: ~50

| Category | Count | Priority |
|----------|-------|----------|
| Authentication | 8 | Critical |
| User Management | 4 | Critical |
| Dashboard/Config | 2 | Critical |
| Services | 4 | Critical |
| Categories | 2 | High |
| Bookings | 6 | Critical |
| Payments | 5 | Critical |
| Wallet | 4 | High |
| Notifications | 1 | High |
| Reviews | 6 | Medium |
| Wishlist | 6 | Medium |
| Shops | 3 | Medium |
| Post Jobs | 4 | Low |
| Location | 3 | Medium |
| Banks | 4 | Medium |
| Utilities | 3 | Low |

### New APIs to Add: ~6

| API | Priority |
|-----|----------|
| OTP Send/Verify/Resend | High (if OTP enabled) |
| Save/Update Bank | Medium |
| Real-time Location Tracking | Medium |
| Help Desk | Low |

---

**Document Version:** 1.0  
**Last Updated:** December 29, 2024
