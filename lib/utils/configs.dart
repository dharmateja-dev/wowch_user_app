import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const APP_NAME = 'Wowch User App';
const APP_NAME_TAG_LINE = 'On-Demand Services App';
var defaultPrimaryColor = Color(0xFF2E6B4F);

// Don't add slash at the end of the url
// Using a public API for testing/demo purposes
const DOMAIN_URL = "https://jsonplaceholder.typicode.com";
const BASE_URL = '$DOMAIN_URL/api/';

const DEFAULT_LANGUAGE = 'en';

//Note: For FIREBASE_SERVER_CLIENT_ID ---> Go to android/app/google-services.json
// - Find press ctrl+F and look for "client_type": 3
// "client_id" in same object has be pasted here
const FIREBASE_SERVER_CLIENT_ID =
    '438524885554-57q5kelj6uhtjnbebkb8o82mbb3262gt.apps.googleusercontent.com';

/// You can change this to your Provider App package name
/// This will be used in Registered As Partner in Sign In Screen where your users can redirect to the Play/App Store for Provider App
/// You can specify in Admin Panel, These will be used if you don't specify in Admin Panel
const PROVIDER_PACKAGE_NAME = 'com.iqonic.provider';
const IOS_LINK_FOR_PARTNER =
    "https://apps.apple.com/in/app/handyman-provider-app/id1596025324";

const IOS_LINK_FOR_USER =
    'https://apps.apple.com/us/app/handyman-service-user/id1591427211';

const DASHBOARD_AUTO_SLIDER_SECOND = 5;
const OTP_TEXT_FIELD_LENGTH = 6;

const TERMS_CONDITION_URL = 'https://iqonic.design/terms-of-use/';
const PRIVACY_POLICY_URL = 'https://iqonic.design/privacy-policy/';
const HELP_AND_SUPPORT_URL = 'https://iqonic.design/privacy-policy/';
const REFUND_POLICY_URL =
    'https://iqonic.design/licensing-terms-more/#refund-policy';
const INQUIRY_SUPPORT_EMAIL = 'hello@iqonic.design';

/// You can add help line number here for contact. It's demo number
const HELP_LINE_NUMBER = '+15265897485';

//Airtel Money Payments
///It Supports ["UGX", "NGN", "TZS", "KES", "RWF", "ZMW", "CFA", "XOF", "XAF", "CDF", "USD", "XAF", "SCR", "MGA", "MWK"]
const AIRTEL_CURRENCY_CODE = "MWK";
const AIRTEL_COUNTRY_CODE = "MW";
const AIRTEL_TEST_BASE_URL = 'https://openapiuat.airtel.africa/'; //Test Url
const AIRTEL_LIVE_BASE_URL = 'https://openapi.airtel.africa/'; // Live Url

/// PAYSTACK PAYMENT DETAIL
const PAYSTACK_CURRENCY_CODE = 'NGN';

/// Nigeria Currency

/// STRIPE PAYMENT DETAIL
const STRIPE_MERCHANT_COUNTRY_CODE = 'IN';
const STRIPE_CURRENCY_CODE = 'INR';
// IMPORTANT: Never commit secret keys to version control!
// Public key can be in code (it's meant to be public)
const STRIPE_TEST_PUBLIC_KEY =
    'pk_test_51Sgs0YRwxGwHFvGQyUpk5d5RLA4xiDvKV5E8LTPzr3hGVyEA13SXsULb6Ig8nQj1quzuP3AR5Urfmf1aaAUp3CTP00WqY1yzQz';

// Secret key loaded from .env file (added to .gitignore)
// Create a .env file in the project root with: STRIPE_SECRET_KEY=sk_test_your_key_here
String getStripeSecretKey() => dotenv.get('STRIPE_SECRET_KEY', fallback: '');
const STRIPE_URL = 'https://api.stripe.com/v1/payment_intents';

/// RAZORPAY PAYMENT DETAIL
const RAZORPAY_CURRENCY_CODE = 'INR';

/// PAYPAL PAYMENT DETAIL
const PAYPAL_CURRENCY_CODE = 'USD';

/// SADAD PAYMENT DETAIL
const SADAD_API_URL = 'https://api-s.sadad.qa';
const SADAD_PAY_URL = "https://d.sadad.qa";

DateTime todayDate = DateTime(2022, 8, 24);

Country defaultCountry() {
  return Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 91,
    geographic: true,
    level: 1,
    name: 'India',
    example: '9123456789',
    displayName: 'India (IN) [+91]',
    displayNameNoCountryCode: 'India (IN)',
    e164Key: '91-IN-0',
    fullExampleWithPlusSign: '+919123456789',
  );
}

//Chat Module File Upload Configs
const chatFilesAllowedExtensions = [
  'jpg', 'jpeg', 'png', 'gif', 'webp', // Images
  'pdf', 'txt', // Documents
  'mkv', 'mp4', // Video
  'mp3', // Audio
];

const max_acceptable_file_size = 5; //Size in Mb
