import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/dashboard_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/dashboard/component/category_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/featured_service_list_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/service_list_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/slider_and_location_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/horizontal_shop_list_component.dart';
import 'package:booking_system_flutter/screens/dashboard/shimmer/dashboard_shimmer.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/dummy_data_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/loader_widget.dart';
import '../component/booking_confirmed_component.dart';
import '../component/new_job_request_component.dart';
import '../component/promotional_banner_slider_component.dart';

class DashboardFragment extends StatefulWidget {
  @override
  _DashboardFragmentState createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends State<DashboardFragment> {
  Future<DashboardResponse>? future;

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

  Future<void> init({bool showLoader = true}) async {
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
                    return AnimatedScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      listAnimationType: ListAnimationType.FadeIn,
                      fadeInConfiguration:
                          FadeInConfiguration(duration: 2.seconds),
                      onSwipeRefresh: () async {
                        setValue(LAST_APP_CONFIGURATION_SYNCED_TIME, 0);
                        await init();
                        return await 2.seconds.delay;
                      },
                      children: [
                        SliderLocationComponent(
                          sliderList: dummyData.slider.validate(),
                          featuredList: dummyData.featuredServices.validate(),
                          callback: () async {
                            await init();
                          },
                        ),
                        30.height,
                        PendingBookingComponent(
                            upcomingConfirmedBooking: dummyData.upcomingData),
                        CategoryComponent(
                            categoryList: dummyData.category.validate()),
                        if (dummyData.promotionalBanner.validate().isNotEmpty &&
                            appConfigurationStore.isPromotionalBanner)
                          PromotionalBannerSliderComponent(
                            promotionalBannerList:
                                dummyData.promotionalBanner.validate(),
                          ).paddingTop(16),
                        16.height,
                        FeaturedServiceListComponent(
                            serviceList: dummyData.featuredServices.validate()),
                        ServiceListComponent(
                            serviceList: dummyData.service.validate()),
                        16.height,
                        HorizontalShopListComponent(
                            shopList:
                                dummyData.shops.validate().take(5).toList()),
                        16.height,
                        if (appConfigurationStore.jobRequestStatus)
                          const NewJobRequestComponent(),
                      ],
                    );
                  },
                  loadingWidget: DashboardShimmer(),
                  onSuccess: (snap) {
                    return AnimatedScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      listAnimationType: ListAnimationType.FadeIn,
                      fadeInConfiguration:
                          FadeInConfiguration(duration: 2.seconds),
                      onSwipeRefresh: () async {
                        setValue(LAST_APP_CONFIGURATION_SYNCED_TIME, 0);
                        await init();

                        return await 2.seconds.delay;
                      },
                      children: [
                        SliderLocationComponent(
                          sliderList: snap.slider.validate(),
                          featuredList: snap.featuredServices.validate(),
                          callback: () async {
                            await init();
                          },
                        ),
                        30.height,
                        PendingBookingComponent(
                            upcomingConfirmedBooking: snap.upcomingData),
                        CategoryComponent(
                            categoryList: snap.category.validate()),
                        if (snap.promotionalBanner.validate().isNotEmpty &&
                            appConfigurationStore.isPromotionalBanner)
                          PromotionalBannerSliderComponent(
                            promotionalBannerList:
                                snap.promotionalBanner.validate(),
                          ).paddingTop(16),
                        16.height,
                        FeaturedServiceListComponent(
                            serviceList: snap.featuredServices.validate()),
                        ServiceListComponent(
                            serviceList: snap.service.validate()),
                        16.height,
                        HorizontalShopListComponent(
                            shopList: snap.shops.validate().take(5).toList()),
                        16.height,
                        if (appConfigurationStore.jobRequestStatus)
                          const NewJobRequestComponent(),
                      ],
                    );
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
}
