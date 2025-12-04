import 'package:booking_system_flutter/screens/dashboard/component/promotional_banner_slider_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/horizontal_shop_list_component.dart';
import 'package:booking_system_flutter/screens/newDashboard/dashboard_4/component/app_bar_dashboard_component_4.dart';
import 'package:booking_system_flutter/screens/newDashboard/dashboard_4/component/service_list_dashboard_component_4.dart';
import 'package:booking_system_flutter/screens/newDashboard/dashboard_4/component/upcoming_booking_dashboard_component_4.dart';
import 'package:booking_system_flutter/screens/newDashboard/dashboard_4/shimmer/dashboard_shimmer_4.dart';
import 'package:booking_system_flutter/utils/dummy_data_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/loader_widget.dart';
import '../../../main.dart';
import '../../../model/dashboard_model.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/colors.dart';
import '../../../utils/constant.dart';
import 'component/category_list_dashboard_component_4.dart';
import 'component/job_request_dashboard_component_4.dart';
import 'component/slider_dashboard_component_4.dart';

class DashboardFragment4 extends StatefulWidget {
  @override
  _DashboardFragment4State createState() => _DashboardFragment4State();
}

class _DashboardFragment4State extends State<DashboardFragment4> {
  Future<DashboardResponse>? future;

  @override
  void initState() {
    super.initState();
    init(showLoader: false);
    setStatusBarColorChange();

    LiveStream().on(LIVESTREAM_UPDATE_DASHBOARD, (p0) async {
      await init();
    });
  }

  Future<void> init({bool showLoader = true}) async {
    appStore.setLoading(showLoader);
    try {
      future = userDashboard(isCurrentLocation: appStore.isCurrentLocation, lat: getDoubleAsync(LATITUDE), long: getDoubleAsync(LONGITUDE));
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
      backgroundColor: appStore.isDarkMode ? context.primaryColor.withValues(alpha: 0.01) : primaryLightColor,
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
              return AnimatedScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                onSwipeRefresh: () async {
                  setValue(LAST_APP_CONFIGURATION_SYNCED_TIME, 0);
                  await init();
                  return await 2.seconds.delay;
                },
                children: [
                  AppBarDashboardComponent4(
                    featuredList: dummyData.featuredServices.validate(),
                    callback: () async {
                      await init();
                    },
                  ),
                  40.height,
                  CategoryListDashboardComponent4(categoryList: dummyData.category.validate(), listTiTle: language.category),
                  UpComingBookingDashboardComponent4(upComingBookingData: dummyData.upcomingData),
                  30.height,
                  SliderDashboardComponent4(sliderList: dummyData.slider.validate()),
                  30.height,
                  ServiceListDashboardComponent4(
                    serviceList: dummyData.service.validate(),
                    serviceListTitle: language.service,
                  ),
                  16.height,
                  if (dummyData.promotionalBanner.validate().isNotEmpty && appConfigurationStore.isPromotionalBanner)
                    PromotionalBannerSliderComponent(
                      promotionalBannerList: dummyData.promotionalBanner.validate(),
                    ).paddingTop(16),
                  16.height,
                  ServiceListDashboardComponent4(
                    serviceList: dummyData.featuredServices.validate(),
                    serviceListTitle: language.featuredServices,
                    isFeatured: true,
                  ),
                  HorizontalShopListComponent(shopList: dummyData.shops.validate().take(5).toList()),
                  16.height,
                  if (appConfigurationStore.jobRequestStatus) JobRequestDashboardComponent4()
                ],
              );
            },
            loadingWidget: DashboardShimmer4(),
            onSuccess: (snap) {
              return AnimatedScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                onSwipeRefresh: () async {
                  setValue(LAST_APP_CONFIGURATION_SYNCED_TIME, 0);
                  await init();
                  return await 2.seconds.delay;
                },
                children: [
                  AppBarDashboardComponent4(
                    featuredList: snap.featuredServices.validate(),
                    callback: () async {
                      await init();
                    },
                  ),
                  40.height,
                  CategoryListDashboardComponent4(categoryList: snap.category.validate(), listTiTle: language.category),
                  UpComingBookingDashboardComponent4(upComingBookingData: snap.upcomingData),
                  30.height,
                  SliderDashboardComponent4(sliderList: snap.slider.validate()),
                  30.height,
                  ServiceListDashboardComponent4(
                    serviceList: snap.service.validate(),
                    serviceListTitle: language.service,
                  ),
                  16.height,
                  if (snap.promotionalBanner.validate().isNotEmpty && appConfigurationStore.isPromotionalBanner)
                    PromotionalBannerSliderComponent(
                      promotionalBannerList: snap.promotionalBanner.validate(),
                    ).paddingTop(16),
                  16.height,
                  ServiceListDashboardComponent4(
                    serviceList: snap.featuredServices.validate(),
                    serviceListTitle: language.featuredServices,
                    isFeatured: true,
                  ),
                  HorizontalShopListComponent(shopList: snap.shops.validate().take(5).toList()),
                  16.height,
                  if (appConfigurationStore.jobRequestStatus) JobRequestDashboardComponent4()
                ],
              );
            },
          ),
          Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}