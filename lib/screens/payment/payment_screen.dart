import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/booking_detail_model.dart';
import 'package:booking_system_flutter/model/booking_data_model.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/screens/booking/component/price_common_widget.dart';
import 'package:booking_system_flutter/screens/wallet/user_wallet_balance_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/extensions/num_extenstions.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/app_common_dialog.dart';
import '../../component/base_scaffold_widget.dart';
import '../../component/empty_error_state_widget.dart';
import '../../component/wallet_balance_component.dart';
import '../../model/payment_gateway_response.dart';
import '../../network/rest_apis.dart';
import '../../services/airtel_money/airtel_money_service.dart';
import '../../services/cinet_pay_services_new.dart';
import '../../services/flutter_wave_service_new.dart';
import '../../services/midtrans_service.dart';
import '../../services/paypal_service.dart';
import '../../services/paystack_service.dart';
import '../../services/phone_pe/phone_pe_service.dart';
import '../../services/razorpay_service_new.dart';
import '../../services/sadad_services_new.dart';
import '../../services/stripe_service_new.dart';
import '../../utils/configs.dart';
import '../../utils/model_keys.dart';
import '../dashboard/dashboard_screen.dart';

class PaymentScreen extends StatefulWidget {
  final BookingDetailResponse bookings;
  final bool isForAdvancePayment;
  final bool isDemoMode;

  PaymentScreen({
    required this.bookings,
    this.isForAdvancePayment = false,
    this.isDemoMode = false,
  });

  /// Factory method to create PaymentScreen with dummy data for demo purposes
  factory PaymentScreen.demo() {
    return PaymentScreen(
      bookings: _createDummyBookingData(),
      isForAdvancePayment: false,
      isDemoMode: true,
    );
  }

  /// Creates dummy booking data for demo/testing purposes
  static BookingDetailResponse _createDummyBookingData() {
    // Create dummy service data
    ServiceData dummyService = ServiceData(
      id: 1,
      name: 'Home Cleaning Service',
      price: 1500,
      discount: 10,
      type: SERVICE_TYPE_FIXED,
      status: 1,
      description: 'Professional home cleaning service',
      isFeatured: 1,
      providerId: 1,
      categoryId: 1,
      categoryName: 'Cleaning',
      subCategoryName: 'Home Cleaning',
      duration: '2',
      isEnableAdvancePayment: 0, // Not advance payment
      advancePaymentPercentage: 0,
    );

    // Create dummy booking data
    BookingData dummyBookingDetail = BookingData(
      id: 101,
      serviceId: 1,
      serviceName: 'Home Cleaning Service',
      customerId: 1,
      customerName: 'John Doe',
      providerId: 1,
      providerName: 'CleanPro Services',
      providerImage: 'https://i.pravatar.cc/150?img=3',
      status: BookingStatusKeys.pending,
      statusLabel: 'Pending',
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      address: '123 Main Street, City, Country',
      totalAmount: 1350, // After 10% discount
      amount: 1500,
      discount: 10,
      type: SERVICE_TYPE_FIXED,
      paymentStatus: SERVICE_PAYMENT_STATUS_PENDING,
      paidAmount: 0,
      quantity: 1,
      taxes: [],
    );

    // Create dummy provider data
    UserData dummyProvider = UserData(
      id: 1,
      displayName: 'CleanPro Services',
      firstName: 'Clean',
      lastName: 'Pro',
      email: 'cleanpro@example.com',
      contactNumber: '+1234567890',
      profileImage: 'https://i.pravatar.cc/150?img=3',
      providersServiceRating: 4.5,
    );

    // Create dummy customer data
    UserData dummyCustomer = UserData(
      id: 1,
      displayName: 'John Doe',
      firstName: 'John',
      lastName: 'Doe',
      email: 'john@example.com',
      contactNumber: '+1234567890',
      profileImage: 'https://i.pravatar.cc/150?img=5',
    );

    return BookingDetailResponse(
      bookingDetail: dummyBookingDetail,
      service: dummyService,
      providerData: dummyProvider,
      customer: dummyCustomer,
      couponData: null,
      handymanData: [],
      ratingData: [],
      bookingActivity: [],
      taxes: [],
    );
  }

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Future<List<PaymentSetting>>? future;

  PaymentSetting? currentPaymentMethod;

  num totalAmount = 0;
  num? advancePaymentAmount;

  @override
  void initState() {
    super.initState();
    init();

    if (widget.bookings.service!.isAdvancePayment &&
        widget.bookings.service!.isFixedService &&
        !widget.bookings.service!.isFreeService &&
        widget.bookings.bookingDetail!.bookingPackage == null) {
      if (widget.bookings.bookingDetail!.paidAmount.validate() == 0) {
        advancePaymentAmount =
            widget.bookings.bookingDetail!.totalAmount.validate() *
                widget.bookings.service!.advancePaymentPercentage.validate() /
                100;
        totalAmount = widget.bookings.bookingDetail!.totalAmount.validate() *
            widget.bookings.service!.advancePaymentPercentage.validate() /
            100;
      } else {
        totalAmount = widget.bookings.bookingDetail!.totalAmount.validate() -
            widget.bookings.bookingDetail!.paidAmount.validate();
      }
    } else {
      totalAmount = widget.bookings.bookingDetail!.totalAmount.validate();
    }

    log(totalAmount);
  }

  void init() async {
    log("ISaDVANCE${widget.isForAdvancePayment}");

    if (widget.isDemoMode) {
      // Use dummy payment methods for demo mode
      future = Future.value(_getDummyPaymentMethods());
    } else {
      future = getPaymentGateways(requireCOD: !widget.isForAdvancePayment);
    }
    setState(() {});
  }

  /// Returns dummy payment methods for demo mode
  List<PaymentSetting> _getDummyPaymentMethods() {
    return [
      PaymentSetting(
        id: 1,
        title: 'Cash on Delivery',
        type: PAYMENT_METHOD_COD,
        status: 1,
        isTest: 1,
      ),
      PaymentSetting(
        id: 2,
        title: 'Credit/Debit Card (Stripe)',
        type: PAYMENT_METHOD_STRIPE,
        status: 1,
        isTest: 1,
      ),
      PaymentSetting(
        id: 3,
        title: 'RazorPay',
        type: PAYMENT_METHOD_RAZOR,
        status: 1,
        isTest: 1,
      ),
      PaymentSetting(
        id: 4,
        title: 'PayPal',
        type: PAYMENT_METHOD_PAYPAL,
        status: 1,
        isTest: 1,
      ),
      PaymentSetting(
        id: 5,
        title: 'Wallet',
        type: PAYMENT_METHOD_FROM_WALLET,
        status: 1,
        isTest: 1,
      ),
    ];
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> _handleClick() async {
    appStore.setLoading(true);
    if (currentPaymentMethod!.type == PAYMENT_METHOD_COD) {
      savePay(
          paymentMethod: PAYMENT_METHOD_COD,
          paymentStatus: SERVICE_PAYMENT_STATUS_PENDING);
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_STRIPE) {
      StripeServiceNew stripeServiceNew = StripeServiceNew(
        paymentSetting: currentPaymentMethod!,
        totalAmount: totalAmount,
        onComplete: (p0) {
          savePay(
            paymentMethod: PAYMENT_METHOD_STRIPE,
            paymentStatus: widget.isForAdvancePayment
                ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                : SERVICE_PAYMENT_STATUS_PAID,
            txnId: p0['transaction_id'],
          );
        },
      );

      stripeServiceNew.stripePay().catchError((e) {
        appStore.setLoading(false);
        toast(e);
      });
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_RAZOR) {
      RazorPayServiceNew razorPayServiceNew = RazorPayServiceNew(
        paymentSetting: currentPaymentMethod!,
        totalAmount: totalAmount,
        onComplete: (p0) {
          savePay(
            paymentMethod: PAYMENT_METHOD_RAZOR,
            paymentStatus: widget.isForAdvancePayment
                ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                : SERVICE_PAYMENT_STATUS_PAID,
            txnId: p0['paymentId'],
          );
        },
      );
      razorPayServiceNew.razorPayCheckout().catchError((e) {
        appStore.setLoading(false);
        toast(e);
      });
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_FLUTTER_WAVE) {
      FlutterWaveServiceNew flutterWaveServiceNew = FlutterWaveServiceNew();

      flutterWaveServiceNew.checkout(
        paymentSetting: currentPaymentMethod!,
        totalAmount: totalAmount,
        onComplete: (p0) {
          savePay(
            paymentMethod: PAYMENT_METHOD_FLUTTER_WAVE,
            paymentStatus: widget.isForAdvancePayment
                ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                : SERVICE_PAYMENT_STATUS_PAID,
            txnId: p0['transaction_id'],
          );
        },
      );
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_CINETPAY) {
      List<String> supportedCurrencies = ["XOF", "XAF", "CDF", "GNF", "USD"];

      if (!supportedCurrencies.contains(appConfigurationStore.currencyCode)) {
        toast(language.cinetPayNotSupportedMessage);
        return;
      } else if (totalAmount < 100) {
        return toast(
            '${language.totalAmountShouldBeMoreThan} ${100.toPriceFormat()}');
      } else if (totalAmount > 1500000) {
        return toast(
            '${language.totalAmountShouldBeLessThan} ${1500000.toPriceFormat()}');
      }

      CinetPayServicesNew cinetPayServices = CinetPayServicesNew(
        paymentSetting: currentPaymentMethod!,
        totalAmount: totalAmount,
        onComplete: (p0) {
          savePay(
            paymentMethod: PAYMENT_METHOD_CINETPAY,
            paymentStatus: widget.isForAdvancePayment
                ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                : SERVICE_PAYMENT_STATUS_PAID,
            txnId: p0['transaction_id'],
          );
        },
      );

      cinetPayServices.payWithCinetPay(context: context).catchError((e) {
        appStore.setLoading(false);
        toast(e);
      });
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_SADAD_PAYMENT) {
      SadadServicesNew sadadServices = SadadServicesNew(
        paymentSetting: currentPaymentMethod!,
        totalAmount: totalAmount,
        remarks: language.topUpWallet,
        onComplete: (p0) {
          savePay(
            paymentMethod: PAYMENT_METHOD_SADAD_PAYMENT,
            paymentStatus: widget.isForAdvancePayment
                ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                : SERVICE_PAYMENT_STATUS_PAID,
            txnId: p0['transaction_id'],
          );
        },
      );

      sadadServices.payWithSadad(context).catchError((e) {
        appStore.setLoading(false);
        toast(e);
      });
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_PAYPAL) {
      PayPalService.paypalCheckOut(
        context: context,
        paymentSetting: currentPaymentMethod!,
        totalAmount: totalAmount,
        onComplete: (p0) {
          log('PayPalService onComplete: $p0');
          savePay(
            paymentMethod: PAYMENT_METHOD_PAYPAL,
            paymentStatus: widget.isForAdvancePayment
                ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                : SERVICE_PAYMENT_STATUS_PAID,
            txnId: p0['transaction_id'],
          );
        },
      );
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_AIRTEL) {
      showInDialog(
        context,
        contentPadding: EdgeInsets.zero,
        barrierDismissible: false,
        builder: (context) {
          return AppCommonDialog(
            title: language.airtelMoneyPayment,
            child: AirtelMoneyDialog(
              amount: totalAmount,
              reference: APP_NAME,
              paymentSetting: currentPaymentMethod!,
              bookingId: widget.bookings.bookingDetail != null
                  ? widget.bookings.bookingDetail!.id.validate()
                  : 0,
              onComplete: (res) {
                log('RES: $res');
                savePay(
                  paymentMethod: PAYMENT_METHOD_AIRTEL,
                  paymentStatus: widget.isForAdvancePayment
                      ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                      : SERVICE_PAYMENT_STATUS_PAID,
                  txnId: res['transaction_id'],
                );
              },
            ),
          );
        },
      ).then((value) => appStore.setLoading(false));
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_PAYSTACK) {
      PayStackService paystackServices = PayStackService();
      appStore.setLoading(true);
      await paystackServices.init(
        context: context,
        currentPaymentMethod: currentPaymentMethod!,
        loderOnOFF: (p0) {
          appStore.setLoading(p0);
        },
        totalAmount: totalAmount.toDouble(),
        bookingId: widget.bookings.bookingDetail != null
            ? widget.bookings.bookingDetail!.id.validate()
            : 0,
        onComplete: (res) {
          savePay(
            paymentMethod: PAYMENT_METHOD_PAYSTACK,
            paymentStatus: widget.isForAdvancePayment
                ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                : SERVICE_PAYMENT_STATUS_PAID,
            txnId: res["transaction_id"],
          );
        },
      );
      await Future.delayed(const Duration(seconds: 1));
      appStore.setLoading(false);
      paystackServices.checkout().catchError((e) {
        appStore.setLoading(false);
        toast(e);
      });
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_MIDTRANS) {
      MidtransService midtransService = MidtransService();
      appStore.setLoading(true);
      await midtransService.initialize(
        currentPaymentMethod: currentPaymentMethod!,
        totalAmount: totalAmount,
        serviceId: widget.bookings.bookingDetail != null
            ? widget.bookings.bookingDetail!.serviceId.validate()
            : 0,
        serviceName: widget.bookings.bookingDetail != null
            ? widget.bookings.bookingDetail!.serviceName.validate()
            : '',
        servicePrice: widget.bookings.bookingDetail != null
            ? widget.bookings.bookingDetail!.amount.validate()
            : 0,
        loaderOnOFF: (p0) {
          appStore.setLoading(p0);
        },
        onComplete: (res) {
          savePay(
            paymentMethod: PAYMENT_METHOD_MIDTRANS,
            paymentStatus: widget.isForAdvancePayment
                ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                : SERVICE_PAYMENT_STATUS_PAID,
            txnId: res["transaction_id"],
          );
        },
      );
      await Future.delayed(const Duration(seconds: 1));
      appStore.setLoading(false);
      midtransService.midtransPaymentCheckout().catchError((e) {
        appStore.setLoading(false);
        toast(e);
      });
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_PHONEPE) {
      PhonePeServices peServices = PhonePeServices(
        paymentSetting: currentPaymentMethod!,
        totalAmount: totalAmount.toDouble(),
        bookingId: widget.bookings.bookingDetail != null
            ? widget.bookings.bookingDetail!.id.validate()
            : 0,
        onComplete: (res) async {
          log('PhonePe Payment Response: $res');

          // Check if payment was successful
          String status = res["status"]?.toString().toLowerCase() ?? 'pending';
          log("${status}");

          // Only save as PAID if payment was successful
          if (status == 'payment_success') {
            await savePay(
              paymentMethod: PAYMENT_METHOD_PHONEPE,
              paymentStatus: widget.isForAdvancePayment
                  ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                  : SERVICE_PAYMENT_STATUS_PAID,
              txnId: res["transactionId"]?.toString() ?? '',
            );
          } else if (status == ' payment_error') {
            appStore.setLoading(false);
            toast("Payment Failed");
          } else if (status == ' payment_pending') {
            appStore.setLoading(false);
            toast("Payment Pending");
          } else {
            appStore.setLoading(false);
            toast("Payment status: $status");
          }
        },
      );

      peServices.phonePeCheckout(context).catchError((e) {
        appStore.setLoading(false);
        toast(e);
      });
    } else if (currentPaymentMethod!.type == PAYMENT_METHOD_FROM_WALLET) {
      savePay(
        paymentMethod: PAYMENT_METHOD_FROM_WALLET,
        paymentStatus: widget.isForAdvancePayment
            ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
            : SERVICE_PAYMENT_STATUS_PAID,
        txnId: '',
      );
    }
  }

  Future<void> savePay(
      {String txnId = '',
      String paymentMethod = '',
      String paymentStatus = ''}) async {
    Map request = {
      CommonKeys.bookingId: widget.bookings.bookingDetail!.id.validate(),
      CommonKeys.customerId: appStore.userId,
      CouponKeys.discount: widget.bookings.service!.discount,
      BookingServiceKeys.totalAmount: totalAmount,
      CommonKeys.dateTime:
          DateFormat(BOOKING_SAVE_FORMAT).format(DateTime.now()),
      CommonKeys.txnId: txnId != ''
          ? txnId
          : "#${widget.bookings.bookingDetail!.id.validate()}",
      CommonKeys.paymentStatus: paymentStatus,
      CommonKeys.paymentMethod: paymentMethod,
    };

    if (widget.bookings.service != null &&
        widget.bookings.service!.isAdvancePayment &&
        widget.bookings.service!.isFixedService &&
        !widget.bookings.service!.isFreeService &&
        widget.bookings.bookingDetail!.bookingPackage == null) {
      request[AdvancePaymentKey.advancePaymentAmount] =
          advancePaymentAmount ?? widget.bookings.bookingDetail!.paidAmount;

      if ((widget.bookings.bookingDetail!.paymentStatus == null ||
              widget.bookings.bookingDetail!.paymentStatus !=
                  SERVICE_PAYMENT_STATUS_ADVANCE_PAID ||
              widget.bookings.bookingDetail!.paymentStatus !=
                  SERVICE_PAYMENT_STATUS_PAID) &&
          (widget.bookings.bookingDetail!.paidAmount == null ||
              widget.bookings.bookingDetail!.paidAmount.validate() <= 0)) {
        // TODO: check this condition  widget.bookings.bookingPackage?.id == -1
        request[CommonKeys.paymentStatus] = SERVICE_PAYMENT_STATUS_ADVANCE_PAID;
      } else if (widget.bookings.bookingDetail!.paymentStatus ==
          SERVICE_PAYMENT_STATUS_ADVANCE_PAID) {
        request[CommonKeys.paymentStatus] = SERVICE_PAYMENT_STATUS_PAID;
      }
    }

    appStore.setLoading(true);

    // Demo mode - simulate successful payment without API call
    if (widget.isDemoMode) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      appStore.setLoading(false);
      toast('Demo: Payment successful via $paymentMethod!');
      push(DashboardScreen(redirectToBooking: true),
          isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
      return;
    }

    await savePayment(request).then((value) {
      appStore.setLoading(false);
      push(DashboardScreen(redirectToBooking: true),
          isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
    }).catchError((e) {
      toast(e.toString());
      appStore.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => AppScaffold(
        appBarTitle: language.payment,
        child: Stack(
          children: [
            AnimatedScrollView(
              listAnimationType: ListAnimationType.FadeIn,
              fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
              physics: const AlwaysScrollableScrollPhysics(),
              onSwipeRefresh: () async {
                if (!appStore.isLoading) init();
                return await 1.seconds.delay;
              },
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PriceCommonWidget(
                          bookingDetail: widget.bookings.bookingDetail!,
                          serviceDetail: widget.bookings.service!,
                          taxes:
                              widget.bookings.bookingDetail!.taxes.validate(),
                          couponData: widget.bookings.couponData,
                          bookingPackage: widget
                                      .bookings.bookingDetail!.bookingPackage !=
                                  null
                              ? widget.bookings.bookingDetail!.bookingPackage
                              : null,
                        ),
                        32.height,
                        Text(language.lblChoosePaymentMethod,
                            style:
                                context.boldTextStyle(size: LABEL_TEXT_SIZE)),
                      ],
                    ).paddingAll(16),
                    SnapHelperWidget<List<PaymentSetting>>(
                      future: future,
                      onSuccess: (list) {
                        return AnimatedListView(
                          itemCount: list.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          listAnimationType: ListAnimationType.FadeIn,
                          fadeInConfiguration:
                              FadeInConfiguration(duration: 2.seconds),
                          emptyWidget: NoDataWidget(
                            title: language.noPaymentMethodFound,
                            imageWidget: const EmptyStateWidget(),
                          ),
                          itemBuilder: (context, index) {
                            PaymentSetting value = list[index];

                            if (value.status.validate() == 0)
                              return const Offstage();

                            return RadioGroup(
                              groupValue: currentPaymentMethod,
                              onChanged: (PaymentSetting? ind) {
                                currentPaymentMethod = ind;
                                setState(() {});
                              },
                              child: RadioListTile<PaymentSetting>(
                                dense: true,
                                activeColor: primaryColor,
                                value: value,
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                                title: Text(value.title.validate(),
                                    style: context.primaryTextStyle()),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    if (appConfigurationStore.isEnableUserWallet)
                      const WalletBalanceComponent()
                          .paddingSymmetric(vertical: 8, horizontal: 16),
                    if (!appStore.isLoading)
                      AppButton(
                        onTap: () async {
                          if (currentPaymentMethod == null) {
                            return toast(language.chooseAnyOnePayment);
                          }

                          if (currentPaymentMethod!.type ==
                                  PAYMENT_METHOD_COD ||
                              currentPaymentMethod!.type ==
                                  PAYMENT_METHOD_FROM_WALLET) {
                            if (currentPaymentMethod!.type ==
                                PAYMENT_METHOD_FROM_WALLET) {
                              appStore.setLoading(true);
                              num walletBalance = await getUserWalletBalance();

                              appStore.setLoading(false);
                              if (walletBalance >= totalAmount) {
                                showConfirmDialogCustom(
                                  context,
                                  width: 290,
                                  height: 80,
                                  dialogType: DialogType.CONFIRMATION,
                                  title:
                                      "${language.lblPayWith} ${currentPaymentMethod!.title.validate()}?",
                                  titleColor: context.dialogTitleColor,
                                  backgroundColor:
                                      context.dialogBackgroundColor,
                                  primaryColor: context.primary,
                                  positiveTextColor: context.onPrimary,
                                  negativeTextColor: context.dialogCancelColor,
                                  positiveText: language.lblYes,
                                  negativeText: language.lblCancel,
                                  customCenterWidget: Image.asset(
                                    ic_warning,
                                    color: context.dialogIconColor,
                                    height: 70,
                                    width: 70,
                                    fit: BoxFit.cover,
                                  ),
                                  onAccept: (p0) {
                                    _handleClick();
                                  },
                                );
                              } else {
                                toast(language.insufficientBalanceMessage);

                                if (appConfigurationStore.onlinePaymentStatus) {
                                  showConfirmDialogCustom(
                                    context,
                                    width: 290,
                                    height: 80,
                                    dialogType: DialogType.CONFIRMATION,
                                    title: language.doYouWantToTopUpYourWallet,
                                    titleColor: context.dialogTitleColor,
                                    backgroundColor:
                                        context.dialogBackgroundColor,
                                    primaryColor: context.primary,
                                    positiveTextColor: context.onPrimary,
                                    negativeTextColor:
                                        context.dialogCancelColor,
                                    positiveText: language.lblYes,
                                    negativeText: language.lblNo,
                                    cancelable: false,
                                    customCenterWidget: Image.asset(
                                      ic_warning,
                                      color: context.dialogIconColor,
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.cover,
                                    ),
                                    onAccept: (p0) {
                                      pop();
                                      push(UserWalletBalanceScreen());
                                    },
                                    onCancel: (p0) {
                                      pop();
                                    },
                                  );
                                }
                              }
                            } else {
                              showConfirmDialogCustom(
                                context,
                                width: 290,
                                height: 80,
                                dialogType: DialogType.CONFIRMATION,
                                title:
                                    "${language.lblPayWith} ${currentPaymentMethod!.title.validate()}?",
                                titleColor: context.dialogTitleColor,
                                backgroundColor: context.dialogBackgroundColor,
                                primaryColor: context.primary,
                                positiveTextColor: context.onPrimary,
                                negativeTextColor: context.dialogCancelColor,
                                positiveText: language.lblYes,
                                negativeText: language.lblCancel,
                                customCenterWidget: Image.asset(
                                  ic_warning,
                                  color: context.dialogIconColor,
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.cover,
                                ),
                                onAccept: (p0) async {
                                  Navigator.of(context).pop();
                                  await 100.milliseconds.delay;
                                  _handleClick();
                                },
                              );
                            }
                          } else {
                            _handleClick().catchError((e) {
                              appStore.setLoading(false);
                              toast(e.toString());
                            });
                          }
                        },
                        text:
                            "${language.lblPayNow} ${totalAmount.toPriceFormat()}",
                        color: context.primaryColor,
                        width: context.width(),
                      ).paddingAll(16),
                  ],
                ),
              ],
            ),
            if (appStore.isLoading) LoaderWidget(),
          ],
        ),
      ),
    );
  }
}
