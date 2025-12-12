import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/booking_data_model.dart';
import 'package:booking_system_flutter/model/service_detail_response.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/booking/booking_detail_screen.dart';
import 'package:booking_system_flutter/screens/booking/component/booking_item_component.dart';
import 'package:booking_system_flutter/screens/booking/component/booking_status_filter_bottom_sheet_new.dart';
import 'package:booking_system_flutter/screens/booking/shimmer/booking_shimmer.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/empty_error_state_widget.dart';
import '../../../store/filter_store.dart';

class BookingFragment extends StatefulWidget {
  @override
  _BookingFragmentState createState() => _BookingFragmentState();
}

class _BookingFragmentState extends State<BookingFragment> {
  // TODO: Set to false when backend is ready
  static const bool _useDummyData = true;

  UniqueKey keyForList = UniqueKey();

  ScrollController scrollController = ScrollController();

  Future<List<BookingData>>? future;
  List<BookingData> bookings = [];
  List<BookingData> allBookings = []; // Store all bookings for local filtering

  int page = 1;
  bool isLastPage = false;

  String selectedValue = BOOKING_TYPE_ALL;

  // Local filter state for the new bottom sheet
  List<String> selectedStatusFilters = [];

  @override
  void initState() {
    super.initState();
    init(showLoader: false);
    filterStore = FilterStore();

    afterBuildCreated(() {
      if (appStore.isLoggedIn) {
        setStatusBarColor(context.primaryColor);
      }
    });

    LiveStream().on(LIVESTREAM_UPDATE_BOOKING_LIST, (p0) {
      setState(() {
        page = 1;
      });
      init();
    });
    cachedBookingStatusDropdown.validate().forEach((element) {
      element.isSelected = false;
    });
  }

  void init({String status = '', bool showLoader = true}) async {
    appStore.setLoading(showLoader);

    // Use dummy data for UI testing
    if (_useDummyData) {
      allBookings = await _getDummyBookings();
      future = _getFilteredBookings();
      isLastPage = true;
      setState(() {});
    } else {
      future = getBookingList(
        page,
        shopId: filterStore.shopIds.join(","),
        serviceId: filterStore.serviceId.join(","),
        dateFrom: filterStore.startDate,
        dateTo: filterStore.endDate,
        providerId: filterStore.providerId.join(","),
        handymanId: filterStore.handymanId.join(","),
        bookingStatus: filterStore.bookingStatus.join(","),
        paymentStatus: filterStore.paymentStatus.join(","),
        paymentType: filterStore.paymentType.join(","),
        bookings: bookings,
        lastPageCallback: (b) {
          isLastPage = b;
        },
      ).whenComplete(
        () => appStore.setLoading(false),
      );
    }
  }

  // Get filtered bookings based on selected status filters
  Future<List<BookingData>> _getFilteredBookings() async {
    appStore.setLoading(false);

    if (selectedStatusFilters.isEmpty) {
      return allBookings;
    }

    return allBookings.where((booking) {
      return selectedStatusFilters.contains(booking.status);
    }).toList();
  }

  // Show the new filter bottom sheet
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingStatusFilterBottomSheetNew(
        selectedStatuses: selectedStatusFilters,
        onApply: (selectedStatuses) {
          setState(() {
            selectedStatusFilters = selectedStatuses;

            // Update filterStore for consistency with existing logic
            filterStore.bookingStatus.clear();
            for (var status in selectedStatuses) {
              filterStore.addToBookingStatusList(bookingStatusList: status);
            }

            // Refresh the list with new filters
            if (_useDummyData) {
              future = _getFilteredBookings();
              keyForList = UniqueKey();
            } else {
              page = 1;
              init();
            }
          });

          // Scroll to top if there are results
          // Use a post-frame callback to ensure the list is built before scrolling
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && scrollController.hasClients) {
              scrollController.animateTo(
                0,
                duration: 300.milliseconds,
                curve: Curves.easeOutQuart,
              );
            }
          });
        },
      ),
    );
  }

  // Generate dummy bookings for UI testing
  Future<List<BookingData>> _getDummyBookings() async {
    // Simulate API delay
    await Future.delayed(Duration(milliseconds: 300));
    appStore.setLoading(false);

    final now = DateTime.now();

    return [
      // Pending Booking
      BookingData(
        id: 12345,
        serviceName: "Home Deep Cleaning",
        serviceId: 101,
        customerId: appStore.userId,
        customerName: appStore.userFullName,
        providerId: 1,
        providerName: "CleanPro Services",
        providerImage: "",
        status: BookingStatusKeys.pending,
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
        customerId: appStore.userId,
        customerName: appStore.userFullName,
        providerId: 2,
        providerName: "CoolTech Solutions",
        providerImage: "",
        status: BookingStatusKeys.accept,
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
        customerId: appStore.userId,
        customerName: appStore.userFullName,
        providerId: 3,
        providerName: "QuickFix Plumbers",
        providerImage: "",
        status: BookingStatusKeys.inProgress,
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
        customerId: appStore.userId,
        customerName: appStore.userFullName,
        providerId: 4,
        providerName: "PowerUp Electricians",
        providerImage: "",
        status: BookingStatusKeys.complete,
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
        customerId: appStore.userId,
        customerName: appStore.userFullName,
        providerId: 5,
        providerName: "SpotlessClean",
        providerImage: "",
        status: BookingStatusKeys.cancelled,
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
      // On Going (Provider on the way)
      BookingData(
        id: 12350,
        serviceName: "Furniture Assembly",
        serviceId: 106,
        customerId: appStore.userId,
        customerName: appStore.userFullName,
        providerId: 6,
        providerName: "HandyMan Pro",
        providerImage: "",
        status: BookingStatusKeys.onGoing,
        statusLabel: "On Going",
        date: now.toString(),
        bookingSlot: "16:00:00",
        address: "987 Oak Street, Westend",
        description: "IKEA wardrobe assembly",
        type: SERVICE_TYPE_FIXED,
        amount: 600,
        totalAmount: 660,
        discount: 0,
        quantity: 1,
        serviceAttachments: [
          "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400"
        ],
        handyman: [],
      ),
      // Hold Booking
      BookingData(
        id: 12351,
        serviceName: "Painting Service",
        serviceId: 107,
        customerId: appStore.userId,
        customerName: appStore.userFullName,
        providerId: 7,
        providerName: "ColorMaster Painters",
        providerImage: "",
        status: BookingStatusKeys.hold,
        statusLabel: "On Hold",
        date: now.subtract(Duration(days: 1)).toString(),
        bookingSlot: "08:00:00",
        address: "159 Maple Drive, Northside",
        description: "Living room wall painting",
        type: SERVICE_TYPE_HOURLY,
        amount: 400,
        totalAmount: 440,
        discount: 0,
        quantity: 1,
        durationDiff: "7200",
        startAt: now.subtract(Duration(hours: 3)).toString(),
        reason: "Waiting for additional paint colors",
        serviceAttachments: [
          "https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=400"
        ],
        handyman: [],
      ),
      // Rejected Booking
      BookingData(
        id: 12352,
        serviceName: "Garden Maintenance",
        serviceId: 108,
        customerId: appStore.userId,
        customerName: appStore.userFullName,
        providerId: 8,
        providerName: "GreenThumb Gardens",
        providerImage: "",
        status: BookingStatusKeys.rejected,
        statusLabel: "Rejected",
        date: now.subtract(Duration(days: 2)).toString(),
        bookingSlot: "07:00:00",
        address: "753 Elm Street, Greenside",
        description: "Lawn mowing and hedge trimming",
        type: SERVICE_TYPE_FIXED,
        amount: 350,
        totalAmount: 350,
        discount: 0,
        quantity: 1,
        reason: "Provider unavailable in the area",
        serviceAttachments: [
          "https://images.unsplash.com/photo-1558904541-efa843a96f01?w=400"
        ],
        handyman: [],
      ),
      // Failed Booking
      BookingData(
        id: 12353,
        serviceName: "Window Cleaning",
        serviceId: 109,
        customerId: appStore.userId,
        customerName: appStore.userFullName,
        providerId: 9,
        providerName: "CrystalClear Windows",
        providerImage: "",
        status: BookingStatusKeys.failed,
        statusLabel: "Failed",
        date: now.subtract(Duration(days: 4)).toString(),
        bookingSlot: "13:00:00",
        address: "246 Pine Road, Hillview",
        description: "External window cleaning for 2-story house",
        type: SERVICE_TYPE_FIXED,
        amount: 450,
        totalAmount: 450,
        discount: 0,
        quantity: 1,
        reason: "Payment processing failed",
        serviceAttachments: [
          "https://images.unsplash.com/photo-1527515545081-5db817172677?w=400"
        ],
        handyman: [],
      ),
      // Pending Approval Booking
      BookingData(
        id: 12354,
        serviceName: "CCTV Installation",
        serviceId: 110,
        customerId: appStore.userId,
        customerName: appStore.userFullName,
        providerId: 10,
        providerName: "SecureHome Tech",
        providerImage: "",
        status: BookingStatusKeys.pendingApproval,
        statusLabel: "Pending Approval",
        date: now.add(Duration(days: 3)).toString(),
        bookingSlot: "11:00:00",
        address: "864 Cedar Lane, Safetown",
        description: "4-camera CCTV system installation",
        type: SERVICE_TYPE_FIXED,
        amount: 2500,
        totalAmount: 2750,
        discount: 0,
        quantity: 1,
        serviceAttachments: [
          "https://images.unsplash.com/photo-1557862921-37829c790f19?w=400"
        ],
        handyman: [],
      ),
      // Waiting for Advance Payment
      BookingData(
        id: 12355,
        serviceName: "Full Home Renovation",
        serviceId: 111,
        customerId: appStore.userId,
        customerName: appStore.userFullName,
        providerId: 11,
        providerName: "DreamHome Renovations",
        providerImage: "",
        status: BookingStatusKeys.waitingAdvancedPayment,
        statusLabel: "Waiting",
        date: now.add(Duration(days: 7)).toString(),
        bookingSlot: "09:00:00",
        address: "135 Birch Boulevard, Newtown",
        description: "Complete kitchen and bathroom renovation",
        type: SERVICE_TYPE_FIXED,
        amount: 15000,
        totalAmount: 16500,
        discount: 0,
        quantity: 1,
        couponData: CouponData(
          id: 2,
          code: "QW3D4RTY",
          discount: 1500,
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
            totalCalculatedValue: 1500.0,
          ),
        ],
        serviceAttachments: [
          "https://images.unsplash.com/photo-1484154218962-a197022b5858?w=400"
        ],
        handyman: [],
      ),
    ];
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    filterStore.clearFilters();
    LiveStream().dispose(LIVESTREAM_UPDATE_BOOKING_LIST);
    scrollController.dispose(); // Properly dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        center: true,
        language.booking,
        textColor: white,
        showBack: false,
        textSize: APP_BAR_TEXT_SIZE,
        elevation: 3.0,
        color: context.primaryColor,
        actions: [
          // Use local filter count for the badge (no Observer needed - using local state)
          Builder(
            builder: (context) {
              int filterCount = selectedStatusFilters.length;
              return Stack(
                children: [
                  IconButton(
                    icon: ic_filter.iconImage(color: white, size: 20),
                    onPressed: _showFilterBottomSheet,
                  ),
                  if (filterCount > 0)
                    Positioned(
                      right: 7,
                      top: 7,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: boxDecorationDefault(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: FittedBox(
                          child: Text(
                            '$filterCount',
                            style: const TextStyle(
                              color: white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SizedBox(
        width: context.width(),
        height: context.height(),
        child: Stack(
          children: [
            SnapHelperWidget<List<BookingData>>(
              initialData: _useDummyData ? null : cachedBookingList,
              future: future,
              errorBuilder: (error) {
                return NoDataWidget(
                  title: error,
                  imageWidget: const ErrorStateWidget(),
                  retryText: language.reload,
                  onRetry: () {
                    init();
                  },
                );
              },
              loadingWidget: const BookingShimmer(),
              onSuccess: (list) {
                return AnimatedListView(
                  key: keyForList,
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                      bottom: 60, top: 16, right: 16, left: 16),
                  itemCount: list.length,
                  shrinkWrap: true,
                  disposeScrollController: false, // Don't auto-dispose, we'll manage it manually
                  listAnimationType: ListAnimationType.FadeIn,
                  fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                  slideConfiguration: SlideConfiguration(verticalOffset: 400),
                  emptyWidget: NoDataWidget(
                    title: language.lblNoBookingsFound,
                    subTitle: language.noBookingSubTitle,
                    imageWidget: const EmptyStateWidget(),
                  ),
                  itemBuilder: (_, index) {
                    BookingData? data = list[index];

                    return GestureDetector(
                      onTap: () {
                        BookingDetailScreen(
                          bookingId: data.id.validate(),
                          bookingData: data, // Pass the booking data to detail screen
                        ).launch(context);
                      },
                      child: BookingItemComponent(bookingData: data),
                    );
                  },
                  onNextPage: () {
                    if (!isLastPage) {
                      setState(() {
                        page++;
                      });
                      init(status: selectedValue);
                    }
                  },
                  onSwipeRefresh: () async {
                    setState(() {
                      page = 1;
                    });

                    init(status: selectedValue);

                    return await 1.seconds.delay;
                  },
                );
              },
            ),
            Observer(
                builder: (_) => LoaderWidget().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
