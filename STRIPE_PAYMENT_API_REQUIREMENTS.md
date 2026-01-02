# Stripe Payment Gateway - API Requirements

> **Document Version:** 1.0  
> **Last Updated:** January 1, 2026  
> **Project:** Wowch User App (Handyman Flutter)

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Required APIs Summary](#required-apis-summary)
4. [Existing Backend APIs](#existing-backend-apis)
5. [New Backend APIs Required](#new-backend-apis-required)
6. [Stripe Direct APIs](#stripe-direct-apis)
7. [Configuration Requirements](#configuration-requirements)
8. [Security Considerations](#security-considerations)
9. [Implementation Checklist](#implementation-checklist)

---

## Overview

This document outlines all the APIs required for implementing Stripe payment gateway in production for the Wowch User App. The payment flow allows users to pay for bookings using credit/debit cards via Stripe.

### Current Payment Flow (Test Mode)
```
Flutter App → Stripe API (Direct) → Payment Sheet → Save to Backend
```

### Recommended Production Flow (Secure)
```
Flutter App → Your Backend → Stripe API → Backend → Flutter App
                  ↓
            Payment Sheet
                  ↓
         Stripe Webhook → Your Backend (Update Status)
```

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              PAYMENT FLOW                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌──────────────┐     ┌──────────────────┐     ┌──────────────────┐       │
│   │  Flutter App │────▶│   Your Backend   │────▶│    Stripe API    │       │
│   │  (User App)  │     │  (Laravel/Node)  │     │                  │       │
│   │              │◀────│                  │◀────│                  │       │
│   └──────────────┘     └──────────────────┘     └──────────────────┘       │
│         │                      │                        │                   │
│         │                      │                        │                   │
│         ▼                      ▼                        │                   │
│   ┌──────────────┐     ┌──────────────────┐            │                   │
│   │Payment Sheet │     │    Database      │◀───────────┘                   │
│   │  (Stripe UI) │     │ (Bookings/Txns)  │     (Webhook Events)           │
│   └──────────────┘     └──────────────────┘                                │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Required APIs Summary

| # | API Endpoint | Method | Type | Status | Priority |
|---|--------------|--------|------|--------|----------|
| 1 | `/api/payment-gateways` | GET | Backend | ✅ Exists | Required |
| 2 | `/api/save-payment` | POST | Backend | ✅ Exists | Required |
| 3 | `/api/stripe/create-payment-intent` | POST | Backend | ❌ New | **Critical** |
| 4 | `/api/stripe/webhook` | POST | Backend | ❌ New | **Critical** |
| 5 | `https://api.stripe.com/v1/payment_intents` | POST | Stripe | External | Reference |

---

## Existing Backend APIs

### 1. Get Payment Gateways API

**Purpose:** Retrieves the list of available payment methods and their configuration settings.

| Property | Value |
|----------|-------|
| **Endpoint** | `/api/payment-gateways` |
| **Method** | `GET` |
| **Authentication** | Bearer Token |
| **Used In** | `payment_screen.dart` |

#### Request Headers
```http
GET /api/payment-gateways HTTP/1.1
Host: your-api-domain.com
Authorization: Bearer <user_token>
Content-Type: application/json
```

#### Query Parameters (Optional)
| Parameter | Type | Description |
|-----------|------|-------------|
| `is_add_wallet` | boolean | Filter for wallet top-up gateways |

#### Response (Success - 200)
```json
[
  {
    "id": 1,
    "title": "Cash on Delivery",
    "type": "cash",
    "status": 1,
    "is_test": 0,
    "value": null,
    "live_value": null
  },
  {
    "id": 2,
    "title": "Credit/Debit Card (Stripe)",
    "type": "stripe",
    "status": 1,
    "is_test": 1,
    "value": {
      "stripe_url": "https://api.stripe.com/v1/payment_intents",
      "stripe_key": "sk_test_xxxxxxxxxxxxxxxx",
      "stripe_publickey": "pk_test_xxxxxxxxxxxxxxxx"
    },
    "live_value": {
      "stripe_url": "https://api.stripe.com/v1/payment_intents",
      "stripe_key": "sk_live_xxxxxxxxxxxxxxxx",
      "stripe_publickey": "pk_live_xxxxxxxxxxxxxxxx"
    }
  }
]
```

#### Response Fields
| Field | Type | Description |
|-------|------|-------------|
| `id` | int | Payment gateway ID |
| `title` | string | Display name of payment method |
| `type` | string | Payment method identifier (`stripe`, `razorpay`, `paypal`, etc.) |
| `status` | int | 1 = Active, 0 = Inactive |
| `is_test` | int | 1 = Test mode, 0 = Live mode |
| `value` | object | Test environment credentials |
| `live_value` | object | Production environment credentials |

---

### 2. Save Payment API

**Purpose:** Records the payment transaction in the database after successful payment processing.

| Property | Value |
|----------|-------|
| **Endpoint** | `/api/save-payment` |
| **Method** | `POST` |
| **Authentication** | Bearer Token |
| **Used In** | `payment_screen.dart` → `savePay()` |

#### Request Headers
```http
POST /api/save-payment HTTP/1.1
Host: your-api-domain.com
Authorization: Bearer <user_token>
Content-Type: application/json
```

#### Request Body
```json
{
  "booking_id": 101,
  "customer_id": 1,
  "discount": 10,
  "total_amount": 1350.00,
  "datetime": "2026-01-01 10:00:00",
  "txn_id": "pi_3QxxxxxxxxxxxxxxABC",
  "payment_status": "paid",
  "payment_method": "stripe",
  "advance_payment_amount": 675.00
}
```

#### Request Fields
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `booking_id` | int | Yes | ID of the booking being paid for |
| `customer_id` | int | Yes | ID of the customer making payment |
| `discount` | number | No | Discount percentage applied |
| `total_amount` | number | Yes | Total payment amount |
| `datetime` | string | Yes | Payment date/time (format: `yyyy-MM-dd HH:mm:ss`) |
| `txn_id` | string | Yes | Stripe PaymentIntent ID or transaction reference |
| `payment_status` | string | Yes | `pending`, `paid`, `advance_paid`, `failed` |
| `payment_method` | string | Yes | `stripe`, `razorpay`, `cash`, etc. |
| `advance_payment_amount` | number | No | Advance payment amount (if applicable) |

#### Response (Success - 200)
```json
{
  "message": "Payment saved successfully",
  "status": true,
  "data": {
    "payment_id": 456,
    "booking_id": 101
  }
}
```

#### Response (Error - 400/500)
```json
{
  "message": "Failed to save payment",
  "status": false,
  "errors": {
    "booking_id": ["Booking not found"]
  }
}
```

---

## New Backend APIs Required

> ⚠️ **CRITICAL:** These APIs are required for secure production deployment.

### 3. Create Payment Intent API (NEW)

**Purpose:** Creates a Stripe PaymentIntent on the server side, keeping the secret key secure. This replaces the current insecure direct Stripe API call from the Flutter app.

| Property | Value |
|----------|-------|
| **Endpoint** | `/api/stripe/create-payment-intent` |
| **Method** | `POST` |
| **Authentication** | Bearer Token |
| **Priority** | 🔴 Critical |

#### Why This API is Required
- **Security:** The Stripe Secret Key (`sk_live_xxx`) should NEVER be exposed in the mobile app
- **Validation:** Server can validate booking details before creating payment
- **Control:** Server can add metadata, customer info, and receipt details
- **Compliance:** Required for PCI DSS compliance

#### Request Headers
```http
POST /api/stripe/create-payment-intent HTTP/1.1
Host: your-api-domain.com
Authorization: Bearer <user_token>
Content-Type: application/json
```

#### Request Body
```json
{
  "amount": 1350.00,
  "currency": "INR",
  "booking_id": 101,
  "customer_id": 1,
  "description": "Booking #101 - Home Cleaning Service",
  "customer_email": "john@example.com",
  "customer_name": "John Doe"
}
```

#### Request Fields
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `amount` | number | Yes | Payment amount in base currency (not cents/paise) |
| `currency` | string | Yes | Currency code (e.g., `INR`, `USD`) |
| `booking_id` | int | Yes | Booking ID for metadata |
| `customer_id` | int | Yes | Customer ID for Stripe customer creation |
| `description` | string | No | Payment description |
| `customer_email` | string | No | Customer email for receipt |
| `customer_name` | string | No | Customer name |

#### Response (Success - 200)
```json
{
  "status": true,
  "message": "Payment intent created successfully",
  "data": {
    "client_secret": "pi_3QxxxxxxxxxxxxxxABC_secret_xxxxxxxx",
    "payment_intent_id": "pi_3QxxxxxxxxxxxxxxABC",
    "ephemeral_key": "ek_test_xxxxxxxxxxxxxxxx",
    "customer_id": "cus_xxxxxxxxxxxxxxxx",
    "publishable_key": "pk_live_xxxxxxxxxxxxxxxx",
    "amount": 135000,
    "currency": "inr"
  }
}
```

#### Response Fields
| Field | Type | Description |
|-------|------|-------------|
| `client_secret` | string | Required for Payment Sheet initialization |
| `payment_intent_id` | string | PaymentIntent ID for tracking |
| `ephemeral_key` | string | Optional: For saved payment methods |
| `customer_id` | string | Stripe Customer ID |
| `publishable_key` | string | Stripe publishable key |
| `amount` | int | Amount in smallest currency unit |
| `currency` | string | Currency code (lowercase) |

#### Response (Error - 400)
```json
{
  "status": false,
  "message": "Failed to create payment intent",
  "error": "Invalid booking ID"
}
```

#### Backend Implementation (Laravel Example)
```php
public function createPaymentIntent(Request $request)
{
    $validated = $request->validate([
        'amount' => 'required|numeric|min:1',
        'currency' => 'required|string|size:3',
        'booking_id' => 'required|exists:bookings,id',
        'customer_id' => 'required|exists:users,id',
    ]);

    \Stripe\Stripe::setApiKey(config('services.stripe.secret'));

    // Get or create Stripe customer
    $customer = $this->getOrCreateStripeCustomer($validated['customer_id']);

    // Create PaymentIntent
    $paymentIntent = \Stripe\PaymentIntent::create([
        'amount' => intval($validated['amount'] * 100), // Convert to paise/cents
        'currency' => strtolower($validated['currency']),
        'customer' => $customer->id,
        'metadata' => [
            'booking_id' => $validated['booking_id'],
            'customer_id' => $validated['customer_id'],
        ],
        'description' => $request->description ?? "Booking #{$validated['booking_id']}",
    ]);

    // Create ephemeral key for saved cards
    $ephemeralKey = \Stripe\EphemeralKey::create(
        ['customer' => $customer->id],
        ['stripe_version' => '2023-10-16']
    );

    return response()->json([
        'status' => true,
        'data' => [
            'client_secret' => $paymentIntent->client_secret,
            'payment_intent_id' => $paymentIntent->id,
            'ephemeral_key' => $ephemeralKey->secret,
            'customer_id' => $customer->id,
            'publishable_key' => config('services.stripe.key'),
            'amount' => $paymentIntent->amount,
            'currency' => $paymentIntent->currency,
        ]
    ]);
}
```

---

### 4. Stripe Webhook API (NEW)

**Purpose:** Receives and processes webhook events from Stripe for payment status updates, ensuring payment status is always accurate even if the app closes after payment.

| Property | Value |
|----------|-------|
| **Endpoint** | `/api/stripe/webhook` |
| **Method** | `POST` |
| **Authentication** | Stripe Signature Verification |
| **Priority** | 🔴 Critical |

#### Why This API is Required
- **Reliability:** Ensures payment status is updated even if app crashes
- **Security:** Validates events are actually from Stripe
- **Reconciliation:** Handles edge cases like network failures
- **Refunds:** Automatically handles refund events

#### Request Headers (From Stripe)
```http
POST /api/stripe/webhook HTTP/1.1
Host: your-api-domain.com
Content-Type: application/json
Stripe-Signature: t=1234567890,v1=xxxxx,v0=xxxxx
```

#### Request Body (From Stripe)
```json
{
  "id": "evt_1234567890",
  "object": "event",
  "type": "payment_intent.succeeded",
  "data": {
    "object": {
      "id": "pi_3QxxxxxxxxxxxxxxABC",
      "amount": 135000,
      "currency": "inr",
      "status": "succeeded",
      "metadata": {
        "booking_id": "101",
        "customer_id": "1"
      }
    }
  }
}
```

#### Events to Handle
| Event Type | Action |
|------------|--------|
| `payment_intent.succeeded` | Update booking payment_status to "paid" |
| `payment_intent.payment_failed` | Update booking payment_status to "failed", notify user |
| `payment_intent.canceled` | Update booking payment_status to "cancelled" |
| `charge.refunded` | Update payment record, add refund entry |
| `charge.dispute.created` | Flag booking for review |

#### Response (Success - 200)
```json
{
  "received": true
}
```

> ⚠️ **Important:** Always return 200 status code to acknowledge receipt, even if processing fails. Handle errors internally.

#### Backend Implementation (Laravel Example)
```php
public function handleWebhook(Request $request)
{
    $payload = $request->getContent();
    $sigHeader = $request->header('Stripe-Signature');
    $webhookSecret = config('services.stripe.webhook_secret');

    try {
        $event = \Stripe\Webhook::constructEvent(
            $payload, $sigHeader, $webhookSecret
        );
    } catch (\Exception $e) {
        return response()->json(['error' => 'Invalid signature'], 400);
    }

    switch ($event->type) {
        case 'payment_intent.succeeded':
            $paymentIntent = $event->data->object;
            $this->handleSuccessfulPayment($paymentIntent);
            break;
            
        case 'payment_intent.payment_failed':
            $paymentIntent = $event->data->object;
            $this->handleFailedPayment($paymentIntent);
            break;
            
        case 'charge.refunded':
            $charge = $event->data->object;
            $this->handleRefund($charge);
            break;
    }

    return response()->json(['received' => true]);
}

private function handleSuccessfulPayment($paymentIntent)
{
    $bookingId = $paymentIntent->metadata->booking_id ?? null;
    
    if ($bookingId) {
        $booking = Booking::find($bookingId);
        if ($booking && $booking->payment_status !== 'paid') {
            $booking->update([
                'payment_status' => 'paid',
                'txn_id' => $paymentIntent->id,
            ]);
            
            // Create payment record if not exists
            Payment::updateOrCreate(
                ['txn_id' => $paymentIntent->id],
                [
                    'booking_id' => $bookingId,
                    'amount' => $paymentIntent->amount / 100,
                    'payment_method' => 'stripe',
                    'payment_status' => 'paid',
                ]
            );
        }
    }
}
```

#### Stripe Dashboard Webhook Configuration
1. Go to [Stripe Dashboard → Webhooks](https://dashboard.stripe.com/webhooks)
2. Click "Add endpoint"
3. Enter your endpoint URL: `https://your-domain.com/api/stripe/webhook`
4. Select events to listen to:
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
   - `payment_intent.canceled`
   - `charge.refunded`
5. Copy the webhook signing secret (`whsec_xxx`) to your backend config

---

## Stripe Direct APIs

### 5. Payment Intents API (Reference)

**Purpose:** Stripe's API for creating and managing PaymentIntents. This should be called from your backend, not directly from the Flutter app.

| Property | Value |
|----------|-------|
| **Base URL** | `https://api.stripe.com/v1` |
| **Endpoint** | `/payment_intents` |
| **Method** | `POST` |
| **Authentication** | Bearer Token (Secret Key) |

#### Current Implementation (⚠️ Insecure)
```dart
// stripe_service_new.dart - Line 66-76
Request request = http.Request(HttpMethodType.POST.name, Uri.parse(stripeURL));
request.bodyFields = {
  'amount': '${(totalAmount * 100).toInt()}',
  'currency': STRIPE_CURRENCY_CODE,
  'description': 'Name: ${appStore.userFullName} - Email: ${appStore.userEmail}',
};
request.headers.addAll(buildHeaderForStripe(stripePaymentKey)); // Using SECRET KEY!
```

#### Request Headers
```http
POST /v1/payment_intents HTTP/1.1
Host: api.stripe.com
Authorization: Bearer sk_live_xxxxxxxxxxxxxxxx
Content-Type: application/x-www-form-urlencoded
```

#### Request Body (URL Encoded)
```
amount=135000
currency=inr
description=Booking%20%23101
metadata[booking_id]=101
metadata[customer_id]=1
```

#### Response
```json
{
  "id": "pi_3QxxxxxxxxxxxxxxABC",
  "object": "payment_intent",
  "amount": 135000,
  "amount_capturable": 0,
  "amount_received": 0,
  "client_secret": "pi_3QxxxxxxxxxxxxxxABC_secret_xxxxxxxx",
  "currency": "inr",
  "status": "requires_payment_method",
  "livemode": true,
  "metadata": {
    "booking_id": "101",
    "customer_id": "1"
  }
}
```

> ⚠️ **Note:** This API call should be moved to the backend. The Flutter app should only use the `client_secret` returned by your backend.

---

## Configuration Requirements

### Flutter App Configuration

#### `lib/utils/configs.dart`
```dart
/// STRIPE PAYMENT DETAIL
const STRIPE_MERCHANT_COUNTRY_CODE = 'IN';  // Your merchant country
const STRIPE_CURRENCY_CODE = 'INR';          // Default currency

// For Production - Only Publishable Key
const STRIPE_PUBLISHABLE_KEY = 'pk_live_xxxxxxxxxxxxxxxx';

// ❌ REMOVE THESE FROM PRODUCTION
// const STRIPE_TEST_SECRET_KEY = 'sk_test_xxx';  // NEVER in app!
// const STRIPE_URL = 'https://api.stripe.com/v1/payment_intents';  // Use backend
```

### Backend Environment Variables

#### `.env` (Laravel/Node.js)
```env
# Stripe Configuration
STRIPE_PUBLISHABLE_KEY=pk_live_xxxxxxxxxxxxxxxx
STRIPE_SECRET_KEY=sk_live_xxxxxxxxxxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxxxx

# Currency Settings
STRIPE_CURRENCY=INR
STRIPE_MERCHANT_COUNTRY=IN
```

### Payment Gateway Database Configuration

The backend should store and return these Stripe settings via the `/api/payment-gateways` endpoint:

| Setting | Test Value | Live Value |
|---------|------------|------------|
| `stripe_url` | https://api.stripe.com/v1/payment_intents | Same |
| `stripe_key` | sk_test_xxx | sk_live_xxx |
| `stripe_publickey` | pk_test_xxx | pk_live_xxx |

---

## Security Considerations

### ❌ Current Security Issues

1. **Secret Key Exposure**
   - The Stripe Secret Key is currently in the Flutter app code
   - This is a major PCI compliance violation
   - Attackers could steal the key and make unauthorized charges

2. **Direct API Calls**
   - Flutter app directly calls Stripe API
   - No server-side validation of amounts

### ✅ Required Security Measures

1. **Move Secret Key to Backend**
   - Secret key should only exist on your server
   - Flutter app should only have the publishable key

2. **Implement Payment Intent API**
   - All PaymentIntent creation must go through your backend
   - Backend validates booking and amounts before creating intent

3. **Webhook Signature Verification**
   - Always verify Stripe webhook signatures
   - Use `Stripe\Webhook::constructEvent()` for validation

4. **HTTPS Only**
   - All API endpoints must use HTTPS
   - No HTTP endpoints for payment-related APIs

5. **Amount Verification**
   - Backend should calculate and verify amounts
   - Don't trust amounts sent from the client

---

## Implementation Checklist

### Backend Team

- [ ] Create `/api/stripe/create-payment-intent` endpoint
- [ ] Create `/api/stripe/webhook` endpoint
- [ ] Configure Stripe webhook in Stripe Dashboard
- [ ] Store webhook signing secret securely
- [ ] Implement signature verification for webhooks
- [ ] Add proper error handling and logging
- [ ] Update `/api/payment-gateways` to include all required settings
- [ ] Test with Stripe test mode
- [ ] Switch to live keys for production

### Flutter Team

- [ ] Remove `STRIPE_TEST_SECRET_KEY` from `configs.dart`
- [ ] Remove `STRIPE_URL` from `configs.dart`
- [ ] Update `stripe_service_new.dart` to call backend API
- [ ] Use only publishable key from backend response
- [ ] Handle new API response format
- [ ] Test payment flow end-to-end
- [ ] Add proper error handling for API failures

### DevOps Team

- [ ] Configure Stripe webhook URL in Stripe Dashboard
- [ ] Set up environment variables on production server
- [ ] Ensure HTTPS is configured for webhook endpoint
- [ ] Set up monitoring for webhook failures
- [ ] Configure Stripe API keys for production environment

---

## Testing

### Test Card Numbers

| Card Type | Number | CVC | Expiry |
|-----------|--------|-----|--------|
| Visa (Success) | 4242 4242 4242 4242 | Any 3 digits | Any future date |
| Visa (Declined) | 4000 0000 0000 0002 | Any 3 digits | Any future date |
| 3D Secure | 4000 0025 0000 3155 | Any 3 digits | Any future date |
| Insufficient Funds | 4000 0000 0000 9995 | Any 3 digits | Any future date |

### Webhook Testing

1. Install Stripe CLI: https://stripe.com/docs/stripe-cli
2. Forward webhooks to local: `stripe listen --forward-to localhost:8000/api/stripe/webhook`
3. Trigger test events: `stripe trigger payment_intent.succeeded`

---

## Support & Resources

- [Stripe API Documentation](https://stripe.com/docs/api)
- [Stripe Flutter SDK](https://pub.dev/packages/flutter_stripe)
- [Stripe Webhooks Guide](https://stripe.com/docs/webhooks)
- [PCI Compliance Guide](https://stripe.com/docs/security/guide)

---

> **Document Maintained By:** Development Team  
> **For Questions:** Contact the backend team lead
