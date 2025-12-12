import 'dart:async';
import 'dart:convert';

import 'package:booking_system_flutter/component/add_review_dialog.dart';
import 'package:booking_system_flutter/component/app_common_dialog.dart';
import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/price_widget.dart';
import 'package:booking_system_flutter/component/view_all_label_component.dart';
import 'package:booking_system_flutter/generated/assets.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/booking_data_model.dart';
import 'package:booking_system_flutter/model/booking_detail_model.dart';
import 'package:booking_system_flutter/model/extra_charges_model.dart';
import 'package:booking_system_flutter/model/package_data_model.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/model/service_detail_response.dart';
import 'package:booking_system_flutter/model/shop_model.dart';
import 'package:booking_system_flutter/model/update_location_response.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/booking/component/booking_detail_handyman_widget.dart';
import 'package:booking_system_flutter/screens/booking/component/booking_detail_provider_widget.dart';
import 'package:booking_system_flutter/screens/booking/component/countdown_component.dart';
import 'package:booking_system_flutter/screens/booking/component/invoice_request_dialog_component.dart';
import 'package:booking_system_flutter/screens/booking/component/price_common_widget.dart';
import 'package:booking_system_flutter/screens/booking/component/reason_dialog.dart';
import 'package:booking_system_flutter/screens/booking/component/service_proof_list_widget.dart';
import 'package:booking_system_flutter/screens/booking/handyman_info_screen.dart';
import 'package:booking_system_flutter/screens/booking/provider_info_screen.dart';
import 'package:booking_system_flutter/screens/booking/shimmer/booking_detail_shimmer.dart';
import 'package:booking_system_flutter/screens/booking/track_location.dart';
import 'package:booking_system_flutter/screens/payment/payment_screen.dart';
import 'package:booking_system_flutter/screens/review/components/review_widget.dart';
import 'package:booking_system_flutter/screens/service/service_detail_screen.dart';
import 'package:booking_system_flutter/screens/shop/shop_detail_screen.dart';
import 'package:booking_system_flutter/utils/booking_calculations_logic.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/extensions/num_extenstions.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/base_scaffold_widget.dart';
import '../../component/empty_error_state_widget.dart';
import '../../model/booking_amount_model.dart';
import '../service/addons/service_addons_component.dart';
import 'booking_history_component.dart';
import 'component/cancellations_booking_charge_dialog.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;

  BookingDetailScreen({required this.bookingId});

  @override
  _BookingDetailScreenState createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen>
    with WidgetsBindingObserver {
  // TODO: Set to false when backend is ready
  static const bool _useDummyData = true;

  Future<BookingDetailResponse>? future;
  bool isSentInvoiceOnEmail = false;
  UpdateLocationResponse? providerLocation;
  BitmapDescriptor? customIcon;
  Timer? _locationUpdateTimer;
  GoogleMapController? mapController;
  LatLng? _currentPosition;
  bool isLocationLoader = false;
  LatLng _initialLocation = const LatLng(0.0, 0.0);
  String bookingStatus = "";
  int providerLocationRefreshPeriodInSeconds = 30;

  @override
  void initState() {
    super.initState();
    init(isLoading: false);
    createCustomIcon();
    WidgetsBinding.instance.addObserver(this);
  }

  void init({isLoading = true}) async {
    appStore.setLoading(isLoading);

    // Use dummy data for UI testing
    if (_useDummyData) {
      future = _getDummyBookingDetail();
    } else {
      future = getBookingDetail(
        {
          CommonKeys.bookingId: widget.bookingId.toString(),
          CommonKeys.customerId: appStore.userId
        },
        callbackForStatus: (status) {
          bookingStatus = status;
          if (bookingStatus == BookingStatusKeys.onGoing) {
            refreshProviderLocation();
            startLocationUpdates();
          } else {
            stopLocationUpdates();
          }
        },
      );
    }
    if (isLoading) setState(() {});
  }

  // Generate dummy booking detail for UI testing
  Future<BookingDetailResponse> _getDummyBookingDetail() async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 500));

    final now = DateTime.now();
    final bookingDate = now.add(Duration(days: 1));

    return BookingDetailResponse(
      bookingDetail: BookingData(
        id: widget.bookingId,
        serviceName: "Home Cleaning Service",
        serviceId: 101,
        customerId: appStore.userId,
        customerName: appStore.userFullName,
        providerId: 1,
        providerName: "John's Cleaning Co.",
        providerImage: "",
        status:
            BookingStatusKeys.pending, // Can change to test different states
        statusLabel: "Pending",
        date: DateFormat(BOOKING_SAVE_FORMAT).format(bookingDate),
        bookingSlot: "10:00:00",
        address: "123 Main Street, City Center, State 12345",
        description: "Deep cleaning required for 3BHK apartment",
        type: SERVICE_TYPE_FIXED,
        amount: 1500,
        totalAmount: 1650,
        discount: 10,
        quantity: 1,
        paymentStatus: null,
        paymentMethod: null,
        bookingType: BOOKING_TYPE_SERVICE,
        totalReview: 45,
        totalRating: 4.5,
        taxes: [
          TaxData(
            id: 1,
            title: "GST",
            type: "percent",
            value: 10,
            totalCalculatedValue: 150,
          ),
        ],
      ),
      service: ServiceData(
        id: 101,
        name: "Home Cleaning Service",
        description:
            "Professional home cleaning service with eco-friendly products",
        price: 1500,
        type: SERVICE_TYPE_FIXED,
        status: 1,
        discount: 10,
        categoryId: 1,
        categoryName: "Cleaning",
        providerId: 1,
        attachments: [
          "https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400"
        ],
        isFeatured: 1,
      ),
      providerData: UserData(
        id: 1,
        firstName: "John",
        lastName: "Smith",
        displayName: "John Smith", // Required for BookingDetailProviderWidget
        email: "john.smith@example.com",
        contactNumber: "+1234567890",
        profileImage:
            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
        address: "456 Provider Street, Business District",
        isVerifyProvider: 1,
        providersServiceRating: 4.5, // Required for star rating display
      ),
      handymanData: [
        UserData(
          id: 2,
          firstName: "Mike",
          lastName: "Johnson",
          displayName: "Mike Johnson", // Required for display
          email: "mike.johnson@example.com",
          contactNumber: "+0987654321",
          profileImage:
              "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200",
          handymanRating: 4.2, // Required for star rating display
        ),
      ],
      customer: UserData(
        id: appStore.userId,
        firstName: appStore.userFirstName,
        lastName: appStore.userLastName,
        email: appStore.userEmail,
        contactNumber: appStore.userContactNumber,
      ),
      bookingActivity: [
        BookingActivity(
          id: 1,
          bookingId: widget.bookingId,
          activityType: "created",
          activityMessage: "Booking created",
          datetime: DateFormat(BOOKING_SAVE_FORMAT).format(now),
          activityData: '{"status": "pending", "label": "Pending"}',
        ),
      ],
      ratingData: [
        RatingData(
          id: 1,
          serviceId: 101,
          customerId: 5,
          customerName: "Jorge Perez",
          profileImage: "",
          rating: 5.0,
          review:
              "Incredible selection and quality in contemporary style clothing my new go to for fashion forward pieces that make a statement.",
          createdAt: "2025-09-29T10:30:00.000Z",
        ),
        RatingData(
          id: 2,
          serviceId: 101,
          customerId: 6,
          customerName: "Maria Garcia",
          profileImage: "",
          rating: 4.5,
          review:
              "Very professional service. The team was punctual and did an excellent job. Highly recommended for anyone looking for quality work.",
          createdAt: "2025-09-25T14:00:00.000Z",
        ),
      ],
      customerReview: null,
      taxes: [
        TaxData(
          id: 1,
          title: "GST",
          type: "percent",
          value: 10,
          totalCalculatedValue: 150,
        ),
      ],
      serviceProof: [],
      couponData: null,
      postRequestDetail: null,
      shop: null,
    );
  }

  //region Widgets
  Widget _buildReasonWidget({required BookingDetailResponse snap}) {
    if (((snap.bookingDetail!.status == BookingStatusKeys.cancelled ||
            snap.bookingDetail!.status == BookingStatusKeys.rejected ||
            snap.bookingDetail!.status == BookingStatusKeys.failed) &&
        ((snap.bookingDetail!.reason != null &&
            snap.bookingDetail!.reason!.isNotEmpty))))
      return Container(
        padding: const EdgeInsets.only(top: 14, left: 14, bottom: 14),
        color: cancellationsBgColor,
        width: context.width(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${language.cancelledReason}: ",
                style: boldTextStyle(size: 12, color: black)),
            Marquee(
                    child: Text(snap.bookingDetail!.reason.validate(),
                        style: boldTextStyle(color: redColor, size: 12)))
                .expand(),
          ],
        ),
      );
    return const SizedBox();
  }

  Widget _completeMessage({required BookingDetailResponse snap}) {
    if (snap.bookingDetail!.status == BookingStatusKeys.complete &&
        snap.customerReview == null)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "You Haven't Rated Yet",
            style: boldTextStyle(size: 16),
          ),
          12.height,
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Rate Now',
              textStyle: boldTextStyle(color: Colors.white),
              color: context.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 12),
              onTap: () {
                showInDialog(
                  context,
                  contentPadding: EdgeInsets.zero,
                  builder: (p0) {
                    return AddReviewDialog(
                      serviceId: snap.bookingDetail!.serviceId.validate(),
                      bookingId: snap.bookingDetail!.id.validate(),
                    );
                  },
                ).then((value) {
                  if (value) {
                    init();
                    setState(() {});
                  }
                }).catchError((e) {
                  log(e.toString());
                });
              },
            ),
          ),
          24.height,
        ],
      );

    return const SizedBox();
  }

  Widget bookingIdWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          language.lblBookingID,
          style: boldTextStyle(size: LABEL_TEXT_SIZE, color: Colors.white),
        ),
        Text(
          '#' + widget.bookingId.validate().toString(),
          style: boldTextStyle(color: Colors.white, size: 16),
        ),
      ],
    );
  }

  String buildTimeString({required BookingData bookingDetail}) {
    if (bookingDetail.bookingSlot == null) {
      return formatDate(bookingDetail.date.validate(), isTime: true);
    }
    return formatDate(
      getSlotWithDate(
        date: bookingDetail.date.validate(),
        slotTime: bookingDetail.bookingSlot.validate(),
      ),
      isTime: true,
    );
  }

  //completed
  Widget serviceDetailWidget(
      {required BookingData bookingDetail,
      required ServiceData serviceDetail}) {
    return GestureDetector(
      onTap: () {
        if (bookingDetail.isPostJob || bookingDetail.isPackageBooking) {
          //
        } else {
          ServiceDetailScreen(serviceId: bookingDetail.serviceId.validate())
              .launch(context);
        }
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: radius(8),
          color: Color(0xFFE8F3EC),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image section with rounded corners
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedImageWidget(
                url: serviceDetail.attachments!.isNotEmpty &&
                        !bookingDetail.isPackageBooking
                    ? serviceDetail.attachments!.first
                    : bookingDetail.bookingPackage != null
                        ? bookingDetail.bookingPackage!.imageAttachments
                                .validate()
                                .isNotEmpty
                            ? bookingDetail.bookingPackage!.imageAttachments
                                .validate()
                                .first
                                .validate()
                            : ''
                        : '',
                height: 70,
                width: 70,
                fit: BoxFit.cover,
                radius: 8,
              ),
            ),
            8.width,
            // Service details section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Service Name
                  Text(
                    bookingDetail.isPackageBooking
                        ? bookingDetail.bookingPackage!.name.validate()
                        : bookingDetail.serviceName.validate(),
                    style: boldTextStyle(size: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  6.height,
                  // Duration (Date)
                  Row(
                    children: [
                      Text(
                        'Duration: ',
                        style: primaryTextStyle(
                          size: 12,
                        ),
                      ),
                      Text(
                        formatDate(bookingDetail.date.validate()),
                        style: primaryTextStyle(
                          size: 12,
                        ),
                      ),
                    ],
                  ),
                  6.height,
                  // Time
                  Row(
                    children: [
                      Text(
                        'Time: ',
                        style: primaryTextStyle(
                          size: 12,
                        ),
                      ),
                      Text(
                        buildTimeString(bookingDetail: bookingDetail),
                        style: primaryTextStyle(
                          size: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget counterWidget({required BookingDetailResponse value}) {
    if (value.bookingDetail!.isHourlyService &&
        (value.bookingDetail!.status == BookingStatusKeys.inProgress ||
            value.bookingDetail!.status == BookingStatusKeys.hold ||
            value.bookingDetail!.status == BookingStatusKeys.complete ||
            value.bookingDetail!.status == BookingStatusKeys.onGoing))
      return Column(
        children: [
          16.height,
          CountdownWidget(bookingDetailResponse: value),
        ],
      );
    else
      return const Offstage();
  }

  Widget serviceProofListWidget({required List<ServiceProof> list}) {
    if (list.isEmpty) return const Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Text(language.lblServiceProof,
            style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        16.height,
        Container(
          decoration: boxDecorationWithRoundedCorners(
            backgroundColor: context.cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
          ),
          child: ListView.separated(
            itemBuilder: (context, index) =>
                ServiceProofListWidget(data: list[index]),
            itemCount: list.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (BuildContext context, int index) {
              return Divider(height: 0, color: context.dividerColor);
            },
          ),
        ),
      ],
    );
  }

  Widget handymanWidget(
      {required List<UserData> handymanList,
      required BookingDetailResponse res,
      required ServiceData serviceDetail,
      required BookingData bookingDetail}) {
    if (handymanList.isEmpty) return const Offstage();

    if (res.providerData!.id != handymanList.first.id)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          24.height,
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Space between items
            children: [
              Text(
                language.lblAboutHandyman,
                style: boldTextStyle(size: LABEL_TEXT_SIZE),
              ),
              GestureDetector(
                onTap: () {
                  HandymanInfoScreen(handymanId: handymanList.first.id)
                      .launch(context)
                      .then((value) => null);
                },
                child: Text(
                  language.viewDetail,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor, // Adjust color as needed
                  ),
                ),
              ),
            ],
          ),
          16.height,
          Column(
            children: handymanList.map((e) {
              return BookingDetailHandymanWidget(
                handymanData: e,
                serviceDetail: serviceDetail,
                bookingDetail: bookingDetail,
                onUpdate: () {
                  init();
                  setState(() {});
                },
              ).onTap(
                () {
                  HandymanInfoScreen(handymanId: e.id)
                      .launch(context)
                      .then((value) => null);
                },
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
              );
            }).toList(),
          ),
        ],
      );
    else
      return const Offstage();
  }

  Widget providerWidget({required BookingDetailResponse res}) {
    if (res.providerData == null) return const Offstage();
    bool canCustomerContact = res.bookingDetail!.canCustomerContact;
    bool providerIsHandyman = res.handymanData.validate().isNotEmpty &&
        (res.providerData!.id == res.handymanData!.first.id.validate());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        32.height,
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: language.lblAboutProvider,
                style: boldTextStyle(),
              ),
              if (res.handymanData.validate().isNotEmpty &&
                  (res.providerData!.id ==
                      res.handymanData!.first.id.validate()))
                TextSpan(
                  text: ' (${language.asHandyman})',
                  style: primaryTextStyle(),
                ),
            ],
          ),
        ),
        16.height,
        BookingDetailProviderWidget(
          providerData: res.providerData!,
          canCustomerContact: canCustomerContact,
          providerIsHandyman: providerIsHandyman,
        ).onTap(
          () {
            ProviderInfoScreen(
              providerId: res.providerData!.id.validate(),
              canCustomerContact: canCustomerContact,
            ).launch(context).then((value) {
              setStatusBarColor(context.primaryColor);
            });
          },
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
      ],
    );
  }

  Widget refundPaymentDetailsWidget({required BookingDetailResponse snap}) {
    if (((snap.bookingDetail!.status == BookingStatusKeys.cancelled ||
            snap.bookingDetail!.status == BookingStatusKeys.rejected ||
            snap.bookingDetail!.status == BookingStatusKeys.failed) &&
        (snap.service!.isEnableAdvancePayment != 0) &&
        (snap.bookingDetail!.isAdvancePaymentDone)))
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          24.height,
          Text(language.refundPaymentDetails,
              style: boldTextStyle(size: LABEL_TEXT_SIZE)),
          16.height,
          Container(
            decoration: boxDecorationDefault(color: context.cardColor),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${language.refundOf} ${snap.bookingDetail!.refundAmount!.toPriceFormat()}',
                            style: boldTextStyle(size: LABEL_TEXT_SIZE))
                        .expand(),
                    16.width,
                    Text(
                        snap.bookingDetail!.refundStatus
                            .validate()
                            .toBookingStatus(),
                        style: boldTextStyle(
                            size: 14,
                            color: snap.bookingDetail!.refundStatus
                                .validate()
                                .getPaymentStatusBackgroundColor)),
                  ],
                ),
                8.height,
                Row(
                  children: [
                    Text('${language.paymentMethod}: ',
                        style: secondaryTextStyle()),
                    Text(language.wallet,
                        style: boldTextStyle(size: 12, color: primaryColor)),
                  ],
                ),
                8.height,
                Container(
                  decoration: boxDecorationDefault(
                      color: appStore.isDarkMode ? black : Colors.white),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(language.price,
                                  style: secondaryTextStyle(size: 14))
                              .expand(),
                          16.width,
                          PriceWidget(
                              price: snap.service!.price!,
                              color: textPrimaryColorGlobal,
                              isBoldText: true),
                        ],
                      ),
                      16.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(language.advancedPayment,
                                  style: secondaryTextStyle(size: 14))
                              .expand(),
                          16.width,
                          PriceWidget(
                              price: getAdvancePaymentAmount(bookingInfo: snap),
                              color: textPrimaryColorGlobal,
                              isBoldText: true),
                        ],
                      ),
                      16.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(language.cancellationFee,
                                  style: secondaryTextStyle(size: 14))
                              .expand(),
                          16.width,
                          PriceWidget(
                              price:
                                  snap.bookingDetail!.cancellationChargeAmount!,
                              color: textPrimaryColorGlobal,
                              isBoldText: true),
                        ],
                      ),
                      Divider(height: 26, color: context.dividerColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(language.refundAmount,
                                  style: boldTextStyle(size: LABEL_TEXT_SIZE))
                              .expand(),
                          16.width,
                          PriceWidget(
                              price: snap.bookingDetail!.refundAmount!,
                              color: primaryColor,
                              isBoldText: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    return const SizedBox();
  }

  getAdvancePaymentAmount({required BookingDetailResponse bookingInfo}) {
    if (bookingInfo.bookingDetail!.paidAmount.validate() != 0) {
      return bookingInfo.bookingDetail!.paidAmount!;
    } else {
      return bookingInfo.bookingDetail!.totalAmount.validate() *
          bookingInfo.service!.advancePaymentPercentage.validate() /
          100;
    }
  }

  Widget extraChargesWidget(
      {required List<ExtraChargesModel> extraChargesList}) {
    if (extraChargesList.isEmpty) return const Offstage();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        Text(language.extraCharges,
            style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        16.height,
        Container(
          decoration: boxDecorationWithRoundedCorners(
              backgroundColor: context.cardColor, borderRadius: radius()),
          padding: const EdgeInsets.all(16),
          child: ListView.separated(
            itemCount: extraChargesList.length,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => 8.height,
            itemBuilder: (_, i) {
              ExtraChargesModel data = extraChargesList[i];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(data.title.validate(),
                              style: secondaryTextStyle(size: 14))
                          .expand(),
                      16.width,
                      Row(
                        children: [
                          Text('${data.qty} * ${data.price.validate()} = ',
                              style: secondaryTextStyle()),
                          4.width,
                          PriceWidget(
                              price:
                                  '${data.price.validate() * data.qty.validate()}'
                                      .toDouble(),
                              color: textPrimaryColorGlobal,
                              isBoldText: true),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget paymentDetailCard(BookingData bookingData) {
    if (bookingData.paymentId != null && bookingData.paymentStatus != null)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          ViewAllLabel(label: language.paymentDetail, list: []),
          8.height,
          Container(
            decoration: boxDecorationWithRoundedCorners(
              backgroundColor: context.cardColor,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.lblId, style: secondaryTextStyle(size: 14)),
                    Text("#" + bookingData.paymentId.toString(),
                        style: boldTextStyle()),
                  ],
                ),
                16.height,
                if (bookingData.paymentMethod.validate().isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(language.lblMethod,
                          style: secondaryTextStyle(size: 14)),
                      Text(
                        (bookingData.paymentMethod != null
                                ? bookingData.paymentMethod.toString()
                                : language.notAvailable)
                            .capitalizeFirstLetter(),
                        style: boldTextStyle(),
                      ),
                    ],
                  ),
                16.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.lblStatus,
                        style: secondaryTextStyle(size: 14)),
                    Text(
                      getPaymentStatusText(
                          bookingData.paymentStatus, bookingData.paymentMethod),
                      style: boldTextStyle(),
                    ),
                  ],
                ),
                if (bookingData.txnId.validate().isNotEmpty &&
                    (bookingData.paymentMethod != PAYMENT_METHOD_COD ||
                        bookingData.paymentMethod !=
                            PAYMENT_METHOD_FROM_WALLET))
                  Row(
                    children: [
                      Text(language.transactionId,
                          style: secondaryTextStyle(size: 14)),
                      8.width,
                      Row(
                        children: [
                          Text(bookingData.txnId.validate(),
                                  textAlign: TextAlign.right,
                                  style: boldTextStyle(color: redColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis)
                              .expand(),
                          4.width,
                          InkWell(
                            onTap: () async {
                              await Clipboard.setData(ClipboardData(
                                  text: bookingData.txnId.validate()));
                              toast(language.copied);
                            },
                            child: const SizedBox(
                                width: 23,
                                height: 23,
                                child: Icon(Icons.copy, size: 18)),
                          ),
                        ],
                      ).expand(),
                    ],
                  ).paddingTop(16),
              ],
            ),
          ),
        ],
      );

    return const Offstage();
  }

  Widget customerReviewWidget(
      {required List<RatingData> ratingList,
      required RatingData? customerReview,
      required BookingData bookingDetail}) {
    // Combine customer review with rating list if exists
    List<RatingData> allReviews = [];
    if (customerReview != null) {
      allReviews.add(customerReview);
    }
    allReviews.addAll(ratingList);

    if (allReviews.isEmpty) return const Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        24.height,
        // Reviews heading with count and optional View All
        Text(
          '${language.review} (${bookingDetail.totalReview ?? allReviews.length})',
          style: boldTextStyle(size: 16),
        ),
        16.height,
        // Customer's own review with edit/delete options
        if (customerReview != null &&
            bookingDetail.status == BookingStatusKeys.complete)
          Stack(
            children: [
              ReviewWidget(data: customerReview),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showInDialog(
                          context,
                          contentPadding: EdgeInsets.zero,
                          builder: (p0) {
                            return AddReviewDialog(
                                customerReview: customerReview);
                          },
                        ).then((value) {
                          if (value ?? false) {
                            init();
                            setState(() {});
                          }
                        }).catchError((e) {
                          toast(e.toString());
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.edit,
                            size: 16, color: context.primaryColor),
                      ),
                    ),
                    8.width,
                    GestureDetector(
                      onTap: () {
                        showConfirmDialogCustom(
                          context,
                          title: language.lblDeleteReview,
                          subTitle: language.lblConfirmReviewSubTitle,
                          positiveText: language.lblYes,
                          negativeText: language.lblNo,
                          dialogType: DialogType.DELETE,
                          onAccept: (p0) async {
                            appStore.setLoading(true);
                            await deleteReview(id: customerReview.id.validate())
                                .then((value) {
                              toast(value.message);
                            }).catchError((e) {
                              toast(e.toString());
                            });
                            init();
                            setState(() {});
                          },
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.delete_outline,
                            size: 16, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        // Other reviews list
        if (ratingList.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ratingList.length > 3 ? 3 : ratingList.length,
            itemBuilder: (context, index) =>
                ReviewWidget(data: ratingList[index]),
          ),
      ],
    );
  }

  Widget locationTrackWidget(
    List<UserData> handymanList,
    BookingDetailResponse res,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        12.height,
        Text(
          handymanList.isEmpty
              ? language.providerLocation
              : res.providerData!.id != handymanList.first.id
                  ? language.handymanLocation
                  : language.providerLocation,
          style: boldTextStyle(),
        ),
        4.height,
        Row(
          children: [
            Text("${language.lastUpdatedAt} ",
                style: secondaryTextStyle(size: 10)),
            Text(
              "${DateTime.parse(providerLocation?.data.datetime.toString() ?? DateTime.now().toString()).timeAgo}",
              style: primaryTextStyle(size: 10),
            ).visible(providerLocation?.data.datetime.isNotEmpty ?? false),
          ],
        ).visible(providerLocation?.data.datetime.isNotEmpty ?? false),
        8.height,
        SizedBox(
          height: 250,
          child: Stack(
            children: [
              GoogleMap(
                zoomControlsEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: _initialLocation,
                  zoom: 14.0,
                ),
                mapType: MapType.normal,
                minMaxZoomPreference: const MinMaxZoomPreference(1, 40),
                gestureRecognizers: Set()
                  ..add(Factory<OneSequenceGestureRecognizer>(
                      () => new EagerGestureRecognizer()))
                  ..add(Factory<PanGestureRecognizer>(
                      () => PanGestureRecognizer()))
                  ..add(Factory<ScaleGestureRecognizer>(
                      () => ScaleGestureRecognizer()))
                  ..add(Factory<TapGestureRecognizer>(
                      () => TapGestureRecognizer()))
                  ..add(Factory<VerticalDragGestureRecognizer>(
                      () => VerticalDragGestureRecognizer())),
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                  setState(() {});
                },
                markers: Set<Marker>.from(
                  [
                    if (providerLocation != null)
                      Marker(
                        markerId: const MarkerId('Location'),
                        position: LatLng(
                          double.parse(
                              providerLocation?.data.latitude.toString() ??
                                  "0.0"),
                          double.parse(
                              providerLocation?.data.longitude.toString() ??
                                  "0.0"),
                        ),
                        icon: customIcon ?? BitmapDescriptor.defaultMarker,
                      ),
                  ],
                ),
              ),
              Positioned(
                left: 10,
                top: 10,
                child: const CupertinoActivityIndicator(color: black)
                    .visible(isLocationLoader),
              ),
            ],
          ),
        ),
        10.height,
        Row(
          children: [
            AppButton(
              onTap: () {
                TrackLocation(
                  bookingId: widget.bookingId,
                  isHandyman: res.providerData!.id != handymanList.first.id,
                ).launch(context);
              },
              padding: const EdgeInsets.only(top: 0, left: 8, right: 8),
              height: 42,
              color: const Color(0xFF39A81D),
              textColor: white,
              text: language.track,
            ).expand(),
            16.width,
            Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(12),
              decoration: boxDecorationDefault(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
              child: const CachedImageWidget(
                url: ic_refresh,
                color: textSecondaryColor,
                height: 42,
              ),
            ).onTap(() {
              refreshProviderLocation();
            }),
            16.width,
            Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(12),
              decoration: boxDecorationDefault(
                color: Colors.white,
                borderRadius: const BorderRadius.all(
                  Radius.circular(6),
                ),
              ),
              child: const CachedImageWidget(
                url: ic_share,
                color: textSecondaryColor,
                height: 22,
              ),
            ).onTap(
              () {
                shareComponent();
              },
            ),
          ],
        ),
        16.height,
        Text(
          handymanList.isEmpty
              ? language.providerReached
              : res.providerData!.id != handymanList.first.id
                  ? language.handymanReached
                  : language.providerReached,
          style: secondaryTextStyle(),
        ),
      ],
    );
  }

  // Widget locationTrackShopWidget(
  //   ShopModel handymanList,
  //   BookingDetailResponse res,
  // ) {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       12.height,
  //       Text(
  //         "Shop Location",
  //         style: boldTextStyle(),
  //       ),
  //       4.height,
  //       Row(
  //         children: [
  //           Text("${language.lastUpdatedAt} ", style: secondaryTextStyle(size: 10)),
  //           Text(
  //             "${DateTime.parse(providerLocation?.data.datetime.toString() ?? DateTime.now().toString()).timeAgo}",
  //             style: primaryTextStyle(size: 10),
  //           ).visible(providerLocation?.data.datetime.isNotEmpty ?? false),
  //         ],
  //       ).visible(providerLocation?.data.datetime.isNotEmpty ?? false),
  //       8.height,
  //       SizedBox(
  //         height: 250,
  //         child: Stack(
  //           children: [
  //             GoogleMap(
  //               zoomControlsEnabled: true,
  //               initialCameraPosition: CameraPosition(
  //                 target: _initialLocation,
  //                 zoom: 14.0,
  //               ),
  //               mapType: MapType.normal,
  //               minMaxZoomPreference: const MinMaxZoomPreference(1, 40),
  //               gestureRecognizers: Set()
  //                 ..add(Factory<OneSequenceGestureRecognizer>(() => new EagerGestureRecognizer()))
  //                 ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
  //                 ..add(Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()))
  //                 ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
  //                 ..add(Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer())),
  //               onMapCreated: (GoogleMapController controller) {
  //                 mapController = controller;
  //                 setState(() {});
  //               },
  //               markers: Set<Marker>.from(
  //                 [
  //                   if (providerLocation != null)
  //                     Marker(
  //                       markerId: const MarkerId('Location'),
  //                       position: LatLng(
  //                         double.parse(handymanList.latitude.toString()),
  //                         double.parse(handymanList.longitude.toString()),
  //                       ),
  //                       icon: customIcon ?? BitmapDescriptor.defaultMarker,
  //                     ),
  //                 ],
  //               ),
  //             ),
  //             Positioned(
  //               left: 10,
  //               top: 10,
  //               child: const CupertinoActivityIndicator(color: black).visible(isLocationLoader),
  //             ),
  //           ],
  //         ),
  //       ),
  //       10.height,
  //       Row(
  //         children: [
  //           AppButton(
  //             onTap: () {
  //               TrackLocation(
  //                 bookingId: widget.bookingId,
  //                 isHandyman: res.providerData!.id != handymanList.id,
  //               ).launch(context);
  //             },
  //             padding: const EdgeInsets.only(top: 0, left: 8, right: 8),
  //             height: 42,
  //             color: const Color(0xFF39A81D),
  //             textColor: white,
  //             text: language.track,
  //           ).expand(),
  //           16.width,
  //           Container(
  //             width: 42,
  //             height: 42,
  //             padding: const EdgeInsets.all(12),
  //             decoration: boxDecorationDefault(
  //               color: Colors.white,
  //               borderRadius: const BorderRadius.all(Radius.circular(6)),
  //             ),
  //             child: const CachedImageWidget(
  //               url: ic_refresh,
  //               color: textSecondaryColor,
  //               height: 42,
  //             ),
  //           ).onTap(() {
  //             refreshProviderLocation();
  //           }),
  //           16.width,
  //           Container(
  //             width: 42,
  //             height: 42,
  //             padding: const EdgeInsets.all(12),
  //             decoration: boxDecorationDefault(
  //               color: Colors.white,
  //               borderRadius: const BorderRadius.all(
  //                 Radius.circular(6),
  //               ),
  //             ),
  //             child: const CachedImageWidget(
  //               url: ic_share,
  //               color: textSecondaryColor,
  //               height: 22,
  //             ),
  //           ).onTap(
  //             () {
  //               shareComponent();
  //             },
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget packageWidget({required BookingPackage? package}) {
    if (package == null) return const Offstage();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Text(language.includedInThisPackage, style: boldTextStyle()),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: package.serviceList!.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (_, i) {
            ServiceData data = package.serviceList![i];
            return Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: boxDecorationWithRoundedCorners(
                borderRadius: radius(),
                backgroundColor: context.cardColor,
                border: appStore.isDarkMode
                    ? Border.all(color: context.dividerColor)
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedImageWidget(
                    url: data.attachments!.isNotEmpty
                        ? data.attachments!.first.validate()
                        : "",
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                    radius: 8,
                  ),
                  16.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.name.validate(),
                          style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                      4.height,
                      if (data.subCategoryName.validate().isNotEmpty)
                        Marquee(
                          child: Row(
                            children: [
                              Text('${data.categoryName}',
                                  style: boldTextStyle(
                                      size: 12,
                                      color: textSecondaryColorGlobal)),
                              Text('  >  ',
                                  style: boldTextStyle(
                                      size: 14,
                                      color: textSecondaryColorGlobal)),
                              Text('${data.subCategoryName}',
                                  style: boldTextStyle(
                                      size: 12, color: context.primaryColor)),
                            ],
                          ),
                        )
                      else
                        Text('${data.categoryName}',
                            style: boldTextStyle(
                                size: 12, color: context.primaryColor)),
                      4.height,
                      PriceWidget(
                        price: data.price.validate(),
                        hourlyTextColor: Colors.white,
                      ),
                    ],
                  ).flexible()
                ],
              ),
            ).onTap(
              () {
                ServiceDetailScreen(serviceId: data.id!).launch(context);
              },
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
            );
          },
        )
      ],
    );
  }

  Widget myServiceList({required List<ServiceData> serviceList}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        Text(language.myServices, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        8.height,
        AnimatedListView(
          itemCount: serviceList.length,
          shrinkWrap: true,
          listAnimationType: ListAnimationType.FadeIn,
          itemBuilder: (_, i) {
            ServiceData data = serviceList[i];

            return Container(
              width: context.width(),
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(8),
              decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: context.cardColor,
                  borderRadius:
                      BorderRadius.all(Radius.circular(defaultRadius))),
              child: Row(
                children: [
                  CachedImageWidget(
                    url: data.attachments.validate().isNotEmpty
                        ? data.attachments!.first.validate()
                        : "",
                    fit: BoxFit.cover,
                    height: 50,
                    width: 50,
                    radius: defaultRadius,
                  ),
                  16.width,
                  Text(data.name.validate(),
                          style: primaryTextStyle(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis)
                      .expand(),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Image.asset(
        Assets.iconsIcDefaultShop,
        height: 14,
        width: 14,
        color: primaryColor,
      ),
    );
  }

  Widget shopDetailWidget({required ShopModel shop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Space between items
          children: [
            RichText(
              text: TextSpan(
                text: language.lblAboutShop,
                style: boldTextStyle(size: LABEL_TEXT_SIZE),
              ),
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                ShopDetailScreen(shopId: shop.id).launch(context);
              },
              child: Text(language.viewDetail, style: secondaryTextStyle()),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.all(16),
          decoration: boxDecorationDefault(
            color: context.cardColor,
            border: appStore.isDarkMode
                ? Border.all(color: context.dividerColor)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: shop.shopFirstImage.isNotEmpty
                          ? CachedImageWidget(
                              url: shop.shopFirstImage,
                              fit: BoxFit.cover,
                              width: 60,
                              height: 60,
                              usePlaceholderIfUrlEmpty: true,
                            )
                          : _buildFallbackImage(),
                    ),
                  ),
                  16.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shop.name, style: boldTextStyle()),
                      4.height,
                      if (shop.shopStartTime.isNotEmpty &&
                          shop.shopEndTime.isNotEmpty) ...[
                        TextIcon(
                          spacing: 10,
                          prefix: Image.asset(ic_clock,
                              width: 12, height: 12, color: context.iconColor),
                          text: shop.shopStartTime.validate().isNotEmpty &&
                                  shop.shopEndTime.isNotEmpty
                              ? '${shop.shopStartTime} - ${shop.shopEndTime}'
                              : '---',
                          textStyle: secondaryTextStyle(size: 12),
                          expandedText: true,
                          edgeInsets: EdgeInsets.zero,
                        ),
                      ]
                    ],
                  ).expand(),
                ],
              ),
              8.height,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((shop.email.validate().isNotEmpty) ||
                      (shop.contactNumber.validate().isNotEmpty)) ...[
                    if (shop.email.validate().isNotEmpty) ...[
                      4.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${language.email}:',
                            style: boldTextStyle(
                                size: 12,
                                color: appStore.isDarkMode
                                    ? textSecondaryColor
                                    : textPrimaryColor),
                          ).expand(),
                          8.width,
                          Expanded(
                            flex: 4,
                            child: GestureDetector(
                              onTap: () {
                                launchMail("${shop.email.validate()}");
                              },
                              child: Text(
                                shop.email.validate(),
                                style: boldTextStyle(
                                    size: 12,
                                    color: appStore.isDarkMode
                                        ? white
                                        : textSecondaryColor,
                                    weight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ],
                      ),
                      4.height,
                    ],
                    if (shop.contactNumber.validate().isNotEmpty) ...[
                      4.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            language.mobile,
                            style: boldTextStyle(
                                size: 12,
                                color: appStore.isDarkMode
                                    ? textSecondaryColor
                                    : textPrimaryColor),
                          ).expand(),
                          8.width,
                          Expanded(
                            flex: 4,
                            child: GestureDetector(
                              onTap: () {
                                launchCall("${shop.contactNumber.validate()}");
                              },
                              child: Text(
                                shop.contactNumber.validate(),
                                style: boldTextStyle(
                                    size: 12,
                                    color: appStore.isDarkMode
                                        ? white
                                        : textSecondaryColor,
                                    weight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ],
                      ),
                      4.height,
                    ]
                  ],
                  if (shop.latitude != 0 && shop.longitude != 0) ...[
                    4.height,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${language.hintAddress}:',
                          style: boldTextStyle(
                              size: 12,
                              color: appStore.isDarkMode
                                  ? textSecondaryColor
                                  : textPrimaryColor),
                        ).expand(),
                        8.width,
                        Expanded(
                          flex: 4,
                          child: GestureDetector(
                              onTap: () {
                                if (shop.latitude != 0 && shop.longitude != 0) {
                                  launchMapFromLatLng(
                                      latitude: shop.latitude,
                                      longitude: shop.longitude);
                                } else {
                                  launchMap(shop.address);
                                }
                              },
                              child: Marquee(
                                child: Text(
                                  "${shop.address}, ${shop.cityName}, ${shop.stateName}, ${shop.countryName}",
                                  style: boldTextStyle(
                                      size: 12,
                                      color: appStore.isDarkMode
                                          ? white
                                          : textSecondaryColor,
                                      weight: FontWeight.w400),
                                  softWrap: true,
                                ),
                              )),
                        ),
                      ],
                    ),
                    4.height,
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _action({required BookingDetailResponse bookingResponse}) {
    final isShopBooking =
        bookingResponse.service?.visitType?.trim().toLowerCase() ==
            VISIT_OPTION_ON_SHOP;
    final shop = bookingResponse.shop;

    if (isShopBooking && shop != null) {
      return _buildShopActions(bookingResponse);
    } else {
      return _buildOnSiteActions(bookingResponse);
    }
  }

  // /// ---------------- SHOP BOOKING ----------------
  Widget _buildShopActions(BookingDetailResponse bookingResponse) {
    final detail = bookingResponse.bookingDetail!;
    switch (bookingResponse.bookingDetail!.status) {
      case BookingStatusKeys.pending:
        return _cancelButton(bookingResponse);

      case BookingStatusKeys.accept:
        return bookingResponse.handymanData.validate().isNotEmpty
            ? _startButton(bookingResponse)
            : Offstage();

      case BookingStatusKeys.onGoing:
      case BookingStatusKeys.inProgress:
        return _holdAndDoneButtons(bookingResponse);

      case BookingStatusKeys.hold:
        return _resumeAndCancelButtons(bookingResponse);

      case BookingStatusKeys.complete:
        if ((detail.type != SERVICE_TYPE_FREE ||
                detail.paymentMethod == PAYMENT_METHOD_COD) &&
            detail.paymentId == null) {
          return _payNowButton(bookingResponse);
        } else if (!detail.isFreeService && !isSentInvoiceOnEmail) {
          return _requestInvoiceButton(bookingResponse);
        } else if (!detail.isFreeService && isSentInvoiceOnEmail) {
          return _invoiceSentMessage();
        } else
          return Offstage();

      case BookingStatusKeys.cancelled:
        return Offstage();

      // 🔑 This ensures no "null" return
      default:
        return Offstage();
    }
  }

  // /// ---------------- ON SITE BOOKING ----------------
  Widget _buildOnSiteActions(BookingDetailResponse bookingResponse) {
    final detail = bookingResponse.bookingDetail!;

    // Special case: Advance Payment flow
    if ((bookingResponse.service?.isAdvancePayment ?? false) &&
        !(bookingResponse.service?.isFreeService ?? true) &&
        (bookingResponse.service?.isFixedService ?? false) &&
        detail.bookingPackage == null &&
        (detail.paymentStatus == null ||
            (detail.paymentStatus == SERVICE_PAYMENT_STATUS_ADVANCE_PAID &&
                detail.status == BookingStatusKeys.complete))) {
      return _payNowOrAdvanceButton(bookingResponse, detail);
    }

    switch (detail.status) {
      case BookingStatusKeys.pending:
      case BookingStatusKeys.accept:
        return _cancelButton(bookingResponse);

      case BookingStatusKeys.onGoing:
        return bookingResponse.handymanData.validate().isNotEmpty
            ? _startButton(bookingResponse)
            : Offstage();

      case BookingStatusKeys.inProgress:
        return _holdAndDoneButtons(bookingResponse);

      case BookingStatusKeys.hold:
        return _resumeAndCancelButtons(bookingResponse);

      case BookingStatusKeys.pendingApproval:
        return _waitingResponseMessage();

      case BookingStatusKeys.complete:
        if ((detail.type != SERVICE_TYPE_FREE ||
                detail.paymentMethod == PAYMENT_METHOD_COD) &&
            detail.paymentId == null) {
          return _payNowButton(bookingResponse);
        } else if (!detail.isFreeService && !isSentInvoiceOnEmail) {
          return _requestInvoiceButton(bookingResponse);
        } else if (!detail.isFreeService && isSentInvoiceOnEmail) {
          return _invoiceSentMessage();
        }
        break;

      default:
        return Offstage();
    }

    return Offstage();
  }

  /// ---------------- REUSABLE BUTTONS ----------------
  Widget _cancelButton(BookingDetailResponse bookingResponse) => AppButton(
        text: language.lblCancelBooking,
        textColor: Colors.white,
        color: cancelled,
        shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () => _handleCancelClick(
          status: bookingResponse,
          isDurationMode: checkTimeDifference(
            inputDateTime:
                DateTime.parse(bookingResponse.bookingDetail!.date.validate()),
          ),
        ),
      );

  Widget _startButton(BookingDetailResponse bookingResponse) => AppButton(
        text: language.lblStart,
        textColor: Colors.white,
        color: primaryColor,
        shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () => _handleStartClick(status: bookingResponse),
      );

  Widget _holdAndDoneButtons(BookingDetailResponse bookingResponse) => Row(
        children: [
          if (!(bookingResponse.service?.isOnlineService ?? true))
            AppButton(
              text: language.lblHold,
              textColor: Colors.white,
              color: hold,
              shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () => _handleHoldClick(status: bookingResponse),
            ).expand(),
          if (!(bookingResponse.service?.isOnlineService ?? true)) 12.width,
          AppButton(
            text: language.done,
            textColor: Colors.white,
            color: primaryColor,
            shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onTap: () => _handleDoneClick(status: bookingResponse),
          ).expand(),
        ],
      );

  Widget _resumeAndCancelButtons(BookingDetailResponse bookingResponse) => Row(
        children: [
          AppButton(
            text: language.lblResume,
            textColor: Colors.white,
            color: primaryColor,
            shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onTap: () => _handleResumeClick(status: bookingResponse),
          ).expand(),
          12.width,
          AppButton(
            text: language.lblCancel,
            textColor: Colors.white,
            color: cancelled,
            shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onTap: () => _handleCancelClick(
              status: bookingResponse,
              isDurationMode: checkTimeDifference(
                inputDateTime: DateTime.parse(
                    bookingResponse.bookingDetail!.date.validate()),
              ),
            ),
          ).expand(),
        ],
      );

  Widget _waitingResponseMessage() => Container(
        width: context.width(),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: pendingApprovalColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time_rounded,
                color: pendingApprovalColor, size: 20),
            8.width,
            Text(language.lblWaitingForResponse,
                style: boldTextStyle(color: pendingApprovalColor)),
          ],
        ),
      );

  Widget _payNowOrAdvanceButton(
          BookingDetailResponse bookingResponse, BookingData detail) =>
      AppButton(
        text: detail.paymentStatus == SERVICE_PAYMENT_STATUS_ADVANCE_PAID &&
                detail.status == BookingStatusKeys.complete
            ? language.lblPayNow
            : language.payAdvance,
        textColor: Colors.white,
        color: completed,
        shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () =>
            PaymentScreen(bookings: bookingResponse, isForAdvancePayment: true)
                .launch(context),
      );

  Widget _payNowButton(BookingDetailResponse bookingResponse) => AppButton(
        text: language.lblPayNow,
        textColor: Colors.white,
        color: completed,
        shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () =>
            PaymentScreen(bookings: bookingResponse, isForAdvancePayment: false)
                .launch(context),
      );

  Widget _requestInvoiceButton(BookingDetailResponse bookingResponse) =>
      AppButton(
        text: language.requestInvoice,
        textColor: Colors.white,
        color: context.primaryColor,
        shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () async {
          bool? res = await showInDialog(
            context,
            contentPadding: EdgeInsets.zero,
            dialogAnimation: DialogAnimation.SLIDE_TOP_BOTTOM,
            barrierDismissible: false,
            builder: (_) => InvoiceRequestDialogComponent(
              bookingId: bookingResponse.bookingDetail!.id.validate(),
            ),
          );

          if (res ?? false) {
            isSentInvoiceOnEmail = res.validate();
            init();
            setState(() {});
          }
        },
      );

  Widget _invoiceSentMessage() => Container(
        width: context.width(),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: completed.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(language.sentInvoiceText,
                style: boldTextStyle(), textAlign: TextAlign.center)
            .center(),
      );

  Widget buildBodyWidget(AsyncSnapshot<BookingDetailResponse> snap) {
    //ShopModel shops = snap.data?.shop != null ? snap.data!.shop! : ShopModel();
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          children: [
            AnimatedScrollView(
              padding: const EdgeInsets.only(bottom: 60),
              physics: const AlwaysScrollableScrollPhysics(),
              listAnimationType: ListAnimationType.FadeIn,
              children: [
                /// Reason message for cancelled/rejected/failed bookings (red banner)
                _buildReasonWidget(snap: snap.data!),
                //_pendingMessage(snap: snap.data!),
                _completeMessage(snap: snap.data!),
                Row(
                  children: [
                    Text(
                      language.lblBookingID,
                      style: boldTextStyle(color: grey, size: 14),
                    ),
                    const Spacer(),
                    Text(
                      '#' + widget.bookingId.validate().toString(),
                      style: boldTextStyle(color: context.primaryColor),
                    ),
                    16.height,
                  ],
                ).paddingSymmetric(horizontal: 12, vertical: 12),
                Divider(
                  color: lightGray,
                  thickness: 1,
                  height: 2,
                ).paddingSymmetric(horizontal: 12),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      8.height,

                      serviceDetailWidget(
                        bookingDetail: snap.data!.bookingDetail!,
                        serviceDetail: snap.data!.service!,
                      ),

                      if (snap.data!.isBookedAtShop)
                        shopDetailWidget(shop: snap.data!.shop!),

                      /// Service Counter Time Widget
                      counterWidget(value: snap.data!),

                      /// My Service List
                      if (snap.data!.postRequestDetail != null &&
                          snap.data!.postRequestDetail!.service != null)
                        myServiceList(
                            serviceList:
                                snap.data!.postRequestDetail!.service!),

                      /// Package Info if User selected any Package
                      packageWidget(
                          package: snap.data!.bookingDetail!.bookingPackage),

                      /// Location
                      locationTrackWidget(
                        snap.data!.handymanData.validate(),
                        snap.data!,
                      ).visible(BookingStatusKeys.onGoing ==
                              snap.data!.bookingDetail!.status &&
                          !snap.data!.isBookedAtShop),

                      /// Service Proof
                      serviceProofListWidget(
                          list: snap.data!.serviceProof.validate()),

                      /// About Provider Card
                      providerWidget(res: snap.data!),

                      /// About Handyman Card (for Hold status)
                      if (snap.data!.bookingDetail!.status ==
                              BookingStatusKeys.hold &&
                          snap.data!.handymanData.validate().isNotEmpty)
                        handymanWidget(
                          handymanList: snap.data!.handymanData.validate(),
                          res: snap.data!,
                          serviceDetail: snap.data!.service!,
                          bookingDetail: snap.data!.bookingDetail!,
                        ),

                      16.height,

                      /// Booking Description
                      if (snap.data!.bookingDetail!.description
                          .validate()
                          .isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              language.lblBookingDescription,
                              style: boldTextStyle(size: 16),
                            ),
                            8.height,
                            Text(
                              snap.data!.bookingDetail!.description.validate(),
                              style: primaryTextStyle(
                                size: 14,
                              ),
                            ),
                            24.height,
                          ],
                        ),

                      /// Refund Payment Details
                      refundPaymentDetailsWidget(snap: snap.data!),

                      ///Add-ons
                      if (snap.data!.bookingDetail!.serviceaddon
                          .validate()
                          .isNotEmpty)
                        AddonComponent(
                          isFromBookingDetails: true,
                          showDoneBtn: snap.data!.bookingDetail!.status ==
                              BookingStatusKeys.inProgress,
                          serviceAddon:
                              snap.data!.bookingDetail!.serviceaddon.validate(),
                          onDoneClick: (p0) {
                            showConfirmDialogCustom(
                              context,
                              onAccept: (_) {
                                _handleAddonDoneClick(
                                    status: snap.data!, serviceAddon: p0);
                              },
                              primaryColor: context.primaryColor,
                              positiveText: language.lblYes,
                              negativeText: language.lblNo,
                              title: language.confirmationRequestTxt,
                            );
                          },
                        ),

                      /// Payment Details (Price breakdown)
                      PriceCommonWidget(
                        bookingDetail: snap.data!.bookingDetail!,
                        serviceDetail: snap.data!.service!,
                        taxes: snap.data!.bookingDetail!.taxes.validate(),
                        couponData: snap.data!.couponData,
                        bookingPackage:
                            snap.data!.bookingDetail!.bookingPackage != null
                                ? snap.data!.bookingDetail!.bookingPackage
                                : null,
                      ),

                      /// Extra charges
                      extraChargesWidget(
                          extraChargesList: snap
                              .data!.bookingDetail!.extraCharges
                              .validate()),

                      /// "You Haven't Rated Yet" section with Rate Now button
                      _completeMessage(snap: snap.data!),

                      /// Customer Review widget
                      customerReviewWidget(
                          ratingList: snap.data!.ratingData.validate(),
                          customerReview: snap.data!.customerReview,
                          bookingDetail: snap.data!.bookingDetail!),
                    ],
                  ),
                ),
              ],
            ).expand(),
            // Bottom action buttons with styled container
            _buildBottomActionContainer(snap.data!),
          ],
        ),
      ],
    );
  }

  /// Builds a styled container for the bottom action buttons
  Widget _buildBottomActionContainer(BookingDetailResponse bookingResponse) {
    Widget actionWidget = _action(bookingResponse: bookingResponse);

    // Don't show container if no actions
    if (actionWidget is Offstage) {
      return const SizedBox.shrink();
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: actionWidget,
    );
  }

  //endregion

  //region Methods
  void commonStartTimer(
      {required bool isHourlyService,
      required String status,
      required int timeInSec}) {
    if (isHourlyService) {
      Map<String, dynamic> liveStreamRequest = {
        "inSeconds": timeInSec,
        "status": status,
      };
      LiveStream().emit(LIVESTREAM_START_TIMER, liveStreamRequest);
    }
  }

  void _handleAddonDoneClick(
      {required BookingDetailResponse status,
      required Serviceaddon serviceAddon}) async {
    Map request = {
      CommonKeys.id: status.bookingDetail!.id.validate(),
      BookingUpdateKeys.serviceAddon: [serviceAddon.id],
      BookingUpdateKeys.type: BookingUpdateKeys.serviceAddon,
    };

    appStore.setLoading(true);
    await updateBooking(request).then((res) async {
      toast(res.message!);
      appStore.setLoading(false);
      init();
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  void _handleDoneClick({required BookingDetailResponse status}) {
    bool isAnyServiceAddonUnCompleted = status.bookingDetail!.serviceaddon
        .validate()
        .any((element) => element.status.getBoolInt() == false);
    showConfirmDialogCustom(
      context,
      negativeText: language.lblNo,
      dialogType: DialogType.CONFIRMATION,
      primaryColor: context.primaryColor,
      title: isAnyServiceAddonUnCompleted
          ? language.confirmation
          : language.lblEndServicesMsg,
      subTitle: isAnyServiceAddonUnCompleted
          ? language.pleaseNoteThatAllServiceMarkedCompleted
          : null,
      positiveText: language.lblYes,
      onAccept: (c) async {
        String endDateTime =
            DateFormat(BOOKING_SAVE_FORMAT).format(DateTime.now());

        log('STATUS.BOOKINGDETAIL!.STARTAT: ${status.bookingDetail!.startAt}');
        num durationDiff = DateTime.parse(endDateTime.validate())
            .difference(
                DateTime.parse(status.bookingDetail!.startAt.validate()))
            .inSeconds;

        Map request = {
          CommonKeys.id: status.bookingDetail!.id.validate(),
          BookingUpdateKeys.startAt: status.bookingDetail!.startAt.validate(),
          BookingUpdateKeys.endAt: endDateTime,
          BookingUpdateKeys.durationDiff: durationDiff,
          BookingUpdateKeys.reason: DONE,
          CommonKeys.status: BookingStatusKeys.pendingApproval,
          BookingUpdateKeys.paymentStatus:
              status.bookingDetail!.isAdvancePaymentDone
                  ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                  : status.bookingDetail!.paymentStatus.validate(),
        };

        //TODO Complete all service addon on booking
        if (status.bookingDetail!.serviceaddon.validate().isNotEmpty) {
          request.putIfAbsent(
              BookingUpdateKeys.serviceAddon,
              () => status.bookingDetail!.serviceaddon
                  .validate()
                  .map((e) => e.id)
                  .toList());
        }

        /// Perform new calculations if service hourly
        if (status.bookingDetail!.isHourlyService) {
          BookingAmountModel bookingAmountModel = finalCalculations(
            servicePrice: status.bookingDetail!.amount.validate(),
            appliedCouponData: status.couponData,
            discount: status.service!.discount.validate(),
            serviceAddons: serviceAddonStore.selectedServiceAddon,
            taxes: status.bookingDetail!.taxes,
            quantity: status.bookingDetail!.quantity.validate(),
            selectedPackage: status.bookingDetail!.bookingPackage,
            extraCharges: status.bookingDetail!.extraCharges,
            serviceType: status.service!.type!,
            bookingType: status.bookingDetail!.bookingType!,
            durationDiff: durationDiff.toInt(),
          );

          request.addAll(bookingAmountModel.toBookingUpdateJson());
        }

        appStore.setLoading(true);

        log('RES: ${jsonEncode(request)}');
        await updateBooking(request).then((res) async {
          toast(res.message!);
          commonStartTimer(
              isHourlyService: status.bookingDetail!.isHourlyService,
              status: BookingStatusKeys.complete,
              timeInSec: status.bookingDetail!.durationDiff.validate().toInt());

          appStore.setLoading(false);
          init();
          setState(() {});
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString(), print: true);
        });
      },
    );
  }

  void startClick({required BookingDetailResponse status}) async {
    Map request = {
      CommonKeys.id: status.bookingDetail!.id.validate(),
      BookingUpdateKeys.startAt: formatBookingDate(DateTime.now().toString(),
          format: BOOKING_SAVE_FORMAT, isLanguageNeeded: false),
      BookingUpdateKeys.endAt: status.bookingDetail!.endAt.validate(),
      BookingUpdateKeys.durationDiff: 0,
      BookingUpdateKeys.reason: "",
      CommonKeys.status: BookingStatusKeys.inProgress,
      BookingUpdateKeys.paymentStatus:
          status.bookingDetail!.isAdvancePaymentDone
              ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
              : status.bookingDetail!.paymentStatus.validate(),
    };

    appStore.setLoading(true);

    await updateBooking(request).then((res) async {
      toast(res.message!);
      stopLocationUpdates();
      commonStartTimer(
          isHourlyService: status.bookingDetail!.isHourlyService,
          status: BookingStatusKeys.inProgress,
          timeInSec: status.bookingDetail!.durationDiff.validate().toInt());

      init();
      setState(() {});
    }).catchError((e) {
      toast(e.toString(), print: true);
    });

    appStore.setLoading(false);
  }

  void _handleStartClick({required BookingDetailResponse status}) {
    showConfirmDialogCustom(
      context,
      title: language.confirmationRequestTxt,
      dialogType: DialogType.CONFIRMATION,
      primaryColor: context.primaryColor,
      negativeText: language.lblNo,
      positiveText: language.lblYes,
      onAccept: (c) {
        startClick(status: status);
      },
    );
  }

  void _handleResumeClick({required BookingDetailResponse status}) {
    showConfirmDialogCustom(
      context,
      dialogType: DialogType.CONFIRMATION,
      primaryColor: context.primaryColor,
      negativeText: language.lblNo,
      positiveText: language.lblYes,
      title: language.lblConFirmResumeService,
      onAccept: (c) async {
        Map request = {
          CommonKeys.id: status.bookingDetail!.id.validate(),
          BookingUpdateKeys.startAt: formatBookingDate(
              DateTime.now().toString(),
              format: BOOKING_SAVE_FORMAT,
              isLanguageNeeded: false),
          // BookingUpdateKeys.endAt: status.bookingDetail!.endAt.validate(),
          // BookingUpdateKeys.durationDiff: status.bookingDetail!.durationDiff.toInt(),
          BookingUpdateKeys.reason: "",
          CommonKeys.status: BookingStatusKeys.inProgress,
          BookingUpdateKeys.paymentStatus:
              status.bookingDetail!.isAdvancePaymentDone
                  ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                  : status.bookingDetail!.paymentStatus.validate(),
        };

        appStore.setLoading(true);

        await updateBooking(request).then((res) async {
          toast(res.message!);
          commonStartTimer(
              isHourlyService: status.bookingDetail!.isHourlyService,
              status: BookingStatusKeys.inProgress,
              timeInSec: status.bookingDetail!.durationDiff.validate().toInt());
          init();
          setState(() {});
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString(), print: true);
        });
      },
    );
  }

  void _handleHoldClick({required BookingDetailResponse status}) {
    if (status.bookingDetail!.status == BookingStatusKeys.inProgress) {
      showInDialog(
        context,
        contentPadding: EdgeInsets.zero,
        backgroundColor: context.scaffoldBackgroundColor,
        builder: (context) {
          return AppCommonDialog(
            title: language.lblConfirmService,
            child: ReasonDialog(
                status: status, currentStatus: BookingStatusKeys.hold),
          );
        },
      ).then((value) async {
        if (value != null) {
          init();
          setState(() {});
        }
      });
    }
  }

  void _handleCancelClick(
      {required BookingDetailResponse status, required bool isDurationMode}) {
    if (status.bookingDetail!.status == BookingStatusKeys.pending ||
        status.bookingDetail!.status == BookingStatusKeys.accept ||
        status.bookingDetail!.status == BookingStatusKeys.hold) {
      showInDialog(
        context,
        contentPadding: EdgeInsets.zero,
        insetPadding: isDurationMode &&
                !status.service!.isFreeService &&
                appConfigurationStore.cancellationCharge
            ? const EdgeInsets.symmetric(horizontal: 10)
            : null,
        builder: (context) {
          if (isDurationMode &&
              !status.service!.isFreeService &&
              appConfigurationStore.cancellationCharge &&
              status.bookingDetail!.isAdvancePaymentDone) {
            return CancellationsBookingChargeDialog(
                status: status, isDurationMode: isDurationMode);
          } else {
            return AppCommonDialog(
              title: language.lblCancelReason,
              child: ReasonDialog(status: status),
            );
          }
        },
      ).then((value) {
        if (value != null) {
          init();
          setState(() {});
        }
      });
    }
  }

  void refreshProviderLocation() async {
    isLocationLoader = true;
    setState(() {});
    getProviderLocation(widget.bookingId).then((value) {
      providerLocation = value;
      _currentPosition = LatLng(
        double.parse(providerLocation?.data.latitude.toString() ?? "0.0"),
        double.parse(providerLocation?.data.longitude.toString() ?? "0.0"),
      );
      _initialLocation = _currentPosition!;
      mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition!,
          zoom: 15.0,
        ),
      ));
      setState(() {});
    }).catchError((error) {
      log(error.toString());
    }).whenComplete(() {
      isLocationLoader = false;
      setState(() {});
    });
  }

  void startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(
      Duration(seconds: providerLocationRefreshPeriodInSeconds),
      (Timer timer) async {
        if (bookingStatus == BookingStatusKeys.onGoing) {
          refreshProviderLocation();
        }
      },
    );
  }

  void stopLocationUpdates() {
    _locationUpdateTimer?.cancel();
  }

  Future<void> createCustomIcon() async {
    const ImageConfiguration imageConfiguration =
        ImageConfiguration(size: Size(24, 24));
    customIcon = await BitmapDescriptor.asset(
      imageConfiguration,
      indicator_2,
    );
  }

  void shareComponent() {
    String url;
    url =
        'https://www.google.com/maps/search/?api=1&query=${providerLocation?.data.latitude},${providerLocation?.data.longitude}';
    share(url: url, context: context);
  }

  //endregion

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      stopLocationUpdates();
    } else if (state == AppLifecycleState.resumed &&
        bookingStatus == BookingStatusKeys.onGoing) {
      refreshProviderLocation();
      startLocationUpdates();
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    stopLocationUpdates();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<BookingDetailResponse>(
          future: future,
          initialData: cachedBookingDetailList
              .firstWhere(
                  (element) => element?.$1 == widget.bookingId.validate(),
                  orElse: () => null)
              ?.$2,
          builder: (context, snap) {
            if (snap.hasData) {
              return RefreshIndicator(
                onRefresh: () async {
                  init();
                  setState(() {});

                  return await 2.seconds.delay;
                },
                child: AppScaffold(
                  actions: [
                    TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          isScrollControlled: true,
                          isDismissible: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (_) {
                            return DraggableScrollableSheet(
                              initialChildSize: 0.50,
                              minChildSize: 0.2,
                              maxChildSize: 1,
                              builder: (context, scrollController) {
                                return BookingHistoryComponent(
                                  data: snap.data!.bookingActivity!.reversed
                                      .toList(),
                                  scrollController: scrollController,
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Text(
                        language.lblCheckStatus,
                        style: boldTextStyle(color: white, size: 14),
                      ),
                    ),
                  ],
                  appBarTitle: snap.hasData
                      ? snap.data!.bookingDetail!.status
                          .validate()
                          .toBookingStatus()
                      : "",
                  child: SafeArea(child: buildBodyWidget(snap)),
                ),
              );
            }

            return Scaffold(
              body: snapWidgetHelper(
                snap,
                errorBuilder: (error) {
                  log("$error");
                  return NoDataWidget(
                    title: error,
                    imageWidget: const ErrorStateWidget(),
                    retryText: language.reload,
                    onRetry: () {
                      init();
                      setState(() {});
                    },
                  );
                },
                loadingWidget: BookingDetailShimmer(),
              ),
            );
          },
        ),
      ],
    );
  }
}
