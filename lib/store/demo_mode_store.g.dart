// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demo_mode_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DemoModeStore on _DemoModeStore, Store {
  Computed<bool>? _$isDemoLoggedInComputed;

  @override
  bool get isDemoLoggedIn =>
      (_$isDemoLoggedInComputed ??= Computed<bool>(() => super.isDemoLoggedIn,
              name: '_DemoModeStore.isDemoLoggedIn'))
          .value;

  late final _$isDemoModeAtom =
      Atom(name: '_DemoModeStore.isDemoMode', context: context);

  @override
  bool get isDemoMode {
    _$isDemoModeAtom.reportRead();
    return super.isDemoMode;
  }

  @override
  set isDemoMode(bool value) {
    _$isDemoModeAtom.reportWrite(value, super.isDemoMode, () {
      super.isDemoMode = value;
    });
  }

  late final _$demoUserAtom =
      Atom(name: '_DemoModeStore.demoUser', context: context);

  @override
  UserData? get demoUser {
    _$demoUserAtom.reportRead();
    return super.demoUser;
  }

  @override
  set demoUser(UserData? value) {
    _$demoUserAtom.reportWrite(value, super.demoUser, () {
      super.demoUser = value;
    });
  }

  late final _$demoBookingsAtom =
      Atom(name: '_DemoModeStore.demoBookings', context: context);

  @override
  ObservableList<BookingData> get demoBookings {
    _$demoBookingsAtom.reportRead();
    return super.demoBookings;
  }

  @override
  set demoBookings(ObservableList<BookingData> value) {
    _$demoBookingsAtom.reportWrite(value, super.demoBookings, () {
      super.demoBookings = value;
    });
  }

  late final _$demoNotificationsAtom =
      Atom(name: '_DemoModeStore.demoNotifications', context: context);

  @override
  ObservableList<NotificationData> get demoNotifications {
    _$demoNotificationsAtom.reportRead();
    return super.demoNotifications;
  }

  @override
  set demoNotifications(ObservableList<NotificationData> value) {
    _$demoNotificationsAtom.reportWrite(value, super.demoNotifications, () {
      super.demoNotifications = value;
    });
  }

  late final _$demoWalletHistoryAtom =
      Atom(name: '_DemoModeStore.demoWalletHistory', context: context);

  @override
  ObservableList<WalletDataElement> get demoWalletHistory {
    _$demoWalletHistoryAtom.reportRead();
    return super.demoWalletHistory;
  }

  @override
  set demoWalletHistory(ObservableList<WalletDataElement> value) {
    _$demoWalletHistoryAtom.reportWrite(value, super.demoWalletHistory, () {
      super.demoWalletHistory = value;
    });
  }

  late final _$demoWalletBalanceAtom =
      Atom(name: '_DemoModeStore.demoWalletBalance', context: context);

  @override
  num get demoWalletBalance {
    _$demoWalletBalanceAtom.reportRead();
    return super.demoWalletBalance;
  }

  @override
  set demoWalletBalance(num value) {
    _$demoWalletBalanceAtom.reportWrite(value, super.demoWalletBalance, () {
      super.demoWalletBalance = value;
    });
  }

  late final _$lastGeneratedOtpAtom =
      Atom(name: '_DemoModeStore.lastGeneratedOtp', context: context);

  @override
  String get lastGeneratedOtp {
    _$lastGeneratedOtpAtom.reportRead();
    return super.lastGeneratedOtp;
  }

  @override
  set lastGeneratedOtp(String value) {
    _$lastGeneratedOtpAtom.reportWrite(value, super.lastGeneratedOtp, () {
      super.lastGeneratedOtp = value;
    });
  }

  late final _$otpPhoneNumberAtom =
      Atom(name: '_DemoModeStore.otpPhoneNumber', context: context);

  @override
  String get otpPhoneNumber {
    _$otpPhoneNumberAtom.reportRead();
    return super.otpPhoneNumber;
  }

  @override
  set otpPhoneNumber(String value) {
    _$otpPhoneNumberAtom.reportWrite(value, super.otpPhoneNumber, () {
      super.otpPhoneNumber = value;
    });
  }

  late final _$otpCountryCodeAtom =
      Atom(name: '_DemoModeStore.otpCountryCode', context: context);

  @override
  String get otpCountryCode {
    _$otpCountryCodeAtom.reportRead();
    return super.otpCountryCode;
  }

  @override
  set otpCountryCode(String value) {
    _$otpCountryCodeAtom.reportWrite(value, super.otpCountryCode, () {
      super.otpCountryCode = value;
    });
  }

  late final _$_DemoModeStoreActionController =
      ActionController(name: '_DemoModeStore', context: context);

  @override
  void setDemoMode(bool value) {
    final _$actionInfo = _$_DemoModeStoreActionController.startAction(
        name: '_DemoModeStore.setDemoMode');
    try {
      return super.setDemoMode(value);
    } finally {
      _$_DemoModeStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void createDemoUser(
      {required String firstName,
      required String lastName,
      required String email,
      String? phone,
      String? password,
      String? profileImage}) {
    final _$actionInfo = _$_DemoModeStoreActionController.startAction(
        name: '_DemoModeStore.createDemoUser');
    try {
      return super.createDemoUser(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          password: password,
          profileImage: profileImage);
    } finally {
      _$_DemoModeStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void createDemoUserFromOtp(
      {required String phoneNumber, required String countryCode}) {
    final _$actionInfo = _$_DemoModeStoreActionController.startAction(
        name: '_DemoModeStore.createDemoUserFromOtp');
    try {
      return super.createDemoUserFromOtp(
          phoneNumber: phoneNumber, countryCode: countryCode);
    } finally {
      _$_DemoModeStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateDemoUserProfile(
      {String? firstName,
      String? lastName,
      String? email,
      String? phone,
      String? address,
      String? profileImage}) {
    final _$actionInfo = _$_DemoModeStoreActionController.startAction(
        name: '_DemoModeStore.updateDemoUserProfile');
    try {
      return super.updateDemoUserProfile(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          address: address,
          profileImage: profileImage);
    } finally {
      _$_DemoModeStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void logoutDemoUser() {
    final _$actionInfo = _$_DemoModeStoreActionController.startAction(
        name: '_DemoModeStore.logoutDemoUser');
    try {
      return super.logoutDemoUser();
    } finally {
      _$_DemoModeStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addDemoBooking(BookingData booking) {
    final _$actionInfo = _$_DemoModeStoreActionController.startAction(
        name: '_DemoModeStore.addDemoBooking');
    try {
      return super.addDemoBooking(booking);
    } finally {
      _$_DemoModeStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateDemoBookingStatus(int bookingId, String newStatus) {
    final _$actionInfo = _$_DemoModeStoreActionController.startAction(
        name: '_DemoModeStore.updateDemoBookingStatus');
    try {
      return super.updateDemoBookingStatus(bookingId, newStatus);
    } finally {
      _$_DemoModeStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addDemoNotification(NotificationData notification) {
    final _$actionInfo = _$_DemoModeStoreActionController.startAction(
        name: '_DemoModeStore.addDemoNotification');
    try {
      return super.addDemoNotification(notification);
    } finally {
      _$_DemoModeStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addDemoWalletTransaction(
      {required num amount,
      required String type,
      required String description}) {
    final _$actionInfo = _$_DemoModeStoreActionController.startAction(
        name: '_DemoModeStore.addDemoWalletTransaction');
    try {
      return super.addDemoWalletTransaction(
          amount: amount, type: type, description: description);
    } finally {
      _$_DemoModeStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String generateDemoOtp() {
    final _$actionInfo = _$_DemoModeStoreActionController.startAction(
        name: '_DemoModeStore.generateDemoOtp');
    try {
      return super.generateDemoOtp();
    } finally {
      _$_DemoModeStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isDemoMode: ${isDemoMode},
demoUser: ${demoUser},
demoBookings: ${demoBookings},
demoNotifications: ${demoNotifications},
demoWalletHistory: ${demoWalletHistory},
demoWalletBalance: ${demoWalletBalance},
lastGeneratedOtp: ${lastGeneratedOtp},
otpPhoneNumber: ${otpPhoneNumber},
otpCountryCode: ${otpCountryCode},
isDemoLoggedIn: ${isDemoLoggedIn}
    ''';
  }
}
