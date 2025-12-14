import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/screens/dashboard/component/promotional_banner_slider_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/horizontal_shop_list_component.dart';
import 'package:booking_system_flutter/screens/newDashboard/dashboard_1/shimmer/dashboard_shimmer_1.dart';
import 'package:booking_system_flutter/utils/context_extensions.dart';
import 'package:booking_system_flutter/utils/dummy_data_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/loader_widget.dart';
import '../../../model/dashboard_model.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/colors.dart';
import '../../../utils/constant.dart';
import '../../dashboard/component/category_component.dart';
import 'component/booking_confirmed_component_1.dart';
import 'component/feature_services_dashboard_component_1.dart';
import 'component/job_request_dashboard_component_1.dart';
import 'component/service_list_dashboard_component_1.dart';
import 'component/slider_dashboard_component_1.dart';

class DashboardFragment1 extends StatefulWidget {
  @override
  _DashboardFragment1State createState() => _DashboardFragment1State();
}

class _DashboardFragment1State extends State<DashboardFragment1> {
  Future<DashboardResponse>? future;

  @override
  void initState() {
    super.initState();
    init(showLoader: false);

    setStatusBarColorChange();

    LiveStream().on(LIVESTREAM_UPDATE_DASHBOARD, (p0) {
      init();
    });
  }

  Future<void> init({bool showLoader = true}) async {
    appStore.setLoading(showLoader);
    try {
      future = userDashboard(
          isCurrentLocation: appStore.isCurrentLocation,
          lat: getDoubleAsync(LATITUDE),
          long: getDoubleAsync(LONGITUDE));
    } catch (e) {
      // If API call fails, use dummy data
      log('API call failed, using dummy data: $e');
      future = Future.value(DummyDataHelper.getDummyDashboardData());
      // Cache the dummy data
      cachedDashboardResponse = DummyDataHelper.getDummyDashboardData();
    }
    setStatusBarColorChange();
    setState(() {});
  }

  Future<void> setStatusBarColorChange() async {
    setStatusBarColor(
      statusBarIconBrightness: appStore.isDarkMode
          ? Brightness.light
          : await isNetworkAvailable()
              ? Brightness.light
              : Brightness.dark,
      transparentColor,
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
          SnapHelperWidget<DashboardResponse>(
            initialData: cachedDashboardResponse,
            future: future,
            errorBuilder: (error) {
              // Instead of showing error, use dummy data
              log('Error loading dashboard, using dummy data: $error');
              final dummyData = DummyDataHelper.getDummyDashboardData();
              cachedDashboardResponse = dummyData;
              return Observer(builder: (context) {
                return _buildDashboardContent(dummyData);
              });
            },
            loadingWidget: DashboardShimmer1(),
            onSuccess: (snap) {
              return Observer(builder: (context) {
                return _buildDashboardContent(snap);
              });
            },
          ),
          Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(DashboardResponse snap) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Stack(
        children: [
          // Green background that extends behind the curved content
          Container(
            height: 200,
            width: double.infinity,
            color: context.primary,
          ),
          // Main content column
          Column(
            children: [
              // Header section with green background
              SliderDashboardComponent1(
                sliderList: snap.slider.validate(),
                featuredList: snap.featuredServices.validate(),
                callback: () async {
                  appStore.setLoading(true);
                  init();
                  setState(() {});
                },
              ),
              // White curved container for content
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    20.height,
                    BookingConfirmedComponent1(
                        upcomingConfirmedBooking: snap.upcomingData),
                    16.height,
                    CategoryComponent(
                        categoryList: snap.category.validate(),
                        isNewDashboard: true),
                    if (snap.promotionalBanner.validate().isNotEmpty &&
                        appConfigurationStore.isPromotionalBanner)
                      PromotionalBannerSliderComponent(
                        promotionalBannerList:
                            snap.promotionalBanner.validate(),
                      ).paddingTop(16),
                    16.height,
                    ServiceListDashboardComponent1(
                        serviceList: snap.service.validate()),
                    16.height,
                    FeatureServicesDashboardComponent1(
                        serviceList: snap.featuredServices.validate()),
                    HorizontalShopListComponent(
                        shopList: snap.shops.take(5).toList()),
                    2.height,
                    if (appConfigurationStore.jobRequestStatus)
                      const NewJobRequestDashboardComponent1(),
                    100.height, // Extra padding at bottom for navigation bar
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
