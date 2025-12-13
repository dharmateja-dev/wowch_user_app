import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/dashboard_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/dashboard/component/category_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/featured_service_list_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/service_list_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/dashboard_header_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/booking_confirmation_banner.dart';
import 'package:booking_system_flutter/screens/dashboard/shimmer/dashboard_shimmer.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/dummy_data_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/loader_widget.dart';
import '../component/new_job_request_component.dart';

class DashboardFragment extends StatefulWidget {
  @override
  _DashboardFragmentState createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends State<DashboardFragment> {
  // Flag to use global dummy data for UI design
  static const bool USE_DUMMY_DATA = true;

  Future<DashboardResponse>? future;

  // Flag to show/hide booking confirmation banner
  bool showBookingBanner = true;

  @override
  void initState() {
    super.initState();
    // Load data immediately, show cached data if available
    init(showLoader: cachedDashboardResponse == null);

    setStatusBarColorChange();

    LiveStream().on(LIVESTREAM_UPDATE_DASHBOARD, (p0) async {
      await init();
    });
  }

  /// Initialize dashboard - uses global dummy data if flag is enabled, otherwise uses API
  Future<void> init({bool showLoader = true}) async {
    if (USE_DUMMY_DATA) {
      // Use global dummy data for UI design
      final dummyData = DummyDataHelper.getDummyDashboardData();
      cachedDashboardResponse = dummyData;
      future = Future.value(dummyData);
      appStore.setLoading(false);
    } else {
      // Use actual API call (backend logic remains intact)
      // If cached data exists, show it immediately while fetching fresh data
      if (cachedDashboardResponse != null && !showLoader) {
        // Create a future that completes immediately with cached data
        // but also fetches fresh data in the background
        final cached = cachedDashboardResponse!;
        future = Future.value(cached).then((cachedData) async {
          try {
            // Fetch fresh data in the background
            final freshData = await userDashboard(
              isCurrentLocation: appStore.isCurrentLocation,
              lat: getDoubleAsync(LATITUDE),
              long: getDoubleAsync(LONGITUDE),
            );
            return freshData;
          } catch (e) {
            // If fetch fails, return cached data or dummy data
            log('Failed to fetch fresh dashboard data: $e');
            return cachedData;
          }
        });
      } else {
        appStore.setLoading(showLoader);
        try {
          future = userDashboard(
            isCurrentLocation: appStore.isCurrentLocation,
            lat: getDoubleAsync(LATITUDE),
            long: getDoubleAsync(LONGITUDE),
          );
        } catch (e) {
          // If API call fails, use dummy data
          log('API call failed, using dummy data: $e');
          future = Future.value(DummyDataHelper.getDummyDashboardData());
          // Cache the dummy data
          cachedDashboardResponse = DummyDataHelper.getDummyDashboardData();
        }
      }
    }
    setStatusBarColorChange();
    setState(() {});
  }

  Future<void> setStatusBarColorChange() async {
    setStatusBarColor(
      statusBarIconBrightness:
          Brightness.light, // Light icons for dark green header
      primaryColor, // Match header color
      delayInMilliSeconds: 800,
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(LIVESTREAM_UPDATE_DASHBOARD);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          Observer(
            builder: (context) {
              return AbsorbPointer(
                absorbing: appStore.isLoading,
                child: SnapHelperWidget<DashboardResponse>(
                  initialData: cachedDashboardResponse,
                  future: future,
                  errorBuilder: (error) {
                    // Instead of showing error, use dummy data
                    log('Error loading dashboard, using dummy data: $error');
                    final dummyData = DummyDataHelper.getDummyDashboardData();
                    cachedDashboardResponse = dummyData;
                    return _buildDashboardContent(dummyData);
                  },
                  loadingWidget: DashboardShimmer(),
                  onSuccess: (snap) {
                    return _buildDashboardContent(snap);
                  },
                ),
              );
            },
          ),

          /// 🔒 Loader Overlay and Interaction Block
          Observer(
            builder: (context) {
              return appStore.isLoading
                  ? LoaderWidget().center()
                  : const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(DashboardResponse snap) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Stack(
        children: [
          // Green background behind curved content
          Container(
            height: 240,
            width: double.infinity,
            color: primaryColor,
          ),
          // Main content column
          Column(
            children: [
              // Header with green background
              DashboardHeaderComponent(
                featuredList: snap.featuredServices.validate(),
              ),
              // White curved container for content
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    16.height,
                    // Booking Confirmation Banner - shows above categories
                    if (showBookingBanner)
                      BookingConfirmationBanner(
                        serviceName: 'Filter Replacement',
                        bookingDateTime: DateTime(2024, 6, 4, 11, 0),
                        onClose: () {
                          setState(() {
                            showBookingBanner = false;
                          });
                        },
                        onTap: () {
                          // Navigate to booking details when tapped
                          // You can add navigation logic here
                        },
                      ),
                    CategoryComponent(categoryList: snap.category.validate()),
                    16.height,
                    FeaturedServiceListComponent(
                        serviceList: snap.featuredServices.validate()),
                    ServiceListComponent(serviceList: snap.service.validate()),
                    16.height,
                    const NewJobRequestComponent(),
                    100.height, // Extra padding for bottom nav
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
