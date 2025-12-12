import 'package:booking_system_flutter/model/booking_data_model.dart';
import 'package:booking_system_flutter/model/notification_model.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/model/user_wallet_history.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:mobx/mobx.dart';
import 'package:booking_system_flutter/model/service_detail_response.dart';
import 'dart:math';

part 'demo_mode_store.g.dart';

/// Global flag to enable/disable demo mode
/// Set to true for demo without backend, false for production
const bool DEMO_MODE_ENABLED = true;

/// Demo OTP code that will be displayed on screen for validation
const String DEMO_OTP_CODE = '123456';

class DemoModeStore = _DemoModeStore with _$DemoModeStore;

abstract class _DemoModeStore with Store {
  /// Demo mode enabled flag
  @observable
  bool isDemoMode = DEMO_MODE_ENABLED;

  /// Demo user data
  @observable
  UserData? demoUser;

  /// Demo bookings list
  @observable
  ObservableList<BookingData> demoBookings = ObservableList<BookingData>();

  /// Demo notifications list
  @observable
  ObservableList<NotificationData> demoNotifications =
      ObservableList<NotificationData>();

  /// Demo wallet history
  @observable
  ObservableList<WalletDataElement> demoWalletHistory =
      ObservableList<WalletDataElement>();

  /// Demo wallet balance
  @observable
  num demoWalletBalance = 5000.0;

  /// Last generated OTP for display
  @observable
  String lastGeneratedOtp = DEMO_OTP_CODE;

  /// Phone number used for OTP login
  @observable
  String otpPhoneNumber = '';

  /// Country code for OTP
  @observable
  String otpCountryCode = '+91';

  /// Check if user is logged in (demo mode)
  @computed
  bool get isDemoLoggedIn => demoUser != null;

  /// Set demo mode
  @action
  void setDemoMode(bool value) {
    isDemoMode = value;
  }

  /// Get a random profile image
  String _getRandomProfileImage() {
    final List<String> profileImages = [
      'https://i.pravatar.cc/150?img=1',
      'https://i.pravatar.cc/150?img=2',
      'https://i.pravatar.cc/150?img=3',
      'https://i.pravatar.cc/150?img=4',
      'https://i.pravatar.cc/150?img=5',
      'https://i.pravatar.cc/150?img=10',
      'https://i.pravatar.cc/150?img=12',
      'https://i.pravatar.cc/150?img=20',
      'https://i.pravatar.cc/150?img=32',
      'https://i.pravatar.cc/150?img=44',
    ];
    return profileImages[Random().nextInt(profileImages.length)];
  }

  /// Create demo user from sign up/sign in data
  @action
  void createDemoUser({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? password,
    String? profileImage,
  }) {
    final userId = DateTime.now().millisecondsSinceEpoch % 100000;
    demoUser = UserData(
      id: userId,
      firstName: firstName,
      lastName: lastName,
      displayName: '$firstName $lastName',
      email: email,
      contactNumber: phone ?? '',
      profileImage: (profileImage != null && profileImage.isNotEmpty)
          ? profileImage
          : _getRandomProfileImage(),
      userType: USER_TYPE_USER,
      status: 1,
      loginType: LOGIN_TYPE_USER,
      uid: 'demo_$userId',
      address: '123 Demo Street, Demo City',
    );

    // Initialize demo data for the user
    _initializeDemoNotifications();
    _initializeDemoWalletHistory();
    _initializeDemoBookings();
  }

  /// Create demo user from OTP login
  @action
  void createDemoUserFromOtp({
    required String phoneNumber,
    required String countryCode,
  }) {
    otpPhoneNumber = phoneNumber;
    otpCountryCode = countryCode;

    final userId = DateTime.now().millisecondsSinceEpoch % 100000;
    demoUser = UserData(
      id: userId,
      firstName: 'Demo',
      lastName: 'User',
      displayName: 'Demo User',
      email: 'demo_$phoneNumber@example.com',
      contactNumber: '$countryCode$phoneNumber',
      profileImage: _getRandomProfileImage(),
      userType: USER_TYPE_USER,
      status: 1,
      loginType: LOGIN_TYPE_OTP,
      uid: 'demo_otp_$userId',
      address: '123 Demo Street, Demo City',
    );

    // Initialize demo data for the user
    _initializeDemoNotifications();
    _initializeDemoWalletHistory();
    _initializeDemoBookings();
  }

  /// Update demo user profile
  @action
  void updateDemoUserProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? profileImage,
  }) {
    if (demoUser != null) {
      demoUser = UserData(
        id: demoUser!.id,
        firstName: firstName ?? demoUser!.firstName,
        lastName: lastName ?? demoUser!.lastName,
        displayName:
            '${firstName ?? demoUser!.firstName} ${lastName ?? demoUser!.lastName}',
        email: email ?? demoUser!.email,
        contactNumber: phone ?? demoUser!.contactNumber,
        profileImage: profileImage ?? demoUser!.profileImage,
        userType: demoUser!.userType,
        status: demoUser!.status,
        loginType: demoUser!.loginType,
        uid: demoUser!.uid,
        address: address ?? demoUser!.address,
      );
    }
  }

  /// Logout demo user
  @action
  void logoutDemoUser() {
    demoUser = null;
    demoBookings.clear();
    demoNotifications.clear();
    demoWalletHistory.clear();
    demoWalletBalance = 5000.0;
  }

  /// Initialize demo bookings
  void _initializeDemoBookings() {
    final now = DateTime.now();

    demoBookings.addAll([
      // Pending Booking
      BookingData(
        id: 12345,
        serviceName: "Home Deep Cleaning",
        serviceId: 101,
        customerId: demoUser?.id,
        customerName: demoUser?.displayName,
        providerId: 1,
        providerName: "CleanPro Services",
        providerImage: "",
        status: BOOKING_STATUS_PENDING,
        statusLabel: "Pending",
        date: now.add(Duration(days: 2)).toString(),
        bookingSlot: "10:00:00",
        address: "123 Main Street, City Center",
        description: "Deep cleaning for 3BHK apartment",
        type: SERVICE_TYPE_FIXED,
        amount: 1500,
        totalAmount: 1650,
        discount: 10,
        quantity: 1,
        serviceAttachments: [
          "https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400"
        ],
        handyman: [],
      ),
      // Accepted Booking (with coupon)
      BookingData(
        id: 12346,
        serviceName: "AC Repair & Service",
        serviceId: 102,
        customerId: demoUser?.id,
        customerName: demoUser?.displayName,
        providerId: 2,
        providerName: "CoolTech Solutions",
        providerImage: "",
        status: BOOKING_STATUS_ACCEPT,
        statusLabel: "Accepted",
        date: now.add(Duration(days: 1)).toString(),
        bookingSlot: "14:00:00",
        address: "456 Park Avenue, Downtown",
        description: "AC not cooling properly",
        type: SERVICE_TYPE_FIXED,
        amount: 800,
        totalAmount: 880,
        discount: 0,
        quantity: 1,
        couponData: CouponData(
          id: 1,
          code: "QW3D4RTY",
          discount: 100,
          discountType: COUPON_TYPE_FIXED,
          expireDate: DateTime.now().add(Duration(days: 30)).toIso8601String(),
          status: 1,
          isApplied: true,
        ),
        taxes: [
          TaxData(
            id: 1,
            title: "GST",
            type: "percent",
            value: 10,
            totalCalculatedValue: 80.0,
          ),
        ],
        serviceAttachments: [
          "https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=400"
        ],
        handyman: [],
      ),
      // In Progress Booking
      BookingData(
        id: 12347,
        serviceName: "Plumbing Repair",
        serviceId: 103,
        customerId: demoUser?.id,
        customerName: demoUser?.displayName,
        providerId: 3,
        providerName: "QuickFix Plumbers",
        providerImage: "",
        status: BOOKING_STATUS_IN_PROGRESS,
        statusLabel: "In Progress",
        date: now.toString(),
        bookingSlot: "09:00:00",
        address: "789 Lake Road, Suburb",
        description: "Bathroom pipe leakage",
        type: SERVICE_TYPE_HOURLY,
        amount: 500,
        totalAmount: 550,
        discount: 0,
        quantity: 1,
        durationDiff: "3600",
        startAt: now.subtract(Duration(hours: 1)).toString(),
        serviceAttachments: [
          "https://images.unsplash.com/photo-1606146485652-75b352ce408a?w=400"
        ],
        handyman: [],
      ),
      // Completed Booking
      BookingData(
        id: 12348,
        serviceName: "Electrical Wiring",
        serviceId: 104,
        customerId: demoUser?.id,
        customerName: demoUser?.displayName,
        providerId: 4,
        providerName: "PowerUp Electricians",
        providerImage: "",
        status: BOOKING_STATUS_COMPLETED,
        statusLabel: "Completed",
        date: now.subtract(Duration(days: 3)).toString(),
        bookingSlot: "11:00:00",
        address: "321 Hill Street, Uptown",
        description: "New socket installation",
        type: SERVICE_TYPE_FIXED,
        amount: 1200,
        totalAmount: 1320,
        discount: 5,
        quantity: 1,
        paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
        paymentMethod: PAYMENT_METHOD_COD,
        paymentId: 9001,
        totalReview: 25,
        totalRating: 4.8,
        serviceAttachments: [
          "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400"
        ],
        handyman: [],
      ),
      // Cancelled Booking
      BookingData(
        id: 12349,
        serviceName: "Carpet Cleaning",
        serviceId: 105,
        customerId: demoUser?.id,
        customerName: demoUser?.displayName,
        providerId: 5,
        providerName: "SpotlessClean",
        providerImage: "",
        status: BOOKING_STATUS_CANCELLED,
        statusLabel: "Cancelled",
        date: now.subtract(Duration(days: 5)).toString(),
        bookingSlot: "15:00:00",
        address: "654 Garden Lane, Eastside",
        description: "Full carpet cleaning",
        type: SERVICE_TYPE_FIXED,
        amount: 2000,
        totalAmount: 2000,
        discount: 0,
        quantity: 1,
        reason: "Customer requested cancellation",
        serviceAttachments: [
          "https://images.unsplash.com/photo-1558317374-067fb5f30001?w=400"
        ],
        handyman: [],
      ),

      // On Going
      BookingData(
        id: 12350,
        serviceName: "Painting Service",
        serviceId: 106,
        customerId: demoUser?.id,
        customerName: demoUser?.displayName,
        providerId: 6,
        providerName: "ColorPro Painters",
        providerImage: "",
        status: BOOKING_STATUS_ON_GOING,
        statusLabel: "On Going",
        date: now.toString(),
        bookingSlot: "12:00:00",
        address: "999 Art Avenue",
        description: "Living room painting",
        type: SERVICE_TYPE_FIXED,
        amount: 2500,
        totalAmount: 2500,
        quantity: 1,
        serviceAttachments: [],
        handyman: [],
      ),
      // Hold
      BookingData(
        id: 12351,
        serviceName: "Roof Repair",
        serviceId: 107,
        customerId: demoUser?.id,
        customerName: demoUser?.displayName,
        providerId: 7,
        providerName: "Roofing Experts",
        providerImage: "",
        status: BOOKING_STATUS_HOLD,
        statusLabel: "Hold",
        date: now.subtract(Duration(days: 1)).toString(),
        bookingSlot: "10:00:00",
        address: "555 High Street",
        description: "Roof leak repair - Material pending",
        type: SERVICE_TYPE_FIXED,
        amount: 3000,
        totalAmount: 3000,
        quantity: 1,
        serviceAttachments: [],
        handyman: [],
      ),
      // Rejected
      BookingData(
        id: 12352,
        serviceName: "Gardening",
        serviceId: 108,
        customerId: demoUser?.id,
        customerName: demoUser?.displayName,
        providerId: 8,
        providerName: "Green Thumb",
        providerImage: "",
        status: BOOKING_STATUS_REJECTED,
        statusLabel: "Rejected",
        date: now.subtract(Duration(days: 2)).toString(),
        bookingSlot: "08:00:00",
        address: "777 Garden Way",
        description: "Lawn mowing",
        type: SERVICE_TYPE_HOURLY,
        amount: 50,
        totalAmount: 100,
        quantity: 1,
        serviceAttachments: [],
        handyman: [],
      ),
      // Failed
      BookingData(
        id: 12353,
        serviceName: "Smart Home Setup",
        serviceId: 109,
        customerId: demoUser?.id,
        customerName: demoUser?.displayName,
        providerId: 9,
        providerName: "Tech Wizards",
        providerImage: "",
        status: BOOKING_STATUS_FAILED,
        statusLabel: "Failed",
        date: now.subtract(Duration(days: 2)).toString(),
        bookingSlot: "16:00:00",
        address: "888 Digital Drive",
        description: "Smart lock installation failed",
        type: SERVICE_TYPE_FIXED,
        amount: 500,
        totalAmount: 500,
        quantity: 1,
        serviceAttachments: [],
        handyman: [],
      ),
      // Pending Approval
      BookingData(
        id: 12354,
        serviceName: "Office Cleaning",
        serviceId: 110,
        customerId: demoUser?.id,
        customerName: demoUser?.displayName,
        providerId: 10,
        providerName: "Corporate Cleaners",
        providerImage: "",
        status: BOOKING_STATUS_PENDING_APPROVAL,
        statusLabel: "Pending Approval",
        date: now.add(Duration(days: 3)).toString(),
        bookingSlot: "18:00:00",
        address: "101 Business Park",
        description: "Full office cleaning required",
        type: SERVICE_TYPE_FIXED,
        amount: 5000,
        totalAmount: 5000,
        quantity: 1,
        serviceAttachments: [],
        handyman: [],
      ),
      // Waiting Advanced Payment
      BookingData(
        id: 12355,
        serviceName: "Interior Design Consultation",
        serviceId: 111,
        customerId: demoUser?.id,
        customerName: demoUser?.displayName,
        providerId: 11,
        providerName: "Creative Spaces",
        providerImage: "",
        status: BOOKING_STATUS_WAITING_ADVANCED_PAYMENT,
        statusLabel: "Waiting Payment",
        date: now.add(Duration(days: 4)).toString(),
        bookingSlot: "11:00:00",
        address: "202 Design Studio",
        description: "Initial consultation",
        type: SERVICE_TYPE_FIXED,
        amount: 2000,
        totalAmount: 2000,
        quantity: 1,
        serviceAttachments: [],
        handyman: [],
      ),
    ]);
  }

  /// Add a demo booking
  @action
  void addDemoBooking(BookingData booking) {
    demoBookings.insert(0, booking);
  }

  /// Update a demo booking status
  @action
  void updateDemoBookingStatus(int bookingId, String newStatus) {
    final index = demoBookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final booking = demoBookings[index];
      booking.status = newStatus;
      booking.statusLabel = newStatus.toBookingStatus();
      demoBookings[index] = booking;
    }
  }

  /// Add demo notification
  @action
  void addDemoNotification(NotificationData notification) {
    demoNotifications.insert(0, notification);
  }

  /// Add wallet transaction
  @action
  void addDemoWalletTransaction({
    required num amount,
    required String type,
    required String description,
  }) {
    final now = DateTime.now();
    final transaction = WalletDataElement(
      id: now.millisecondsSinceEpoch % 100000,
      datetime: now.toIso8601String(),
      activityType: 'wallet',
      activityMessage: description,
      activityData: ActivityData(
        title: type == 'credit' ? 'Credit' : 'Debit',
        userId: demoUser?.id ?? 0,
        amount: amount,
        creditDebitAmount: amount,
        transactionType: type == 'credit' ? 'credit' : PAYMENT_STATUS_DEBIT,
      ),
    );

    demoWalletHistory.insert(0, transaction);

    if (type == 'credit' || type == 'wallet_top_up') {
      demoWalletBalance += amount;
    } else if (type == 'debit' || type == 'wallet_payout') {
      demoWalletBalance -= amount;
    }
  }

  /// Generate a new OTP (always returns demo OTP)
  @action
  String generateDemoOtp() {
    lastGeneratedOtp = DEMO_OTP_CODE;
    return lastGeneratedOtp;
  }

  /// Verify OTP
  bool verifyDemoOtp(String enteredOtp) {
    return enteredOtp == lastGeneratedOtp;
  }

  /// Initialize demo notifications
  void _initializeDemoNotifications() {
    final now = DateTime.now();

    // Notification 1
    demoNotifications.add(
      NotificationData(
        id: '1',
        createdAt: now.toIso8601String(),
        data: NotificationInnerData(
          id: 0,
          notificationType: 'welcome',
          message: 'Welcome to our service! Start exploring.',
          subject: 'Welcome',
        ),
      ),
    );

    // Notification 2
    demoNotifications.add(
      NotificationData(
        id: '2',
        createdAt: now.subtract(Duration(hours: 2)).toIso8601String(),
        data: NotificationInnerData(
          id: 12345,
          notificationType: NOTIFICATION_TYPE_BOOKING,
          message: 'Your booking for Home Cleaning has been confirmed.',
          subject: 'Booking Confirmed',
        ),
      ),
    );

    // Notification 3
    demoNotifications.add(
      NotificationData(
        id: '3',
        readAt: now.subtract(Duration(days: 1)).toIso8601String(),
        createdAt: now.subtract(Duration(days: 1)).toIso8601String(),
        data: NotificationInnerData(
          id: 0,
          notificationType: 'promotion',
          message: 'Special offer: Get 20% off on all services this week!',
          subject: 'Special Offer',
        ),
      ),
    );

    // Notification 4
    demoNotifications.add(
      NotificationData(
        id: '4',
        createdAt: now.subtract(Duration(days: 2)).toIso8601String(),
        data: NotificationInnerData(
          id: 0,
          notificationType: NOTIFICATION_TYPE_WALLET,
          message: 'Your wallet has been credited with ₹500 bonus.',
          subject: 'Wallet Credit',
        ),
      ),
    );
  }

  /// Initialize demo wallet history
  void _initializeDemoWalletHistory() {
    final now = DateTime.now();

    // Transaction 1
    demoWalletHistory.add(
      WalletDataElement(
        id: 1,
        datetime: now.subtract(Duration(days: 1)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Welcome Bonus credited to your wallet',
        activityData: ActivityData(
          title: 'Welcome Bonus',
          amount: 500,
          creditDebitAmount: 500,
          transactionType: 'credit',
        ),
      ),
    );

    // Transaction 2
    demoWalletHistory.add(
      WalletDataElement(
        id: 2,
        datetime: now.subtract(Duration(days: 3)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Wallet Top-up successful',
        activityData: ActivityData(
          title: 'Wallet Top-up',
          amount: 2000,
          creditDebitAmount: 2000,
          transactionType: 'credit',
        ),
      ),
    );

    // Transaction 3
    demoWalletHistory.add(
      WalletDataElement(
        id: 3,
        datetime: now.subtract(Duration(days: 5)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Referral Bonus',
        activityData: ActivityData(
          title: 'Referral Bonus',
          amount: 200,
          creditDebitAmount: 200,
          transactionType: 'credit',
        ),
      ),
    );

    // Transaction 4
    demoWalletHistory.add(
      WalletDataElement(
        id: 4,
        datetime: now.subtract(Duration(days: 7)).toIso8601String(),
        activityType: 'wallet',
        activityMessage: 'Initial Credit',
        activityData: ActivityData(
          title: 'Initial Credit',
          amount: 2300,
          creditDebitAmount: 2300,
          transactionType: 'credit',
        ),
      ),
    );
  }
}

/// Extension for booking status display
extension BookingStatusExtension on String {
  String toBookingStatus() {
    switch (this) {
      case BOOKING_STATUS_PENDING:
        return 'Pending';
      case BOOKING_STATUS_ACCEPT:
        return 'Accepted';
      case BOOKING_STATUS_ON_GOING:
        return 'On Going';
      case BOOKING_STATUS_IN_PROGRESS:
        return 'In Progress';
      case BOOKING_STATUS_HOLD:
        return 'Hold';
      case BOOKING_STATUS_CANCELLED:
        return 'Cancelled';
      case BOOKING_STATUS_REJECTED:
        return 'Rejected';
      case BOOKING_STATUS_FAILED:
        return 'Failed';
      case BOOKING_STATUS_COMPLETED:
        return 'Completed';
      case BOOKING_STATUS_PENDING_APPROVAL:
        return 'Pending Approval';
      case BOOKING_STATUS_WAITING_ADVANCED_PAYMENT:
        return 'Waiting';
      default:
        return this;
    }
  }
}
